import 'dart:math';
import 'package:flutter/material.dart';

class RainEffect extends StatefulWidget {
  const RainEffect({super.key});

  @override
  State<RainEffect> createState() => _RainEffectState();
}

class _RainEffectState extends State<RainEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<RainDrop> _drops = [];
  final Random _random = Random();
  Size _currentSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(() {
        _updateDrops();
      })
      ..repeat();
  }

  void _updateDrops() {
    if (_currentSize == Size.zero || _drops.isEmpty) return;
    for (var drop in _drops) {
      drop.y += drop.speed;
      drop.x += drop.speed * 0.15; // slight wind
      if (drop.y > _currentSize.height) {
        drop.y = -drop.length; // reset top
        drop.x = _random.nextDouble() * _currentSize.width;
      }
      if (drop.x > _currentSize.width) {
        drop.x = 0;
      }
    }
    setState(() {}); // trigger repaint
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final newSize = Size(constraints.maxWidth, constraints.maxHeight);
        if (_currentSize != newSize) {
          _currentSize = newSize;
          _drops.clear();
          for (int i = 0; i < 150; i++) {
            _drops.add(RainDrop(
              x: _random.nextDouble() * _currentSize.width,
              y: _random.nextDouble() * _currentSize.height,
              length: _random.nextDouble() * 15 + 10,
              speed: _random.nextDouble() * 6 + 6,
              opacity: _random.nextDouble() * 0.4 + 0.1,
            ));
          }
        }
        return RepaintBoundary(
          child: CustomPaint(
            size: _currentSize,
            painter: RainPainter(_drops),
          ),
        );
      },
    );
  }
}

class RainDrop {
  double x, y, length, speed, opacity;
  RainDrop({
    required this.x,
    required this.y,
    required this.length,
    required this.speed,
    required this.opacity,
  });
}

class RainPainter extends CustomPainter {
  final List<RainDrop> drops;

  RainPainter(this.drops);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    for (var drop in drops) {
      // Use withValues(alpha:) for recent Flutter versions
      paint.color = Colors.white.withValues(alpha: drop.opacity);
      canvas.drawLine(
        Offset(drop.x, drop.y),
        Offset(drop.x + drop.speed * 0.15, drop.y + drop.length),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant RainPainter oldDelegate) => true;
}
