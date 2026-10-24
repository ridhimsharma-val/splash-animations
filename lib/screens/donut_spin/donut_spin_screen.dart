import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/design_concept.dart';
import '../../theme/app_theme.dart';
import 'widgets/app_home_placeholder.dart';
import 'widgets/donut_frame_animator.dart';
import 'widgets/donut_ground_shadow_painter.dart';
import 'widgets/donut_portal_clipper.dart';
import 'widgets/sprinkle_rain_painter.dart';

/// Complete interactive mobile splash animation screen for Design 01 — Donut Spin.
/// Mobile-first edge-to-edge presentation orchestrating 4 motion phases:
/// - Phase 1 (0–650 ms): Plain golden donut drop from off-screen, gravity acceleration, gooey squash/stretch bounce.
/// - Phase 2 (650–1,550 ms): True 3D diagonal 360° rotation with progressive strawberry glaze spreading across the same donut.
/// - Phase 3 (1,550–2,150 ms): Glazed donut at rest, 3D candy sprinkles pop on glaze, celebration falling sprinkle cascade, subtle camera zoom.
/// - Phase 4 (2,150–3,000 ms): Seamless portal transition originating precisely from the donut's calibrated center hole revealing AppHomePlaceholder.
class DonutSpinScreen extends StatefulWidget {
  final DesignConcept? concept;

  const DonutSpinScreen({
    super.key,
    this.concept,
  });

  @override
  State<DonutSpinScreen> createState() => _DonutSpinScreenState();
}

