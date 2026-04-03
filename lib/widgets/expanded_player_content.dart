import 'dart:async';
import 'dart:math' as math;

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grradio/radio/music_visualizer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../main.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  ExpandedPlayerContent
//
//  Enhancements:
//   • Share button — shares current station name + stream URL via system sheet.
//   • ICY/track metadata row — shows currently-playing song title from the
//     mediaItem extras map (key: "icy_title") when available.
//   • Haptic feedback on record toggle and play/pause.
//   • Record button ONLY shown for radio stations (album == "Live Radio").
//   • Skip / Play-Pause controls fully locked (dimmed + null) while recording.
//   • Polished art container: gradient fallback, rounded shadow, Hero tag.
//   • "Stop recording to switch stations" hint below controls when locked.
// ─────────────────────────────────────────────────────────────────────────────

class ExpandedPlayerContent extends StatefulWidget {
  final MediaItem? mediaItem;
  final bool isPlaying;
  final dynamic audioHandler;
  final Function(bool)? onRecordingStatusChanged;
  final PanelController? pc;
  final VoidCallback? onNavigateToRecordings;
  final bool sidePanel;

  const ExpandedPlayerContent({
    Key? key,
    required this.mediaItem,
    required this.isPlaying,
    required this.audioHandler,
    this.onRecordingStatusChanged,
    this.pc,
    this.onNavigateToRecordings,
    this.sidePanel = false,
  }) : super(key: key);

  @override
  State<ExpandedPlayerContent> createState() => _ExpandedPlayerContentState();
}

