import 'dart:math';
import 'package:flutter/material.dart';

enum ParticleType { fire, snow }

class RainEffect extends StatefulWidget {
  const RainEffect({super.key});

  @override
  State<RainEffect> createState() => _RainEffectState();
}

class _RainEffectState extends State<RainEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final Random _random = Random();
  Size _currentSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(() {
        _updateParticles();
      })
      ..repeat();
  }

  void _updateParticles() {
    if (_currentSize == Size.zero || _particles.isEmpty) return;
    for (var p in _particles) {
      if (p.type == ParticleType.fire) {
        p.y += p.speed;
        p.x += p.speed * 0.15; // wind
      } else {
        p.y += p.speed;
        p.x += sin(p.y * 0.05) * 1.5 + p.speed * 0.1; // swaying and wind
      }

      if (p.y > _currentSize.height) {
        p.y = -p.size; // reset top
        p.x = _random.nextDouble() * _currentSize.width;
      }
      if (p.x > _currentSize.width) {
        p.x = 0;
      } else if (p.x < 0) {
        p.x = _currentSize.width;
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
          _particles.clear();
          // Fire particles
          for (int i = 0; i < 80; i++) {
            _particles.add(Particle(
              type: ParticleType.fire,
              x: _random.nextDouble() * _currentSize.width,
              y: _random.nextDouble() * _currentSize.height,
              size: _random.nextDouble() * 15 + 10,
              speed: _random.nextDouble() * 8 + 8,
              opacity: _random.nextDouble() * 0.5 + 0.3,
            ));
          }
          // Snow particles
          for (int i = 0; i < 70; i++) {
            _particles.add(Particle(
              type: ParticleType.snow,
              x: _random.nextDouble() * _currentSize.width,
              y: _random.nextDouble() * _currentSize.height,
              size: _random.nextDouble() * 2.5 + 1.5,
              speed: _random.nextDouble() * 2.5 + 1.5,
              opacity: _random.nextDouble() * 0.5 + 0.3,
            ));
          }
        }
        return RepaintBoundary(
          child: CustomPaint(
            size: _currentSize,
            painter: StormPainter(_particles),
          ),
        );
      },
    );
  }
}

class Particle {
  ParticleType type;
  double x, y, size, speed, opacity;
  Particle({
    required this.type,
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

class StormPainter extends CustomPainter {
  final List<Particle> particles;

  StormPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final firePaint = Paint()..strokeCap = StrokeCap.round;
    final snowPaint = Paint()..style = PaintingStyle.fill;

    for (var p in particles) {
      if (p.type == ParticleType.fire) {
        final gradientPaint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.yellowAccent.withValues(alpha: 0.0),
              Colors.orange.withValues(alpha: p.opacity),
              Colors.redAccent.withValues(alpha: p.opacity),
            ],
          ).createShader(Rect.fromPoints(
            Offset(p.x, p.y),
            Offset(p.x + p.speed * 0.15, p.y + p.size),
          ))
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round;

        canvas.drawLine(
          Offset(p.x, p.y),
          Offset(p.x + p.speed * 0.15, p.y + p.size),
          gradientPaint,
        );
      } else if (p.type == ParticleType.snow) {
        snowPaint.color = Colors.white.withValues(alpha: p.opacity);
        canvas.drawCircle(Offset(p.x, p.y), p.size, snowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant StormPainter oldDelegate) => true;
}
