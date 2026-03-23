import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grradio/api/analytics_service_api.dart';
import 'package:grradio/main.dart';
import 'package:grradio/radio/radiostation.dart';

class StationCategoryScreen extends StatelessWidget {
  final String title;
  final List<RadioStation> stations;
  final dynamic audioHandler;

  StationCategoryScreen({
    Key? key,
    required this.title,
    required this.stations,
    required this.audioHandler,
  }) : super(key: key);

  final AnalyticsServiceAPI _analyticsService = AnalyticsServiceAPI();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0.95, end: 1.05),
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOut,
        builder: (context, double scale, child) {
          return Transform.scale(scale: scale, child: child);
        },
        child: FloatingActionButton.extended(
          // FIX: Pass the context to the shuffle function
          onPressed: () => _shuffleAndPlay(context, stations),
          icon: const Icon(Icons.shuffle, color: Colors.white),
          label: const Text(
            "SHUFFLE PLAY",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          backgroundColor: const Color(0xFF7C4DFF),
          elevation: 8,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: StreamBuilder<MediaItem?>(
        stream: audioHandler.mediaItem,
        builder: (context, snapshot) {
          final currentMediaId = snapshot.data?.id;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 120.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF7C4DFF), Color(0xFF448AFF)],
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final station = stations[index];
                    // FIXED: This method is now defined below
                    return _buildDiscoveryGridCard(
                      context,
                      station,
                      currentMediaId,
                    );
                  }, childCount: stations.length),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
    );
  }

  void _shuffleAndPlay(BuildContext context, List<RadioStation> stations) {
    if (stations.isEmpty) return;

    HapticFeedback.vibrate();

    final shuffledList = List<RadioStation>.from(stations)..shuffle();
    final randomStation = shuffledList.first;

    _analyticsService.logActivity(
      deviceId ?? 'unknown',
      'Shuffle Play Category',
      details: {
        'category': title,
        'stationId': randomStation.id,
        'stationName': randomStation.name,
      },
    );

    // FIX: Use the global variable directly here
    globalRadioAudioHandler.playFromMediaId(randomStation.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("🔀 Shuffling: Playing ${randomStation.name}"),
        backgroundColor: const Color(0xFF7C4DFF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // NEW: Implementation for the Grid Card used in the SliverGrid
  Widget _buildDiscoveryGridCard(
    BuildContext context,
    RadioStation station,
    String? currentId,
  ) {
    final isPlaying = currentId == station.id;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _analyticsService.logActivity(
          deviceId ?? 'unknown',
          'Play Station from Category',
          details: {
            'stationId': station.id,
            'stationName': station.name,
            'category': title,
          },
        );
        globalRadioAudioHandler.playFromMediaId(station.id);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: isPlaying
                        ? const Color(0xFF7C4DFF).withOpacity(0.4)
                        : Colors.black12,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                image: station.logoUrl != null
                    ? DecorationImage(
                        image: NetworkImage(station.logoUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: isPlaying
                    ? Border.all(color: const Color(0xFF7C4DFF), width: 3)
                    : null,
              ),
              child: isPlaying
                  ? const Center(
                      child: Icon(
                        Icons.pause_circle_filled,
                        color: Colors.white,
                        size: 40,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            station.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: isPlaying ? FontWeight.bold : FontWeight.w600,
              color: isPlaying ? const Color(0xFF7C4DFF) : null,
            ),
          ),
          Text(
            station.language ?? "Radio",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
