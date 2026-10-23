import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/design_concept.dart';
import '../../theme/app_theme.dart';
import 'widgets/app_home_placeholder.dart';
import 'widgets/donut_3d_mesh_renderer.dart';
import 'widgets/donut_3d_painter.dart';
import 'widgets/donut_portal_clipper.dart';
import 'widgets/sprinkle_rain_painter.dart';

/// Complete interactive mobile splash animation screen for Design 01 — Donut Spin.
/// Mobile-first edge-to-edge presentation orchestrating 4 motion phases:
/// - Phase A (0–650 ms): Donut drop from completely off-screen, gravity acceleration, gooey squash/stretch bounce.
/// - Phase B (650–1,350 ms): 3D perspective spin, thickness tilt, light sweep, falling sprinkle rain.
/// - Phase C (1,350–1,950 ms): Hole glow, camera plunge expanding through the donut hole.
/// - Phase D (1,950–2,700 ms): Seamless reveal of the minimal App Home Placeholder.
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

  // Total duration: 2,700 ms (~2.7 seconds)
  static const int _totalDurationMs = 2700;

  @override
  void initState() {
    super.initState();
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
          // Mobile container: full edge-to-edge on phones, capped at 460 on wide web view
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

    // Dynamic Sizing:
    // Donut diameter occupies 62% of available screen width (strictly within 55%-70% requirement).
    // Proportions: major ring radius R = 0.67 * donutRadius, minor tube radius r = 0.33 * donutRadius.
    // Total outer radius = R + r = 1.0 * donutRadius = donutDiameter / 2.
    // Hole radius = R - r = 0.34 * donutRadius (~21% of screen width, clearly visible).
    final donutDiameter = screenWidth * 0.62;
    final donutRadius = donutDiameter / 2.0;
    final ringRadius = donutRadius * 0.67;
    final tubeRadius = donutRadius * 0.33;
    final innerHoleRadius = ringRadius - tubeRadius;

    // Guaranteed off-screen start position:
    // Screen top edge is at -(screenHeight / 2). Bottom of donut is at startDropY + donutRadius.
    // Making startDropY = -(screenHeight / 2 + donutRadius + 60) guarantees it is 100% off-screen.
    final startDropY = -(screenHeight / 2.0 + donutRadius + 60.0);

    double donutY = 0.0;
    double donutTiltZ = 0.0;
    double squashX = 1.0;
    double squashY = 1.0;
    double shadowOpacity = 0.30;
    double shadowScale = 1.0;
    double pitch = 0.0;
    double yaw = 0.0;
    double cameraZoom = 1.0;
    double donutOpacity = 1.0;

    // -------------------------------------------------------------------------
    // Phase A: The Drop & Gooey Elastic Bounce (0 ms to 650 ms, t in [0.0, 0.241])
    // -------------------------------------------------------------------------
    if (t < 0.241) {
      if (t < 0.148) {
        // Falling with gravity acceleration from completely off-screen
        final p = (t / 0.148).clamp(0.0, 1.0);
        final dropCurve = Curves.easeInQuad.transform(p);
        donutY = startDropY * (1.0 - dropCurve);
        donutTiltZ = (-12.0 * (1.0 - dropCurve)) * (math.pi / 180.0);
        shadowOpacity = 0.02 + 0.28 * dropCurve;
        shadowScale = 0.25 + 0.75 * dropCurve;
      } else if (t < 0.178) {
        // Impact & gooey squash deformation
        final p = ((t - 0.148) / 0.030).clamp(0.0, 1.0);
        final c = math.sin(p * math.pi / 2);
        squashY = 1.0 - 0.28 * c;
        squashX = 1.0 + 0.26 * c;
        donutY = 16.0 * c;
        shadowOpacity = 0.30 + 0.12 * c;
        shadowScale = 1.0 + 0.24 * c;
      } else if (t < 0.207) {
        // Elastic rebound & vertical stretch
        final p = ((t - 0.178) / 0.029).clamp(0.0, 1.0);
        final c = math.sin(p * math.pi / 2);
        squashY = 0.72 + (1.14 - 0.72) * c;
        squashX = 1.26 - (1.26 - 0.90) * c;
        donutY = 16.0 - 48.0 * c; // Rebounds upward to -32 px
        shadowOpacity = 0.42 - 0.20 * c;
        shadowScale = 1.24 - 0.40 * c;
      } else {
        // Dampened gooey settle
        final p = ((t - 0.207) / 0.034).clamp(0.0, 1.0);
        squashY = 1.14 + (1.0 - 1.14) * Curves.easeOutBack.transform(p);
        squashX = 0.90 + (1.0 - 0.90) * Curves.easeOutBack.transform(p);
        donutY = -32.0 * (1.0 - Curves.easeOutQuad.transform(p));
        shadowOpacity = 0.22 + 0.08 * p;
        shadowScale = 0.84 + 0.16 * p;
      }
    }
    // -------------------------------------------------------------------------
    // Phase B: 3D Spin & Sprinkle Rain (650 ms to 1,350 ms, t in [0.241, 0.500])
    // -------------------------------------------------------------------------
    else if (t < 0.500) {
      final p = ((t - 0.241) / (0.500 - 0.241)).clamp(0.0, 1.0);
      final spinCurve = Curves.easeInOutCubic.transform(p);

      // True 3D Yaw rotation (full 360 degrees)
      yaw = 2 * math.pi * spinCurve;

      // Realistic pitch tilt showcasing the top glaze & 3D thickness
      pitch = 0.38 * math.sin(p * math.pi); // Max ~22 degrees tilt
      shadowOpacity = 0.30;
      shadowScale = 1.0;
    }
    // -------------------------------------------------------------------------
    // Phase C: Donut-Hole Portal & Camera Move (1,350 ms to 1,950 ms, t in [0.500, 0.722])
    // -------------------------------------------------------------------------
    else if (t < 0.722) {
      yaw = 0.0;
      pitch = 0.0;
      donutY = 0.0;

      // Hole deepening & alignment cue (1350 to 1500 ms)
      if (t < 0.556) {
        shadowOpacity = 0.30;
      } else {
        // Camera plunges forward through the center opening (1500 to 1950 ms)
        final p = ((t - 0.556) / (0.722 - 0.556)).clamp(0.0, 1.0);
        final plungeCurve = Curves.easeInOutCubic.transform(p);

        // Donut scales up moderately (from 1.0 to 3.2x), moving outer body outside the viewport
        cameraZoom = 1.0 + 2.2 * plungeCurve;

        // Fade out donut smoothly as camera passes through the plane of the opening
        if (p < 0.35) {
          donutOpacity = 1.0;
        } else {
          donutOpacity = (1.0 - (p - 0.35) / 0.55).clamp(0.0, 1.0);
        }
        shadowOpacity = (0.30 * (1.0 - plungeCurve)).clamp(0.0, 1.0);
      }
    }
    // -------------------------------------------------------------------------
    // Phase D: App Home Placeholder (1,950 ms to 2,700 ms, t in [0.722, 1.000])
    // -------------------------------------------------------------------------
    else {
      donutOpacity = 0.0;
      shadowOpacity = 0.0;
      cameraZoom = 3.2;
    }

    // Sprinkle rain progress (active across Phase B and part of C)
    double sprinkleProgress = 0.0;
    if (t >= 0.241 && t <= 0.650) {
      sprinkleProgress = ((t - 0.241) / (0.650 - 0.241)).clamp(0.0, 1.0);
    }

    // Screen diagonal for complete corner-to-corner portal expansion
    final screenDiagonal =
        math.sqrt(screenWidth * screenWidth + screenHeight * screenHeight);

    // Continuous, smooth portal expansion originating from the actual donut hole
    double portalRadius = 0.0;
    if (t >= 0.500) {
      if (t < 0.556) {
        portalRadius = innerHoleRadius;
      } else if (t < 0.722) {
        final p = ((t - 0.556) / (0.722 - 0.556)).clamp(0.0, 1.0);
        final baseHole = innerHoleRadius * cameraZoom;
        portalRadius = baseHole + (screenDiagonal - baseHole) * math.pow(p, 2.0);
      } else {
        portalRadius = screenDiagonal * 1.2; // Fully expanded
      }
    }

    // Placeholder enter progress
    double placeholderEnter = 0.0;
    if (t >= 0.500) {
      if (t < 0.722) {
        final p = ((t - 0.500) / (0.722 - 0.500)).clamp(0.0, 1.0);
        placeholderEnter = 0.40 + 0.60 * Curves.easeInOut.transform(p);
      } else {
        placeholderEnter = 1.0;
      }
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
                ringRadius: ringRadius,
                tubeRadius: tubeRadius,
                squashX: squashX,
                shadowOpacity: shadowOpacity,
                shadowScale: shadowScale,
              ),
            ),
          ),

        // 3. Background Candy Sprinkles Layer (tumbles behind the 3D donut)
        if (sprinkleProgress > 0.0 && sprinkleProgress < 1.0)
          Positioned.fill(
            child: CustomPaint(
              painter: SprinkleRainPainter(
                progress: sprinkleProgress,
                depthFilter: SprinkleDepthFilter.backgroundOnly,
              ),
            ),
          ),

        // 4. Portal Revealed Layer: Minimal App Home Placeholder
        // Smoothly revealed through the donut's actual center opening
        if (t >= 0.500)
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

        // 6. Genuine 3D Donut Mesh Layer (Drop, Gooey Bounce, True 3D Spin, Zoom Plunge)
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
                      child: CustomPaint(
                        size: Size(donutDiameter, donutDiameter),
                        painter: Donut3DMeshRenderer(
                          pitch: pitch,
                          yaw: yaw,
                          ringRadius: ringRadius,
                          tubeRadius: tubeRadius,
                          squashX: squashX,
                          squashY: squashY,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

        // 7. Foreground Candy Sprinkles Layer (tumbles in front of the donut glaze)
        if (sprinkleProgress > 0.0 && sprinkleProgress < 1.0)
          Positioned.fill(
            child: CustomPaint(
              painter: SprinkleRainPainter(
                progress: sprinkleProgress,
                depthFilter: SprinkleDepthFilter.foregroundOnly,
              ),
            ),
          ),
      ],
    );
  }
}
