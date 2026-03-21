import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grradio/util/screens/musicvisualizer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../main.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  ExpandedPlayerContent
//
//  Enhancements:
//   • Share button — shares current station name + stream URL via system sheet.
//   • ICY/track metadata row — shows currently-playing song title from the
//     mediaItem extras map (key: "icy_title") when available.
//   • Haptic feedback on record toggle and play/pause.
//   • Record button ONLY shown for radio stations (album == "Live Radio").
//   • Skip / Play-Pause controls fully locked (dimmed + null) while recording.
//   • Polished art container: gradient fallback, rounded shadow, Hero tag.
//   • "Stop recording to switch stations" hint below controls when locked.
// ─────────────────────────────────────────────────────────────────────────────

class ExpandedPlayerContent extends StatefulWidget {
  final MediaItem? mediaItem;
  final bool isPlaying;
  final dynamic audioHandler;
  final Function(bool)? onRecordingStatusChanged;
  final PanelController? pc;
  final VoidCallback? onNavigateToRecordings;

  const ExpandedPlayerContent({
    Key? key,
    required this.mediaItem,
    required this.isPlaying,
    required this.audioHandler,
    this.onRecordingStatusChanged,
    this.pc,
    this.onNavigateToRecordings,
  }) : super(key: key);

  @override
  State<ExpandedPlayerContent> createState() => _ExpandedPlayerContentState();
}

