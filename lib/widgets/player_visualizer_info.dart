import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

import '../util/screens/musicvisualizer.dart';

class PlayerVisualizerInfo extends StatelessWidget {
  final MediaItem? mediaItem;
  final bool isPlaying;

  const PlayerVisualizerInfo({
    Key? key,
    this.mediaItem,
    required this.isPlaying,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Album Art
        Container(
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            image: mediaItem?.artUri != null
                ? DecorationImage(
                    image: NetworkImage(mediaItem!.artUri.toString()),
                    fit: BoxFit.cover,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        // Visualizer
        SizedBox(height: 40, child: MusicVisualizer(isPlaying: isPlaying)),
        const SizedBox(height: 20),
        // Title/Artist
        Text(
          mediaItem?.title ?? "Unknown Station",
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          mediaItem?.artist ?? "Radio",
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }
}
