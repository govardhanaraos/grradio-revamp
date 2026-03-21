import 'package:grradio/radiostation.dart';

import 'radio_handler_base.dart';

class RadioHandlerStub implements RadioHandlerBase {
  @override
  Future<void> playStation(RadioStation station) async {
    throw UnsupportedError("Platform not supported");
  }

  @override
  Future<void> stop() async {}

  @override
  bool get isRecording => false;

  @override
  Future<void> toggleRecord(mediaItem) async {
    throw UnsupportedError("Platform not supported");
  }

  @override
  void setStations(List<RadioStation> stations) {
    // Stub implementation does nothing
  }

  @override
  Future<void> cycleRepeatMode() {
    // TODO: implement cycleRepeatMode
    throw UnimplementedError();
  }

  @override
  Future<void> toggleShuffle() {
    // TODO: implement toggleShuffle
    throw UnimplementedError();
  }
}
