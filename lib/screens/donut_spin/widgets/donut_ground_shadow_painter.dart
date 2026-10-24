import 'package:flutter/material.dart';

/// Standalone ground contact shadow that stays fixed on the floor plane
/// while the 3D donut drops, squashes, stretches, and settles above it.
class DonutGroundShadowPainter extends CustomPainter {
  final Offset center;
  final double donutRadius;
  final double squashX;
  final double shadowOpacity;
  final double shadowScale;

  const DonutGroundShadowPainter({
    required this.center,
    required this.donutRadius,
    this.squashX = 1.0,
    this.shadowOpacity = 0.30,
    this.shadowScale = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (shadowOpacity <= 0.0) return;

    final shadowY = center.dy + donutRadius * 0.88;
    final shadowWidth = donutRadius * 2.0 * shadowScale * squashX;
    final shadowHeight = (donutRadius * 0.38) * shadowScale;

    final shadowRect = Rect.fromCenter(
      center: Offset(center.dx, shadowY),
      width: shadowWidth,
      height: shadowHeight,
    );

    final shadowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF5A3825).withValues(alpha: shadowOpacity * 0.70),
          const Color(0xFF5A3825).withValues(alpha: shadowOpacity * 0.35),
          const Color(0xFF5A3825).withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(shadowRect);

    canvas.drawOval(shadowRect, shadowPaint);
  }

  @override
  bool shouldRepaint(covariant DonutGroundShadowPainter oldDelegate) {
    return oldDelegate.shadowOpacity != shadowOpacity ||
        oldDelegate.shadowScale != shadowScale ||
        oldDelegate.squashX != squashX ||
        oldDelegate.donutRadius != donutRadius ||
        oldDelegate.center != center;
  }
}
