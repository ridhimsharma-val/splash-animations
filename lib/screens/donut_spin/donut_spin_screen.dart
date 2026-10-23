import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/design_concept.dart';
import '../../theme/app_theme.dart';
import '../../widgets/category_badge.dart';
import 'widgets/app_home_placeholder.dart';
import 'widgets/donut_3d_painter.dart';
import 'widgets/donut_portal_clipper.dart';
import 'widgets/sprinkle_rain_painter.dart';

/// Complete interactive splash animation screen for Design 01 — Donut Spin.
/// Orchestrates all 4 motion phases:
/// - Phase A (0–650 ms): Donut drop, gravity acceleration, and gooey elastic bounce.
/// - Phase B (650–1,350 ms): 3D perspective spin and falling sprinkle rain.
/// - Phase C (1,350–1,950 ms): Donut-hole portal opening and camera plunge through the hole.
/// - Phase D (1,950–2,700 ms): Smooth reveal of the minimal App Home Placeholder.
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
    with SingleTickerProviderRefObserver, SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Total duration: 2,700 ms
  static const int _totalDurationMs = 2700;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _totalDurationMs),
    );

    // Auto-play automatically on screen entry
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Center(
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => Navigator.of(context).maybePop(),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFEADBCE)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 15,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7DDEB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Design 01',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFD81B60),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const CategoryBadge(
                category: DesignCategory.splashScreen,
                isCompact: true,
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: IconButton(
              tooltip: 'Replay Splash Animation',
              icon: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEADBCE)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.replay_rounded,
                  size: 18,
                  color: Color(0xFFD81B60),
                ),
              ),
              onPressed: _replay,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return _buildSplashComposition(context);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSplashComposition(BuildContext context) {
    final double t = _controller.value; // master 0.0 to 1.0

    // Normalized timeline phase thresholds:
    // 0 ms -> t = 0.0
    // 650 ms -> t = 0.241 (Phase A: Drop & Bounce)
    // 1350 ms -> t = 0.500 (Phase B: 3D Spin & Sprinkle Rain)
    // 1950 ms -> t = 0.722 (Phase C: Portal & Camera Plunge)
    // 2700 ms -> t = 1.000 (Phase D: App Home Placeholder)

    double donutY = 0.0;
    double donutTiltZ = 0.0;
    double squashX = 1.0;
    double squashY = 1.0;
    double shadowOpacity = 0.30;
    double shadowScale = 1.0;
    double pitch = 0.0;
    double yaw = 0.0;
    double lightSweep = 0.0;
    double holeGlow = 0.0;
    double cameraZoom = 1.0;
    double donutOpacity = 1.0;

    // -------------------------------------------------------------------------
    // Phase A: The Drop & Gooey Bounce (0 ms to 650 ms, t in [0.0, 0.241])
    // -------------------------------------------------------------------------
    if (t < 0.241) {
      if (t < 0.148) {
        // Falling with gravity acceleration
        final p = (t / 0.148).clamp(0.0, 1.0);
        final dropCurve = Curves.easeInQuad.transform(p);
        donutY = -420.0 + 420.0 * dropCurve;
        donutTiltZ = (-14.0 * (1.0 - dropCurve)) * (math.pi / 180.0);
        shadowOpacity = 0.02 + 0.28 * dropCurve;
        shadowScale = 0.30 + 0.70 * dropCurve;
      } else if (t < 0.178) {
        // Impact & squash deformation
        final p = ((t - 0.148) / 0.030).clamp(0.0, 1.0);
        final c = math.sin(p * math.pi / 2);
        squashY = 1.0 - 0.28 * c;
        squashX = 1.0 + 0.26 * c;
        donutY = 18.0 * c;
        shadowOpacity = 0.30 + 0.12 * c;
        shadowScale = 1.0 + 0.25 * c;
      } else if (t < 0.207) {
        // Elastic rebound & vertical stretch
        final p = ((t - 0.178) / 0.029).clamp(0.0, 1.0);
        final c = math.sin(p * math.pi / 2);
        squashY = 0.72 + (1.14 - 0.72) * c;
        squashX = 1.26 - (1.26 - 0.90) * c;
        donutY = 18.0 - 50.0 * c; // Rebounds upward to -32 px
        shadowOpacity = 0.42 - 0.20 * c;
        shadowScale = 1.25 - 0.40 * c;
      } else {
        // Dampened gooey settle
        final p = ((t - 0.207) / 0.034).clamp(0.0, 1.0);
        squashY = 1.14 + (1.0 - 1.14) * Curves.easeOutBack.transform(p);
        squashX = 0.90 + (1.0 - 0.90) * Curves.easeOutBack.transform(p);
        donutY = -32.0 * (1.0 - Curves.easeOutQuad.transform(p));
        shadowOpacity = 0.22 + 0.08 * p;
        shadowScale = 0.85 + 0.15 * p;
      }
    }
    // -------------------------------------------------------------------------
    // Phase B: 3D Spin & Sprinkle Rain (650 ms to 1350 ms, t in [0.241, 0.500])
    // -------------------------------------------------------------------------
    else if (t < 0.500) {
      final p = ((t - 0.241) / (0.500 - 0.241)).clamp(0.0, 1.0);
      final spinCurve = Curves.easeInOutCubic.transform(p);

      // True 3D Yaw rotation (full 360 degrees)
      yaw = 2 * math.pi * spinCurve;

      // Realistic pitch tilt showcasing the top glaze & 3D thickness
      pitch = 0.38 * math.sin(p * math.pi); // Max ~22 degrees tilt

      // Specular light sweep across the glaze
      lightSweep = -1.0 + 2.0 * p;
    }
    // -------------------------------------------------------------------------
    // Phase C: Donut-Hole Portal & Camera Move (1350 ms to 1950 ms, t in [0.500, 0.722])
    // -------------------------------------------------------------------------
    else if (t < 0.722) {
      yaw = 0.0;
      pitch = 0.0;
      donutY = 0.0;

      // Hole deepening & soft glow cue (1350 to 1500 ms)
      if (t < 0.556) {
        final p = ((t - 0.500) / 0.056).clamp(0.0, 1.0);
        holeGlow = Curves.easeInOut.transform(p);
      } else {
        holeGlow = 1.0;

        // Camera plunge & zoom through hole (1500 to 1950 ms)
        final p = ((t - 0.556) / (0.722 - 0.556)).clamp(0.0, 1.0);
        final plungeCurve = Curves.easeInCubic.transform(p);

        // Donut scales up dramatically as camera moves into the hole
        cameraZoom = 1.0 + 17.0 * plungeCurve;

        // Fade out donut as camera moves past the outer rim
        if (p > 0.80) {
          donutOpacity = (1.0 - (p - 0.80) / 0.20).clamp(0.0, 1.0);
        }
        shadowOpacity = (0.30 * (1.0 - p)).clamp(0.0, 1.0);
      }
    }
    // -------------------------------------------------------------------------
    // Phase D: App Home Placeholder (1950 ms to 2700 ms, t in [0.722, 1.000])
    // -------------------------------------------------------------------------
    else {
      donutOpacity = 0.0;
      shadowOpacity = 0.0;
      cameraZoom = 18.0;
    }

    // Sprinkle rain progress (active across Phase B and part of C)
    double sprinkleProgress = 0.0;
    if (t >= 0.241 && t <= 0.650) {
      sprinkleProgress = ((t - 0.241) / (0.650 - 0.241)).clamp(0.0, 1.0);
    }

    // Portal opening radius (tied precisely to donut hole radius)
    // Base inner hole radius is 34 px
    const double baseInnerHoleRadius = 34.0;
    double portalRadius = 0.0;
    if (t >= 0.556) {
      portalRadius = baseInnerHoleRadius * cameraZoom;
      if (t >= 0.722) {
        portalRadius = 1200.0; // Fully expanded
      }
    }

    // Placeholder enter progress
    double placeholderEnter = 0.0;
    if (t >= 0.722) {
      placeholderEnter = ((t - 0.722) / (1.000 - 0.722)).clamp(0.0, 1.0);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final centerOffset = Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);

        return Stack(
          fit: StackFit.expand,
          children: [
            // 1. Background layer: Vanilla cream
            Container(color: const Color(0xFFFFF6E9)),

            // 2. Sprinkle Rain Layer (celebratory cascade during spin)
            if (sprinkleProgress > 0.0 && sprinkleProgress < 1.0)
              Positioned.fill(
                child: CustomPaint(
                  painter: SprinkleRainPainter(progress: sprinkleProgress),
                ),
              ),

            // 3. Portal Revealed Layer: App Home Placeholder
            // Clipped to the expanding inner hole circle
            if (t >= 0.556)
              ClipPath(
                clipper: DonutHolePortalClipper(
                  center: centerOffset,
                  radius: portalRadius,
                ),
                child: AppHomePlaceholder(
                  enterProgress: placeholderEnter,
                ),
              ),

            // 4. Portal Inner Rim Glow Band (as camera moves through)
            if (portalRadius > 0.0 && portalRadius < 800.0)
              Positioned.fill(
                child: CustomPaint(
                  painter: PortalRimPainter(
                    center: centerOffset,
                    radius: portalRadius,
                    opacity: (1.0 - (portalRadius / 800.0)).clamp(0.0, 1.0),
                  ),
                ),
              ),

            // 5. 3D Donut Layer (Drop, Gooey Bounce, 3D Spin, Zoom Plunge)
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
                            size: const Size(220, 220),
                            painter: Donut3DPainter(
                              pitch: pitch,
                              yaw: yaw,
                              squashX: squashX,
                              squashY: squashY,
                              shadowOpacity: shadowOpacity,
                              shadowScale: shadowScale,
                              holeGlow: holeGlow,
                              lightSweep: lightSweep,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Helper mixin to prevent SingleTickerProviderStateMixin vs WidgetsBinding observer collision
mixin SingleTickerProviderRefObserver on State<DonutSpinScreen> {}
