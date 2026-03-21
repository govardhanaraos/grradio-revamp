import 'package:flutter/material.dart';
import 'dart:math' as math;

// ─────────────────────────────────────────────
//  Radio App Animated Icons
//  Day & Night theme support
//  Usage: RadioAnimatedIcons(isDark: true/false)
// ─────────────────────────────────────────────

// ── Theme palette ──────────────────────────────
class RadioIconTheme {
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color surface;

  const RadioIconTheme({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.surface,
  });

  static const day = RadioIconTheme(
    primary: Color(0xFF1A73E8),
    secondary: Color(0xFF5C35CC),
    accent: Color(0xFFFF6B35),
    surface: Color(0xFFF5F5F5),
  );

  static const night = RadioIconTheme(
    primary: Color(0xFF82B1FF),
    secondary: Color(0xFFCE93D8),
    accent: Color(0xFFFFCC80),
    surface: Color(0xFF1E1E2E),
  );
}

// ═══════════════════════════════════════════════
//  1. EQUALIZER  — bouncing bars
// ═══════════════════════════════════════════════
class EqualizerIcon extends StatefulWidget {
  final bool isDark;
  final double size;
  final bool isPlaying;
  const EqualizerIcon({super.key, this.isDark = false, this.size = 48, this.isPlaying = true});

  @override
  State<EqualizerIcon> createState() => _EqualizerIconState();
}

class _EqualizerIconState extends State<EqualizerIcon> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _anims;

  final List<Duration> _durations = [
    const Duration(milliseconds: 900),
    const Duration(milliseconds: 700),
    const Duration(milliseconds: 1100),
    const Duration(milliseconds: 800),
    const Duration(milliseconds: 1000),
  ];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(5, (i) => AnimationController(vsync: this, duration: _durations[i]));
    _anims = _controllers.map((c) => Tween<double>(begin: 0.15, end: 1.0)
        .animate(CurvedAnimation(parent: c, curve: Curves.easeInOut))).toList();
    if (widget.isPlaying) {
      for (var i = 0; i < _controllers.length; i++) {
        Future.delayed(Duration(milliseconds: i * 80), () {
          if (mounted) _controllers[i].repeat(reverse: true);
        });
      }
    }
  }

  @override
  void didUpdateWidget(EqualizerIcon old) {
    super.didUpdateWidget(old);
    if (widget.isPlaying != old.isPlaying) {
      if (widget.isPlaying) {
        for (var c in _controllers) c.repeat(reverse: true);
      } else {
        for (var c in _controllers) c.stop();
      }
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.isDark ? RadioIconTheme.night : RadioIconTheme.day;
    return AnimatedBuilder(
      animation: Listenable.merge(_controllers),
      builder: (_, __) => CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _EqualizerPainter(_anims.map((a) => a.value).toList(), theme),
      ),
    );
  }
}

class _EqualizerPainter extends CustomPainter {
  final List<double> values;
  final RadioIconTheme theme;
  _EqualizerPainter(this.values, this.theme);

  @override
  void paint(Canvas canvas, Size size) {
    final barW = size.width / 9;
    final maxH = size.height * 0.85;
    final colors = [
      theme.primary,
      theme.secondary,
      theme.accent,
      theme.secondary,
      theme.primary,
    ];
    for (var i = 0; i < 5; i++) {
      final x = barW + i * (barW + barW * 0.6);
      final h = maxH * values[i];
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.fill;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, size.height - h, barW, h),
        const Radius.circular(3),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(_EqualizerPainter old) => old.values != values;
}

// ═══════════════════════════════════════════════
//  2. PLAY / PAUSE  — morphing icon
// ═══════════════════════════════════════════════
class PlayPauseIcon extends StatefulWidget {
  final bool isDark;
  final double size;
  final bool isPlaying;
  final VoidCallback? onTap;
  const PlayPauseIcon({super.key, this.isDark = false, this.size = 56, this.isPlaying = false, this.onTap});

  @override
  State<PlayPauseIcon> createState() => _PlayPauseIconState();
}

class _PlayPauseIconState extends State<PlayPauseIcon> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    if (widget.isPlaying) _ctrl.value = 1.0;
  }

  @override
  void didUpdateWidget(PlayPauseIcon old) {
    super.didUpdateWidget(old);
    if (widget.isPlaying != old.isPlaying) {
      widget.isPlaying ? _ctrl.forward() : _ctrl.reverse();
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final theme = widget.isDark ? RadioIconTheme.night : RadioIconTheme.day;
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, __) => CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _PlayPausePainter(_anim.value, theme),
        ),
      ),
    );
  }
}

