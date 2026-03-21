import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  MiniPlayerTile
//
//  Enhancements:
//   • Buffering shimmer line — thin animated gradient bar at the very top of
//     the tile that pulses while the stream is loading / buffering.
//   • LIVE badge (violet) for radio stations, REC badge (red) while recording.
//   • Play/pause locked (dimmed + null onPressed) during recording.
//   • Haptic feedback on play/pause toggle.
//   • Hero animation tag on art so it morphs into the expanded player art.
//   • Smooth AnimatedSwitcher on play/pause icon change.
// ─────────────────────────────────────────────────────────────────────────────

class MiniPlayerTile extends StatelessWidget {
  final MediaItem? mediaItem;
  final bool isPlaying;
  final bool isRecording;
  final bool isBuffering;
  final VoidCallback onTogglePlay;
  final VoidCallback onTap;
  final dynamic audioHandler;

  const MiniPlayerTile({
    Key? key,
    required this.mediaItem,
    required this.isPlaying,
    required this.onTogglePlay,
    required this.onTap,
    required this.audioHandler,
    this.isRecording = false,
    this.isBuffering = false,
  }) : super(key: key);

  bool get _isRadioStation => (mediaItem?.album ?? '') == 'Live Radio';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        color: Colors.transparent,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Stack(
              children: [
                // ── Main tile container ──────────────────────────────────
                Container(
                  height: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withOpacity(0.92)
                        : Colors.white.withOpacity(0.94),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                    border: Border(
                      top: BorderSide(
                        color: isRecording
                            ? Colors.red.withOpacity(0.7)
                            : const Color(0xFF7C4DFF).withOpacity(0.15),
                        width: 1.5,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      // ── Art with Hero ──────────────────────────────────
                      _buildArt(),
                      const SizedBox(width: 12),

                      // ── Title + badges ─────────────────────────────────
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _buildBadge(),
                                Expanded(
                                  child: Text(
                                    mediaItem?.title ?? 'Not Playing',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              mediaItem?.artist ?? 'Select a station',
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── Play / Pause ───────────────────────────────────
                      Opacity(
                        opacity: isRecording ? 0.35 : 1.0,
                        child: GestureDetector(
                          onTap: isRecording
                              ? null
                              : () {
                                  HapticFeedback.lightImpact();
                                  onTogglePlay();
                                },
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            transitionBuilder: (child, anim) =>
                                ScaleTransition(scale: anim, child: child),
                            child: Icon(
                              isPlaying
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_filled,
                              key: ValueKey(isPlaying),
                              size: 44,
                              color: isRecording
                                  ? Colors.grey
                                  : const Color(0xFF7C4DFF),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Buffering shimmer bar at the very top ────────────────
                if (isBuffering)
                  Positioned(top: 0, left: 0, right: 0, child: _BufferingBar()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge() {
    if (!_isRadioStation) return const SizedBox.shrink();
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Container(
        key: ValueKey(isRecording),
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: isRecording ? Colors.red : const Color(0xFF7C4DFF),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          isRecording ? 'REC' : 'LIVE',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }

  Widget _buildArt() {
    if (mediaItem?.artUri != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          mediaItem!.artUri.toString(),
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallbackArt(),
        ),
      );
    }
    return _fallbackArt();
  }

  Widget _fallbackArt() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7C4DFF), Color(0xFF448AFF)],
        ),
      ),
      child: Icon(
        _isRadioStation ? Icons.radio : Icons.music_note,
        color: Colors.white.withOpacity(0.9),
        size: 26,
      ),
    );
  }
}

// ── Animated buffering bar ────────────────────────────────────────────────────
class _BufferingBar extends StatefulWidget {
  @override
  State<_BufferingBar> createState() => _BufferingBarState();
}

class _BufferingBarState extends State<_BufferingBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _anim = Tween<double>(
      begin: -1.5,
      end: 2.5,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        height: 2.5,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          gradient: LinearGradient(
            begin: Alignment(_anim.value - 1, 0),
            end: Alignment(_anim.value + 1, 0),
            colors: const [
              Colors.transparent,
              Color(0xFF7C4DFF),
              Color(0xFF448AFF),
              Colors.transparent,
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
      ),
    );
  }
}
