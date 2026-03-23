import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:grradio/masstamilan/data/massteluguservice.dart';
import 'package:grradio/masstamilan/data/mp3queplayer.dart';
import 'package:grradio/masstamilan/presentation/modernminiplayer.dart';
import 'package:grradio/more/downloadmanagerscreen.dart';
import 'package:path_provider/path_provider.dart';
import '../data/masstelugualbumdetails.dart';

class AlbumDetailsPage extends StatefulWidget {
  final String albumUrl;
  final String language;

  const AlbumDetailsPage({
    super.key,
    required this.albumUrl,
    required this.language,
  });

  @override
  State<AlbumDetailsPage> createState() => _AlbumDetailsPageState();
}

class _AlbumDetailsPageState extends State<AlbumDetailsPage> {
  late Future<AlbumDetails> future;
  String albumArtURL = '';
  String albumName = '';

  final ValueNotifier<Map<String, double>> downloadProgressNotifier =
      ValueNotifier<Map<String, double>>({});

  final ValueNotifier<Map<String, bool>> isDownloadingNotifier =
      ValueNotifier<Map<String, bool>>({});

  final ValueNotifier<Map<String, int>> downloadReceivedNotifier =
      ValueNotifier<Map<String, int>>({});

  final ValueNotifier<Map<String, int>> downloadTotalNotifier =
      ValueNotifier<Map<String, int>>({});

  final Map<String, CancelToken> cancelTokens = {};

  @override
  void initState() {
    super.initState();
    future = AlbumApi().fetchAlbumDetails(widget.albumUrl, widget.language);
  }

  void _cancelDownload(String key) {
    if (cancelTokens.containsKey(key)) {
      cancelTokens[key]!.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Album Details")),
      body: FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final album = snapshot.data!;
          albumArtURL = album.albumArt;
          albumName = album.albumName;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Album Art Card
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          album.albumArt,
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        album.albumName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Movie Info Card
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Movie Information",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _info("Starring", album.starring),
                      _info("Music", album.music),
                      _info("Director", album.director),
                      _info("Lyricists", album.lyricists),
                      _info("Year", album.year),
                      _info("Language", album.language),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Tracks Header
              const Text(
                "Tracks",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Track List
              ...album.tracks.map((t) => _trackTile(context, t)).toList(),
            ],
          );
        },
      ),
      bottomNavigationBar: StreamBuilder<bool>(
        stream: globalMp3QueueServicemini.isVisibleStream,
        builder: (context, visibleSnap) {
          if (visibleSnap.data != true) return const SizedBox();

          return StreamBuilder<bool>(
            stream: globalMp3QueueServicemini.isPlayingStream,
            builder: (context, playingSnap) {
              final isPlayingBool = playingSnap.data ?? false;
              return ModernMiniPlayer(
                title: globalMp3QueueServicemini.currentTitle,
                imageUrl: globalMp3QueueServicemini.currentImage,
                positionStream: globalMp3QueueServicemini.positionStream,
                durationStream: globalMp3QueueServicemini.durationStream,
                onPause: globalMp3QueueServicemini.pause,
                onPlay: globalMp3QueueServicemini.resume,
                onClose: globalMp3QueueServicemini.stop,
                isPlaying: isPlayingBool,
              );
            },
          );
        },
      ),
    );
  }

  Widget _info(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  Widget _trackTile(BuildContext context, Track t) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Track title + play button
            Row(
              children: [
                Expanded(
                  child: Text(
                    "${t.position}. ${t.name}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.play_circle_fill,
                    size: 32,
                    color: Colors.blueAccent,
                  ),
                  onPressed: () {
                    globalMp3QueueServicemini.playTrack(
                      title: t.name,
                      url: t.download320 ?? t.download128!,
                      imageUrl: albumArtURL,
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 4),

            Text(t.singers, style: const TextStyle(fontSize: 14)),
            Text(
              "Duration: ${t.duration}",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),

            const SizedBox(height: 10),

            // Download buttons
            Row(
              children: [
                if (t.download128 != null)
                  ElevatedButton.icon(
                    onPressed: () => _downloadWithManager(
                      url: t.download128!,
                      fileName: '${t.name}_128.mp3',
                      albumName: albumName,
                      coverUrl: albumArtURL,
                    ),
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text("128 kbps"),
                  ),
                const SizedBox(width: 10),
                if (t.download320 != null)
                  ElevatedButton.icon(
                    onPressed: () => _downloadWithManager(
                      url: t.download320!,
                      fileName: '${t.name}_320.mp3',
                      albumName: albumName,
                      coverUrl: albumArtURL,
                    ),
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text("320 kbps"),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadWithManager({
    required String url,
    required String fileName,
    required String albumName,
    required String coverUrl,
  }) async {
    final downloadKey = '${url.hashCode}-$fileName';

    // Prevent duplicate downloads
    if (isDownloadingNotifier.value[downloadKey] == true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Download already in progress")));
      return;
    }

    // Initialize state (new maps so ValueNotifier listeners fire)
    isDownloadingNotifier.value = {
      ...isDownloadingNotifier.value,
      downloadKey: true,
    };
    downloadProgressNotifier.value = {
      ...downloadProgressNotifier.value,
      downloadKey: 0.0,
    };

    // Open download manager screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DownloadManagerScreen(
          downloadProgressNotifier: downloadProgressNotifier,
          isDownloadingNotifier: isDownloadingNotifier,
          downloadReceivedNotifier: downloadReceivedNotifier,
          downloadTotalNotifier: downloadTotalNotifier,
          onCancel: _cancelDownload,
        ),
      ),
    );

    try {
      final directory = await getApplicationDocumentsDirectory();
      final musicDir = Directory('${directory.path}/Music');
      if (!await musicDir.exists()) {
        await musicDir.create(recursive: true);
      }

      String safeName = fileName.endsWith('.mp3') ? fileName : '$fileName.mp3';
      safeName = safeName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');

      final filePath = '${musicDir.path}/$safeName';
      final file = File(filePath);

      if (await file.exists()) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("File already exists")));
        return;
      }

      final dio = Dio();
      final cancelToken = CancelToken();
      cancelTokens[downloadKey] = cancelToken;

      await dio.download(
        url,
        filePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final progress = (received / total) * 100;

            downloadProgressNotifier.value = {
              ...downloadProgressNotifier.value,
              downloadKey: progress,
            };
            downloadReceivedNotifier.value = {
              ...downloadReceivedNotifier.value,
              downloadKey: received,
            };
            downloadTotalNotifier.value = {
              ...downloadTotalNotifier.value,
              downloadKey: total,
            };
          }
        },
        options: Options(
          headers: {
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          },
          receiveTimeout: Duration(minutes: 5),
          followRedirects: true,
          maxRedirects: 5,
        ),
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Download complete")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Download failed: $e")));
    } finally {
      final done = Map<String, bool>.from(isDownloadingNotifier.value)
        ..remove(downloadKey);
      isDownloadingNotifier.value = done;

      final prog = Map<String, double>.from(downloadProgressNotifier.value)
        ..remove(downloadKey);
      downloadProgressNotifier.value = prog;
    }
  }
}