class _PlayPausePainter extends CustomPainter {
  final double t; // 0 = play, 1 = pause
  final RadioIconTheme theme;
  _PlayPausePainter(this.t, this.theme);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.46;
    // Circle background
    canvas.drawCircle(Offset(cx, cy), r,
        Paint()..color = theme.primary.withOpacity(0.15));
    canvas.drawCircle(Offset(cx, cy), r,
        Paint()..color = theme.primary..style = PaintingStyle.stroke..strokeWidth = 2);

    final paint = Paint()..color = theme.primary..style = PaintingStyle.fill;

    // Lerp between play triangle and pause bars
    final barW = size.width * 0.09;
    final barH = size.height * 0.38;
    final barY = cy - barH / 2;
    final gap = size.width * 0.07;

    // Left shape: lerp from play-left to pause-left-bar
    final playLeft = [
      Offset(cx - size.width * 0.18, cy - size.height * 0.23),
      Offset(cx + size.width * 0.22, cy),
      Offset(cx - size.width * 0.18, cy + size.height * 0.23),
    ];
    final pauseLeft = [
      Offset(cx - gap - barW, barY),
      Offset(cx - gap, barY),
      Offset(cx - gap, barY + barH),
    ];
    final pauseLeft4 = [
      Offset(cx - gap - barW, barY),
      Offset(cx - gap, barY),
      Offset(cx - gap, barY + barH),
      Offset(cx - gap - barW, barY + barH),
    ];

    if (t < 0.5) {
      // Draw triangle morphing to left bar
      final path = Path()
        ..moveTo(_lerp(playLeft[0].dx, pauseLeft[0].dx, t * 2),
                 _lerp(playLeft[0].dy, pauseLeft[0].dy, t * 2))
        ..lineTo(_lerp(playLeft[1].dx, pauseLeft[1].dx, t * 2),
                 _lerp(playLeft[1].dy, pauseLeft[1].dy, t * 2))
        ..lineTo(_lerp(playLeft[2].dx, pauseLeft4[2].dx, t * 2),
                 _lerp(playLeft[2].dy, pauseLeft4[2].dy, t * 2))
        ..close();
      canvas.drawPath(path, paint);
    } else {
      // Full pause bars
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(cx - gap - barW, barY, barW, barH), const Radius.circular(3)),
        paint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(cx + gap * _lerp(3, 0, (t - 0.5) * 2), barY, barW * _lerp(0.1, 1, (t - 0.5) * 2), barH), const Radius.circular(3)),
        paint,
      );
    }
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t.clamp(0.0, 1.0);

  @override
  bool shouldRepaint(_PlayPausePainter old) => old.t != t;
}

// ═══════════════════════════════════════════════
//  3. SIGNAL / WIFI WAVES  — staggered pulse
// ═══════════════════════════════════════════════
class SignalIcon extends StatefulWidget {
  final bool isDark;
  final double size;
  const SignalIcon({super.key, this.isDark = false, this.size = 48});

  @override
  State<SignalIcon> createState() => _SignalIconState();
}

class _SignalIconState extends State<SignalIcon> with TickerProviderStateMixin {
  late List<AnimationController> _ctrls;
  late List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(3, (_) => AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1600)));
    _anims = _ctrls.map((c) => Tween<double>(begin: 0.1, end: 1.0)
        .animate(CurvedAnimation(parent: c, curve: Curves.easeInOut))).toList();
    for (var i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 300), () {
        if (mounted) _ctrls[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() { for (var c in _ctrls) c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final theme = widget.isDark ? RadioIconTheme.night : RadioIconTheme.day;
    return AnimatedBuilder(
      animation: Listenable.merge(_ctrls),
      builder: (_, __) => CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _SignalPainter(_anims.map((a) => a.value).toList(), theme),
      ),
    );
  }
}

