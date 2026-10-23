import 'package:flutter/material.dart';

/// Photorealistic 3D Donut Widget.
/// Displays the high-resolution, organically anti-aliased 3D donut asset
/// with authentic 3D perspective matrix transformations (pitch X and yaw Y),
/// smooth studio lighting, and an unobstructed center hole.
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
    // 3D Perspective Matrix with realistic focal depth
    final matrix = Matrix4.identity()
      ..setEntry(3, 2, 0.0016) // Natural perspective foreshortening
      ..rotateX(pitch)
      ..rotateY(yaw);

    return SizedBox(
      width: diameter,
      height: diameter,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // 1. High-Resolution Photorealistic 3D Donut Asset
          // Preserves the natural porous dough texture, glossy icing, and organic center hole
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

          // 2. Subtle soft studio specular highlight sheen sweeping across the glaze
          if (lightSweep.abs() < 0.92)
            Transform(
              transform: matrix,
              alignment: Alignment.center,
              child: IgnorePointer(
                child: CustomPaint(
                  size: Size(diameter, diameter),
                  painter: _StudioGlossSweepPainter(
                    sweepPosition: lightSweep,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Gentle, soft studio light sheen that sweeps across the rounded glaze surface
class _StudioGlossSweepPainter extends CustomPainter {
  final double sweepPosition; // -1.0 to 1.0

  const _StudioGlossSweepPainter({
    required this.sweepPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Upper glaze area highlight
    final sweepX = center.dx + sweepPosition * (size.width * 0.32);
    final sweepY = center.dy - size.height * 0.16;

    final sweepRect = Rect.fromCenter(
      center: Offset(sweepX, sweepY),
      width: size.width * 0.42,
      height: size.height * 0.28,
    );

    final sweepPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.22),
          Colors.white.withValues(alpha: 0.08),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.50, 1.0],
      ).createShader(sweepRect)
      ..blendMode = BlendMode.screen;

    canvas.drawOval(sweepRect, sweepPaint);
  }

  @override
  bool shouldRepaint(covariant _StudioGlossSweepPainter oldDelegate) {
    return oldDelegate.sweepPosition != sweepPosition;
  }
}