class _ExpandedPlayerContentState extends State<ExpandedPlayerContent>
    with TickerProviderStateMixin {
  // ── Recording state — driven entirely by the handler's customEvent ────────
  bool _isRecording = false;
  int _recordSeconds = 0;
  Timer? _recordTimer; // counts display seconds locally
  StreamSubscription? _customEventSub; // listens to handler events

  // ── Playback progress (local files only — music / download / recording) ────
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  StreamSubscription? _mediaItemSub; // watches duration from mediaItem

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseScale;
  late Animation<double> _pulseOpacity;

  // ── Share button scale animation ──────────────────────────────────────────
  late AnimationController _shareBounceCtrl;
  late Animation<double> _shareBounce;

  bool _shuffleEnabled = false;
  String _repeatMode = 'LoopMode.off';
  int _sleepRemainingSeconds = 0;
  bool _sleepTimerActive = false;
  StreamSubscription<Duration>? _positionSub;

  // Throttle UI rebuilds caused by frequent positionStream events.
  int _lastPositionUiUpdateMs = 0;

  /// While dragging the seek bar, parent scroll is disabled and stream position
  /// does not fight the thumb.
  bool _sliderDragging = false;
  double _sliderDragValue = 0.0;
  // ─────────────────────────────────────────────────────────────────────────
  // True for live radio stations; false only when album is explicitly 'Local Files'.
  // Defaults to true (show record) when album is null/empty so the button is
  // never accidentally hidden due to a missing album tag.
  bool get _isRadioStation {
    final album = widget.mediaItem?.album ?? '';
    if (album == 'Local Files') return false;
    return true; // 'Live Radio' or unknown → show record
  }

  /// ICY track title from the mediaItem extras, if the handler populates it.
  String? get _icyTitle {
    final extras = widget.mediaItem?.extras;
    if (extras == null) return null;
    final raw = extras['icy_title'];
    if (raw == null || raw.toString().trim().isEmpty) return null;
    return raw.toString().trim();
  }

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseScale = Tween<double>(
      begin: 1.0,
      end: 1.6,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut));
    _pulseOpacity = Tween<double>(
      begin: 0.55,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut));

    _shareBounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _shareBounce = Tween<double>(
      begin: 1.0,
      end: 0.82,
    ).animate(CurvedAnimation(parent: _shareBounceCtrl, curve: Curves.easeOut));

    // ── Progress bar: poll position every 500 ms + watch duration ────────────
    _mediaItemSub = widget.audioHandler.mediaItem.listen((mi) {
      if (!mounted) return;
      final dur = (mi as MediaItem?)?.duration ?? Duration.zero;
      if (dur != _duration) setState(() => _duration = dur);
    });
    _positionSub = globalRadioAudioHandler.positionStream.listen((pos) {
      if (!mounted || _sliderDragging) return;
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      if (nowMs - _lastPositionUiUpdateMs < 250) return;
      _lastPositionUiUpdateMs = nowMs;
      setState(() => _position = pos);
    });
    _syncSleepTimerStateFromHandler();
    _customEventSub = widget.audioHandler.customEvent.listen((event) {
      if (event is! Map) return;
      final type = event['event'];
      if (type == 'shuffle_changed') {
        setState(() {
          _shuffleEnabled = event['enabled'] as bool;
        });
      } else if (type == 'repeat_changed') {
        setState(() {
          _repeatMode = event['mode'] as String;
        });
      } else if (type == 'sleep_timer_update') {
        if (!mounted) return;
        setState(() {
          _sleepTimerActive = (event['active'] as bool?) ?? false;
          _sleepRemainingSeconds = (event['remaining_seconds'] as int?) ?? 0;
        });
      } else if (type == 'record_status') {
        final isRec = event['isRecording'] as bool? ?? false;
        if (!mounted) return;
        setState(() => _isRecording = isRec);

        if (isRec) {
          _pulseCtrl.repeat();
          _recordSeconds = 0;
          _recordTimer?.cancel();
          _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
            if (mounted) setState(() => _recordSeconds++);
          });
        } else {
          _pulseCtrl.stop();
          _pulseCtrl.reset();
          _recordTimer?.cancel();
        }

        widget.onRecordingStatusChanged?.call(isRec);
      } else if (type == 'permission_denied') {
        if (!mounted) return;
        final msg = event['message'] as String? ?? 'Permission denied';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _customEventSub?.cancel();
    _mediaItemSub?.cancel();
    _positionSub?.cancel();
    _pulseCtrl.dispose();
    _recordTimer?.cancel();
    _shareBounceCtrl.dispose();
    super.dispose();
  }

  // ── Toggle recording — delegates to RadioHandlerImpl.toggleRecord ────────
  // The handler owns the recording lifecycle (permission check, file I/O,
  // start/stop). It broadcasts 'record_status' via customEvent, which the
  // _customEventSub listener above picks up to update UI state.
  void _toggleRecording() {
    HapticFeedback.mediumImpact();
    widget.audioHandler.toggleRecord(widget.mediaItem);
  }

  void _goToRecordings() {
    widget.pc?.close();
    widget.onNavigateToRecordings?.call();
  }

  // ── Share current station ─────────────────────────────────────────────────
  Future<void> _shareStation() async {
    HapticFeedback.lightImpact();
    _shareBounceCtrl.forward().then((_) => _shareBounceCtrl.reverse());

    final item = widget.mediaItem;
    if (item == null) return;

    final streamUrl = item.extras?['stream_url'] as String? ?? '';
    final text = streamUrl.isNotEmpty
        ? '🎙️ Listening to ${item.title} on GR Radio!\n$streamUrl'
        : '🎙️ Listening to ${item.title} on GR Radio!';

    await Share.share(text, subject: 'Check out ${item.title}');
  }

  void _onPlayPause() {
    if (_isRecording) return;
    HapticFeedback.lightImpact();
    widget.isPlaying ? widget.audioHandler.pause() : widget.audioHandler.play();
  }

  void _onSkipPrevious() {
    if (_isRecording) return;
    HapticFeedback.selectionClick();
    widget.audioHandler.skipToPrevious();
  }

  void _onSkipNext() {
    if (_isRecording) return;
    HapticFeedback.selectionClick();
    widget.audioHandler.skipToNext();
  }

  void _syncSleepTimerStateFromHandler() {
    try {
      final Duration? remaining =
          widget.audioHandler.getSleepTimerRemaining() as Duration?;
      if (!mounted) return;
      setState(() {
        _sleepTimerActive = remaining != null && remaining > Duration.zero;
        _sleepRemainingSeconds = remaining?.inSeconds ?? 0;
      });
    } catch (_) {}
  }

  // ── Progress helpers ──────────────────────────────────────────────────────
  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '${h.toString().padLeft(2, '0')}:$m:$s' : '$m:$s';
  }

  double get _progressValue {
    if (_duration.inMilliseconds <= 0) return 0.0;
    return (_position.inMilliseconds / _duration.inMilliseconds).clamp(
      0.0,
      1.0,
    );
  }

  /// Elapsed time shown next to the scrubber (preview position while dragging).
  Duration get _displayPosition {
    if (_duration.inMilliseconds <= 0) return Duration.zero;
    if (_sliderDragging) {
      return Duration(
        milliseconds: (_sliderDragValue * _duration.inMilliseconds).round(),
      );
    }
    return _position;
  }

  double get _sliderDisplayValue {
    if (_duration.inMilliseconds <= 0) return 0.0;
    if (_sliderDragging) {
      return _sliderDragValue.clamp(0.0, 1.0);
    }
    return _progressValue;
  }

  void _onSeek(double value) {
    if (_duration.inMilliseconds <= 0) return;
    widget.audioHandler.seek(
      Duration(milliseconds: (value * _duration.inMilliseconds).round()),
    );
  }

  String get _timerLabel {
    final m = (_recordSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_recordSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenWidth = mq.size.width;
    final screenHeight = mq.size.height;
    final bool sidePanelMode = widget.sidePanel;
    final isLandscapeWide =
        mq.orientation == Orientation.landscape && screenWidth >= 600;
    final double artSize = sidePanelMode
        ? math.min(screenWidth * 0.30 * 0.8, 200.0).clamp(90.0, 200.0)
        : isLandscapeWide
        ? math
              .min(math.min(screenHeight * 0.58, screenWidth * 0.38), 320.0)
              .clamp(200.0, 340.0)
        : screenWidth * 0.72;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final headerRow = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          sidePanelMode
              ? const SizedBox(width: 44)
              : GestureDetector(
                  onTap: widget.pc == null ? null : () => widget.pc!.close(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.07)
                          : Colors.black.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 24,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ),
          Column(
            children: [
              Text(
                _isRadioStation ? 'LIVE RADIO' : 'NOW PLAYING',
                style: tt.labelMedium?.copyWith(
                  letterSpacing: 1.5,
                  color: _isRadioStation
                      ? const Color(0xFF7C4DFF)
                      : cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
          ScaleTransition(
            scale: _shareBounce,
            child: GestureDetector(
              onTap: _shareStation,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C4DFF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.ios_share_rounded,
                  size: 22,
                  color: Color(0xFF7C4DFF),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    final recordingPill = _isRecording
        ? TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 300),
            builder: (_, v, child) => Opacity(opacity: v, child: child),
            child: Container(
              margin: EdgeInsets.only(bottom: sidePanelMode ? 8 : 14),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.shade700,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.35),
                    blurRadius: 14,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _BlinkingDot(),
                  const SizedBox(width: 6),
                  const Text(
                    'REC • CONTROLS LOCKED',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          )
        : const SizedBox.shrink();

    final albumArt = Container(
      width: artSize,
      height: artSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C4DFF).withOpacity(0.28),
            blurRadius: 40,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: const Color(0xFF448AFF).withOpacity(0.14),
            blurRadius: 60,
            offset: const Offset(0, 20),
          ),
        ],
        image: widget.mediaItem?.artUri != null
            ? DecorationImage(
                image: NetworkImage(widget.mediaItem!.artUri.toString()),
                fit: BoxFit.cover,
              )
            : null,
        gradient: widget.mediaItem?.artUri == null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF1A0A3E), const Color(0xFF0D2040)]
                    : [const Color(0xFFF0EEFF), const Color(0xFFE0F0FF)],
              )
            : null,
      ),
      child: widget.mediaItem?.artUri == null
          ? Center(
              child: Icon(
                _isRadioStation ? Icons.radio : Icons.music_note,
                size: artSize * 0.32,
                color: const Color(0xFF7C4DFF).withOpacity(0.5),
              ),
            )
          : null,
    );

    final visualizerBlock = SizedBox(
      height: sidePanelMode ? 38 : (isLandscapeWide ? 40 : 52),
      child: MusicVisualizer(
        isPlaying: widget.isPlaying,
        // Landscape/right-side panel is narrow; fewer animated bars reduces
        // main-thread work and helps prevent "Skipped frames".
        barCount: sidePanelMode ? 10 : (isLandscapeWide ? 12 : 15),
      ),
    );

    final bool disableScroll = isLandscapeWide || sidePanelMode;

    final Widget columnContent = Padding(
      padding: EdgeInsets.only(bottom: sidePanelMode ? 0 : 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: sidePanelMode ? 8 : 12),

          // ── Drag handle ──────────────────────────────────────────────
          if (!sidePanelMode)
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.35),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          if (!sidePanelMode) SizedBox(height: sidePanelMode ? 8 : 12),

          if (isLandscapeWide && !sidePanelMode)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 46,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        albumArt,
                        const SizedBox(height: 12),
                        visualizerBlock,
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 54,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        headerRow,
                        const SizedBox(height: 12),
                        recordingPill,
                        _buildMetaIcyAndProgressSection(
                          tt,
                          cs,
                          isLandscapeWide,
                        ),
                        _buildTransportAndActions(tt, compact: sidePanelMode),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else ...[
            headerRow,
            SizedBox(height: sidePanelMode ? 10 : 18),
            recordingPill,
            albumArt,
            SizedBox(height: sidePanelMode ? 14 : 24),
            visualizerBlock,
            SizedBox(height: sidePanelMode ? 10 : 18),
            _buildMetaIcyAndProgressSection(tt, cs, isLandscapeWide),
            _buildTransportAndActions(tt, compact: sidePanelMode),
          ],
        ],
      ),
    );

    if (sidePanelMode) {
      // Scale the entire expanded player to fit the available panel height,
      // ensuring all controls are visible without scrolling.
      return SizedBox.expand(
        child: LayoutBuilder(
          builder: (context, constraints) => FittedBox(
            fit: BoxFit.fitHeight,
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: constraints.maxWidth,
                minHeight: constraints.maxHeight,
              ),
              child: columnContent,
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      physics: _sliderDragging
          ? const NeverScrollableScrollPhysics()
          : disableScroll
          ? const NeverScrollableScrollPhysics()
          : const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
      child: columnContent,
    );
  }

  /// Title, artist, ICY, seek bar (local files).
  Widget _buildMetaIcyAndProgressSection(
    TextTheme tt,
    ColorScheme cs,
    bool isLandscapeWide,
  ) {
    final bool compact = isLandscapeWide || widget.sidePanel;
    final metaHPad = compact ? 10.0 : 28.0;
    final icyHMargin = compact ? 6.0 : 32.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: metaHPad),
          child: Text(
            widget.mediaItem?.title ?? 'Station Name',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tt.titleLarge?.copyWith(
              fontSize: compact ? 18 : (isLandscapeWide ? 20 : 22),
              color: cs.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 6),
        if (!_isRadioStation) ...[
          const SizedBox(height: 6),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isLandscapeWide ? 12 : 24,
            ),
            child: Column(
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3.5,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 14,
                    ),
                    activeTrackColor: const Color(0xFF7C4DFF),
                    inactiveTrackColor: const Color(
                      0xFF7C4DFF,
                    ).withOpacity(0.18),
                    thumbColor: const Color(0xFF7C4DFF),
                    overlayColor: const Color(0xFF7C4DFF).withOpacity(0.15),
                  ),
                  child: Slider(
                    value: _sliderDisplayValue,
                    onChangeStart: _duration.inMilliseconds > 0
                        ? (_) {
                            setState(() {
                              _sliderDragging = true;
                              _sliderDragValue = _progressValue;
                            });
                          }
                        : null,
                    onChanged: _duration.inMilliseconds > 0
                        ? (v) {
                            setState(() => _sliderDragValue = v);
                          }
                        : null,
                    onChangeEnd: _duration.inMilliseconds > 0
                        ? (v) {
                            _onSeek(v);
                            setState(() => _sliderDragging = false);
                          }
                        : null,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(_displayPosition),
                        style: tt.labelMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        _formatDuration(_duration),
                        style: tt.labelMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isLandscapeWide ? 8 : 16),
        ] else
          SizedBox(height: isLandscapeWide ? 8 : 30),
      ],
    );
  }

  Widget _buildTransportAndActions(TextTheme tt, {required bool compact}) {
    final double skipSize = compact ? 34 : 40;
    final double playSize = compact ? 62 : 76;
    final double gap = compact ? 12 : 18;
    final double playIconSize = compact ? 32 : 38;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ControlButton(
              icon: Icons.skip_previous_rounded,
              size: skipSize,
              locked: _isRecording,
              onTap: _onSkipPrevious,
            ),
            SizedBox(width: gap),
            GestureDetector(
              onTap: _onPlayPause,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: playSize,
                height: playSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: _isRecording
                      ? null
                      : const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF7C4DFF), Color(0xFF448AFF)],
                        ),
                  color: _isRecording ? Colors.grey.shade700 : null,
                  boxShadow: _isRecording
                      ? []
                      : [
                          BoxShadow(
                            color: const Color(0xFF7C4DFF).withOpacity(0.45),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                ),
                child: StreamBuilder<PlaybackState>(
                  stream: globalRadioAudioHandler.playbackState,
                  builder: (context, snapshot) {
                    final state = snapshot.data?.processingState;
                    if (state == AudioProcessingState.loading ||
                        state == AudioProcessingState.buffering) {
                      return const Center(
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        ),
                      );
                    }
                    return Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, anim) =>
                            ScaleTransition(scale: anim, child: child),
                        child: Icon(
                          widget.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          key: ValueKey(widget.isPlaying),
                          size: playIconSize,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(width: gap),
            _ControlButton(
              icon: Icons.skip_next_rounded,
              size: skipSize,
              locked: _isRecording,
              onTap: _onSkipNext,
            ),
          ],
        ),
        if (_isRecording)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              'Stop recording to switch stations',
              style: TextStyle(
                fontSize: 11,
                color: Colors.red.shade400,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        SizedBox(height: compact ? 12 : 24),
        if (widget.mediaItem != null)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 24),
            child: Transform.scale(
              scale: compact ? 0.9 : 1.0,
              alignment: Alignment.center,
              child: compact
                  ? Wrap(
                      alignment: WrapAlignment.spaceEvenly,
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (_isRadioStation) ...[
                          _buildRecordButton(),
                          _buildSleepTimerButton(),
                          _buildRecordingsButton(),
                        ] else ...[
                          _buildShuffleButton(),
                          _buildSleepTimerButton(),
                          _buildRepeatButton(),
                        ],
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (_isRadioStation) ...[
                          _buildRecordButton(),
                          Container(
                            width: 1,
                            height: 64,
                            color: Colors.grey.withOpacity(0.18),
                          ),
                          _buildSleepTimerButton(),
                          Container(
                            width: 1,
                            height: 64,
                            color: Colors.grey.withOpacity(0.18),
                          ),
                          _buildRecordingsButton(),
                        ] else ...[
                          _buildShuffleButton(),
                          Container(
                            width: 1,
                            height: 64,
                            color: Colors.grey.withOpacity(0.18),
                          ),
                          _buildSleepTimerButton(),
                          Container(
                            width: 1,
                            height: 64,
                            color: Colors.grey.withOpacity(0.18),
                          ),
                          _buildRepeatButton(),
                        ],
                      ],
                    ),
            ),
          ),
      ],
    );
  }

  // ── Record toggle ─────────────────────────────────────────────────────────
  Widget _buildRecordButton() {
    return GestureDetector(
      onTap: _toggleRecording,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, __) => SizedBox(
              width: 68,
              height: 68,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_isRecording)
                    Transform.scale(
                      scale: _pulseScale.value,
                      child: Opacity(
                        opacity: _pulseOpacity.value,
                        child: Container(
                          width: 54,
                          height: 54,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeInOut,
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isRecording
                          ? Colors.red
                          : Colors.red.withOpacity(0.09),
                      border: Border.all(
                        color: Colors.red,
                        width: _isRecording ? 0 : 1.8,
                      ),
                    ),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        transitionBuilder: (child, anim) =>
                            ScaleTransition(scale: anim, child: child),
                        child: _isRecording
                            ? const Icon(
                                Icons.stop_rounded,
                                key: ValueKey('stop'),
                                color: Colors.white,
                                size: 26,
                              )
                            : Icon(
                                Icons.mic,
                                key: const ValueKey('mic'),
                                color: Colors.red.shade700,
                                size: 24,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: _isRecording
                ? Row(
                    key: const ValueKey('active'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _BlinkingDot(),
                      const SizedBox(width: 5),
                      Text(
                        _timerLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Text(
                    'Record',
                    key: const ValueKey('idle'),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ── Recordings shortcut ───────────────────────────────────────────────────
  Widget _buildRecordingsButton() {
    return Opacity(
      opacity: _isRecording ? 0.28 : 1.0,
      child: GestureDetector(
        onTap: _isRecording ? null : _goToRecordings,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF7C4DFF).withOpacity(0.09),
                border: Border.all(color: const Color(0xFF7C4DFF), width: 1.8),
              ),
              child: const Center(
                child: Icon(
                  Icons.library_music_rounded,
                  color: Color(0xFF7C4DFF),
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Recordings',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShuffleButton() {
    final isActive = _shuffleEnabled;
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        widget.audioHandler.toggleShuffle();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF7C4DFF).withOpacity(0.15)
              : Colors.grey.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? const Color(0xFF7C4DFF)
                : Colors.grey.withOpacity(0.40),
            width: 1.2,
          ),
        ),
        child: Icon(
          Icons.shuffle, // ← ALWAYS use this one
          size: 26,
          color: isActive
              ? const Color(0xFF7C4DFF)
              : cs.onSurfaceVariant.withValues(alpha: 0.72),
        ),
      ),
    );
  }

  Widget _buildRepeatButton() {
    final cs = Theme.of(context).colorScheme;
    final mode = _repeatMode; // "LoopMode.off", "LoopMode.one", "LoopMode.all"

    IconData icon;
    bool isActive = mode != 'LoopMode.off';

    if (mode.contains('one')) {
      icon = Icons.repeat_one;
    } else {
      icon = Icons.repeat;
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        widget.audioHandler.cycleRepeatMode();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF7C4DFF).withOpacity(0.15)
              : Colors.grey.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? const Color(0xFF7C4DFF)
                : Colors.grey.withOpacity(0.25),
            width: 1.2,
          ),
        ),
        child: Icon(
          icon,
          size: 26,
          color: isActive
              ? const Color(0xFF7C4DFF)
              : cs.onSurfaceVariant.withValues(alpha: 0.72),
        ),
      ),
    );
  }

  Widget _buildSleepTimerButton() {
    final cs = Theme.of(context).colorScheme;
    final isActive = _sleepTimerActive;
    return GestureDetector(
      onTap: _showSleepTimerSheet,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? const Color(0xFF7C4DFF).withOpacity(0.15)
                  : Colors.grey.withOpacity(0.12),
              border: Border.all(
                color: isActive
                    ? const Color(0xFF7C4DFF)
                    : Colors.grey.withOpacity(0.25),
                width: 1.2,
              ),
            ),
            child: Icon(
              Icons.bedtime_rounded,
              size: 24,
              color: isActive
                  ? const Color(0xFF7C4DFF)
                  : cs.onSurfaceVariant.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isActive ? _formatSleepRemaining(_sleepRemainingSeconds) : 'Sleep',
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  String _formatSleepRemaining(int totalSeconds) {
    if (totalSeconds <= 0) return 'Sleep';
    final minutes = (totalSeconds / 60).ceil();
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final remMins = minutes % 60;
      if (remMins == 0) return '${hours}h';
      return '${hours}h ${remMins}m';
    }
    return '${minutes}m';
  }

  Future<void> _showSleepTimerSheet() async {
    HapticFeedback.selectionClick();
    final options = <int>[15, 30, 45, 60, 90];
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sleep timer',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final mins in options)
                      ActionChip(
                        label: Text('$mins min'),
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await widget.audioHandler.setSleepTimer(
                            Duration(minutes: mins),
                          );
                          _syncSleepTimerStateFromHandler();
                        },
                      ),
                  ],
                ),
                if (_sleepTimerActive) ...[
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await widget.audioHandler.cancelSleepTimer();
                      _syncSleepTimerStateFromHandler();
                    },
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Cancel sleep timer'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Locked control button ──────────────────────────────────────────────────
class _ControlButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final bool locked;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.size,
    required this.locked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: locked ? 0.28 : 1.0,
      child: IconButton(
        icon: Icon(icon, size: size),
        onPressed: locked ? null : onTap,
      ),
    );
  }
}

// ── Blinking dot ──────────────────────────────────────────────────────────────
class _BlinkingDot extends StatefulWidget {
  @override
  State<_BlinkingDot> createState() => _BlinkingDotState();
}

class _BlinkingDotState extends State<_BlinkingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _ctrl,
      child: Container(
        width: 7,
        height: 7,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red,
        ),
      ),
    );
  }
}
