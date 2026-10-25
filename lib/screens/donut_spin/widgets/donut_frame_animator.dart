import 'package:flutter/material.dart';

import 'sprinkle_rain_painter.dart';

/// Analytical calibration constants measured from donut_plain.png (1024x1024):
/// - Image size: 1024x1024 px
/// - Hole center: (516.4, 529.3)
/// - Hole radius: 90.2 px (~8.8% of diameter)
/// - Outer rim radius: 481.0 px (~47.0% of diameter)
class DonutCalibration {
  static const double frameSize = 1024.0;
  static const double holeRadius = 90.2;
  static const double outerRadius = 481.0;

  /// Inner hole radius relative to the rendered donut diameter (~0.0881).
  static const double holeRadiusRatio = holeRadius / frameSize;

  /// Outer radius relative to the rendered donut diameter (~0.4697).
  static const double outerRadiusRatio = outerRadius / frameSize;

  /// Center X offset relative to frame center: (516.4 - 512.0) / 1024.0 = 0.0043.
  static const double holeCenterOffsetX = (516.4 - 512.0) / frameSize;

  /// Center Y offset relative to frame center: (529.3 - 512.0) / 1024.0 = 0.0169.
  static const double holeCenterOffsetY = (529.3 - 512.0) / frameSize;
}

/// Compatibility manager for asset warmup.
class DonutAtlasManager {
  static bool get isLoaded => true;
  static Future<void> ensureLoaded() async {}
}

/// 2D Donut Animator Widget:
/// Displays `donut_plain.png`, `donut_icing.png`, and landed candy sprinkles
/// with identical bounds and transforms, supporting smooth opacity reveals
/// and camera zoom through the transparent center hole.
class DonutFrameAnimator extends StatelessWidget {
  final int frameIndex;
  final double diameter;
  final double squashX;
  final double squashY;
  final double rotation;
  final double icingOpacity;
  final double sprinklesProgress;

  const DonutFrameAnimator({
    super.key,
    this.frameIndex = 0,
    required this.diameter,
    this.squashX = 1.0,
    this.squashY = 1.0,
    this.rotation = 0.0,
    this.icingOpacity = 0.0,
    this.sprinklesProgress = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scaleX: squashX,
      scaleY: squashY,
      alignment: Alignment.center,
      child: Transform.rotate(
        angle: rotation,
        alignment: Alignment.center,
        child: SizedBox(
          width: diameter,
          height: diameter,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Plain Golden Donut Base Layer
              Image.asset(
                'assets/images/donut/donut_plain.png',
                width: diameter,
                height: diameter,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),

              // 2. Glossy Pastel-Pink Icing Overlay Layer
              // Aligned exactly over plain donut with identical canvas dimensions and transforms.
              if (icingOpacity > 0.0)
                Opacity(
                  opacity: icingOpacity.clamp(0.0, 1.0),
                  child: Image.asset(
                    'assets/images/donut/donut_icing.png',
                    width: diameter,
                    height: diameter,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),

              // 3. Landed 3D Candy Sprinkles Layer
              // Affixed securely to the strawberry icing, maintaining identical transforms & zoom.
              if (sprinklesProgress > 0.0)
                Positioned.fill(
                  child: CustomPaint(
                    painter: LandedSprinklesPainter(
                      progress: sprinklesProgress,
                      diameter: diameter,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
