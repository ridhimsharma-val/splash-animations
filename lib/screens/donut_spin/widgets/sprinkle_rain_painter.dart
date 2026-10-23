import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Deterministic data model for a falling sprinkle particle.
class _RainParticle {
  final double startX; // Relative horizontal position [-180, 180]
  final double speed; // Fall speed multiplier
  final double delay; // Normalized start time offset [0.0, 0.4]
  final double rotationSpeed; // Angular velocity
  final double initialAngle; // Starting rotation
  final double length; // Length of sprinkle pill
  final double thickness; // Width of sprinkle pill
  final double driftAmplitude; // Horizontal oscillation amplitude
  final double driftFrequency; // Oscillation speed
  final Color color;

  const _RainParticle({
    required this.startX,
    required this.speed,
    required this.delay,
    required this.rotationSpeed,
    required this.initialAngle,
    required this.length,
    required this.thickness,
    required this.driftAmplitude,
    required this.driftFrequency,
    required this.color,
  });
}

/// Renders a graceful cascade of celebratory dessert sprinkles raining down
/// during Phase B of the splash sequence.
class SprinkleRainPainter extends CustomPainter {
  /// Progress of the sprinkle rain animation (0.0 to 1.0)
  final double progress;

  // 30 deterministic particles with diverse speeds, colors, and trajectories
  static final List<_RainParticle> _particles = _generateParticles();

  static List<_RainParticle> _generateParticles() {
    const colors = [
      Color(0xFF70E0D0), // Mint
      Color(0xFFFFD166), // Yellow
      Color(0xFFFF8B8B), // Coral
      Color(0xFFDED2F9), // Lavender
      Color(0xFF9AD0EC), // Sky Blue
    ];

    final list = <_RainParticle>[];
    final random = math.Random(42); // Deterministic seed

    for (int i = 0; i < 32; i++) {
      list.add(_RainParticle(
        startX: (random.nextDouble() - 0.5) * 320.0,
        speed: 0.85 + random.nextDouble() * 0.75,
        delay: random.nextDouble() * 0.35,
        rotationSpeed: (random.nextDouble() - 0.5) * 8.0,
        initialAngle: random.nextDouble() * math.pi * 2,
        length: 10.0 + random.nextDouble() * 5.0,
        thickness: 3.5 + random.nextDouble() * 1.0,
        driftAmplitude: 6.0 + random.nextDouble() * 14.0,
        driftFrequency: 2.0 + random.nextDouble() * 3.0,
        color: colors[i % colors.length],
      ));
    }
    return list;
  }

  const SprinkleRainPainter({
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0 || progress >= 1.0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    for (final p in _particles) {
      if (progress < p.delay) continue;

      // Local progress for this particle
      final t = (progress - p.delay) / (1.0 - p.delay);
      if (t > 1.0) continue;

      // Vertical position (starts above viewport, falls through)
      final startY = -size.height * 0.45;
      final endY = size.height * 0.55;
      final curY = startY + (endY - startY) * (t * p.speed);

      // Horizontal position with gentle sine drift
      final curX = p.startX + p.driftAmplitude * math.sin(t * math.pi * p.driftFrequency);

      // Fade-in at the top and fade-out near bottom
      double alpha = 1.0;
      if (t < 0.12) {
        alpha = t / 0.12;
      } else if (t > 0.78) {
        alpha = (1.0 - t) / 0.22;
      }
      alpha = alpha.clamp(0.0, 1.0);

      final curAngle = p.initialAngle + p.rotationSpeed * t;

      canvas.save();
      canvas.translate(center.dx + curX, center.dy + curY);
      canvas.rotate(curAngle);

      // Micro drop shadow
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: const Offset(1.0, 1.5),
            width: p.length,
            height: p.thickness,
          ),
          Radius.circular(p.thickness / 2),
        ),
        shadowPaint..color = Colors.black.withValues(alpha: 0.10 * alpha),
      );

      // Sprinkle pill
      paint.color = p.color.withValues(alpha: alpha);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.length,
            height: p.thickness,
          ),
          Radius.circular(p.thickness / 2),
        ),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant SprinkleRainPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
