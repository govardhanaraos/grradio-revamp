import 'dart:math';

import 'package:flutter/cupertino.dart';

class MusicVisualizer extends StatelessWidget {
  final bool isPlaying;
  final int barCount;

  const MusicVisualizer({
    required this.isPlaying,
    this.barCount = 15,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        barCount,
        (index) => VisualizerBar(isPlaying: isPlaying),
      ),
    );
  }
}

class VisualizerBar extends StatefulWidget {
  final bool isPlaying;
  const VisualizerBar({required this.isPlaying});

  @override
  _VisualizerBarState createState() => _VisualizerBarState();
}

class _VisualizerBarState extends State<VisualizerBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: Random().nextInt(500) + 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 5, end: 40).animate(_controller);
    if (widget.isPlaying) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(VisualizerBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.isPlaying ? _controller.repeat(reverse: true) : _controller.stop();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Container(
        width: 4,
        height: _animation.value,
        decoration: BoxDecoration(
          color: const Color(0xFF7C4DFF).withOpacity(0.8),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
}
