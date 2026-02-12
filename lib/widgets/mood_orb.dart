import 'package:flutter/material.dart';
import 'dart:ui';

class MoodOrb extends StatefulWidget {
  final Function(double x, double y) onMoodChanged;
  final VoidCallback onMoodReleased;

  const MoodOrb({
    super.key,
    required this.onMoodChanged,
    required this.onMoodReleased,
  });

  @override
  State<MoodOrb> createState() => _MoodOrbState();
}

class _MoodOrbState extends State<MoodOrb> with SingleTickerProviderStateMixin {
  Offset _position = Offset.zero;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _position += details.delta;
          // Constrain movement within a reasonable area
          _position = Offset(
            _position.dx.clamp(-100.0, 100.0),
            _position.dy.clamp(-100.0, 100.0),
          );
        });
        widget.onMoodChanged(_position.dx / 100, _position.dy / 100);
      },
      onPanEnd: (_) {
        setState(() => _position = Offset.zero);
        widget.onMoodReleased();
      },
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Transform.translate(
            offset: _position,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(
                      0xFFB08D5B,
                    ).withValues(alpha: 0.3 * _pulseController.value),
                    blurRadius: 20 + (10 * _pulseController.value),
                    spreadRadius: 5 * _pulseController.value,
                  ),
                ],
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFB08D5B).withValues(alpha: 0.8),
                    const Color(0xFFB08D5B).withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Center(
                    child: Icon(
                      Icons.blur_on_rounded,
                      color: Colors.white.withValues(
                        alpha: 0.5 + (0.5 * _pulseController.value),
                      ),
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
