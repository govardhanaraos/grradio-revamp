import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:grradio/radio/radiostation.dart';

class HorizontalStationList extends StatelessWidget {
  final List<RadioStation> stations;
  final String? currentMediaId;
  final Function(RadioStation) onPlay;
  final Function(RadioStation)? onRemoveFavourite;

  const HorizontalStationList({
    Key? key,
    required this.stations,
    required this.currentMediaId,
    required this.onPlay,
    this.onRemoveFavourite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
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
                  Stack(
                    children: [
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
                      if (onRemoveFavourite != null)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              onRemoveFavourite!(station);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.remove,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    station.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight:
                          isPlaying ? FontWeight.w700 : FontWeight.w600,
                      color: isPlaying ? const Color(0xFF7C4DFF) : onSurface,
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
