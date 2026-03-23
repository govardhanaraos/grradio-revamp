import 'dart:async';
import 'dart:io';
import 'dart:math' show Random;

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:dio/dio.dart';
import 'package:grradio/radio/radiostation.dart';
import 'package:grradio/radio/radio_handler_base.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:grradio/api/analytics_service_api.dart';
import 'package:grradio/main.dart';

class RadioHandlerImpl extends BaseAudioHandler
    with SeekHandler
    implements RadioHandlerBase {
  // 💡 FIX 1: Configure AudioPlayer with aggressive buffering for live streams
  final _player = AudioPlayer(
    audioLoadConfiguration: const AudioLoadConfiguration(
      androidLoadControl: AndroidLoadControl(
        minBufferDuration: Duration(seconds: 15),
        maxBufferDuration: Duration(seconds: 45),
        bufferForPlaybackDuration: Duration(seconds: 5),
        bufferForPlaybackAfterRebufferDuration: Duration(seconds: 10),
      ),
      darwinLoadControl: DarwinLoadControl(
        preferredForwardBufferDuration: Duration(seconds: 30),
      ),
    ),
  );

  RadioStation? _currentStation;
  bool _isLoading = false;
  bool _isRecording = false;
  String? _lastExtractedStreamUrl;
  bool _shuffleEnabled = false;
  LoopMode _loopMode = LoopMode.off;

  // Stream interruption recovery
  Timer? _recoveryTimer;
  int _reconnectAttempts = 0;
  final int _maxReconnectAttempts = 5;
  bool _isRecovering = false;

  // 🔧 FIX 2: Background playback monitoring
  StreamSubscription? _playbackStateSubscription;
  bool _wasPlayingBeforeInterruption = false;
  DateTime? _lastSuccessfulPlayback;

  // Dio components for stream recording
  final Dio _dio = Dio();
  CancelToken? _recordingCancelToken;
  final _analyticsService = AnalyticsServiceAPI();

  Stream<Duration> get positionStream => _player.positionStream;

  List<RadioStation> _radioStations;

  // ── Local file queue ──────────────────────────────────────────────────────
  // Populated by loadLocalQueueAndPlay() whenever the user taps a local file.
  // next/previous on local files navigate within this list, completely
  // independent of the radio station list.
  List<Map<String, String>> _localQueue = []; // [{path, title}, ...]
  int _localQueueIndex = -1;
  bool _handlingLocalCompletion = false;
  Timer? _sleepTimer;
  Timer? _sleepTicker;
  DateTime? _sleepEndsAt;

  RadioHandlerImpl({required List<RadioStation> stations})
    : _radioStations = stations {
    _setupAudioSession();
    _notifyAudioHandlerAboutPlaybackEvents();
    _setupPlayerListeners();
    _setupBackgroundPlaybackMonitoring();
  }

  @override
  Future<void> toggleShuffle() async {
    _shuffleEnabled = !_shuffleEnabled;
    // Queue is managed in Dart (not ConcatenatingAudioSource); shuffle is
    // applied in skipToNext/skipToPrevious when multiple local files exist.
    await _player.setShuffleModeEnabled(false);
    customEvent.add({'event': 'shuffle_changed', 'enabled': _shuffleEnabled});
  }

  @override
  Future<void> cycleRepeatMode() async {
    if (_loopMode == LoopMode.off) {
      _loopMode = LoopMode.one;
    } else if (_loopMode == LoopMode.one) {
      _loopMode = LoopMode.all;
    } else {
      _loopMode = LoopMode.off;
    }

    // Local files: native loop mode breaks "repeat all" on a single track
    // (just_audio often stops after one play). [_handleLocalPlaybackCompleted]
    // owns repeat for _currentStation == null.
    if (_currentStation == null) {
      await _player.setLoopMode(LoopMode.off);
    } else {
      await _player.setLoopMode(_loopMode);
    }

    customEvent.add({'event': 'repeat_changed', 'mode': _loopMode.toString()});
  }

  @override
  Future<void> setSleepTimer(Duration duration) async {
    await cancelSleepTimer();
    if (duration <= Duration.zero) return;
    _sleepEndsAt = DateTime.now().add(duration);
    _sleepTimer = Timer(duration, () async {
      await stop();
      await cancelSleepTimer();
    });
    _sleepTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      _emitSleepTimerUpdate();
    });
    _emitSleepTimerUpdate();
  }

  @override
  Future<void> cancelSleepTimer() async {
    _sleepTimer?.cancel();
    _sleepTicker?.cancel();
    _sleepTimer = null;
    _sleepTicker = null;
    _sleepEndsAt = null;
    _emitSleepTimerUpdate();
  }

  @override
  Duration? getSleepTimerRemaining() {
    final endsAt = _sleepEndsAt;
    if (endsAt == null) return null;
    final remaining = endsAt.difference(DateTime.now());
    if (remaining <= Duration.zero) return Duration.zero;
    return remaining;
  }

  void _emitSleepTimerUpdate() {
    final remaining = getSleepTimerRemaining();
    customEvent.add({
      'event': 'sleep_timer_update',
      'active': remaining != null && remaining > Duration.zero,
      'remaining_seconds': remaining?.inSeconds ?? 0,
    });
  }

  /// Required: [SeekHandler] does not implement this — [BaseAudioHandler.seek] is a no-op.
  @override
  Future<void> seek(Duration position) async {
    await _player.seek(position);
    _updatePlaybackState();
  }

  @override
  void setStations(List<RadioStation> stations) {
    _radioStations = List.from(stations);
    print("📻 RadioHandler updated with ${stations.length} stations");
  }

  void _updateMediaItem(RadioStation station) {
    mediaItem.add(
      MediaItem(
        id: station.id.toString(),
        album: "Live Radio",
        title: station.name,
        artist: station.language ?? "Global",
        artUri: Uri.parse(station.logoUrl ?? ""),
      ),
    );
  }

  @override
  Future<void> playFromMediaId(
    String mediaId, [
    Map<String, dynamic>? extras,
  ]) async {
    // safer: search and handle if not found
    RadioStation? foundStation;
    try {
      foundStation = _radioStations.firstWhere((s) => s.id == mediaId);
    } catch (_) {
      print("❌ No station found for id: $mediaId in RadioHandler list");
      // If not found, it might be because the list is outdated.
      // We'll try to find it in the provided extras if any, or just return.
      return;
    }

    _currentStation = foundStation;
    mediaItem.add(
      MediaItem(
        id: foundStation.id,
        album: "Live Radio",
        title: foundStation.name,
        artist: foundStation.language ?? "Global",
        artUri: Uri.parse(foundStation.logoUrl ?? ""),
      ),
    );
    await _playStation(foundStation);
  }

  // ── Local file playback ───────────────────────────────────────────────────

  /// Called from Mp3PlayerScreen._onFileTap with the full visible list so that
  /// next/previous buttons navigate among the same files the user sees.
  Future<void> loadLocalQueueAndPlay(
    List<Map<String, String>> queue,
    int startIndex,
  ) async {
    _localQueue = List.from(queue);
    _localQueueIndex = startIndex.clamp(0, queue.length - 1);
    await _playLocalEntry(_localQueue[_localQueueIndex]);
  }

  /// Convenience wrapper — keeps single-file call sites working unchanged.
  /// Wraps the file in a one-item queue so _localQueue is always populated.
  Future<void> playDownloadedFile(File file, String title) async {
    await loadLocalQueueAndPlay([
      {'path': file.path, 'title': title},
    ], 0);
  }

  /// Internal: play one local file entry and update all state.
  ///
  /// Uses a single [setAudioSource] call. (Previously this path called
  /// [setFilePath], then [stop], then [setAudioSource] again — decoding the
  /// file twice and adding noticeable delay for local / downloaded / recorded
  /// tracks.)
  ///
  /// Radio is unaffected: [playFromMediaId] / [_playStation] still do their own
  /// [stop] + buffer delay + stream [setAudioSource]. Switching radio → local
  /// replaces the current [AudioPlayer] source the same way switching stations
  /// does; stream recovery and interruption logic all gate on [_currentStation].
  Future<void> _playLocalEntry(Map<String, String> entry) async {
    final path = entry['path']!;
    final title = entry['title']!;

    _analyticsService.logActivity(
      deviceId!,
      'Play Local File',
      details: {
        'title': title,
        'path': path,
      },
    );

    // Cancel any radio recovery — we are now in local-file mode.
    _recoveryTimer?.cancel();
    _recoveryTimer = null;
    _isRecovering = false;
    _currentStation = null; // null = local-file mode for skipToNext/Previous

    // SongModel.data on Android may be content://; downloads/recordings use file paths.
    final Uri playbackUri = path.startsWith('content://')
        ? Uri.parse(path)
        : Uri.file(path);

    final item = MediaItem(
      id: path,
      album: 'Local Files',
      title: title,
      artist: 'Local',
      artUri: null,
    );

    try {
      await _player.setAudioSource(
        AudioSource.uri(playbackUri, tag: item),
      );
      // Always off for local: repeat-one / repeat-all / advance-next are handled
      // in [_handleLocalPlaybackCompleted] when processingState == completed.
      await _player.setLoopMode(LoopMode.off);
      final resolved = _player.duration;
      mediaItem.add(
        resolved != null && resolved > Duration.zero
            ? item.copyWith(duration: resolved)
            : item,
      );
      await _player.play();
    } catch (e) {
      print('Error playing local file: $e');
    }
  }

  /// When a local file finishes, apply repeat / queue advance / reset scrubber.
  Future<void> _handleLocalPlaybackCompleted() async {
    if (_localQueue.isEmpty || _handlingLocalCompletion) return;
    _handlingLocalCompletion = true;
    try {
      switch (_loopMode) {
        case LoopMode.one:
          await _player.seek(Duration.zero);
          await _player.play();
          return;
        case LoopMode.all:
          if (_localQueue.length == 1) {
            // Restart from beginning: seek+play after [completed] is unreliable
            // on some devices; reloading the source matches multi-track wrap.
            await _playLocalEntry(_localQueue[0]);
          } else {
            _localQueueIndex = (_localQueueIndex + 1) % _localQueue.length;
            await _playLocalEntry(_localQueue[_localQueueIndex]);
          }
          return;
        case LoopMode.off:
          if (_localQueue.length > 1 &&
              _localQueueIndex < _localQueue.length - 1) {
            _localQueueIndex++;
            await _playLocalEntry(_localQueue[_localQueueIndex]);
          } else {
            await _player.seek(Duration.zero);
            await _player.pause();
            playbackState.add(
              playbackState.value.copyWith(
                playing: false,
                processingState: AudioProcessingState.completed,
              ),
            );
            _updatePlaybackState();
          }
          return;
      }
    } catch (e) {
      print('Local playback completion handling error: $e');
    } finally {
      _handlingLocalCompletion = false;
    }
  }

  int _nextShuffleLocalIndex() {
    if (_localQueue.length <= 1) return _localQueueIndex;
    if (_localQueue.length == 2) {
      return 1 - _localQueueIndex;
    }
    var next = _localQueueIndex;
    for (var i = 0; i < 12 && next == _localQueueIndex; i++) {
      next = Random().nextInt(_localQueue.length);
    }
    return next;
  }

  // Enhanced player listeners for stream recovery
  void _setupPlayerListeners() {
    _playbackStateSubscription = _player.playerStateStream.listen((
      playerState,
    ) {
      _isLoading = playerState.processingState == ProcessingState.loading;
      _updatePlaybackState();

      if (playerState.playing &&
          playerState.processingState == ProcessingState.ready) {
        _lastSuccessfulPlayback = DateTime.now();
      }

      if (playerState.processingState == ProcessingState.completed) {
        if (_currentStation == null && _localQueue.isNotEmpty) {
          unawaited(_handleLocalPlaybackCompleted());
        } else {
          playbackState.add(
            playbackState.value.copyWith(
              playing: false,
              processingState: AudioProcessingState.completed,
            ),
          );
        }
      }

      if (!playerState.playing &&
          playbackState.value.playing &&
          !_isLoading &&
          _currentStation != null &&
          !_isRecovering) {
        final timeSinceLastPlay = _lastSuccessfulPlayback != null
            ? DateTime.now().difference(_lastSuccessfulPlayback!)
            : Duration.zero;

        if (timeSinceLastPlay.inMinutes >= 3) {
          print(
            '📱 Detected background playback interruption after ${timeSinceLastPlay.inMinutes} minutes',
          );
          if (playerState.processingState != ProcessingState.completed) {
            _scheduleRecovery();
          }
        } else if (playerState.processingState == ProcessingState.completed) {
          print('⚠️ Stream marked as completed - scheduling recovery');
          _scheduleRecovery();
        } else if (_isIcecastShoutcastStream(
          _currentStation?.streamUrl ?? '',
        )) {
          Future.delayed(Duration(seconds: 3), () {
            if (!_player.playing && !_isRecovering) {
              print('⚠️ Icecast stream stopped unexpectedly');
              _scheduleRecovery();
            }
          });
        }
      }
    });

    _player.processingStateStream.listen((processingState) {
      _isLoading = processingState == ProcessingState.loading;
      if (processingState == ProcessingState.completed &&
          _currentStation != null) {
        print(
          '⚠️ Stream marked as completed (EOF) - restarting live stream...',
        );
        if (!_isRecovering) {
          _attemptRecovery();
        }
      }
    });

    _player.playbackEventStream.listen((event) {
      if (event.processingState == ProcessingState.idle &&
          playbackState.value.playing &&
          _currentStation != null) {
        print('⚠️ Stream went idle unexpectedly');
        _scheduleRecovery();
      }
    });
  }

  void _setupBackgroundPlaybackMonitoring() {
    _player.playbackEventStream.listen((event) {
      if (_player.playing &&
          event.processingState == ProcessingState.idle &&
          _currentStation != null) {
        print('⚠️ Background stream stalled - triggering recovery');
        _scheduleRecovery();
      }
    });
  }

  void _scheduleRecovery() {
    if (_recoveryTimer != null && _recoveryTimer!.isActive) {
      return;
    }
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      print('❌ Max reconnection attempts reached');
      _reconnectAttempts = 0;
      _isRecovering = false;
      return;
    }
    print('🔄 Scheduling recovery attempt ${_reconnectAttempts + 1}');
    _recoveryTimer = Timer(Duration(seconds: 2 + _reconnectAttempts * 2), () {
      _attemptRecovery();
    });
  }

  Future<void> _attemptRecovery() async {
    if (_currentStation == null) return;
    _isRecovering = true;
    print('🔄 Attempting stream recovery (attempt ${_reconnectAttempts + 1})');
    _reconnectAttempts++;
    try {
      await _playStation(_currentStation!, isRecovery: true);
      _reconnectAttempts = 0;
      _isRecovering = false;
      print('✅ Stream recovery successful');
    } catch (e) {
      print('❌ Stream recovery failed: $e');
      _isRecovering = false;
      if (_reconnectAttempts < _maxReconnectAttempts) {
        _scheduleRecovery();
      } else {
        print(
          '❌ Giving up on stream recovery after $_maxReconnectAttempts attempts',
        );
        _reconnectAttempts = 0;
      }
    }
  }

  @override
  Future<void> toggleRecord(MediaItem? mediaItem) async {
    if (mediaItem == null || !playbackState.value.playing) {
      _sendPermissionDenied('Please play a radio station before recording.');
      return;
    }
    if (!_isRecording) {
      final status = await Permission.audio.request();
      if (status.isGranted || status.isLimited) {
        _isRecording = true;
        _analyticsService.logActivity(
          deviceId!,
          'Start Recording',
          details: {
            'stationId': mediaItem.id,
            'stationName': mediaItem.title,
          },
        );
        _sendRecordStatus(true);
        await _startRecording(mediaItem);
      } else {
        _sendPermissionDenied('Storage permission denied. Cannot record.');
        openAppSettings();
        return;
      }
    } else {
      _analyticsService.logActivity(
        deviceId!,
        'Stop Recording',
        details: {
          'stationId': mediaItem?.id,
          'stationName': mediaItem?.title,
        },
      );
      await _stopRecording();
      _isRecording = false;
      _sendRecordStatus(false);
    }
  }

  Future<void> _startRecording(MediaItem mediaItem) async {
    _recordingCancelToken = CancelToken();
    String currentUrl = _currentStation?.streamUrl ?? 'Unknown streaming URL';
    String referer = currentUrl.contains('radio.garden')
        ? 'https://radio.garden/'
        : 'https://akashvani.gov.in/';

    Map<String, String> richHeaders = {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.127 Safari/537.36',
      'Referer': referer,
      'Accept-Encoding': 'identity',
      'Accept': '*/*',
    };

    bool isHlsRecording = false;
    int maxRedirects = 3;

    for (int i = 0; i < maxRedirects; i++) {
      if (currentUrl.toLowerCase().contains('.m3u8')) {
        print(
          'M3U8 detected. Attempting to extract direct stream URL for recording...',
        );
        final Uri baseUri = Uri.parse(currentUrl);
        try {
          final response = await http.get(baseUri, headers: richHeaders);
          if (response.statusCode == 200) {
            final lines = response.body.split('\n');
            String? foundUrl;
            for (final line in lines) {
              final trimmedLine = line.trim();
              if (trimmedLine.isNotEmpty && !trimmedLine.startsWith('#')) {
                String resolvedUrl = baseUri.resolve(trimmedLine).toString();
                if (resolvedUrl.toLowerCase().contains('.m3u8')) {
                  foundUrl = resolvedUrl;
                  break;
                } else {
                  isHlsRecording = true;
                  i = maxRedirects;
                  break;
                }
              }
            }
            if (foundUrl != null) {
              currentUrl = foundUrl;
            } else if (isHlsRecording) {
              break;
            } else {
              break;
            }
          } else {
            break;
          }
        } catch (e) {
          break;
        }
      } else {
        break;
      }
    }

    final recordingUrl = currentUrl;
    Directory directory;
    final externalDirectories = await getExternalStorageDirectories(
      type: StorageDirectory.downloads,
    );
    if (externalDirectories != null && externalDirectories.isNotEmpty) {
      directory = externalDirectories.first;
    } else {
      directory = await getApplicationDocumentsDirectory();
    }
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    String extension = '.mp3';
    if (recordingUrl.toLowerCase().contains('.ts')) {
      extension = '.ts';
    } else if (recordingUrl.toLowerCase().contains('.aac') ||
        recordingUrl.toLowerCase().contains('.m4a')) {
      extension = '.aac';
    } else if (recordingUrl.toLowerCase().contains('.ogg')) {
      extension = '.ogg';
    }
    final safeTitle = mediaItem.title.replaceAll(RegExp(r'[^\w\s\-]'), '');
    final fileName =
        '${safeTitle}_${DateTime.now().millisecondsSinceEpoch}$extension';
    final filePath = '${directory.path}/$fileName';

    IOSink? sink;
    bool didError = false;
    final file = File(filePath);
    final Set<String> downloadedSegments = {};

    try {
      sink = file.openWrite(mode: FileMode.append);
      if (isHlsRecording) {
        while (!(_recordingCancelToken?.isCancelled ?? false)) {
          final playlistUri = Uri.parse(recordingUrl);
          final playlistResponse = await http.get(
            playlistUri,
            headers: richHeaders,
          );
          if (playlistResponse.statusCode != 200) {
            didError = true;
            throw Exception(
              'Failed to fetch M3U8 playlist: ${playlistResponse.statusCode}',
            );
          }
          final lines = playlistResponse.body.split('\n');
          final segmentUrls = <String>[];
          for (final line in lines) {
            final trimmedLine = line.trim();
            if (trimmedLine.isNotEmpty &&
                !trimmedLine.startsWith('#') &&
                !trimmedLine.toLowerCase().contains('.m3u8')) {
              final segmentUrl = playlistUri.resolve(trimmedLine).toString();
              segmentUrls.add(segmentUrl);
            }
          }
          for (final segmentUrl in segmentUrls) {
            if (!downloadedSegments.contains(segmentUrl)) {
              if (_recordingCancelToken?.isCancelled == true || !_isRecording) {
                return;
              }
              try {
                final segmentResponse = await _dio.get<ResponseBody>(
                  segmentUrl,
                  options: Options(
                    responseType: ResponseType.stream,
                    receiveTimeout: const Duration(seconds: 30),
                    headers: richHeaders,
                  ),
                  cancelToken: _recordingCancelToken,
                );
                if (segmentResponse.data?.stream != null) {
                  await sink.addStream(segmentResponse.data!.stream);
                  downloadedSegments.add(segmentUrl);
                }
              } on DioException catch (e) {
                if (e.type != DioExceptionType.cancel) {
                  print('Dio segment download error: $e');
                }
              } catch (e) {
                print('General segment download error: $e');
              }
            }
          }
          await Future.delayed(const Duration(seconds: 10));
        }
      } else {
        final response = await _dio.get<ResponseBody>(
          recordingUrl,
          options: Options(
            responseType: ResponseType.stream,
            receiveTimeout: const Duration(minutes: 30),
            headers: richHeaders,
          ),
          cancelToken: _recordingCancelToken,
        );
        if (response.data?.stream != null) {
          await sink.addStream(response.data!.stream);
        }
      }
    } on DioException catch (e) {
      if (e.type != DioExceptionType.cancel) {
        didError = true;
        _sendPermissionDenied('Recording failed: ${e.message}');
      }
    } finally {
      if (sink != null) {
        await sink.close();
      }
      if (didError || (_recordingCancelToken?.isCancelled ?? false)) {
        if (await file.exists()) {
          await file.delete();
        }
      }
    }
  }

  Future<void> _stopRecording() async {
    if (_recordingCancelToken != null && !_recordingCancelToken!.isCancelled) {
      _recordingCancelToken!.cancel('Recording stopped by user');
    }
    _recordingCancelToken?.cancel();
    _recordingCancelToken = null;
    // record_status: false is sent by toggleRecord after this returns.
  }

  void _sendRecordStatus(bool isRecording) {
    customEvent.add({'event': 'record_status', 'isRecording': isRecording});
  }

  void _sendPermissionDenied(String message) {
    customEvent.add({'event': 'permission_denied', 'message': message});
  }

  @override
  Future<void> skipToNext() async {
    // ── Local file mode ───────────────────────────────────────────────────────
    // _currentStation is null when a local file is playing.
    if (_currentStation == null && _localQueue.isNotEmpty) {
      if (_shuffleEnabled && _localQueue.length > 1) {
        _localQueueIndex = _nextShuffleLocalIndex();
      } else {
        _localQueueIndex = (_localQueueIndex + 1) % _localQueue.length;
      }
      await _playLocalEntry(_localQueue[_localQueueIndex]);
      return;
    }

    // ── Radio station mode ────────────────────────────────────────────────────
    if (_isRecording) {
      await toggleRecord(mediaItem.value);
    }
    _recoveryTimer?.cancel();
    _recoveryTimer = null;
    _reconnectAttempts = 0;
    _isRecovering = false;
    final currentIndex = _currentStation != null
        ? _radioStations.indexWhere(
            (station) => station.id == _currentStation?.id,
          )
        : -1;
    if (currentIndex != -1 && _radioStations.isNotEmpty) {
      final nextIndex = (currentIndex + 1) % _radioStations.length;
      await _playStation(_radioStations[nextIndex]);
    } else if (_radioStations.isNotEmpty) {
      await _playStation(_radioStations.first);
    }
  }

  @override
  Future<void> skipToPrevious() async {
    // ── Local file mode ───────────────────────────────────────────────────────
    if (_currentStation == null && _localQueue.isNotEmpty) {
      if (_shuffleEnabled && _localQueue.length > 1) {
        _localQueueIndex = _nextShuffleLocalIndex();
      } else {
        _localQueueIndex =
            (_localQueueIndex - 1 + _localQueue.length) % _localQueue.length;
      }
      await _playLocalEntry(_localQueue[_localQueueIndex]);
      return;
    }

    // ── Radio station mode ────────────────────────────────────────────────────
    if (_isRecording) {
      await toggleRecord(mediaItem.value);
    }
    _recoveryTimer?.cancel();
    _recoveryTimer = null;
    _reconnectAttempts = 0;
    _isRecovering = false;
    final currentIndex = _currentStation != null
        ? _radioStations.indexWhere(
            (station) => station.id == _currentStation?.id,
          )
        : -1;
    if (currentIndex != -1 && _radioStations.isNotEmpty) {
      final prevIndex =
          (currentIndex - 1 + _radioStations.length) % _radioStations.length;
      await _playStation(_radioStations[prevIndex]);
    } else if (_radioStations.isNotEmpty) {
      await _playStation(_radioStations.last);
    }
  }

  Future<void> _setupAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(
      AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions:
            AVAudioSessionCategoryOptions.allowBluetooth,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        androidAudioAttributes: const AndroidAudioAttributes(
          contentType: AndroidAudioContentType.music,
          usage: AndroidAudioUsage.media,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      ),
    );
    session.interruptionEventStream.listen((event) async {
      if (event.begin) {
        _wasPlayingBeforeInterruption = _player.playing;
        if (event.type == AudioInterruptionType.pause ||
            event.type == AudioInterruptionType.unknown) {
          pause();
        }
      } else {
        if (_wasPlayingBeforeInterruption && _currentStation != null) {
          await _player.setAudioSource(
            AudioSource.uri(Uri.parse(_currentStation!.streamUrl!)),
            preload: true,
          );
          play();
        }
      }
    });
  }

  void _notifyAudioHandlerAboutPlaybackEvents() {
    _player.playbackEventStream.listen((PlaybackEvent event) {
      _updatePlaybackState();
    });
  }

  void _updatePlaybackState({PlaybackState? state}) {
    final playing = _player.playing;
    final processingState = _player.processingState;
    final controls = <MediaControl>[];
    if (mediaItem.value != null) {
      if (playing) {
        controls.add(MediaControl.pause);
      } else {
        controls.add(MediaControl.play);
      }
    }
    final bool showSkip = _radioStations.length > 1 ||
        (_currentStation == null && _localQueue.length > 1);
    if (showSkip) {
      controls.add(MediaControl.skipToPrevious);
      controls.add(MediaControl.skipToNext);
    }
    controls.add(MediaControl.stop);

    final systemActions = <MediaAction>{
      MediaAction.seek,
      if (showSkip) ...<MediaAction>{
        MediaAction.skipToPrevious,
        MediaAction.skipToNext,
      },
    };

    playbackState.add(
      playbackState.value.copyWith(
        controls: controls,
        androidCompactActionIndices:
            controls.length > 2 ? const [0, 1, 2] : [0, 1],
        systemActions: systemActions,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        processingState:
            {
              ProcessingState.idle: AudioProcessingState.idle,
              ProcessingState.loading: AudioProcessingState.loading,
              ProcessingState.buffering: AudioProcessingState.buffering,
              ProcessingState.ready: AudioProcessingState.ready,
              ProcessingState.completed: AudioProcessingState.completed,
            }[processingState] ??
            AudioProcessingState.idle,
        playing: playing,
      ),
    );
  }

  Future<void> _playStation(
    RadioStation station, {
    bool isRecovery = false,
  }) async {
    if (station.streamUrl == null) {
      customEvent.add({
        'event': 'playback_error',
        'station': station.name,
        'error': 'Station stream URL is missing.',
      });
      return;
    }
    if (!isRecovery) {
      // Leaving local-file mode (if any): drop queue so skip next/prev and
      // _currentStation stay consistent — same handler serves radio + local MP3.
      _localQueue = [];
      _localQueueIndex = -1;
      _currentStation = station;
      mediaItem.add(station.toMediaItem());
    }
    if (!isRecovery) {
      await _player.stop();
      await Future.delayed(Duration(milliseconds: 100));
    }
    String streamUrl = station.streamUrl!;
    Map<String, String> richHeaders = {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      'Accept':
          'audio/webm,audio/ogg,audio/wav,audio/*;q=0.9,application/ogg;q=0.7,video/*;q=0.6,*/*;q=0.5',
      'Accept-Encoding': 'identity',
      'Connection': 'keep-alive',
      'Icy-MetaData': '1',
    };
    if (streamUrl.contains('radio.garden')) {
      richHeaders['Referer'] = 'https://radio.garden/';
      richHeaders['Origin'] = 'https://radio.garden';
    } else if (streamUrl.contains('akashvani.gov.in')) {
      richHeaders['Referer'] = 'https://akashvani.gov.in/';
    }
    if (_isIcecastShoutcastStream(streamUrl)) {
      await _playIcecastShoutcastStream(
        station,
        streamUrl,
        richHeaders,
        isRecovery,
      );
      return;
    }
    if (_hasSSLIssues(streamUrl)) {
      await _playWithSSLWorkaround(station, streamUrl, richHeaders, isRecovery);
      return;
    }
    try {
      if (streamUrl.toLowerCase().contains('.m3u8')) {
        await _player.setAudioSource(
          HlsAudioSource(Uri.parse(streamUrl), headers: richHeaders),
        );
      } else {
        await _player.setAudioSource(
          ProgressiveAudioSource(Uri.parse(streamUrl), headers: richHeaders),
        );
      }
      _lastExtractedStreamUrl = streamUrl;
      await _player.play();
      _updatePlaybackState();
      _reconnectAttempts = 0;
      _recoveryTimer?.cancel();
      _isRecovering = false;
      _lastSuccessfulPlayback = DateTime.now();
      customEvent.add({'event': 'playback_started', 'station': station.name});
      _analyticsService.logActivity(
        deviceId!,
        'Radio Playback Started',
        details: {
          'stationId': station.id,
          'stationName': station.name,
          'isRecovery': isRecovery,
          'url': _lastExtractedStreamUrl,
        },
      );
    } catch (error) {
      if (_isSSLError(error)) {
        await _playWithSSLWorkaround(
          station,
          streamUrl,
          richHeaders,
          isRecovery,
        );
      } else {
        customEvent.add({
          'event': 'playback_error',
          'station': station.name,
          'error': error.toString(),
        });
        if (!streamUrl.contains('radio.garden')) {
          await _tryFallbackUrls(station, error, streamUrl);
        } else {
          await _trySimpleRadioGardenFallback(station);
        }
      }
    }
  }

  bool _hasSSLIssues(String url) {
    final problematicDomains = ['stream.teluguoneradio.com', 'radio.garden'];
    return problematicDomains.any((domain) => url.contains(domain));
  }

  bool _isSSLError(dynamic error) {
    final errorStr = error.toString();
    return errorStr.contains('CERTIFICATE_VERIFY_FAILED') ||
        errorStr.contains('SSLHandshakeException') ||
        errorStr.contains('CertPathValidatorException') ||
        errorStr.contains('unable to get local issuer certificate');
  }

  Future<void> _playWithSSLWorkaround(
    RadioStation station,
    String originalUrl,
    Map<String, String> headers,
    bool isRecovery,
  ) async {
    if (originalUrl.startsWith('https://')) {
      final httpUrl = originalUrl.replaceFirst('https://', 'http://');
      try {
        await _player.setAudioSource(
          ProgressiveAudioSource(Uri.parse(httpUrl), headers: headers),
        );
        await _player.play();
        _updatePlaybackState();
        customEvent.add({'event': 'playback_started', 'station': station.name});
        _analyticsService.logActivity(
          deviceId!,
          'Radio Playback Started (Alternative)',
          details: {
            'stationId': station.id,
            'stationName': station.name,
            'url': httpUrl,
          },
        );
        return;
      } catch (e) {}
    }
    final alternativeUrls = await _getAlternativeUrls(station);
    for (final altUrl in alternativeUrls) {
      try {
        await _player.setUrl(altUrl, headers: headers);
        await _player.play();
        _updatePlaybackState();
        customEvent.add({'event': 'playback_started', 'station': station.name});
        _analyticsService.logActivity(
          deviceId!,
          'Radio Playback Started (SSL Workaround)',
          details: {
            'stationId': station.id,
            'stationName': station.name,
            'url': altUrl,
          },
        );
        return;
      } catch (e) {}
    }
    customEvent.add({
      'event': 'playback_error',
      'station': station.name,
      'error':
          'Stream unavailable due to security restrictions. Please try another station.',
    });
    _analyticsService.logActivity(
      deviceId!,
      'Radio Playback Error (SSL)',
      details: {
        'stationId': station.id,
        'stationName': station.name,
        'error': 'Security restrictions / SSL issues',
      },
    );
  }

  Future<List<String>> _getAlternativeUrls(RadioStation station) async {
    final alternatives = <String>[];
    String streamUrl = station.streamUrl!;
    if (streamUrl.contains('teluguoneradio.com')) {
      alternatives.addAll([
        'http://stream.teluguoneradio.com:8164/;stream/1',
        'https://stream.teluguoneradio.com:8164/stream',
        'http://stream.teluguoneradio.com:8164/stream',
      ]);
    }
    if (streamUrl.contains('radio.garden')) {
      final match = RegExp(
        r'listen/([^/]+)/channel\.mp3',
      ).firstMatch(streamUrl);
      if (match != null) {
        final channelId = match.group(1);
        alternatives.addAll([
          'https://radio.garden/api/ara/content/channel/$channelId/listen.mp3',
          'https://radio.garden/api/ara/content/listen/$channelId/stream.mp3',
        ]);
      }
    }
    return alternatives;
  }

  Future<void> _tryFallbackUrls(
    RadioStation station,
    dynamic initialError,
    String currentUrl,
  ) async {
    if (_isSSLError(initialError)) {
      await _playWithSSLWorkaround(station, currentUrl, {}, false);
      return;
    }
    final isRedirectLoop = initialError.toString().contains(
      'Redirect loop detected',
    );
    String referer = station.streamUrl!.contains('akashvani.gov.in')
        ? 'https://akashvani.gov.in/'
        : 'https://example.com/';
    Map<String, String> richHeaders = {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      'Referer': referer,
      'Accept-Encoding': 'identity',
      'Accept': '*/*',
      'Connection': 'keep-alive',
    };
    final baseUri = Uri.parse(currentUrl);
    if (!isRedirectLoop && currentUrl.toLowerCase().contains('.m3u8')) {
      try {
        final response = await http.get(baseUri, headers: richHeaders);
        if (response.statusCode == 200) {
          final lines = response.body.split('\n');
          for (final line in lines) {
            if (line.trim().isNotEmpty && !line.startsWith('#')) {
              String relativeUrl = line.trim();
              final streamUri = baseUri.resolve(relativeUrl);
              String streamUrl = streamUri.toString();
              await _player.setUrl(streamUrl, headers: richHeaders);
              _lastExtractedStreamUrl = streamUrl;
              await _player.play();
              _updatePlaybackState();
              return;
            }
          }
        }
      } catch (e) {}
    }
    final fallbacks = <String>[
      currentUrl.replaceAll('.m3u8', '.mp3'),
      currentUrl.replaceAll('.m3u8', '.aac'),
      currentUrl.replaceAll('/listen/', '/stream/'),
    ];
    if (currentUrl.startsWith('https://')) {
      fallbacks.add(currentUrl.replaceFirst('https://', 'http://'));
    }
    for (final fallbackUrl in fallbacks) {
      if (fallbackUrl != currentUrl) {
        try {
          await _player.setUrl(fallbackUrl, headers: richHeaders);
          await _player.play();
          _updatePlaybackState();
          return;
        } catch (e) {}
      }
    }
    customEvent.add({
      'event': 'playback_error',
      'station': station.name,
      'error': 'Unable to play this station. The stream may be unavailable.',
    });
    _analyticsService.logActivity(
      deviceId!,
      'Radio Playback Error',
      details: {
        'stationId': station.id,
        'stationName': station.name,
        'error': 'Unable to play station after fallbacks',
      },
    );
  }

  Future<void> _playIcecastShoutcastStream(
    RadioStation station,
    String streamUrl,
    Map<String, String> headers,
    bool isRecovery,
  ) async {
    String cleanUrl = streamUrl;
    final streamVariations = [
      cleanUrl,
      '$cleanUrl/',
      '$cleanUrl/stream',
      '$cleanUrl/;',
      streamUrl,
    ];
    final icecastHeaders = Map<String, String>.from(headers);
    icecastHeaders.addAll({
      'Icy-MetaData': '1',
      'Accept': '*/*',
      'Connection': 'keep-alive',
    });
    for (final variation in streamVariations) {
      try {
        await _player.setUrl(variation, headers: icecastHeaders);
        await Future.delayed(Duration(milliseconds: 200));
        await _player.play();
        await Future.delayed(Duration(seconds: 2));
        if (_player.playing &&
            _player.processingState != ProcessingState.idle) {
          _updatePlaybackState();
          _lastExtractedStreamUrl = variation;
          _reconnectAttempts = 0;
          _recoveryTimer?.cancel();
          _isRecovering = false;
          customEvent.add({
            'event': 'playback_started',
            'station': station.name,
          });
          _analyticsService.logActivity(
            deviceId!,
            'Radio Playback Started (Icecast/Shoutcast)',
            details: {
              'stationId': station.id,
              'stationName': station.name,
              'url': variation,
            },
          );
          return;
        }
      } catch (e) {}
    }
    try {
      await _player.setUrl(cleanUrl);
      _player.setLoopMode(LoopMode.off);
      await _player.play();
      await Future.delayed(Duration(seconds: 3));
      if (_player.playing) {
        _updatePlaybackState();
        _lastExtractedStreamUrl = cleanUrl;
        _reconnectAttempts = 0;
        _recoveryTimer?.cancel();
        _isRecovering = false;
        customEvent.add({'event': 'playback_started', 'station': station.name});
        _analyticsService.logActivity(
          deviceId!,
          'Radio Playback Started (Icecast Fallback)',
          details: {
            'stationId': station.id,
            'stationName': station.name,
            'url': cleanUrl,
          },
        );
        return;
      }
    } catch (e) {}
    customEvent.add({
      'event': 'playback_error',
      'station': station.name,
      'error':
          'Icecast/Shoutcast stream format not supported. Please try another station.',
    });
    _analyticsService.logActivity(
      deviceId!,
      'Radio Playback Error (Icecast)',
      details: {
        'stationId': station.id,
        'stationName': station.name,
        'error': 'Icecast/Shoutcast format not supported',
      },
    );
  }

  Future<void> _trySimpleRadioGardenFallback(RadioStation station) async {
    try {
      await _player.setUrl(station.streamUrl!);
      await _player.play();
      _updatePlaybackState();
    } catch (e) {
      await _tryExtractRadioGardenStream(station);
    }
  }

  Future<void> _tryExtractRadioGardenStream(RadioStation station) async {
    try {
      final match = RegExp(
        r'listen/([^/]+)/channel\.mp3',
      ).firstMatch(station.streamUrl!);
      if (match != null) {
        final channelId = match.group(1);
        final alternatives = [
          'https://radio.garden/api/ara/content/channel/$channelId/listen.mp3',
          'https://radio.garden/api/ara/content/listen/$channelId/stream.mp3',
          'https://radio.garden/api/ara/content/listen/$channelId/index.m3u8',
        ];
        for (final altUrl in alternatives) {
          try {
            await _player.setUrl(
              altUrl,
              headers: {
                'User-Agent':
                    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
                'Referer': 'https://radio.garden/',
              },
            );
            await _player.play();
            _updatePlaybackState();
            return;
          } catch (e) {}
        }
      }
    } catch (e) {}
  }

  @override
  Future<void> play() async {
    if (_player.processingState == ProcessingState.completed) {
      if (_currentStation != null) {
        await _playStation(_currentStation!, isRecovery: true);
        return;
      }
      // Local file finished: restart from the beginning.
      await _player.seek(Duration.zero);
    }
    await WakelockPlus.enable();
    await _player.play();
  }

  @override
  Future<void> pause() async {
    await _player.pause();
    await WakelockPlus.disable();
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    await cancelSleepTimer();
    await WakelockPlus.disable();
    return super.stop();
  }

  Future<void> playStation(RadioStation station) async {
    await _playStation(station);
  }

  RadioStation? get currentStation => _currentStation;
  bool get isLoading => _isLoading;
  bool get isRecording => _isRecording;

  Future<void> cleanup() async {
    _recoveryTimer?.cancel();
    _sleepTimer?.cancel();
    _sleepTicker?.cancel();
    await _player.dispose();
  }

  bool _isIcecastShoutcastStream(String url) {
    return url.contains(';stream/') ||
        url.contains('/stream') ||
        url.contains(':8164') ||
        url.contains(':8000') ||
        url.toLowerCase().contains('icecast') ||
        url.toLowerCase().contains('shoutcast');
  }
}
