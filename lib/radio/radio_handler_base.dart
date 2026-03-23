// radio_handler_base.dart
import 'package:audio_service/audio_service.dart';
import 'package:grradio/radio/radiostation.dart';

abstract class RadioHandlerBase {
  void setStations(List<RadioStation> stations);
  Future<void> playStation(RadioStation station);
  Future<void> stop();
  Future<void> toggleRecord(MediaItem? mediaItem);
  bool get isRecording;
  Future<void> toggleShuffle();
  Future<void> cycleRepeatMode();
  Future<void> setSleepTimer(Duration duration);
  Future<void> cancelSleepTimer();
  Duration? getSleepTimerRemaining();
}