class _ExpandedPlayerContentState extends State<ExpandedPlayerContent>
    with TickerProviderStateMixin {
  // ── Recording state — driven entirely by the handler's customEvent ────────
  bool _isRecording = false;
  int _recordSeconds = 0;
  Timer? _recordTimer; // counts display seconds locally
  StreamSubscription? _customEventSub; // listens to handler events

  // ── Playback progress (local files only — music / download / recording) ────
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  Timer? _progressTimer; // polls position every 500 ms
  StreamSubscription? _mediaItemSub; // watches duration from mediaItem

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseScale;
  late Animation<double> _pulseOpacity;

  // ── Share button scale animation ──────────────────────────────────────────
  late AnimationController _shareBounceCtrl;
  late Animation<double> _shareBounce;

  bool _shuffleEnabled = false;
  String _repeatMode = 'LoopMode.off';
  StreamSubscription<Duration>? _positionSub;
  // ─────────────────────────────────────────────────────────────────────────
  // True for live radio stations; false only when album is explicitly 'Local Files'.
  // Defaults to true (show record) when album is null/empty so the button is
  // never accidentally hidden due to a missing album tag.
  bool get _isRadioStation {
    final album = widget.mediaItem?.album ?? '';
    if (album == 'Local Files') return false;
    return true; // 'Live Radio' or unknown → show record
  }

  /// ICY track title from the mediaItem extras, if the handler populates it.
  String? get _icyTitle {
    final extras = widget.mediaItem?.extras;
    if (extras == null) return null;
    final raw = extras['icy_title'];
    if (raw == null || raw.toString().trim().isEmpty) return null;
    return raw.toString().trim();
  }

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseScale = Tween<double>(
      begin: 1.0,
      end: 1.6,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut));
    _pulseOpacity = Tween<double>(
      begin: 0.55,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut));

    _shareBounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _shareBounce = Tween<double>(
      begin: 1.0,
      end: 0.82,
    ).animate(CurvedAnimation(parent: _shareBounceCtrl, curve: Curves.easeOut));

    // ── Progress bar: poll position every 500 ms + watch duration ────────────
    _startProgressTimer();
    _mediaItemSub = widget.audioHandler.mediaItem.listen((mi) {
      if (!mounted) return;
      final dur = (mi as MediaItem?)?.duration ?? Duration.zero;
      if (dur != _duration) setState(() => _duration = dur);
    });
    _positionSub = globalRadioAudioHandler.positionStream.listen((pos) {
      if (mounted) setState(() => _position = pos);
    });
    _customEventSub = widget.audioHandler.customEvent.listen((event) {
      if (event is Map) {
        if (event['event'] == 'shuffle_changed') {
          setState(() {
            _shuffleEnabled = event['enabled'] as bool;
          });
        } else if (event['event'] == 'repeat_changed') {
          setState(() {
            _repeatMode = event['mode'] as String;
          });
        }
      }
    });
    // ── Listen to handler events so UI stays in sync with actual recording state
    _customEventSub = widget.audioHandler.customEvent.listen((event) {
      if (event is Map && event['event'] == 'record_status') {
        final isRec = event['isRecording'] as bool? ?? false;
        if (!mounted) return;
        setState(() => _isRecording = isRec);

        if (isRec) {
          // Recording just started
          _pulseCtrl.repeat();
          _recordSeconds = 0;
          _recordTimer?.cancel();
          _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
            if (mounted) setState(() => _recordSeconds++);
          });
        } else {
          // Recording stopped
          _pulseCtrl.stop();
          _pulseCtrl.reset();
          _recordTimer?.cancel();
        }

        widget.onRecordingStatusChanged?.call(isRec);
      } else if (event is Map && event['event'] == 'permission_denied') {
        if (!mounted) return;
        final msg = event['message'] as String? ?? 'Permission denied';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _customEventSub?.cancel();
    _mediaItemSub?.cancel();
    _positionSub?.cancel();
    _pulseCtrl.dispose();
    _recordTimer?.cancel();
    _shareBounceCtrl.dispose();
    super.dispose();
  }

  // ── Toggle recording — delegates to RadioHandlerImpl.toggleRecord ────────
  // The handler owns the recording lifecycle (permission check, file I/O,
  // start/stop). It broadcasts 'record_status' via customEvent, which the
  // _customEventSub listener above picks up to update UI state.
  void _toggleRecording() {
    HapticFeedback.mediumImpact();
    widget.audioHandler.toggleRecord(widget.mediaItem);
  }

  void _goToRecordings() {
    widget.pc?.close();
    widget.onNavigateToRecordings?.call();
  }

  // ── Share current station ─────────────────────────────────────────────────
  Future<void> _shareStation() async {
    HapticFeedback.lightImpact();
    _shareBounceCtrl.forward().then((_) => _shareBounceCtrl.reverse());

    final item = widget.mediaItem;
    if (item == null) return;

    final streamUrl = item.extras?['stream_url'] as String? ?? '';
    final text = streamUrl.isNotEmpty
        ? '🎙️ Listening to ${item.title} on GR Radio!\n$streamUrl'
        : '🎙️ Listening to ${item.title} on GR Radio!';

    await Share.share(text, subject: 'Check out ${item.title}');
  }

  void _onPlayPause() {
    if (_isRecording) return;
    HapticFeedback.lightImpact();
    widget.isPlaying ? widget.audioHandler.pause() : widget.audioHandler.play();
  }

  void _onSkipPrevious() {
    if (_isRecording) return;
    HapticFeedback.selectionClick();
    widget.audioHandler.skipToPrevious();
  }

  void _onSkipNext() {
    if (_isRecording) return;
    HapticFeedback.selectionClick();
    widget.audioHandler.skipToNext();
  }

  // ── Progress timer — polls playbackState.position every 500 ms ───────────
  void _startProgressTimer() {
    _progressTimer?.cancel();
  }

  // ── Progress helpers ──────────────────────────────────────────────────────
  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '${h.toString().padLeft(2, '0')}:$m:$s' : '$m:$s';
  }

  double get _progressValue {
    if (_duration.inMilliseconds <= 0) return 0.0;
    return (_position.inMilliseconds / _duration.inMilliseconds).clamp(
      0.0,
      1.0,
    );
  }

  void _onSeek(double value) {
    if (_duration.inMilliseconds <= 0) return;
    widget.audioHandler.seek(
      Duration(milliseconds: (value * _duration.inMilliseconds).round()),
    );
  }

  String get _timerLabel {
    final m = (_recordSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_recordSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final artSize = screenWidth * 0.72;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12),

            // ── Drag handle ──────────────────────────────────────────────
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.35),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),

            // ── Header row: close chevron + share ────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Down chevron to collapse
                  GestureDetector(
                    onTap: () => widget.pc?.close(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.07)
                            : Colors.black.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 24,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ),

                  // NOW PLAYING label
                  Column(
                    children: [
                      Text(
                        _isRadioStation ? 'LIVE RADIO' : 'NOW PLAYING',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: _isRadioStation
                              ? const Color(0xFF7C4DFF)
                              : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),

                  // Share button
                  ScaleTransition(
                    scale: _shareBounce,
                    child: GestureDetector(
                      onTap: _shareStation,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C4DFF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.ios_share_rounded,
                          size: 22,
                          color: Color(0xFF7C4DFF),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // ── Recording status pill ─────────────────────────────────────
            if (_isRecording)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 300),
                builder: (_, v, child) => Opacity(opacity: v, child: child),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade700,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.35),
                        blurRadius: 14,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _BlinkingDot(),
                      const SizedBox(width: 6),
                      const Text(
                        'REC • CONTROLS LOCKED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // 1. Album Art ────────────────────────────────────────────────
            Container(
              width: artSize,
              height: artSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C4DFF).withOpacity(0.28),
                    blurRadius: 40,
                    offset: const Offset(0, 14),
                  ),
                  BoxShadow(
                    color: const Color(0xFF448AFF).withOpacity(0.14),
                    blurRadius: 60,
                    offset: const Offset(0, 20),
                  ),
                ],
                image: widget.mediaItem?.artUri != null
                    ? DecorationImage(
                        image: NetworkImage(
                          widget.mediaItem!.artUri.toString(),
                        ),
                        fit: BoxFit.cover,
                      )
                    : null,
                gradient: widget.mediaItem?.artUri == null
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [const Color(0xFF1A0A3E), const Color(0xFF0D2040)]
                            : [
                                const Color(0xFFF0EEFF),
                                const Color(0xFFE0F0FF),
                              ],
                      )
                    : null,
              ),
              child: widget.mediaItem?.artUri == null
                  ? Center(
                      child: Icon(
                        _isRadioStation ? Icons.radio : Icons.music_note,
                        size: artSize * 0.32,
                        color: const Color(0xFF7C4DFF).withOpacity(0.5),
                      ),
                    )
                  : null,
            ),

            const SizedBox(height: 24),

            // 2. Music Visualizer ─────────────────────────────────────────
            SizedBox(
              height: 52,
              child: MusicVisualizer(isPlaying: widget.isPlaying),
            ),
            const SizedBox(height: 18),

            // 3. Metadata + ICY track title ────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Text(
                widget.mediaItem?.title ?? 'Station Name',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isRadioStation)
                  const Icon(Icons.radio, size: 14, color: Color(0xFF7C4DFF)),
                if (_isRadioStation) const SizedBox(width: 4),
                Text(
                  widget.mediaItem?.artist ?? 'Genre',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF7C4DFF),
                  ),
                ),
              ],
            ),

            // ICY / Now-playing metadata row
            if (_icyTitle != null) ...[
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C4DFF).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF7C4DFF).withOpacity(0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.music_note_rounded,
                      size: 13,
                      color: Color(0xFF7C4DFF),
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        _icyTitle!,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF7C4DFF),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // ── Progress bar + time labels (local files only) ─────────────
            if (!_isRadioStation) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 3.5,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 14,
                        ),
                        activeTrackColor: const Color(0xFF7C4DFF),
                        inactiveTrackColor: const Color(
                          0xFF7C4DFF,
                        ).withOpacity(0.18),
                        thumbColor: const Color(0xFF7C4DFF),
                        overlayColor: const Color(0xFF7C4DFF).withOpacity(0.15),
                      ),
                      child: Slider(
                        value: _progressValue,
                        onChanged: _duration.inMilliseconds > 0
                            ? _onSeek
                            : null,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(_position),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                          Text(
                            _formatDuration(_duration),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ] else
              const SizedBox(height: 30),

            // 4. Playback controls ─────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ControlButton(
                  icon: Icons.skip_previous_rounded,
                  size: 40,
                  locked: _isRecording,
                  onTap: _onSkipPrevious,
                ),
                const SizedBox(width: 18),

                // Main play/pause circle
                GestureDetector(
                  onTap: _onPlayPause,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: _isRecording
                          ? null
                          : const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF7C4DFF), Color(0xFF448AFF)],
                            ),
                      color: _isRecording ? Colors.grey.shade700 : null,
                      boxShadow: _isRecording
                          ? []
                          : [
                              BoxShadow(
                                color: const Color(
                                  0xFF7C4DFF,
                                ).withOpacity(0.45),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                            ],
                    ),
                    child: StreamBuilder<PlaybackState>(
                      stream: globalRadioAudioHandler.playbackState,
                      builder: (context, snapshot) {
                        final state = snapshot.data?.processingState;
                        if (state == AudioProcessingState.loading ||
                            state == AudioProcessingState.buffering) {
                          return const Center(
                            child: SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            ),
                          );
                        }
                        return Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder: (child, anim) =>
                                ScaleTransition(scale: anim, child: child),
                            child: Icon(
                              widget.isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              key: ValueKey(widget.isPlaying),
                              size: 38,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 18),

                _ControlButton(
                  icon: Icons.skip_next_rounded,
                  size: 40,
                  locked: _isRecording,
                  onTap: _onSkipNext,
                ),
              ],
            ),

            if (_isRecording)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  'Stop recording to switch stations',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.red.shade400,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

            const SizedBox(height: 30),

            // 5. Action row: Record + Recordings ──────────────────────────
            //    • Radio station  → Record button + Recordings shortcut
            //    • Local files    → Recordings shortcut only (no Record)
            if (widget.mediaItem != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (_isRadioStation) ...[
                      _buildRecordButton(),
                      Container(
                        width: 1,
                        height: 64,
                        color: Colors.grey.withOpacity(0.18),
                      ),
                      _buildRecordingsButton(),
                    ] else ...[
                      _buildShuffleButton(),
                      Container(
                        width: 1,
                        height: 64,
                        color: Colors.grey.withOpacity(0.18),
                      ),
                      _buildRepeatButton(),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Record toggle ─────────────────────────────────────────────────────────
  Widget _buildRecordButton() {
    return GestureDetector(
      onTap: _toggleRecording,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, __) => SizedBox(
              width: 68,
              height: 68,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_isRecording)
                    Transform.scale(
                      scale: _pulseScale.value,
                      child: Opacity(
                        opacity: _pulseOpacity.value,
                        child: Container(
                          width: 54,
                          height: 54,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeInOut,
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isRecording
                          ? Colors.red
                          : Colors.red.withOpacity(0.09),
                      border: Border.all(
                        color: Colors.red,
                        width: _isRecording ? 0 : 1.8,
                      ),
                    ),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        transitionBuilder: (child, anim) =>
                            ScaleTransition(scale: anim, child: child),
                        child: _isRecording
                            ? const Icon(
                                Icons.stop_rounded,
                                key: ValueKey('stop'),
                                color: Colors.white,
                                size: 26,
                              )
                            : Icon(
                                Icons.mic,
                                key: const ValueKey('mic'),
                                color: Colors.red.shade700,
                                size: 24,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: _isRecording
                ? Row(
                    key: const ValueKey('active'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _BlinkingDot(),
                      const SizedBox(width: 5),
                      Text(
                        _timerLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Text(
                    'Record',
                    key: const ValueKey('idle'),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ── Recordings shortcut ───────────────────────────────────────────────────
  Widget _buildRecordingsButton() {
    return Opacity(
      opacity: _isRecording ? 0.28 : 1.0,
      child: GestureDetector(
        onTap: _isRecording ? null : _goToRecordings,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF7C4DFF).withOpacity(0.09),
                border: Border.all(color: const Color(0xFF7C4DFF), width: 1.8),
              ),
              child: const Center(
                child: Icon(
                  Icons.library_music_rounded,
                  color: Color(0xFF7C4DFF),
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Recordings',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShuffleButton() {
    final isActive = _shuffleEnabled;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        widget.audioHandler.toggleShuffle();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF7C4DFF).withOpacity(0.15)
              : Colors.grey.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? const Color(0xFF7C4DFF)
                : Colors.grey.withOpacity(0.40),
            width: 1.2,
          ),
        ),
        child: Icon(
          Icons.shuffle, // ← ALWAYS use this one
          size: 26,
          color: isActive
              ? const Color(0xFF7C4DFF) // purple when active
              : Colors.white.withOpacity(0.55), // dimmed when inactive
        ),
      ),
    );
  }

  Widget _buildRepeatButton() {
    final mode = _repeatMode; // "LoopMode.off", "LoopMode.one", "LoopMode.all"

    IconData icon;
    bool isActive = mode != 'LoopMode.off';

    if (mode.contains('one')) {
      icon = Icons.repeat_one;
    } else {
      icon = Icons.repeat;
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        widget.audioHandler.cycleRepeatMode();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF7C4DFF).withOpacity(0.15)
              : Colors.grey.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? const Color(0xFF7C4DFF)
                : Colors.grey.withOpacity(0.25),
            width: 1.2,
          ),
        ),
        child: Icon(
          icon,
          size: 26,
          color: isActive
              ? const Color(0xFF7C4DFF)
              : Colors.white.withOpacity(0.65),
        ),
      ),
    );
  }
}

// ── Locked control button ──────────────────────────────────────────────────
class _ControlButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final bool locked;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.size,
    required this.locked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: locked ? 0.28 : 1.0,
      child: IconButton(
        icon: Icon(icon, size: size),
        onPressed: locked ? null : onTap,
      ),
    );
  }
}

// ── Blinking dot ──────────────────────────────────────────────────────────────
class _BlinkingDot extends StatefulWidget {
  @override
  State<_BlinkingDot> createState() => _BlinkingDotState();
}

class _BlinkingDotState extends State<_BlinkingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _ctrl,
      child: Container(
        width: 7,
        height: 7,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red,
        ),
      ),
    );
  }
}
