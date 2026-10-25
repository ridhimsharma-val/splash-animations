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

  const DonutSpinScreen({super.key, this.concept});

  @override
  State<DonutSpinScreen> createState() => _DonutSpinScreenState();
}

class _DonutSpinScreenState extends State<DonutSpinScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isReplaying = false;

  // Total duration: 3,000 ms (3.0 seconds) across coordinated motion phases
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

    // Autoplay automatically once when screen opens
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _replay() {
    if (_isReplaying) return;
    _isReplaying = true;
    _controller.forward(from: 0.0).then((_) {
      if (mounted) {
        _isReplaying = false;
      }
    });
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
            child: Icon(icon, size: 16, color: AppColors.textPrimary),
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
    final screenDiagonal = math.sqrt(
      screenWidth * screenWidth + screenHeight * screenHeight,
    );

    // Responsive Donut Diameter: 62% of available screen width
    final donutDiameter = screenWidth * 0.62;
    final donutRadius = donutDiameter / 2.0;

    // Optical hole center and radius calibrated from 2D assets
    final innerHoleRadius = donutDiameter * DonutCalibration.holeRadiusRatio;
    final holeCenter = Offset(
      centerOffset.dx + donutDiameter * DonutCalibration.holeCenterOffsetX,
      centerOffset.dy + donutDiameter * DonutCalibration.holeCenterOffsetY,
    );

    // Zoom origin aligned precisely to the hole's optical center
    final holeAlignment = Alignment(
      2.0 * DonutCalibration.holeCenterOffsetX,
      2.0 * DonutCalibration.holeCenterOffsetY,
    );

    // Guaranteed off-screen start position
    final startDropY = -(screenHeight / 2.0 + donutRadius + 60.0);

    double donutX = 0.0;
    double donutY = 0.0;
    double donutRotation = 0.0;
    double squashX = 1.0;
    double squashY = 1.0;
    double shadowOpacity = 0.30;
    double shadowScale = 1.0;
    double cameraZoom = 1.0;
    double donutOpacity = 1.0;
    int frameIndex = 0;

    // Pink icing splash dynamics
    double splashOpacity = 0.0;
    double splashScale = 1.0;
    double splashRotation = 0.0;
    double icingOpacity = 0.0;

    // Sprinkle rain dynamics
    double sprinklesProgress = 0.0;
    bool sprinkleRainActive = false;

    // AppHomePlaceholder portal dynamics
    double placeholderOpacity = 0.0;
    double placeholderScale = 0.88;
    double placeholderEnter = 0.0;
    double portalRadius = 0.0;

    // -------------------------------------------------------------------------
    // Phase 1: Plain Donut Drop & Gooey Bounce (0–600 ms, t in [0.0, 0.200])
    // -------------------------------------------------------------------------
    if (t < 0.200) {
      frameIndex = 0; // Plain golden dough base (matching LEFT reference)
      icingOpacity = 0.0;
      splashOpacity = 0.0;
      sprinklesProgress = 0.0;

      if (t < 0.125) {
        // Falling with gravity acceleration from completely off-screen
        final p = (t / 0.125).clamp(0.0, 1.0);
        final dropCurve = Curves.easeInQuad.transform(p);
        donutY = startDropY * (1.0 - dropCurve);
        donutRotation = (-10.0 * (1.0 - dropCurve)) * (math.pi / 180.0);
        shadowOpacity = 0.02 + 0.28 * dropCurve;
        shadowScale = 0.25 + 0.75 * dropCurve;
      } else if (t < 0.155) {
        // Impact & gooey squash deformation
        final p = ((t - 0.125) / 0.030).clamp(0.0, 1.0);
        final c = math.sin(p * math.pi / 2);
        squashY = 1.0 - 0.28 * c;
        squashX = 1.0 + 0.26 * c;
        donutY = 16.0 * c;
        shadowOpacity = 0.30 + 0.12 * c;
        shadowScale = 1.0 + 0.24 * c;
      } else if (t < 0.180) {
        // Elastic rebound & vertical stretch
        final p = ((t - 0.155) / 0.025).clamp(0.0, 1.0);
        final c = math.sin(p * math.pi / 2);
        squashY = 0.72 + (1.14 - 0.72) * c;
        squashX = 1.26 - (1.26 - 0.90) * c;
        donutY = 16.0 - 44.0 * c;
        shadowOpacity = 0.42 - 0.20 * c;
        shadowScale = 1.24 - 0.38 * c;
      } else {
        // Dampened gooey settle to rest at (0, 0)
        final p = ((t - 0.180) / 0.020).clamp(0.0, 1.0);
        squashY = 1.14 + (1.0 - 1.14) * Curves.easeOutBack.transform(p);
        squashX = 0.90 + (1.0 - 0.90) * Curves.easeOutBack.transform(p);
        donutY = -28.0 * (1.0 - Curves.easeOutQuad.transform(p));
        shadowOpacity = 0.22 + 0.08 * p;
        shadowScale = 0.86 + 0.14 * p;
      }
    }
    // -------------------------------------------------------------------------
    // Phase 2: Pink Icing Splash & Glaze Reveal (600–1,350 ms, t in [0.200, 0.450])
    // -------------------------------------------------------------------------
    else if (t < 0.450) {
      final p = ((t - 0.200) / (0.450 - 0.200)).clamp(0.0, 1.0);
      frameIndex = (p * 47).round().clamp(0, 47);

      donutX = 0.0;
      donutRotation = 0.0;
      shadowOpacity = 0.30;
      shadowScale = 1.0;
      sprinklesProgress = 0.0;

      // 1. Splash burst & expansion around the donut (p in [0.0, 0.40])
      if (p < 0.40) {
        final splashProg = p / 0.40;
        // Explosive outward expansion starting around donut rim
        splashScale = 0.85 + 0.40 * Curves.easeOutCubic.transform(splashProg);
        // Slight liquid swirl rotation
        splashRotation = 0.18 * splashProg;
        // Fast burst in and smooth droplet fade out
        if (splashProg < 0.20) {
          splashOpacity = Curves.easeOut.transform(splashProg / 0.20);
        } else {
          splashOpacity =
              (1.0 - Curves.easeIn.transform((splashProg - 0.20) / 0.80)).clamp(
                0.0,
                1.0,
              );
        }
      } else {
        splashOpacity = 0.0;
      }

      // 2. Smooth reveal of the pastel-pink icing overlay (p in [0.08, 0.50])
      if (p < 0.08) {
        icingOpacity = 0.0;
      } else if (p < 0.50) {
        final icingProg = (p - 0.08) / 0.42;
        icingOpacity = Curves.easeInOutCubic.transform(icingProg);
      } else {
        icingOpacity = 1.0;
      }

      // 3. Subtle settling / bounce under glaze weight (p in [0.55, 0.85])
      if (p >= 0.55 && p < 0.85) {
        final bounceProg = (p - 0.55) / 0.30;
        final bounce = math.sin(bounceProg * math.pi);
        squashY = 1.0 - 0.045 * bounce;
        squashX = 1.0 + 0.035 * bounce;
        donutY = 3.5 * bounce;
        shadowScale = 1.0 + 0.05 * bounce;
        shadowOpacity = 0.30 + 0.03 * bounce;
      } else {
        squashX = 1.0;
        squashY = 1.0;
        donutY = 0.0;
      }
    }
    // -------------------------------------------------------------------------
    // Phase 3: Colorful Sprinkle Rain & Landing (1,350–2,050 ms, t in [0.450, 0.683])
    // -------------------------------------------------------------------------
    else if (t < 0.683) {
      final p = ((t - 0.450) / (0.683 - 0.450)).clamp(0.0, 1.0);

      frameIndex = 47; // Fully glazed strawberry pink donut
      donutY = 0.0;
      donutX = 0.0;
      donutRotation = 0.0;
      icingOpacity = 1.0;
      splashOpacity = 0.0;
      shadowOpacity = 0.30;
      shadowScale = 1.0;

      // Sprinkles cascade and land permanently onto the icing
      sprinklesProgress = p;
      sprinkleRainActive = true;
    }
    // -------------------------------------------------------------------------
    // Phase 4: Settle & Target Lock (2,050–2,200 ms, t in [0.683, 0.733])
    // -------------------------------------------------------------------------
    else if (t < 0.733) {
      frameIndex = 47;
      donutY = 0.0;
      donutX = 0.0;
      donutRotation = 0.0;
      icingOpacity = 1.0;
      splashOpacity = 0.0;
      sprinklesProgress = 1.0;
      sprinkleRainActive = false;

      cameraZoom = 1.0;
      shadowOpacity = 0.30;
      shadowScale = 1.0;

      // Destination is completely hidden behind donut during hold
      portalRadius = 0.0;
      placeholderOpacity = 0.0;
    }
    // -------------------------------------------------------------------------
    // Phase 5: Camera Plunges Inside the Circle of the Donut (2,200–2,650 ms, t in [0.733, 0.883])
    // -------------------------------------------------------------------------
    else if (t < 0.883) {
      final dProg = ((t - 0.733) / (0.883 - 0.733)).clamp(0.0, 1.0);
      final diveCurve = Curves.easeInCubic.transform(dProg);

      frameIndex = 47;
      donutY = 0.0;
      donutX = 0.0;
      donutRotation = 0.0;
      icingOpacity = 1.0;
      splashOpacity = 0.0;
      sprinklesProgress = 1.0;
      sprinkleRainActive = false;

      // Camera flies deep inside the donut hole (accelerating from 1.0x to 27.0x)
      cameraZoom = 1.0 + 26.0 * diveCurve;

      // The circular hole aperture expands around holeCenter
      portalRadius = innerHoleRadius * cameraZoom;

      // As camera enters the hole cylinder, outer dough rushes past the lens
      if (dProg < 0.55) {
        donutOpacity = 1.0;
      } else {
        donutOpacity = (1.0 - (dProg - 0.55) / 0.35).clamp(0.0, 1.0);
      }

      shadowOpacity = (0.30 * (1.0 - diveCurve)).clamp(0.0, 1.0);

      // Destination is glimpsed deep in the distance inside the circular tunnel
      placeholderOpacity = Curves.easeIn.transform(dProg);
      placeholderScale = 0.25 + 0.30 * diveCurve;
      placeholderEnter = 0.15 * diveCurve;
    }
    // -------------------------------------------------------------------------
    // Phase 6: Emerging Through the Hole — The App Opens! (2,650–3,000 ms, t in [0.883, 1.000])
    // -------------------------------------------------------------------------
    else {
      final oProg = ((t - 0.883) / (1.000 - 0.883)).clamp(0.0, 1.0);

      frameIndex = 47;
      donutOpacity = 0.0;
      donutY = 0.0;
      donutX = 0.0;
      shadowOpacity = 0.0;
      icingOpacity = 1.0;
      splashOpacity = 0.0;
      sprinklesProgress = 1.0;
      sprinkleRainActive = false;
      cameraZoom = 27.0;

      // Portal aperture blossoms open to engulf full screen
      portalRadius = math.max(
        innerHoleRadius * 27.0,
        (screenDiagonal * 1.25) * Curves.easeOutCubic.transform(oProg),
      );

      // The app blossoms and expands outward from the circle into full view
      placeholderOpacity = 1.0;
      placeholderScale = 0.55 + 0.45 * Curves.easeOutBack.transform(oProg);
      placeholderEnter = Curves.easeOutCubic.transform(oProg);

      if (t >= 0.980) {
        portalRadius = screenDiagonal * 1.5;
        placeholderScale = 1.0;
        placeholderEnter = 1.0;
      }
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Background layer: Warm vanilla cream
        Container(color: const Color(0xFFFFF6E9)),

        // 2. Ground Contact Shadow (anchored to ground plane)
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

        // 3. Destination Layer (AppHomePlaceholder)
        // - Before dive (t < 0.733): completely hidden behind donut (portalRadius == 0.0)
        // - During camera dive into hole (0.733 <= t < 0.883): glimpsed deep inside hole aperture
        // - Emerging from hole (0.883 <= t < 0.980): blossoming out from the center to fill screen
        // - Final destination (t >= 0.980): unclipped and full screen for complete interactivity
        if (t >= 0.980)
          Positioned.fill(
            child: AppHomePlaceholder(enterProgress: placeholderEnter),
          )
        else if (portalRadius > 0.0 && placeholderOpacity > 0.0)
          Positioned.fill(
            child: ClipPath(
              clipper: DonutHolePortalClipper(
                center: holeCenter,
                radius: portalRadius,
              ),
              child: Opacity(
                opacity: placeholderOpacity.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: placeholderScale,
                  alignment: Alignment.center,
                  child: AppHomePlaceholder(enterProgress: placeholderEnter),
                ),
              ),
            ),
          ),

        // 4. Pink Icing Splash Layer (Dynamic radial burst erupting from BEHIND the donut)
        if (splashOpacity > 0.0 && donutOpacity > 0.0)
          Positioned.fill(
            child: Opacity(
              opacity: donutOpacity,
              child: Center(
                child: Transform.translate(
                  offset: Offset(donutX, donutY),
                  child: Transform.rotate(
                    angle: donutRotation + splashRotation,
                    child: Transform.scale(
                      scale: cameraZoom * splashScale,
                      alignment: holeAlignment,
                      child: Opacity(
                        opacity: splashOpacity.clamp(0.0, 1.0),
                        child: Image.asset(
                          'assets/images/donut/icing_splash.png',
                          width: donutDiameter * 1.45,
                          height: donutDiameter * 1.45,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

        // 5. 2D Plain Donut + Pink Icing + Landed Sprinkles Layer (Foreground)
        // Scaled continuously around holeAlignment so the center hole stays fixed at holeCenter
        if (donutOpacity > 0.0)
          Positioned.fill(
            child: Opacity(
              opacity: donutOpacity,
              child: Center(
                child: Transform.translate(
                  offset: Offset(donutX, donutY),
                  child: Transform.scale(
                    scale: cameraZoom,
                    alignment: holeAlignment,
                    child: DonutFrameAnimator(
                      frameIndex: frameIndex,
                      diameter: donutDiameter,
                      squashX: squashX,
                      squashY: squashY,
                      rotation: donutRotation,
                      icingOpacity: icingOpacity,
                      sprinklesProgress: sprinklesProgress,
                    ),
                  ),
                ),
              ),
            ),
          ),

        // 6. Falling Sprinkle Rain Layer (Active only during Phase 3 cascade)
        if (sprinkleRainActive && donutOpacity > 0.0)
          Positioned.fill(
            child: CustomPaint(
              painter: SprinkleRainPainter(
                progress: sprinklesProgress,
                donutCenter: centerOffset + Offset(donutX, donutY),
                donutDiameter: donutDiameter,
              ),
            ),
          ),
      ],
    );
  }
}
