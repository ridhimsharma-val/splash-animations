import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'donut_frame_animator.dart';

/// Exact bright confectionery candy palette matching Blender Cycles & visual specification.
const List<Color> _candyColors = [
  Color(0xFF0077FF), // Electric Royal Blue
  Color(0xFFFF1744), // Candy Red
  Color(0xFFFFD600), // Vibrant Lemon Yellow
  Color(0xFFFF6D00), // Tangerine Orange
  Color(0xFF00E676), // Lime Spring Green
  Color(0xFFD500F9), // Vivid Grape Purple
  Color(0xFFFFFFFF), // Pure Sugar White
  Color(0xFFFF4081), // Hot Strawberry Pink
];

/// Deterministic data specification for a sprinkle that lands on the donut's pink icing.
class LandedSprinkleData {
  /// Distance from center hole optical center relative to donut diameter [0.20, 0.38]
  final double radiusRatio;

  /// Angle around donut center in radians [0, 2*pi]
  final double angle;

  /// Orientation tilt angle of the cylindrical rod in radians [0, pi]
  final double tilt;

  /// Length of the rod relative to donut diameter (~0.058)
  final double lengthRatio;

  /// Thickness of the rod relative to donut diameter (~0.018)
  final double thicknessRatio;

  /// Confectionery candy color
  final Color color;

  /// Normalized progress in Phase 3 at which this sprinkle impacts the icing [0.10, 0.85]
  final double landProgress;

  const LandedSprinkleData({
    required this.radiusRatio,
    required this.angle,
    required this.tilt,
    required this.lengthRatio,
    required this.thicknessRatio,
    required this.color,
    required this.landProgress,
  });
}

/// 24 carefully distributed sprinkles positioned squarely on the strawberry icing crown.
/// Strictly avoids the center hole (r >= 0.20 > 0.088) and outer dough rim (r <= 0.38 < 0.47).
final List<LandedSprinkleData> kLandedSprinkles = _buildLandedSprinkles();

List<LandedSprinkleData> _buildLandedSprinkles() {
  const angles = [
    0.18,
    0.44,
    0.70,
    0.96,
    1.22,
    1.48,
    1.74,
    2.00,
    2.26,
    2.52,
    2.78,
    3.04,
    3.30,
    3.56,
    3.82,
    4.08,
    4.34,
    4.60,
    4.86,
    5.12,
    5.38,
    5.64,
    5.90,
    6.16,
  ];

  // Strictly on the top crown of the icing (r in [0.22, 0.35]).
  // Well away from center hole (r > 0.088) and outer dough rim (r < 0.470).
  const radii = [
    0.23,
    0.33,
    0.26,
    0.31,
    0.22,
    0.34,
    0.25,
    0.32,
    0.24,
    0.35,
    0.27,
    0.30,
    0.23,
    0.34,
    0.25,
    0.31,
    0.24,
    0.35,
    0.26,
    0.33,
    0.22,
    0.32,
    0.27,
    0.29,
  ];

  const tilts = [
    0.35,
    1.20,
    2.10,
    0.85,
    1.75,
    2.60,
    0.40,
    1.45,
    2.30,
    0.95,
    1.80,
    2.70,
    0.50,
    1.60,
    2.45,
    0.75,
    1.90,
    2.85,
    0.60,
    1.50,
    2.25,
    0.80,
    1.70,
    2.55,
  ];

  // All 24 sprinkles land by progress 0.72, giving ample settling time
  const landings = [
    0.10,
    0.22,
    0.16,
    0.32,
    0.25,
    0.38,
    0.12,
    0.28,
    0.44,
    0.35,
    0.20,
    0.48,
    0.30,
    0.46,
    0.40,
    0.54,
    0.58,
    0.50,
    0.64,
    0.56,
    0.68,
    0.60,
    0.72,
    0.52,
  ];

  final list = <LandedSprinkleData>[];
  for (int i = 0; i < 24; i++) {
    list.add(
      LandedSprinkleData(
        radiusRatio: radii[i],
        angle: angles[i],
        tilt: tilts[i],
        lengthRatio: 0.054 + (i % 3) * 0.003,
        thicknessRatio: 0.016 + (i % 2) * 0.002,
        color: _candyColors[i % _candyColors.length],
        landProgress: landings[i],
      ),
    );
  }
  return list;
}