class _SignalPainter extends CustomPainter {
  final List<double> values;
  final RadioIconTheme theme;
  _SignalPainter(this.values, this.theme);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.72;
    final dot = size.width * 0.07;
    // Dot
    canvas.drawCircle(Offset(cx, cy), dot, Paint()..color = theme.primary);
    // Arcs
    final radii = [size.width * 0.22, size.width * 0.37, size.width * 0.50];
    for (var i = 0; i < 3; i++) {
      final paint = Paint()
        ..color = theme.primary.withOpacity(values[i])
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: radii[i]),
        -math.pi * 1.25,
        math.pi * 0.5,
        false,
        paint,
      );
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: radii[i]),
        -math.pi * 0.25,
        math.pi * 0.5,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_SignalPainter old) => old.values != values;
}

// ═══════════════════════════════════════════════
//  4. VOLUME  — animated sound waves
// ═══════════════════════════════════════════════
class VolumeIcon extends StatefulWidget {
  final bool isDark;
  final double size;
  final double level; // 0.0 to 1.0
  const VolumeIcon({super.key, this.isDark = false, this.size = 48, this.level = 0.7});

  @override
  State<VolumeIcon> createState() => _VolumeIconState();
}

class _VolumeIconState extends State<VolumeIcon> with TickerProviderStateMixin {
  late List<AnimationController> _ctrls;
  late List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(3, (i) => AnimationController(
      vsync: this, duration: Duration(milliseconds: 900 + i * 200)));
    _anims = _ctrls.map((c) => Tween<double>(begin: 0.4, end: 1.0)
        .animate(CurvedAnimation(parent: c, curve: Curves.easeInOut))).toList();
    for (var i = 0; i < _ctrls.length; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) _ctrls[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() { for (var c in _ctrls) c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final theme = widget.isDark ? RadioIconTheme.night : RadioIconTheme.day;
    return AnimatedBuilder(
      animation: Listenable.merge(_ctrls),
      builder: (_, __) => CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _VolumePainter(_anims.map((a) => a.value).toList(), widget.level, theme),
      ),
    );
  }
}

class _VolumePainter extends CustomPainter {
  final List<double> values;
  final double level;
  final RadioIconTheme theme;
  _VolumePainter(this.values, this.level, this.theme);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final paint = Paint()..color = theme.primary..style = PaintingStyle.fill;
    // Speaker body
    final path = Path()
      ..moveTo(s * 0.12, s * 0.38)
      ..lineTo(s * 0.12, s * 0.62)
      ..lineTo(s * 0.32, s * 0.62)
      ..lineTo(s * 0.52, s * 0.80)
      ..lineTo(s * 0.52, s * 0.20)
      ..lineTo(s * 0.32, s * 0.38)
      ..close();
    canvas.drawPath(path, paint);
    // Waves — only show based on level
    final visibleWaves = (level * 3).ceil().clamp(0, 3);
    for (var i = 0; i < visibleWaves; i++) {
      final wp = Paint()
        ..color = theme.primary.withOpacity(values[i] * level)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round;
      final r = s * (0.16 + i * 0.15);
      final cx = s * 0.52;
      final cy = s * 0.50;
      canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r),
          -math.pi * 0.4, math.pi * 0.8, false, wp);
    }
  }

  @override
  bool shouldRepaint(_VolumePainter old) => old.values != values || old.level != level;
}

// ═══════════════════════════════════════════════
//  5. HEART / FAVOURITE  — pulse beat
// ═══════════════════════════════════════════════
class HeartIcon extends StatefulWidget {
  final bool isDark;
  final double size;
  final bool isFilled;
  const HeartIcon({super.key, this.isDark = false, this.size = 48, this.isFilled = true});

  @override
  State<HeartIcon> createState() => _HeartIconState();
}

class _HeartIconState extends State<HeartIcon> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _anim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.28), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.28, end: 1.0), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _ctrl.repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final theme = widget.isDark ? RadioIconTheme.night : RadioIconTheme.day;
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Transform.scale(
        scale: _anim.value,
        child: CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _HeartPainter(widget.isFilled, theme),
        ),
      ),
    );
  }
}

class _HeartPainter extends CustomPainter {
  final bool filled;
  final RadioIconTheme theme;
  _HeartPainter(this.filled, this.theme);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final paint = Paint()
      ..color = theme.accent
      ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 2.0;
    final path = Path();
    final cx = s / 2, cy = s * 0.52;
    path.moveTo(cx, cy + s * 0.28);
    path.cubicTo(cx - s * 0.45, cy, cx - s * 0.45, cy - s * 0.35, cx, cy - s * 0.18);
    path.cubicTo(cx + s * 0.45, cy - s * 0.35, cx + s * 0.45, cy, cx, cy + s * 0.28);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_HeartPainter old) => old.filled != filled;
}

