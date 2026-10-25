import 'dart:math' as math;

import 'package:flutter/material.dart';

/// CustomPainter that renders a delicate freshness ring in soft mint & sage green.
///
/// Once the ring completes its 360° sweep, it rotates dynamically in Scene 4
/// to lead into the centered NutriFridge brand reveal.
class FreshnessRingPainter extends CustomPainter {
  final Offset center;
  final double radius;
  final double progress; // 0.0 to 1.0 (sweep completion)
  final double rotation; // In radians: spins the ring once formed
  final double opacity; // 0.0 to 1.0 (fade in & fade out)

  const FreshnessRingPainter({
    required this.center,
    required this.radius,
    required this.progress,
    this.rotation = 0.0,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (radius <= 0.0 || opacity <= 0.005 || progress <= 0.005) return;

    final effectiveOpacity = opacity.clamp(0.0, 1.0);
    final sweepAngle = 2.0 * math.pi * progress.clamp(0.0, 1.0);

    // Subtle finishing pulse as sweep completes
    final pulseScale = (progress > 0.85 && rotation == 0.0)
        ? (1.0 + 0.02 * math.sin((progress - 0.85) / 0.15 * math.pi))
        : 1.0;
    final currentRadius = radius * pulseScale;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    if (rotation != 0.0) {
      canvas.rotate(rotation);
    }
    canvas.translate(-center.dx, -center.dy);

    // 1. Soft Ambient Outer Aura (Very restrained, delicate mint)
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = const Color(0xFFA7D7A5)
          .withValues(alpha: 0.25 * effectiveOpacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: currentRadius),
      -math.pi / 2,
      sweepAngle,
      false,
      glowPaint,
    );

    // 2. Refined, Thin Freshness Ring (Soft Mint to Sage-Forest Green)
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: [
          const Color(0xFF2E7D32).withValues(alpha: 0.80 * effectiveOpacity),
          const Color(0xFFA7D7A5).withValues(alpha: 0.85 * effectiveOpacity),
          const Color(0xFF81C784).withValues(alpha: 0.65 * effectiveOpacity),
          const Color(0xFF2E7D32).withValues(alpha: 0.80 * effectiveOpacity),
        ],
        stops: const [0.0, 0.40, 0.75, 1.0],
        transform: GradientRotation(progress * math.pi),
      ).createShader(Rect.fromCircle(center: center, radius: currentRadius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: currentRadius),
      -math.pi / 2,
      sweepAngle,
      false,
      ringPaint,
    );

    // 3. Leading Spark Tip (Single soft pearl highlight leading the stroke)
    if (progress < 0.98) {
      final leadAngle = -math.pi / 2 + sweepAngle;
      final tipPos = Offset(
        center.dx + currentRadius * math.cos(leadAngle),
        center.dy + currentRadius * math.sin(leadAngle),
      );
      final tipPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = const Color(0xFF2E7D32)
            .withValues(alpha: 0.90 * effectiveOpacity);
      canvas.drawCircle(tipPos, 2.2, tipPaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant FreshnessRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.rotation != rotation ||
        oldDelegate.opacity != opacity ||
        oldDelegate.radius != radius ||
        oldDelegate.center != center;
  }
}
