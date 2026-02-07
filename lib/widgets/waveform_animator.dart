import 'package:flutter/material.dart';
import 'dart:math' as math;

class WaveformAnimator extends StatefulWidget {
  final bool isRecording;
  final Color color;

  const WaveformAnimator({
    super.key,
    required this.isRecording,
    this.color = const Color(0xFFB08D5B),
  });

  @override
  State<WaveformAnimator> createState() => _WaveformAnimatorState();
}

class _WaveformAnimatorState extends State<WaveformAnimator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isRecording) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          15,
          (index) => Container(
            width: 3,
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(15, (index) {
            final double phase = (index / 15.0) * 2 * math.pi;
            final double value = math.sin(
              _controller.value * 2 * math.pi + phase,
            );
            final double height = 10 + (25 * (value.abs()));

            return Container(
              width: 3,
              height: height,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.3),
                    blurRadius: 4,
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}