/// Stray sprinkles: minimal (only 6 subtle particles) that fall quickly
/// past the sides of the donut and exit off-screen before the rain finishes.
class _StraySprinkle {
  final double relX;
  final double speed;
  final double delay;
  final double length;
  final double thickness;
  final double tilt;
  final double rotationSpeed;
  final double driftAmp;
  final double driftFreq;
  final Color color;

  const _StraySprinkle({
    required this.relX,
    required this.speed,
    required this.delay,
    required this.length,
    required this.thickness,
    required this.tilt,
    required this.rotationSpeed,
    required this.driftAmp,
    required this.driftFreq,
    required this.color,
  });
}

final List<_StraySprinkle> _kStraySprinkles = _buildStraySprinkles();

List<_StraySprinkle> _buildStraySprinkles() {
  final list = <_StraySprinkle>[];
  final random = math.Random(54321);

  // Exactly 6 stray sprinkles falling cleanly on the far outer edges
  for (int i = 0; i < 6; i++) {
    final side = (i % 2 == 0) ? -1.0 : 1.0;
    final relX = side * (140.0 + random.nextDouble() * 80.0);

    list.add(
      _StraySprinkle(
        relX: relX,
        speed: 1.40 + random.nextDouble() * 0.40, // Fast fall, exits early
        delay: 0.02 + random.nextDouble() * 0.16,
        length: 12.0 + random.nextDouble() * 3.0,
        thickness: 3.6 + random.nextDouble() * 0.6,
        tilt: random.nextDouble() * math.pi,
        rotationSpeed: (random.nextDouble() - 0.5) * 4.0,
        driftAmp: 4.0 + random.nextDouble() * 8.0,
        driftFreq: 2.0 + random.nextDouble() * 2.0,
        color: _candyColors[i % _candyColors.length],
      ),
    );
  }
  return list;
}

/// Paints the 24 landed sprinkles securely affixed to the donut's icing.
/// Rendered INSIDE DonutFrameAnimator so sprinkles automatically inherit
/// all position, squash, rotation, and portal camera zoom transforms.
class LandedSprinklesPainter extends CustomPainter {
  /// Master progress of sprinkles (0.0 to 1.0 during Phase 3, 1.0 in Phase 4–6).
  final double progress;
  final double diameter;