// ═══════════════════════════════════════════════
//  6. SKIP NEXT / PREVIOUS  — animated chevron
// ═══════════════════════════════════════════════
class SkipIcon extends StatefulWidget {
  final bool isDark;
  final double size;
  final bool isNext; // true = skip next, false = skip prev
  const SkipIcon({super.key, this.isDark = false, this.size = 48, this.isNext = true});

  @override
  State<SkipIcon> createState() => _SkipIconState();
}

class _SkipIconState extends State<SkipIcon> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _anim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _ctrl.repeat(reverse: true);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final theme = widget.isDark ? RadioIconTheme.night : RadioIconTheme.day;
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _SkipPainter(_anim.value, widget.isNext, theme),
      ),
    );
  }
}

class _SkipPainter extends CustomPainter {
  final double t;
  final bool isNext;
  final RadioIconTheme theme;
  _SkipPainter(this.t, this.isNext, this.theme);

  @override
  void paint(Canvas canvas, Size size) {
    if (!isNext) {
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }
    final s = size.width;
    final paint = Paint()..color = theme.primary..style = PaintingStyle.fill;
    final shift = t * s * 0.06;
    // Triangle 1
    final p1 = Path()
      ..moveTo(s * 0.12 + shift, s * 0.20)
      ..lineTo(s * 0.52 + shift, s * 0.50)
      ..lineTo(s * 0.12 + shift, s * 0.80)
      ..close();
    canvas.drawPath(p1, paint..color = theme.primary.withOpacity(0.5 + t * 0.5));
    // Triangle 2
    final p2 = Path()
      ..moveTo(s * 0.42 + shift, s * 0.20)
      ..lineTo(s * 0.82 + shift, s * 0.50)
      ..lineTo(s * 0.42 + shift, s * 0.80)
      ..close();
    canvas.drawPath(p2, paint..color = theme.primary);
    // Bar
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(s * 0.82, s * 0.20, s * 0.06, s * 0.60), const Radius.circular(2)),
      Paint()..color = theme.primary,
    );
  }

  @override
  bool shouldRepaint(_SkipPainter old) => old.t != t;
}

// ═══════════════════════════════════════════════
//  7. LOADING / BUFFERING  — spinning arc
// ═══════════════════════════════════════════════
class BufferingIcon extends StatefulWidget {
  final bool isDark;
  final double size;
  const BufferingIcon({super.key, this.isDark = false, this.size = 48});

  @override
  State<BufferingIcon> createState() => _BufferingIconState();
}

class _BufferingIconState extends State<BufferingIcon> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final theme = widget.isDark ? RadioIconTheme.night : RadioIconTheme.day;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _BufferingPainter(_ctrl.value, theme),
      ),
    );
  }
}

class _BufferingPainter extends CustomPainter {
  final double t;
  final RadioIconTheme theme;
  _BufferingPainter(this.t, this.theme);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final r = size.width * 0.40;
    // Track
    canvas.drawCircle(Offset(cx, cy), r,
        Paint()..color = theme.primary.withOpacity(0.15)..style = PaintingStyle.stroke..strokeWidth = 3.5);
    // Arc
    final paint = Paint()
      ..color = theme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      t * math.pi * 2 - math.pi / 2,
      math.pi * 1.4,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_BufferingPainter old) => old.t != t;
}

// ═══════════════════════════════════════════════
//  8. SUN / MOON  — theme toggle icon
// ═══════════════════════════════════════════════
class ThemeToggleIcon extends StatefulWidget {
  final bool isDark;
  final double size;
  const ThemeToggleIcon({super.key, this.isDark = false, this.size = 48});

  @override
  State<ThemeToggleIcon> createState() => _ThemeToggleIconState();
}

class _ThemeToggleIconState extends State<ThemeToggleIcon> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutBack);
    if (widget.isDark) _ctrl.value = 1.0;
  }

  @override
  void didUpdateWidget(ThemeToggleIcon old) {
    super.didUpdateWidget(old);
    if (widget.isDark != old.isDark) {
      widget.isDark ? _ctrl.forward() : _ctrl.reverse();
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _ThemeTogglePainter(_anim.value),
      ),
    );
  }
}

