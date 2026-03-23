import 'package:flutter/material.dart';
import 'package:grradio/api/analytics_service_api.dart';
import 'package:grradio/main.dart';

class ModernMiniPlayer extends StatelessWidget {
  final String title;
  final String imageUrl;
  final Stream<Duration> positionStream;
  final Stream<Duration?> durationStream;
  final VoidCallback onPause;
  final VoidCallback onPlay;
  final VoidCallback onClose;
  final bool isPlaying;

  const ModernMiniPlayer({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.positionStream,
    required this.durationStream,
    required this.onPause,
    required this.onPlay,
    required this.onClose,
    required this.isPlaying,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78, // FIXED HEIGHT FOR CLEAN BOTTOM PLAYER
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.92),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: Row(
        children: [
          // Album Art
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              width: 52,
              height: 52,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 12),

          // Title + Progress
          // Title + Progress
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),

                const SizedBox(height: 6),

                StreamBuilder<Duration?>(
                  stream: durationStream,
                  builder: (context, snapDur) {
                    final duration = snapDur.data ?? Duration.zero;

                    return StreamBuilder<Duration>(
                      stream: positionStream,
                      builder: (context, snapPos) {
                        final position = snapPos.data ?? Duration.zero;

                        final progress = duration.inMilliseconds == 0
                            ? 0.0
                            : position.inMilliseconds / duration.inMilliseconds;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Progress bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress.clamp(0.0, 1.0),
                                backgroundColor: Colors.white24,
                                color: Colors.blueAccent,
                                minHeight: 4,
                              ),
                            ),

                            const SizedBox(height: 4),

                            // Time labels
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(position),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  _formatDuration(duration),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Play / Pause
          IconButton(
            icon: Icon(
              isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
              color: Colors.white,
              size: 34,
            ),
            onPressed: () {
              AnalyticsServiceAPI().logActivity(
                deviceId!,
                isPlaying
                    ? "Pause Masstamilan Mini Player"
                    : "Resume Masstamilan Mini Player",
                details: {"title": title},
              );
              isPlaying ? onPause() : onPlay();
            },
          ),

          // Close
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              AnalyticsServiceAPI().logActivity(
                deviceId!,
                "Close Masstamilan Mini Player",
                details: {"title": title},
              );
              onClose();
            },
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