  const LandedSprinklesPainter({
    required this.progress,
    required this.diameter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0) return;

    final centerX = diameter * (0.5 + DonutCalibration.holeCenterOffsetX);
    final centerY = diameter * (0.5 + DonutCalibration.holeCenterOffsetY);

    final shadowPaint = Paint()..style = PaintingStyle.fill;
    final cylinderPaint = Paint()..style = PaintingStyle.fill;
    final highlightPaint = Paint()..style = PaintingStyle.fill;

    for (final s in kLandedSprinkles) {
      if (progress < s.landProgress) continue;

      // Position along the donut icing crown
      final r = diameter * s.radiusRatio;
      final lx = centerX + r * math.cos(s.angle);
      final ly = centerY + r * math.sin(s.angle);

      // Micro settle bounce immediately after impact
      double bounceY = 0.0;
      double bounceSquash = 1.0;
      if (progress < s.landProgress + 0.08) {
        final bt = (progress - s.landProgress) / 0.08;
        final sBounce = math.sin(bt * math.pi);
        bounceY = -1.8 * sBounce;
        bounceSquash = 1.0 + 0.06 * sBounce;
      }

      final visibleLength = diameter * s.lengthRatio * bounceSquash;
      final thickness = diameter * s.thicknessRatio;
      final halfLen = visibleLength / 2.0;
      final halfThick = thickness / 2.0;
      final radius = Radius.circular(halfThick);

      canvas.save();
      canvas.translate(lx, ly + bounceY);
      canvas.rotate(s.tilt);

      final rodRect = Rect.fromCenter(
        center: Offset.zero,
        width: visibleLength,
        height: thickness,
      );

      // 1. Soft contact shadow on strawberry icing beneath sprinkle
      final shadowRect = Rect.fromCenter(
        center: const Offset(1.2, 1.6),
        width: visibleLength,
        height: thickness,
      );
      shadowPaint.color = const Color(0xFF4A1028).withValues(alpha: 0.26);
      canvas.drawRRect(
        RRect.fromRectAndRadius(shadowRect, radius),
        shadowPaint,
      );

      // 2. 3D Cylindrical Gradient Shading across cylinder thickness
      final topColor = Color.lerp(s.color, Colors.white, 0.50)!;
      final crestColor = Color.lerp(s.color, Colors.white, 0.78)!;
      final bodyColor = s.color;
      final bottomColor = Color.lerp(s.color, Colors.black, 0.25)!;

      cylinderPaint.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [topColor, crestColor, bodyColor, bottomColor],
        stops: const [0.0, 0.22, 0.60, 1.0],
      ).createShader(rodRect);

      canvas.drawRRect(RRect.fromRectAndRadius(rodRect, radius), cylinderPaint);

      // 3. Specular gloss highlight stripe along upper cylinder edge
      final highlightRect = Rect.fromLTWH(
        -halfLen * 0.72,
        -halfThick * 0.62,
        visibleLength * 0.72,
        thickness * 0.24,
      );
      highlightPaint.color = Colors.white.withValues(alpha: 0.55);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          highlightRect,
          Radius.circular(thickness * 0.12),
        ),
        highlightPaint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant LandedSprinklesPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.diameter != diameter;
  }
}

/// Paints sprinkles falling through the air during the Phase 3 cascade:
/// 1. The 24 sprinkles descending from above the screen towards their landing spots.
/// 2. Stray sprinkles cascading past the donut and exiting off-screen.
class SprinkleRainPainter extends CustomPainter {
  /// Progress of the sprinkle rain shower (0.0 to 1.0 during Phase 3).
  final double progress;
  final Offset donutCenter;
  final double donutDiameter;

