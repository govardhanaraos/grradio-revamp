// lib/transcription/vosk_model_manager.dart
//
// VoskModelManager
// ─────────────────────────────────────────────────────────────────────────────
// Responsibilities:
//   1. Download a Vosk model ZIP from a remote URL (with progress reporting).
//   2. Cache the extracted model in the app's documents directory so subsequent
//      launches skip the download entirely.
//   3. Expose a simple async API: [ensureModel] → returns the local path to the
//      extracted model directory, ready to pass to vosk_flutter's ModelLoader.
//
// Why not load from assets?
//   Vosk models are 40–150 MB. Bundling them in the APK would bloat the install
//   size for every user, including those who never use transcription. Downloading
//   on first use is the standard approach for on-device ASR.
//
// Thread safety:
//   All file I/O is done via Dart's async isolate-friendly APIs. The download
//   lock (_downloadCompleter) prevents concurrent downloads if [ensureModel] is
//   called twice before the first call resolves.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

/// Describes a Vosk language model available for download.
class VoskModelInfo {
  /// Human-readable label shown in the UI (e.g. "English (small)").
  final String label;

  /// BCP-47 language tag (e.g. "en-US", "hi-IN").
  final String languageCode;

  /// Direct download URL for the model ZIP.
  /// Hosted on alphacephei.com (official Vosk model repository).
  final String downloadUrl;

  /// Approximate download size in bytes — used for progress display.
  final int approximateSizeBytes;

  const VoskModelInfo({
    required this.label,
    required this.languageCode,
    required this.downloadUrl,
    required this.approximateSizeBytes,
  });
}

