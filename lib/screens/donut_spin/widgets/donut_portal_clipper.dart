import 'package:flutter/material.dart';

/// CustomClipper that clips child content to an expanding circular portal
/// centered precisely on the donut's inner hole.
class DonutHolePortalClipper extends CustomClipper<Path> {
  final Offset center;
  final double radius;

  const DonutHolePortalClipper({
    required this.center,
    required this.radius,
  });

  @override
  Path getClip(Size size) {
    if (radius <= 0.0) return Path();
    final path = Path();
    path.addOval(Rect.fromCircle(center: center, radius: radius));
    return path;
  }

  @override
  bool shouldReclip(covariant DonutHolePortalClipper oldClipper) {
    return oldClipper.radius != radius || oldClipper.center != center;
  }
}

/// Paints the illuminated inner rim of the expanding portal as the camera
/// travels through the donut hole.
class PortalRimPainter extends CustomPainter {
  final Offset center;
  final double radius;
  final double opacity;

  const PortalRimPainter({
    required this.center,
    required this.radius,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (radius <= 0.0 || opacity <= 0.0) return;

    // Glowing rim band
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFF58FB3).withValues(alpha: 0.65 * opacity),
          const Color(0xFFFFF6E9).withValues(alpha: 0.20 * opacity),
          Colors.transparent,
        ],
        stops: const [0.85, 0.95, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius + 4.0));

    canvas.drawCircle(center, radius, rimPaint);
  }

  @override
  bool shouldRepaint(covariant PortalRimPainter oldDelegate) {
    return oldDelegate.radius != radius ||
        oldDelegate.opacity != opacity ||
        oldDelegate.center != center;
  }
}
