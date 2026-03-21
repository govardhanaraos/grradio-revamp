import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../radiostation.dart';

class HorizontalStationList extends StatelessWidget {
  final List<RadioStation> stations;
  final String? currentMediaId;
  final Function(RadioStation) onPlay;

  const HorizontalStationList({
    Key? key,
    required this.stations,
    required this.currentMediaId,
    required this.onPlay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(right: 16),
        itemCount: stations.length,
        itemBuilder: (context, index) {
          final station = stations[index];
          final isPlaying = currentMediaId == station.id;
          final hasLogo =
              station.logoUrl != null && station.logoUrl!.isNotEmpty;

          return Container(
            width: 140,
            margin: const EdgeInsets.only(left: 16),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onPlay(station);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Art card ────────────────────────────────────────────
                  Container(
                    height: 140,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: isPlaying
                              ? const Color(0xFF7C4DFF).withOpacity(0.3)
                              : Colors.black12,
                          blurRadius: 8,
                        ),
                      ],
                      border: isPlaying
                          ? Border.all(color: const Color(0xFF7C4DFF), width: 2)
                          : null,
                      // Solid background — shown while loading or as fallback
                      color: const Color(0xFF7C4DFF).withOpacity(0.08),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        isPlaying ? 18 : 20,
                      ), // compensate for border
                      child: hasLogo
                          ? Image.network(
                              station.logoUrl!,
                              width: 140,
                              height: 140,
                              fit: BoxFit.cover,
                              // Shimmer-style placeholder while loading
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      width: 140,
                                      height: 140,
                                      color: const Color(
                                        0xFF7C4DFF,
                                      ).withOpacity(0.08),
                                      child: const Center(
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Color(0xFF7C4DFF),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                              // Fallback icon if URL is broken/404
                              errorBuilder: (context, error, stackTrace) =>
                                  const SizedBox(
                                    width: 140,
                                    height: 140,
                                    child: Icon(
                                      Icons.radio,
                                      color: Color(0xFF7C4DFF),
                                      size: 40,
                                    ),
                                  ),
                            )
                          // No URL at all — show fallback icon immediately
                          : const SizedBox(
                              width: 140,
                              height: 140,
                              child: Icon(
                                Icons.radio,
                                color: Color(0xFF7C4DFF),
                                size: 40,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    station.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: isPlaying
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
