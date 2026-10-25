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