class _DonutSpinScreenState extends State<DonutSpinScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Total duration: 3,000 ms (3.0 seconds) across 4 clearly delineated phases
  static const int _totalDurationMs = 3000;

  @override
  void initState() {
    super.initState();
    // Warm up the GPU texture atlas cache as early as possible
    DonutAtlasManager.ensureLoaded();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _totalDurationMs),
    );

    // Autoplay automatically when screen opens
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _replay() {
    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6E9), // Warm vanilla cream
      body: Center(
        child: ConstrainedBox(
          // Mobile container: full edge-to-edge on phones, capped at 460 on wide desktop/web
          constraints: const BoxConstraints(maxWidth: 460),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  // 1. Full-screen active splash animation canvas
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      return _buildSplashCanvas(context, constraints);
                    },
                  ),

                  // 2. Unobtrusive floating controls outside focal composition
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Back Navigation Button
                            _buildCircleButton(
                              icon: Icons.arrow_back_ios_new_rounded,
                              tooltip: 'Back to Gallery',
                              onPressed: () => Navigator.of(context).maybePop(),
                            ),

                            // Replay Splash Animation Button
                            _buildCircleButton(
                              icon: Icons.replay_rounded,
                              tooltip: 'Replay Splash Animation',
                              onPressed: _replay,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onPressed,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.88),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFEADBCE).withValues(alpha: 0.8),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              icon,
              size: 16,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSplashCanvas(BuildContext context, BoxConstraints constraints) {
    final double t = _controller.value; // master progress 0.0 to 1.0

    final screenWidth = constraints.maxWidth;
    final screenHeight = constraints.maxHeight;
    final centerOffset = Offset(screenWidth / 2, screenHeight / 2);

    // Responsive Donut Diameter: 62% of available screen width
    final donutDiameter = screenWidth * 0.62;
    final donutRadius = donutDiameter / 2.0;

    // Calibrated inner hole radius:
    // Empirically measured from 320x320 analytical 3D raymarch frame (radius = 58 px, ratio = 0.18125)
    final innerHoleRadius = donutDiameter * DonutCalibration.holeRadiusRatio;

    // Guaranteed off-screen start position
    final startDropY = -(screenHeight / 2.0 + donutRadius + 60.0);

    double donutY = 0.0;
    double donutTiltZ = 0.0;
    double squashX = 1.0;
    double squashY = 1.0;
    double shadowOpacity = 0.30;
    double shadowScale = 1.0;
    double cameraZoom = 1.0;
    double donutOpacity = 1.0;
    int frameIndex = 0;
    double sprinklePopProgress = 0.0;
    double sprinkleRainProgress = 0.0;

    // -------------------------------------------------------------------------
    // Phase 1: Plain Donut Drop & Gooey Bounce (0–650 ms, t in [0.0, 0.217])
    // -------------------------------------------------------------------------
    if (t < 0.217) {
      frameIndex = 0; // Plain golden dough base, no glaze, no sprinkles

      if (t < 0.133) {
        // Falling with gravity acceleration from completely off-screen
        final p = (t / 0.133).clamp(0.0, 1.0);
        final dropCurve = Curves.easeInQuad.transform(p);
        donutY = startDropY * (1.0 - dropCurve);
        donutTiltZ = (-10.0 * (1.0 - dropCurve)) * (math.pi / 180.0);
        shadowOpacity = 0.02 + 0.28 * dropCurve;
        shadowScale = 0.25 + 0.75 * dropCurve;
      } else if (t < 0.160) {
        // Impact & gooey squash deformation
        final p = ((t - 0.133) / 0.027).clamp(0.0, 1.0);
        final c = math.sin(p * math.pi / 2);
        squashY = 1.0 - 0.28 * c;
        squashX = 1.0 + 0.26 * c;
        donutY = 16.0 * c;
        shadowOpacity = 0.30 + 0.12 * c;
        shadowScale = 1.0 + 0.24 * c;
      } else if (t < 0.187) {
        // Elastic rebound & vertical stretch
        final p = ((t - 0.160) / 0.027).clamp(0.0, 1.0);
        final c = math.sin(p * math.pi / 2);
        squashY = 0.72 + (1.14 - 0.72) * c;
        squashX = 1.26 - (1.26 - 0.90) * c;
        donutY = 16.0 - 44.0 * c; // Rebounds upward to -28 px
        shadowOpacity = 0.42 - 0.20 * c;
        shadowScale = 1.24 - 0.38 * c;
      } else {
        // Dampened gooey settle to rest at (0, 0)
        final p = ((t - 0.187) / 0.030).clamp(0.0, 1.0);
        squashY = 1.14 + (1.0 - 1.14) * Curves.easeOutBack.transform(p);
        squashX = 0.90 + (1.0 - 0.90) * Curves.easeOutBack.transform(p);
        donutY = -28.0 * (1.0 - Curves.easeOutQuad.transform(p));
        shadowOpacity = 0.22 + 0.08 * p;
        shadowScale = 0.86 + 0.14 * p;
      }
    }
    // -------------------------------------------------------------------------
    // Phase 2: Diagonal 360° Spin + Progressive Pink Glaze (650–1,550 ms, t in [0.217, 0.517])
    // -------------------------------------------------------------------------
    else if (t < 0.517) {
      final p = ((t - 0.217) / (0.517 - 0.217)).clamp(0.0, 1.0);
      final spinCurve = Curves.easeInOutCubic.transform(p);

      // Advance through the 48 photorealistic 3D frames showing genuine diagonal rotation
      // and continuous pink icing spread over the same donut
      frameIndex = (spinCurve * 47).round().clamp(0, 47);

      donutY = 0.0;
      squashX = 1.0;
      squashY = 1.0;
      shadowOpacity = 0.30;
      shadowScale = 1.0;
    }
    // -------------------------------------------------------------------------
    // Phase 3: Glazed Donut at Rest, Sprinkles Pop-in & Celebration Cascade (1,550–2,150 ms, t in [0.517, 0.717])
    // -------------------------------------------------------------------------
    else if (t < 0.717) {
      final p = ((t - 0.517) / (0.717 - 0.517)).clamp(0.0, 1.0);

      frameIndex = 47; // Fully glazed strawberry pink donut facing camera
      donutY = 0.0;

      // Surface candy sprinkles dynamically pop on the glaze with micro-bounces
      sprinklePopProgress = Curves.easeOutQuad.transform(p);

      // Background and foreground falling sprinkle rain cascade
      sprinkleRainProgress = p;

      // Subtle camera zoom (1.0x to 1.14x) for dramatic focal lock
      cameraZoom = 1.0 + 0.14 * Curves.easeInOut.transform(p);
      shadowOpacity = 0.30;
      shadowScale = 1.0;
    }
    // -------------------------------------------------------------------------
    // Phase 4: Calibrated Center-Hole Portal Plunge (2,150–3,000 ms, t in [0.717, 1.000])
    // -------------------------------------------------------------------------
    else {
      final p = ((t - 0.717) / (1.000 - 0.717)).clamp(0.0, 1.0);
      final plungeCurve = Curves.easeInOutCubic.transform(p);

      frameIndex = 47;
      donutY = 0.0;
      sprinklePopProgress = 1.0;

      // Camera zooms forward through the opening (from 1.14x to 4.2x)
      cameraZoom = 1.14 + 3.06 * plungeCurve;

      // Fade out donut smoothly as the camera passes through the opening plane
      if (p < 0.35) {
        donutOpacity = 1.0;
      } else {
        donutOpacity = (1.0 - (p - 0.35) / 0.50).clamp(0.0, 1.0);
      }

      shadowOpacity = (0.30 * (1.0 - plungeCurve)).clamp(0.0, 1.0);
      sprinkleRainProgress = (1.0 - p * 0.7).clamp(0.0, 1.0);
    }

    // Screen diagonal for complete corner-to-corner portal expansion
    final screenDiagonal =
        math.sqrt(screenWidth * screenWidth + screenHeight * screenHeight);

    // Continuous, smooth portal expansion originating strictly from the calibrated hole
    double portalRadius = 0.0;
    if (t >= 0.717) {
      final p = ((t - 0.717) / (1.000 - 0.717)).clamp(0.0, 1.0);
      final baseHole = innerHoleRadius * cameraZoom;
      portalRadius = baseHole + (screenDiagonal * 1.25 - baseHole) * math.pow(p, 2.2);
    }

    // Placeholder enter progress
    double placeholderEnter = 0.0;
    if (t >= 0.717) {
      final p = ((t - 0.717) / (1.000 - 0.717)).clamp(0.0, 1.0);
      placeholderEnter = 0.40 + 0.60 * Curves.easeOutCubic.transform(p);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Background layer: Warm vanilla cream
        Container(color: const Color(0xFFFFF6E9)),

        // 2. Ground Contact Shadow (anchored to ground plane, responsive to drop & squashing)
        if (shadowOpacity > 0.0)
          Positioned.fill(
            child: CustomPaint(
              painter: DonutGroundShadowPainter(
                center: centerOffset,
                donutRadius: donutRadius,
                squashX: squashX,
                shadowOpacity: shadowOpacity,
                shadowScale: shadowScale,
              ),
            ),
          ),

        // 3. Background Candy Sprinkles Layer (tumbles behind the 3D donut)
        if (sprinkleRainProgress > 0.0 && donutOpacity > 0.1)
          Positioned.fill(
            child: CustomPaint(
              painter: SprinkleRainPainter(
                progress: sprinkleRainProgress,
                depthFilter: SprinkleDepthFilter.backgroundOnly,
              ),
            ),
          ),

        // 4. Portal Revealed Layer: Minimal App Home Placeholder
        // Smoothly revealed through the donut's actual calibrated center opening
        if (t >= 0.717)
          ClipPath(
            clipper: DonutHolePortalClipper(
              center: centerOffset,
              radius: portalRadius,
            ),
            child: AppHomePlaceholder(
              enterProgress: placeholderEnter,
            ),
          ),

        // 5. Portal Inner Rim Glow Band (subtle soft illumination while passing through)
        if (portalRadius > 0.0 &&
            portalRadius < screenDiagonal * 0.85 &&
            donutOpacity > 0.15)
          Positioned.fill(
            child: CustomPaint(
              painter: PortalRimPainter(
                center: centerOffset,
                radius: portalRadius,
                opacity: donutOpacity * 0.60,
              ),
            ),
          ),

        // 6. Photorealistic 3D Donut Layer
        // (Drop, Gooey Bounce, Diagonal 360° Spin + Progressive Glaze, Sprinkles, Zoom Plunge)
        if (donutOpacity > 0.0)
          Positioned.fill(
            child: Opacity(
              opacity: donutOpacity,
              child: Center(
                child: Transform.translate(
                  offset: Offset(0.0, donutY),
                  child: Transform.rotate(
                    angle: donutTiltZ,
                    child: Transform.scale(
                      scale: cameraZoom,
                      child: DonutFrameAnimator(
                        frameIndex: frameIndex,
                        diameter: donutDiameter,
                        squashX: squashX,
                        squashY: squashY,
                        sprinklePopProgress: sprinklePopProgress,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

        // 7. Foreground Candy Sprinkles Layer (tumbles in front of the donut glaze)
        if (sprinkleRainProgress > 0.0 && donutOpacity > 0.1)
          Positioned.fill(
            child: CustomPaint(
              painter: SprinkleRainPainter(
                progress: sprinkleRainProgress,
                depthFilter: SprinkleDepthFilter.foregroundOnly,
              ),
            ),
          ),
      ],
    );
  }
}
