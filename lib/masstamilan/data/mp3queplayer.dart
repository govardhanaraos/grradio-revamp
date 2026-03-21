import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

class Mp3QueueService {
  final AudioPlayer _player = AudioPlayer();

  final BehaviorSubject<bool> _isVisible = BehaviorSubject.seeded(false);
  final BehaviorSubject<String> _title = BehaviorSubject.seeded("");
  final BehaviorSubject<String> _image = BehaviorSubject.seeded("");

  Stream<bool> get isVisibleStream => _isVisible.stream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<bool> get isPlayingStream => _player.playingStream;

  bool get isPlaying => _player.playing;
  String get currentTitle => _title.value;
  String get currentImage => _image.value;

  Mp3QueueService() {
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        // Track finished
        _player.pause(); // ensures isPlaying becomes false
        _isVisible.add(true); // keep mini-player visible
      }
    });
  }

  Future<void> playTrack({
    required String title,
    required String url,
    required String imageUrl,
  }) async {
    _title.add(title);
    _image.add(imageUrl);
    _isVisible.add(true);

    await _player.setUrl(url);
    await _player.play();
  }

  void pause() => _player.pause();
  void resume() => _player.play();

  void stop() {
    _player.stop();
    _isVisible.add(false);
  }

  Future<void> seek(Duration position) => _player.seek(position);
}

// Global instance
final globalMp3QueueServicemini = Mp3QueueService();
