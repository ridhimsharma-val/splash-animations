import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/design_concept.dart';
import 'widgets/floating_ingredients_widget.dart';
import 'widgets/freshness_ring_painter.dart';
import 'widgets/fridge_cabinet_widget.dart';
import 'widgets/fridge_door_widget.dart';
import 'widgets/nutrifridge_brand_reveal.dart';
import 'widgets/nutrifridge_home_placeholder.dart';

/// Design 02 — NutriFridge: Magic Fridge Splash Animation.
///
/// Master sequence:
/// - Scene 1 (0.00–0.18): Refrigerator arrives with soft spring bounce. Door completely closed.
/// - Scene 2 (0.18–0.28): Magical in-place door dissolve (1.0 -> 0.0) revealing illuminated shelves.
/// - Scene 3 (0.28–0.54): 7 fresh ingredients emerge from shelves with smooth staggered arcs.
/// - Scene 4a (0.54–0.68): Ingredients gather into circular orbit as freshness ring draws 360°.
/// - Scene 4b (0.68–0.82): The formed ring & ingredients rotate dynamically in an orbital swirl,
///   gently contracting inward and leading directly into the centered wordmark logo.
/// - Scene 5 (0.82–0.94): Centered NutriFridge brand logo enters with gentle upward motion.
/// - Scene 6 (0.94–1.00): Stable logo hold for 600–800 ms with seamless transition to dashboard.
class MagicFridgeScreen extends StatefulWidget {
  final DesignConcept? concept;

  const MagicFridgeScreen({super.key, this.concept});

  @override
  State<MagicFridgeScreen> createState() => _MagicFridgeScreenState();
}