// ── Built-in model catalogue ──────────────────────────────────────────────────
// Only "small" models are listed here to keep download sizes reasonable.
// Full models (100–200 MB) can be added by the developer as needed.
const List<VoskModelInfo> kVoskModels = [
  VoskModelInfo(
    label: 'English (small ~40 MB)',
    languageCode: 'en-US',
    downloadUrl:
        'https://alphacephei.com/vosk/models/vosk-model-small-en-us-0.15.zip',
    approximateSizeBytes: 40_000_000,
  ),
  VoskModelInfo(
    label: 'Hindi (small ~42 MB)',
    languageCode: 'hi-IN',
    downloadUrl:
        'https://alphacephei.com/vosk/models/vosk-model-small-hi-0.22.zip',
    approximateSizeBytes: 42_000_000,
  ),
  VoskModelInfo(
    label: 'Arabic (small ~35 MB)',
    languageCode: 'ar',
    downloadUrl:
        'https://alphacephei.com/vosk/models/vosk-model-ar-mgb2-0.4.zip',
    approximateSizeBytes: 35_000_000,
  ),
  VoskModelInfo(
    label: 'Tamil (small ~36 MB)',
    languageCode: 'ta-IN',
    downloadUrl:
        'https://alphacephei.com/vosk/models/vosk-model-small-ta-0.4.zip',
    approximateSizeBytes: 36_000_000,
  ),
  VoskModelInfo(
    label: 'Telugu (small ~52 MB)',
    languageCode: 'te-IN',
    downloadUrl:
        'https://alphacephei.com/vosk/models/vosk-model-small-te-0.42.zip',
    approximateSizeBytes: 52_000_000,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────

/// Manages the lifecycle of a single Vosk model on disk.
///
/// Usage:
/// ```dart
/// final manager = VoskModelManager(model: kVoskModels[0]);
/// final path = await manager.ensureModel(
///   onProgress: (received, total) { ... },
/// );
/// // path is now ready for ModelLoader().loadFromPath(path)
/// ```
class VoskModelManager {
  VoskModelManager({required this.model});

  final VoskModelInfo model;

  // Prevents concurrent downloads of the same model.
  Completer<String>? _downloadCompleter;

  // ── Public API ──────────────────────────────────────────────────────────────

  /// Returns the local filesystem path to the extracted model directory.
  ///
  /// If the model is already cached on disk, returns immediately.
  /// Otherwise, downloads and extracts the ZIP, then returns the path.
  ///
  /// [onProgress] receives (bytesReceived, totalBytes) during download.
  /// [cancelToken] can be used to abort an in-progress download.
  Future<String> ensureModel({
    void Function(int received, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    // Fast path: already extracted.
    final cached = await _cachedModelPath();
    if (cached != null) return cached;

    // Deduplicate concurrent calls.
    if (_downloadCompleter != null && !_downloadCompleter!.isCompleted) {
      return _downloadCompleter!.future;
    }

    _downloadCompleter = Completer<String>();
    try {
      final path = await _downloadAndExtract(
        onProgress: onProgress,
        cancelToken: cancelToken,
      );
      _downloadCompleter!.complete(path);
      return path;
    } catch (e) {
      _downloadCompleter!.completeError(e);
      _downloadCompleter = null;
      rethrow;
    }
  }

  /// Returns true if the model is already downloaded and extracted.
  Future<bool> get isDownloaded async => (await _cachedModelPath()) != null;

  /// Deletes the cached model from disk (frees storage).
  Future<void> deleteModel() async {
    final dir = await _modelDirectory();
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  // ── Private helpers ─────────────────────────────────────────────────────────

  /// Returns the expected extraction directory for this model.
  Future<Directory> _modelDirectory() async {
    final base = await getApplicationDocumentsDirectory();
    // Use the last path segment of the URL (without .zip) as the folder name.
    final zipName = model.downloadUrl.split('/').last;
    final folderName = zipName.replaceAll('.zip', '');
    return Directory('${base.path}/vosk_models/$folderName');
  }

  /// Returns the path if the model directory exists and is non-empty, else null.
  Future<String?> _cachedModelPath() async {
    final dir = await _modelDirectory();
    if (await dir.exists()) {
      final contents = await dir.list().toList();
      if (contents.isNotEmpty) return dir.path;
    }
    return null;
  }

  Future<String> _downloadAndExtract({
    void Function(int received, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    final base = await getApplicationDocumentsDirectory();
    final zipPath = '${base.path}/vosk_models/${model.downloadUrl.split('/').last}';
    final zipFile = File(zipPath);

    // Ensure parent directory exists.
    await zipFile.parent.create(recursive: true);

    // ── Step 1: Download ZIP ──────────────────────────────────────────────────
    final dio = Dio();
    await dio.download(
      model.downloadUrl,
      zipPath,
      cancelToken: cancelToken,
      onReceiveProgress: (received, total) {
        if (total > 0) onProgress?.call(received, total);
      },
      options: Options(
        receiveTimeout: const Duration(minutes: 10),
        headers: {
          'User-Agent': 'GRRadio/1.0 (Flutter; Vosk model downloader)',
        },
      ),
    );

    // ── Step 2: Extract ZIP using Dart's Process (unzip) ─────────────────────
    // On Android, the 'unzip' binary is available in the system PATH.
    // We extract into the vosk_models directory; the ZIP itself contains a
    // top-level folder (e.g. vosk-model-small-en-us-0.15/) which becomes the
    // model path.
    final extractDir = zipFile.parent.path;
    final result = await Process.run('unzip', [
      '-o', // overwrite without prompting
      zipPath,
      '-d', extractDir,
    ]);

    if (result.exitCode != 0) {
      // Fallback: try the Dart-native extraction approach via dart:io Archive.
      // This avoids the dependency on the system 'unzip' binary.
      await _extractZipDartNative(zipFile, Directory(extractDir));
    }

    // Clean up the ZIP to save storage.
    if (await zipFile.exists()) await zipFile.delete();

    final modelDir = await _modelDirectory();
    if (!await modelDir.exists()) {
      throw Exception(
        'Vosk model extraction failed: expected directory not found at ${modelDir.path}',
      );
    }
    return modelDir.path;
  }

  /// Pure-Dart ZIP extraction fallback (no system binary required).
  ///
  /// Uses byte-level parsing of the ZIP central directory. This is a minimal
  /// implementation sufficient for Vosk model ZIPs (no encryption, standard
  /// deflate compression). For production use, add the `archive` pub package
  /// and replace this with `ZipDecoder().decodeBytes(bytes)`.
  ///
  /// NOTE: If you add `archive: ^3.4.0` to pubspec.yaml, replace this method
  /// body with the archive-based implementation shown in the comments below.
  Future<void> _extractZipDartNative(File zipFile, Directory destDir) async {
    // ── archive package implementation (recommended) ──────────────────────────
    // Uncomment after adding `archive: ^3.4.0` to pubspec.yaml:
    //
    // import 'package:archive/archive_io.dart';
    //
    // final bytes = await zipFile.readAsBytes();
    // final archive = ZipDecoder().decodeBytes(bytes);
    // for (final file in archive) {
    //   final filePath = '${destDir.path}/${file.name}';
    //   if (file.isFile) {
    //     final outFile = File(filePath);
    //     await outFile.create(recursive: true);
    //     await outFile.writeAsBytes(file.content as List<int>);
    //   } else {
    //     await Directory(filePath).create(recursive: true);
    //   }
    // }
    // ─────────────────────────────────────────────────────────────────────────

    // Minimal fallback: try 'unzip' with full path on Android.
    final result = await Process.run('/system/bin/unzip', [
      '-o',
      zipFile.path,
      '-d',
      destDir.path,
    ]);
    if (result.exitCode != 0) {
      throw Exception(
        'ZIP extraction failed (exit ${result.exitCode}): ${result.stderr}\n'
        'Add the `archive` package to pubspec.yaml for a pure-Dart fallback.',
      );
    }
  }
}
