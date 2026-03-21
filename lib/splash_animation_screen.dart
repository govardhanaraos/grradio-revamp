import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'main.dart';

class AnimatedSplashScreen extends StatefulWidget {
  @override
  _AnimatedSplashScreenState createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _textVisible = false; // State for staggered text animation

  @override
  void initState() {
    super.initState();

    // 1. Controller for the pulse effect
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    // 2. Pulse Animation (Scale)
    _animation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // 3. HAPTIC FEEDBACK: Trigger at the peak of the pulse
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Trigger a light vibration when the icon is at its largest
        HapticFeedback.lightImpact();
      }
    });

    // 4. STAGGERED ANIMATION: Fade text in after 500ms
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _textVisible = true;
        });
      }
    });

    // 5. Navigation timer
    Timer(const Duration(seconds: 4), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MainNavigator()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // SUBTLE BACKGROUND GRADIENT
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              const Color(0xFF7C4DFF).withOpacity(0.08), // 8% Electric Violet
              Colors.white, // Fades to pure white
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // PULSING ICON
            ScaleTransition(
              scale: _animation,
              child: Image.asset(
                'assets/icons/gr_radio_launcher_icon.png',
                width: 140,
                height: 140,
              ),
            ),
            const SizedBox(height: 30),

            // STAGGERED TEXT ANIMATION
            AnimatedOpacity(
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeIn,
              opacity: _textVisible ? 1.0 : 0.0,
              child: const Column(
                children: [
                  Text(
                    "GR Radio",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Your Ultimate Music Companion",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