class _ThemeTogglePainter extends CustomPainter {
  final double t; // 0 = sun, 1 = moon
  _ThemeTogglePainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final sunColor = const Color(0xFFFFB300);
    final moonColor = const Color(0xFF82B1FF);
    final color = Color.lerp(sunColor, moonColor, t)!;

    // Sun rays fade out / body morphs to crescent
    final rayPaint = Paint()..color = color.withOpacity(1 - t)..strokeWidth = 2.5..strokeCap = StrokeCap.round;
    final r = size.width * 0.18;
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final inner = r + 4;
      final outer = r + 10;
      canvas.drawLine(
        Offset(cx + math.cos(angle) * inner, cy + math.sin(angle) * inner),
        Offset(cx + math.cos(angle) * outer, cy + math.sin(angle) * outer),
        rayPaint,
      );
    }
    // Main body (sun circle → moon crescent)
    final bodyR = size.width * (0.22 - t * 0.04);
    canvas.drawCircle(Offset(cx, cy), bodyR, Paint()..color = color);
    // Moon cut-out
    if (t > 0.1) {
      canvas.drawCircle(
        Offset(cx + size.width * 0.12 * t, cy - size.height * 0.08 * t),
        bodyR * 0.76 * t,
        Paint()..color = const Color(0xFF1E1E2E).withOpacity(t),
      );
    }
  }

  @override
  bool shouldRepaint(_ThemeTogglePainter old) => old.t != t;
}

// ═══════════════════════════════════════════════
//  9. RECORD / LIVE  — pulsing dot
// ═══════════════════════════════════════════════
class LiveIcon extends StatefulWidget {
  final bool isDark;
  final double size;
  const LiveIcon({super.key, this.isDark = false, this.size = 48});

  @override
  State<LiveIcon> createState() => _LiveIconState();
}

class _LiveIconState extends State<LiveIcon> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _anim = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final theme = widget.isDark ? RadioIconTheme.night : RadioIconTheme.day;
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _LivePainter(_anim.value, theme),
      ),
    );
  }
}

class _LivePainter extends CustomPainter {
  final double t;
  final RadioIconTheme theme;
  _LivePainter(this.t, this.theme);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final red = const Color(0xFFE53935);
    // Pulsing ring
    canvas.drawCircle(Offset(cx, cy), size.width * 0.18 + size.width * 0.28 * t,
        Paint()..color = red.withOpacity((1 - t) * 0.6));
    // Solid dot
    canvas.drawCircle(Offset(cx, cy), size.width * 0.18, Paint()..color = red);
    // "LIVE" text is handled by the widget above via Text widget
  }

  @override
  bool shouldRepaint(_LivePainter old) => old.t != t;
}

// ═══════════════════════════════════════════════
//  10. SHUFFLE  — rotating arrows
// ═══════════════════════════════════════════════
class ShuffleIcon extends StatefulWidget {
  final bool isDark;
  final double size;
  final bool active;
  const ShuffleIcon({super.key, this.isDark = false, this.size = 48, this.active = true});

  @override
  State<ShuffleIcon> createState() => _ShuffleIconState();
}

class _ShuffleIconState extends State<ShuffleIcon> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
    _anim = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    if (widget.active) _ctrl.repeat();
  }

  @override
  void didUpdateWidget(ShuffleIcon old) {
    super.didUpdateWidget(old);
    if (widget.active != old.active) {
      widget.active ? _ctrl.repeat() : _ctrl.stop();
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final theme = widget.isDark ? RadioIconTheme.night : RadioIconTheme.day;
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _ShufflePainter(_anim.value, widget.active, theme),
      ),
    );
  }
}

