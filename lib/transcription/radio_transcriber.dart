import 'dart:async';
import 'dart:convert'; // Added for jsonDecode
import 'dart:io';

// ffmpeg_kit_flutter_audio removed — package discontinued (archived 2025).
// We now use Dart's built-in Process API to invoke system ffmpeg if available.
import 'package:vosk_flutter/vosk_flutter.dart';

import 'vosk_model_manager.dart';

class RadioTranscriber {
  RadioTranscriber(this._modelInfo);

  final VoskModelInfo _modelInfo;

  VoskModelManager? _manager;
  Model? _model;
  Recognizer? _recognizer;

  Process? _ffmpegProcess;
  bool _isRunning = false;

  final VoskFlutterPlugin _vosk =
      VoskFlutterPlugin.instance(); // Use plugin instance

  final _transcriptController =
      StreamController<TranscriptionChunk>.broadcast();

  Stream<TranscriptionChunk> get transcriptStream =>
      _transcriptController.stream;

  Future<void> _ensureModelLoaded() async {
    _manager ??= VoskModelManager(model: _modelInfo);
    final path = await _manager!.ensureModel();

    // Models must be created via the Vosk plugin instance
    _model ??= await _vosk.createModel(path);
  }

  Future<void> start(String streamUrl) async {
    if (_isRunning) return;
    _isRunning = true;

    await _ensureModelLoaded();

    // Recognizers must be created via the Vosk plugin instance
    _recognizer = await _vosk.createRecognizer(
      model: _model!,
      sampleRate: 16000,
    );

    final tmpDir = await Directory.systemTemp.createTemp('grradio_vosk_');
    final pcmFile = File('${tmpDir.path}/stream.pcm');
    if (await pcmFile.exists()) await pcmFile.delete();

    final args = [
      '-i', streamUrl,
      '-vn',
      '-acodec', 'pcm_s16le',
      '-ac', '1',
      '-ar', '16000',
      '-f', 's16le',
      pcmFile.path,
    ];

    try {
      // Use system ffmpeg process instead of ffmpeg_kit_flutter_audio
      _ffmpegProcess = await Process.start('ffmpeg', args);
      _ffmpegProcess!.exitCode.then((_) => _isRunning = false);
    } catch (e) {
      // ffmpeg not available on device — transcription disabled gracefully
      _isRunning = false;
      return;
    }

    _pumpPcmToRecognizer(pcmFile);
  }

  Future<void> _pumpPcmToRecognizer(File pcmFile) async {
    int offset = 0;

    while (_isRunning) {
      if (!await pcmFile.exists()) {
        await Future.delayed(const Duration(milliseconds: 200));
        continue;
      }

      final length = await pcmFile.length();
      if (length <= offset) {
        await Future.delayed(const Duration(milliseconds: 200));
        continue;
      }

      final raf = await pcmFile.open();
      await raf.setPosition(offset);
      final bytes = await raf.read(length - offset);
      await raf.close();
      offset = length;

      // acceptWaveformBytes is asynchronous and expects a Uint8List
      final ok = await _recognizer!.acceptWaveformBytes(bytes);

      if (ok) {
        // Must await the result.
        // Note: Switched getFinalResult() to getResult() here as it is the standard
        // Vosk method for completed chunks mid-stream.
        final json = await _recognizer!.getResult();
        if (json.isNotEmpty) {
          final text = _extractText(json);
          if (text.isNotEmpty) {
            _transcriptController.add(
              TranscriptionChunk(text: text, isFinal: true),
            );
          }
        }
      } else {
        // Must await the partial result
        final json = await _recognizer!.getPartialResult();
        final text = _extractText(json);
        if (text.isNotEmpty) {
          _transcriptController.add(
            TranscriptionChunk(text: text, isFinal: false),
          );
        }
      }
    }
  }

  /// Extract "text" field from Vosk JSON
  String _extractText(String json) {
    try {
      final map = jsonDecode(json);
      // Depending on ok state, the key might be 'text' or 'partial'
      return map['text']?.toString() ?? map['partial']?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }

  Future<void> stop() async {
    _isRunning = false;
    try {
      _ffmpegProcess?.kill();
      _ffmpegProcess = null;
    } catch (_) {}

    _recognizer?.dispose();
    _recognizer = null;
  }

  Future<void> dispose() async {
    await stop();
    await _transcriptController.close();
    _model = null;
  }
}

class TranscriptionChunk {
  final String text;
  final bool isFinal;

  TranscriptionChunk({required this.text, required this.isFinal});
}