class _MagicFridgeScreenState extends State<MagicFridgeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _showDestination = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4400),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() {
          _showDestination = true;
        });
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _replay() {
    if (!mounted) return;
    setState(() {
      _showDestination = false;
    });
    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F4), // Fresh soft sage background
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
                    builder: (context, child) {
                      return _buildSceneCanvas(context, constraints);
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
                              onTap: () => Navigator.of(context).maybePop(),
                            ),

                            // Replay Splash Animation Button
                            _buildCircleButton(
                              icon: Icons.replay_rounded,
                              tooltip: 'Replay Magic Fridge Splash',
                              onTap: _replay,
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
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.90),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE8EFE9), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Icon(icon, size: 18, color: const Color(0xFF20542C)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSceneCanvas(BuildContext context, BoxConstraints constraints) {
    final double t = _controller.value; // Master timeline progress 0.0 to 1.0

    final screenWidth = constraints.maxWidth;
    final screenHeight = constraints.maxHeight;
    final centerOffset = Offset(screenWidth / 2, screenHeight / 2 - 14);

    // Moderately increased, responsive fridge dimensions with balanced negative space
    final fridgeWidth = (screenWidth * 0.54).clamp(195.0, 275.0);
    final fridgeHeight = fridgeWidth * 1.48;

    // -------------------------------------------------------------------------
    // Timeline variables
    // -------------------------------------------------------------------------
    double fridgeY = 0.0;
    double fridgeScale = 1.0;
    double fridgeOpacity = 1.0;
    double shadowScale = 1.0;
    double shadowOpacity = 0.25;
    double doorOpacity = 1.0; // 1.0 initially closed
    double interiorGlow = 0.0;
    double freshnessRingProgress = 0.0;
    double freshnessRingOpacity = 0.0;
    double ringRotation = 0.0;
    double ringContract = 0.0;
    double brandProgress = 0.0;
    double homePlaceholderEnter = 0.0;

    // Scene 1: Fridge Arrival & Settling Bounce (0.00–0.18)
    if (t < 0.18) {
      final p = (t / 0.18).clamp(0.0, 1.0);
      final bounceCurve = Curves.easeOutBack.transform(p);
      fridgeY = 95.0 * (1.0 - bounceCurve);
      fridgeScale = 0.86 + 0.14 * bounceCurve;
      shadowScale = 0.45 + 0.55 * bounceCurve;
      shadowOpacity = 0.04 + 0.22 * bounceCurve;
      doorOpacity = 1.0; // Door remains completely closed
      interiorGlow = 0.0;
    }
    // Scene 2: Magical In-Place Door Dissolve (0.18–0.28, ~440ms)
    else if (t < 0.28) {
      final p = ((t - 0.18) / (0.28 - 0.18)).clamp(0.0, 1.0);
      fridgeY = 0.0;
      fridgeScale = 1.0;
      shadowScale = 1.0;
      shadowOpacity = 0.26;

      // Door smoothly dissolves in-place without swinging or sliding
      doorOpacity = (1.0 - Curves.easeInOut.transform(p)).clamp(0.0, 1.0);
      // Warm interior illumination rises as door dissolves
      interiorGlow = Curves.easeIn.transform(p);
    }
    // Scene 3: Ingredients Emerge from Shelves (0.28–0.54)
    else if (t < 0.54) {
      fridgeY = 0.0;
      fridgeScale = 1.0;
      shadowScale = 1.0;
      shadowOpacity = 0.26;
      doorOpacity = 0.0; // Door remains invisible
      interiorGlow = 1.0;
      freshnessRingOpacity = 0.0;
    }
    // Scene 4a: Ingredients Orbit & Ring Draws (0.54–0.68)
    else if (t < 0.68) {
      final p = ((t - 0.54) / (0.68 - 0.54)).clamp(0.0, 1.0);
      fridgeY = 0.0;
      fridgeScale = 1.0;
      shadowScale = 1.0;
      shadowOpacity = 0.26;
      doorOpacity = 0.0;
      interiorGlow = 1.0;

      freshnessRingProgress = Curves.easeInOutCubic.transform(p);
      freshnessRingOpacity = Curves.easeIn.transform(p);
      ringRotation = 0.0;
      ringContract = 0.0;
    }
    // Scene 4b: Ring & Ingredients Rotate in Orbital Swirl, Leading to Wordmark (0.68–0.82)
    else if (t < 0.82) {
      final p = ((t - 0.68) / (0.82 - 0.68)).clamp(0.0, 1.0);
      doorOpacity = 0.0;
      interiorGlow = 1.0;

      // Ring is fully formed and smoothly spins by ~330°
      freshnessRingProgress = 1.0;
      ringRotation = Curves.easeInOutCubic.transform(p) * (1.85 * math.pi);

      // In the second half of the swirl (p >= 0.50, t >= 0.75),
      // the rotating ring, ingredients, and fridge gently contract and dissolve
      if (p >= 0.50) {
        final contractProg = (p - 0.50) / 0.50;
        ringContract = Curves.easeIn.transform(contractProg);
        final fadeOut = (1.0 - contractProg).clamp(0.0, 1.0);

        freshnessRingOpacity = fadeOut;
        fridgeOpacity = fadeOut;
        shadowOpacity = 0.26 * fadeOut;
        fridgeScale = 1.0 - 0.08 * contractProg;
      } else {
        ringContract = 0.0;
        freshnessRingOpacity = 1.0;
        fridgeOpacity = 1.0;
        shadowOpacity = 0.26;
        fridgeScale = 1.0;
      }
      fridgeY = 0.0;
      shadowScale = 1.0;
    }
    // Scene 5: Centered NutriFridge Logo Reveal (0.82–0.94)
    else if (t < 0.94) {
      final p = ((t - 0.82) / (0.94 - 0.82)).clamp(0.0, 1.0);
      fridgeOpacity = 0.0;
      shadowOpacity = 0.0;
      doorOpacity = 0.0;
      freshnessRingOpacity = 0.0;

      brandProgress = p;
    }
    // Scene 6: Stable Logo Hold & Destination Transition (0.94–1.00)
    else {
      final p = ((t - 0.94) / (1.00 - 0.94)).clamp(0.0, 1.0);
      fridgeOpacity = 0.0;
      shadowOpacity = 0.0;
      doorOpacity = 0.0;
      freshnessRingOpacity = 0.0;
      brandProgress = 1.0; // Clean, stable hold

      if (_showDestination) {
        homePlaceholderEnter = Curves.easeOutCubic.transform(p);
      }
    }

    final fridgeLeft = centerOffset.dx - fridgeWidth / 2;
    final fridgeTop = centerOffset.dy - fridgeHeight / 2 + fridgeY;

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Soft Warm Cream / Sage Background
        Container(color: const Color(0xFFF4F7F4)),

        // 2. Soft Contact Ground Shadow underneath Fridge
        if (shadowOpacity > 0.01)
          Positioned(
            left: centerOffset.dx - (fridgeWidth * 0.65 * shadowScale),
            top: centerOffset.dy + fridgeHeight / 2 - 8 + fridgeY,
            width: fridgeWidth * 1.30 * shadowScale,
            height: 26 * shadowScale,
            child: Opacity(
              opacity: shadowOpacity.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.elliptical(
                      fridgeWidth * 1.30 * shadowScale,
                      26 * shadowScale,
                    ),
                  ),
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF2E7D32).withValues(alpha: 0.35),
                      Colors.transparent,
                    ],
                    stops: const [0.35, 1.0],
                  ),
                ),
              ),
            ),
          ),

        // 3. Refrigerator Cabinet Body (With shelves & interior glow)
        if (fridgeOpacity > 0.01)
          Positioned(
            left: fridgeLeft,
            top: fridgeTop,
            width: fridgeWidth,
            height: fridgeHeight,
            child: Opacity(
              opacity: fridgeOpacity.clamp(0.0, 1.0),
              child: Transform.scale(
                scale: fridgeScale,
                alignment: Alignment.center,
                child: FridgeCabinetWidget(
                  width: fridgeWidth,
                  height: fridgeHeight,
                  interiorGlowProgress: interiorGlow,
                ),
              ),
            ),
          ),

        // 4. Floating Fresh Ingredients (Emerging from shelves, orbiting, and swirling)
        if (t >= 0.27 && t < 0.83)
          Positioned.fill(
            child: FloatingIngredientsWidget(
              progress: t,
              canvasWidth: screenWidth,
              canvasHeight: screenHeight,
              fridgeCenter: centerOffset + Offset(0, fridgeY),
              fridgeWidth: fridgeWidth,
              fridgeHeight: fridgeHeight,
              ringRotation: ringRotation,
              ringContract: ringContract,
            ),
          ),

        // 5. Refrigerator Door (In-place magical dissolve overlay)
        if (fridgeOpacity > 0.01 && doorOpacity > 0.005)
          Positioned(
            left: fridgeLeft,
            top: fridgeTop,
            width: fridgeWidth,
            height: fridgeHeight,
            child: Opacity(
              opacity: fridgeOpacity.clamp(0.0, 1.0),
              child: Transform.scale(
                scale: fridgeScale,
                alignment: Alignment.center,
                child: FridgeDoorWidget(
                  width: fridgeWidth,
                  height: fridgeHeight,
                  doorOpacity: doorOpacity,
                ),
              ),
            ),
          ),

        // 6. Orbital Freshness Ring (Progressive draw & dynamic rotation)
        if (freshnessRingOpacity > 0.01)
          Positioned.fill(
            child: CustomPaint(
              painter: FreshnessRingPainter(
                center: centerOffset,
                radius: screenWidth * 0.38,
                progress: freshnessRingProgress,
                rotation: ringRotation,
                opacity: freshnessRingOpacity,
              ),
            ),
          ),

        // 7. Uncluttered NutriFridge Brand Logo Payoff (Scene 5 & 6)
        if (brandProgress > 0.01 && !_showDestination)
          Positioned.fill(
            child: NutriFridgeBrandReveal(
              progress: brandProgress,
              canvasWidth: screenWidth,
            ),
          ),

        // 8. NutriFridge Home Placeholder Destination Screen
        if (_showDestination)
          Positioned.fill(
            child: NutriFridgeHomePlaceholder(
              enterProgress: homePlaceholderEnter,
            ),
          ),
      ],
    );
  }
}