class _ShufflePainter extends CustomPainter {
  final double t;
  final bool active;
  final RadioIconTheme theme;
  _ShufflePainter(this.t, this.active, this.theme);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final color = active ? theme.secondary : theme.primary.withOpacity(0.4);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    // Two crossing paths
    final path1 = Path()
      ..moveTo(s * 0.10, s * 0.32)
      ..cubicTo(s * 0.35, s * 0.32, s * 0.55, s * 0.68, s * 0.80, s * 0.68);
    final path2 = Path()
      ..moveTo(s * 0.10, s * 0.68)
      ..cubicTo(s * 0.35, s * 0.68, s * 0.55, s * 0.32, s * 0.80, s * 0.32);
    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);
    // Arrow heads
    _drawArrow(canvas, Offset(s * 0.70, s * 0.60), Offset(s * 0.82, s * 0.68), Offset(s * 0.70, s * 0.76), paint);
    _drawArrow(canvas, Offset(s * 0.70, s * 0.24), Offset(s * 0.82, s * 0.32), Offset(s * 0.70, s * 0.40), paint);
    // Sparkle dot when active
    if (active) {
      canvas.drawCircle(Offset(s * 0.88, s * 0.20), s * 0.06 * (0.6 + 0.4 * math.sin(t * math.pi * 2)),
          Paint()..color = theme.accent);
    }
  }

  void _drawArrow(Canvas canvas, Offset a, Offset tip, Offset b, Paint paint) {
    final path = Path()..moveTo(a.dx, a.dy)..lineTo(tip.dx, tip.dy)..lineTo(b.dx, b.dy);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ShufflePainter old) => old.t != t || old.active != active;
}

// ═══════════════════════════════════════════════
//  DEMO SCREEN — shows all icons
// ═══════════════════════════════════════════════
class RadioIconsDemo extends StatefulWidget {
  const RadioIconsDemo({super.key});
  @override
  State<RadioIconsDemo> createState() => _RadioIconsDemoState();
}

class _RadioIconsDemoState extends State<RadioIconsDemo> {
  bool _isDark = false;
  bool _isPlaying = false;
  double _volume = 0.7;

  @override
  Widget build(BuildContext context) {
    final bg = _isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF8F9FF);
    final cardBg = _isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final textColor = _isDark ? Colors.white : const Color(0xFF1A1A2E);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Radio Icons',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: textColor)),
                    GestureDetector(
                      onTap: () => setState(() => _isDark = !_isDark),
                      child: ThemeToggleIcon(isDark: _isDark, size: 40),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Player card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          LiveIcon(isDark: _isDark, size: 28),
                          const SizedBox(width: 6),
                          Text('LIVE', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                              color: const Color(0xFFE53935), letterSpacing: 1.2)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      EqualizerIcon(isDark: _isDark, size: 64, isPlaying: _isPlaying),
                      const SizedBox(height: 20),
                      // Controls row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SkipIcon(isDark: _isDark, size: 36, isNext: false),
                          GestureDetector(
                            onTap: () => setState(() => _isPlaying = !_isPlaying),
                            child: PlayPauseIcon(isDark: _isDark, size: 60, isPlaying: _isPlaying),
                          ),
                          SkipIcon(isDark: _isDark, size: 36, isNext: true),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Volume row
                      Row(
                        children: [
                          VolumeIcon(isDark: _isDark, size: 28, level: _volume),
                          Expanded(
                            child: Slider(
                              value: _volume,
                              onChanged: (v) => setState(() => _volume = v),
                              activeColor: _isDark ? const Color(0xFF82B1FF) : const Color(0xFF1A73E8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Icon grid
                Text('All icons', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: textColor)),
                const SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    _iconCell('Equalizer', EqualizerIcon(isDark: _isDark, size: 40, isPlaying: true), cardBg, textColor),
                    _iconCell('Play/Pause', PlayPauseIcon(isDark: _isDark, size: 40, isPlaying: _isPlaying), cardBg, textColor),
                    _iconCell('Signal', SignalIcon(isDark: _isDark, size: 40), cardBg, textColor),
                    _iconCell('Volume', VolumeIcon(isDark: _isDark, size: 40, level: _volume), cardBg, textColor),
                    _iconCell('Heart', HeartIcon(isDark: _isDark, size: 40), cardBg, textColor),
                    _iconCell('Skip', SkipIcon(isDark: _isDark, size: 40), cardBg, textColor),
                    _iconCell('Buffer', BufferingIcon(isDark: _isDark, size: 40), cardBg, textColor),
                    _iconCell('Shuffle', ShuffleIcon(isDark: _isDark, size: 40), cardBg, textColor),
                    _iconCell('Live', LiveIcon(isDark: _isDark, size: 40), cardBg, textColor),
                    _iconCell('Theme', ThemeToggleIcon(isDark: _isDark, size: 40), cardBg, textColor),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconCell(String label, Widget icon, Color bg, Color textColor) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(height: 6),
          Text(label, style: TextStyle(fontSize: 10, color: textColor.withOpacity(0.6))),
        ],
      ),
    );
  }
}

void main() => runApp(const RadioIconsDemo());
