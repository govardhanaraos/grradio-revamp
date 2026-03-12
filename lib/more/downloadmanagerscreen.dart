import 'dart:math';

import 'package:flutter/material.dart';

class DownloadManagerScreen extends StatelessWidget {
  final ValueNotifier<Map<String, double>> downloadProgressNotifier;
  final ValueNotifier<Map<String, bool>> isDownloadingNotifier;
  final ValueNotifier<Map<String, int>> downloadReceivedNotifier;
  final ValueNotifier<Map<String, int>> downloadTotalNotifier;
  final void Function(String) onCancel;

  const DownloadManagerScreen({
    Key? key,
    required this.downloadProgressNotifier,
    required this.isDownloadingNotifier,
    required this.downloadReceivedNotifier,
    required this.downloadTotalNotifier,
    required this.onCancel,
  }) : super(key: key);

  String _formatBytes(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB"];
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(1)) + ' ' + suffixes[i];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Downloads',
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: ValueListenableBuilder<Map<String, double>>(
        valueListenable: downloadProgressNotifier,
        builder: (context, progressMap, _) {
          final entries = progressMap.entries.toList();

          if (entries.isEmpty) {
            return Center(
              child: Text(
                'No active downloads',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              final key = entry.key;
              final progress = entry.value;
              final downloading = isDownloadingNotifier.value[key] ?? false;
              final received = downloadReceivedNotifier.value[key] ?? 0;
              final total = downloadTotalNotifier.value[key] ?? 0;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Icon(
                    downloading ? Icons.downloading : Icons.check_circle,
                    color: downloading
                        ? Theme.of(context).textTheme.bodyLarge!.color
                        : Colors.green,
                  ),
                  title: Text(
                    (key.split('-').length) > 2
                        ? key.substring(key.indexOf('-') + 1, key.length)
                        : key,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LinearProgressIndicator(
                        value: progress > 0 ? progress / 100 : null,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${progress.toStringAsFixed(1)}% '
                        '(${_formatBytes(received)} / ${_formatBytes(total)})',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                      ),
                    ],
                  ),
                  trailing: downloading
                      ? IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          onPressed: () => onCancel(key),
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