  const SprinkleRainPainter({
    required this.progress,
    required this.donutCenter,
    required this.donutDiameter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0 || progress >= 1.0) return;

    final cylinderPaint = Paint()..style = PaintingStyle.fill;
    final highlightPaint = Paint()..style = PaintingStyle.fill;
    final shadowPaint = Paint()..style = PaintingStyle.fill;

    // A. Animate falling sprinkles heading for the donut icing
    for (final s in kLandedSprinkles) {
      if (progress >= s.landProgress) {
        // Already landed on the donut, drawn by LandedSprinklesPainter
        continue;
      }

      final targetX =
          donutCenter.dx +
          donutDiameter * DonutCalibration.holeCenterOffsetX +
          donutDiameter * s.radiusRatio * math.cos(s.angle);
      final targetY =
          donutCenter.dy +
          donutDiameter * DonutCalibration.holeCenterOffsetY +
          donutDiameter * s.radiusRatio * math.sin(s.angle);

      final t = (progress / s.landProgress).clamp(0.0, 1.0);
      final fallT = Curves.easeInQuad.transform(t);

      final startY = -size.height * 0.40;
      final curY = startY + (targetY - startY) * fallT;
      final curX = targetX + 16.0 * (1.0 - t) * math.sin(t * math.pi * 2.0);
      final curAngle = s.tilt + (1.0 - t) * 3.5;

      final alpha = (t * 2.2).clamp(0.0, 1.0);

      final visibleLength = donutDiameter * s.lengthRatio;
      final thickness = donutDiameter * s.thicknessRatio;
      final halfLen = visibleLength / 2.0;
      final halfThick = thickness / 2.0;
      final radius = Radius.circular(halfThick);

      canvas.save();
      canvas.translate(curX, curY);
      canvas.rotate(curAngle);

      final rodRect = Rect.fromCenter(
        center: Offset.zero,
        width: visibleLength,
        height: thickness,
      );

      final topColor = Color.lerp(
        s.color,
        Colors.white,
        0.50,
      )!.withValues(alpha: alpha);
      final crestColor = Color.lerp(
        s.color,
        Colors.white,
        0.78,
      )!.withValues(alpha: alpha);
      final bodyColor = s.color.withValues(alpha: alpha);
      final bottomColor = Color.lerp(
        s.color,
        Colors.black,
        0.25,
      )!.withValues(alpha: alpha);

      cylinderPaint.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [topColor, crestColor, bodyColor, bottomColor],
        stops: const [0.0, 0.22, 0.60, 1.0],
      ).createShader(rodRect);

      canvas.drawRRect(RRect.fromRectAndRadius(rodRect, radius), cylinderPaint);

      final highlightRect = Rect.fromLTWH(
        -halfLen * 0.72,
        -halfThick * 0.62,
        visibleLength * 0.72,
        thickness * 0.24,
      );
      highlightPaint.color = Colors.white.withValues(alpha: 0.50 * alpha);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          highlightRect,
          Radius.circular(thickness * 0.12),
        ),
        highlightPaint,
      );

      canvas.restore();
    }

    // B. Stray sprinkles falling cleanly past the sides of the donut
    final screenCenter = Offset(size.width / 2.0, size.height / 2.0);
    for (final s in _kStraySprinkles) {
      if (progress < s.delay) continue;

      final t = (progress - s.delay) / (1.0 - s.delay);
      if (t > 1.0) continue;

      final startY = -size.height * 0.45;
      final endY = size.height * 0.55;
      final curY = startY + (endY - startY) * (t * s.speed);
      final curX = s.relX + s.driftAmp * math.sin(t * math.pi * s.driftFreq);
      final curAngle = s.tilt + s.rotationSpeed * t;

      double alpha = 1.0;
      if (t < 0.12) {
        alpha = t / 0.12;
      } else if (t > 0.80) {
        alpha = (1.0 - t) / 0.20;
      }
      alpha = alpha.clamp(0.0, 1.0);

      final halfLen = s.length / 2.0;
      final halfThick = s.thickness / 2.0;
      final radius = Radius.circular(halfThick);

      canvas.save();
      canvas.translate(screenCenter.dx + curX, screenCenter.dy + curY);
      canvas.rotate(curAngle);

      final rodRect = Rect.fromCenter(
        center: Offset.zero,
        width: s.length,
        height: s.thickness,
      );

      final shadowRect = Rect.fromCenter(
        center: const Offset(1.2, 1.6),
        width: s.length,
        height: s.thickness,
      );
      shadowPaint.color = Colors.black.withValues(alpha: 0.10 * alpha);
      canvas.drawRRect(
        RRect.fromRectAndRadius(shadowRect, radius),
        shadowPaint,
      );

      final topColor = Color.lerp(
        s.color,
        Colors.white,
        0.45,
      )!.withValues(alpha: alpha);
      final crestColor = Color.lerp(
        s.color,
        Colors.white,
        0.75,
      )!.withValues(alpha: alpha);
      final bodyColor = s.color.withValues(alpha: alpha);
      final bottomColor = Color.lerp(
        s.color,
        Colors.black,
        0.22,
      )!.withValues(alpha: alpha);

      cylinderPaint.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [topColor, crestColor, bodyColor, bottomColor],
        stops: const [0.0, 0.20, 0.55, 1.0],
      ).createShader(rodRect);

      canvas.drawRRect(RRect.fromRectAndRadius(rodRect, radius), cylinderPaint);

      final highlightRect = Rect.fromLTWH(
        -halfLen * 0.70,
        -halfThick * 0.60,
        s.length * 0.70,
        s.thickness * 0.22,
      );
      highlightPaint.color = Colors.white.withValues(alpha: 0.45 * alpha);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          highlightRect,
          Radius.circular(s.thickness * 0.12),
        ),
        highlightPaint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant SprinkleRainPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.donutCenter != donutCenter ||
        oldDelegate.donutDiameter != donutDiameter;
  }
}
