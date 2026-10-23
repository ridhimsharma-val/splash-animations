import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Photorealistic 3D Donut Widget.
/// Combines a high-resolution, photorealistic 3D food render asset with:
/// - True 3D perspective matrix transformations (pitch X and yaw Y).
/// - Dynamic volumetric dough thickness shading during 3D rotation.
/// - Specular gloss sweep that travels across the strawberry glaze.
/// - Inner hole depth glow cue aligned with the genuine circular hole.
class RealisticDonutWidget extends StatelessWidget {
  final double pitch; // X-axis tilt in radians
  final double yaw; // Y-axis spin in radians
  final double diameter; // Outer diameter
  final double ringRadius;
  final double tubeRadius;
  final double holeGlow; // 0.0 to 1.0
  final double lightSweep; // -1.0 to 1.0

  const RealisticDonutWidget({
    super.key,
    required this.pitch,
    required this.yaw,
    required this.diameter,
    required this.ringRadius,
    required this.tubeRadius,
    this.holeGlow = 0.0,
    this.lightSweep = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    // 3D Perspective Matrix with focal depth
    final matrix = Matrix4.identity()
      ..setEntry(3, 2, 0.0016) // Perspective foreshortening
      ..rotateX(pitch)
      ..rotateY(yaw);

    // Compute 3D thickness offset for volumetric dough edge
    final sinYaw = math.sin(yaw);
    final sinPitch = math.sin(pitch);
    final thicknessOffset = Offset(-sinYaw * 12.0, sinPitch * 10.0);
    final showThickness = sinYaw.abs() > 0.05 || sinPitch.abs() > 0.05;

    return SizedBox(
      width: diameter,
      height: diameter,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // 1. Volumetric Dough Thickness Layer (visible when rotating in 3D)
          if (showThickness)
            Transform(
              transform: matrix,
              alignment: Alignment.center,
              child: Transform.translate(
                offset: thicknessOffset,
                child: Container(
                  width: diameter * 0.96,
                  height: diameter * 0.96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFD48B47).withValues(alpha: 0.95), // Baked dough
                        const Color(0xFFB56C2B).withValues(alpha: 0.90), // Shaded dough
                        const Color(0xFF7A3E10).withValues(alpha: 0.85), // Deep crust
                      ],
                      stops: const [0.45, 0.75, 1.0],
                    ),
                  ),
                ),
              ),
            ),

          // 2. High-Resolution Photorealistic 3D Donut Asset
          Transform(
            transform: matrix,
            alignment: Alignment.center,
            child: Image.asset(
              'assets/images/donut/donut_3d_photoreal.png',
              width: diameter,
              height: diameter,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              errorBuilder: (context, error, stackTrace) {
                // Graceful fallback for headless environments
                return Container(
                  width: diameter,
                  height: diameter,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF58FB3),
                    shape: BoxShape.circle,
                  ),
                );
              },
            ),
          ),

          // 3. Dynamic Specular Gloss Sweep across the strawberry glaze
          if (lightSweep.abs() < 0.95)
            Transform(
              transform: matrix,
              alignment: Alignment.center,
              child: IgnorePointer(
                child: CustomPaint(
                  size: Size(diameter, diameter),
                  painter: _GlossSweepPainter(
                    sweepPosition: lightSweep,
                    ringRadius: ringRadius,
                    tubeRadius: tubeRadius,
                  ),
                ),
              ),
            ),

          // 4. Soft pink-cream glow inside the inner hole
          if (holeGlow > 0.0)
            IgnorePointer(
              child: CustomPaint(
                size: Size(diameter, diameter),
                painter: _HoleGlowPainter(
                  holeGlow: holeGlow,
                  innerRadius: (ringRadius - tubeRadius),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Dynamic gloss sheen that sweeps across the rounded glaze surface
class _GlossSweepPainter extends CustomPainter {
  final double sweepPosition; // -1.0 to 1.0
  final double ringRadius;
  final double tubeRadius;

  const _GlossSweepPainter({
    required this.sweepPosition,
    required this.ringRadius,
    required this.tubeRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final sweepX = center.dx + sweepPosition * (size.width * 0.40);

    final sweepRect = Rect.fromCircle(
      center: Offset(sweepX, center.dy - size.height * 0.12),
      radius: size.width * 0.28,
    );

    final sweepPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.35),
          Colors.white.withValues(alpha: 0.15),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(sweepRect)
      ..blendMode = BlendMode.screen;

    canvas.drawOval(sweepRect, sweepPaint);
  }

  @override
  bool shouldRepaint(covariant _GlossSweepPainter oldDelegate) {
    return oldDelegate.sweepPosition != sweepPosition;
  }
}

/// Soft glowing pink-cream cue emerging from the actual donut hole
class _HoleGlowPainter extends CustomPainter {
  final double holeGlow;
  final double innerRadius;

  const _HoleGlowPainter({
    required this.holeGlow,
    required this.innerRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = innerRadius * 1.30 * holeGlow;

    final glowRect = Rect.fromCircle(center: center, radius: radius);
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFF6E9).withValues(alpha: 0.85 * holeGlow),
          const Color(0xFFF7DDEB).withValues(alpha: 0.55 * holeGlow),
          const Color(0xFFF58FB3).withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(glowRect);

    canvas.drawCircle(center, radius, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _HoleGlowPainter oldDelegate) {
    return oldDelegate.holeGlow != holeGlow ||
        oldDelegate.innerRadius != innerRadius;
  }
}
