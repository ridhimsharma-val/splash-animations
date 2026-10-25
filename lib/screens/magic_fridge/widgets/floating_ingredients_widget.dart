import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Specification for each floating fresh ingredient item.
class IngredientItemData {
  final String assetName;
  final String label;
  final double baseSize; // Relative to canvas width [0.18, 0.22]
  final double startTrigger; // Master timeline progress [0.28, 0.48]
  final Offset shelfRelativeOffset; // Initial position on a cabinet shelf (relative to fridge size)
  final Offset
  burstOffset; // Mid-air burst offset (relative to canvas dimensions)
  final double targetAngle; // Angle in radians on the circular freshness ring
  final double initialRotation; // Rotation in radians

  const IngredientItemData({
    required this.assetName,
    required this.label,
    required this.baseSize,
    required this.startTrigger,
    required this.shelfRelativeOffset,
    required this.burstOffset,
    required this.targetAngle,
    required this.initialRotation,
  });
}

/// 6 fresh ingredients (milk bottle removed) with balanced hexagonal symmetry.
final List<IngredientItemData> kNutriIngredients = [
  // 1. Ripe Red Tomato — Top shelf (12 o'clock)
  const IngredientItemData(
    assetName: 'assets/images/magic_fridge/ingredient_tomato.png',
    label: 'Tomato',
    baseSize: 0.19,
    startTrigger: 0.28,
    shelfRelativeOffset: Offset(0.08, -0.16),
    burstOffset: Offset(0.24, -0.28),
    targetAngle: -math.pi / 2, // 12 o'clock
    initialRotation: 0.15,
  ),
  // 2. Fresh Broccoli Crown — Middle shelf (2 o'clock)
  const IngredientItemData(
    assetName: 'assets/images/magic_fridge/ingredient_broccoli.png',
    label: 'Broccoli',
    baseSize: 0.20,
    startTrigger: 0.32,
    shelfRelativeOffset: Offset(0.06, 0.00),
    burstOffset: Offset(0.36, -0.06),
    targetAngle: -math.pi / 2 + (math.pi / 3), // 2 o'clock
    initialRotation: -0.12,
  ),
  // 3. Sunny Citrus Lemon — Bottom shelf (4 o'clock)
  const IngredientItemData(
    assetName: 'assets/images/magic_fridge/ingredient_lemon.png',
    label: 'Lemon',
    baseSize: 0.18,
    startTrigger: 0.36,
    shelfRelativeOffset: Offset(0.12, 0.15),
    burstOffset: Offset(0.30, 0.22),
    targetAngle: -math.pi / 2 + (2 * math.pi / 3), // 4 o'clock
    initialRotation: 0.25,
  ),
  // 4. Rich Green Avocado — Middle shelf (6 o'clock)
  const IngredientItemData(
    assetName: 'assets/images/magic_fridge/ingredient_avocado.png',
    label: 'Avocado',
    baseSize: 0.20,
    startTrigger: 0.40,
    shelfRelativeOffset: Offset(-0.04, 0.00),
    burstOffset: Offset(0.00, 0.34),
    targetAngle: -math.pi / 2 + math.pi, // 6 o'clock
    initialRotation: 0.20,
  ),
  // 5. Crunchy Orange Carrot — Top shelf (8 o'clock)
  const IngredientItemData(
    assetName: 'assets/images/magic_fridge/ingredient_carrot.png',
    label: 'Carrot',
    baseSize: 0.21,
    startTrigger: 0.44,
    shelfRelativeOffset: Offset(-0.02, -0.16),
    burstOffset: Offset(-0.32, 0.16),
    targetAngle: -math.pi / 2 + (4 * math.pi / 3), // 8 o'clock
    initialRotation: -0.22,
  ),
  // 6. Fresh Green Leaf — Door emblem (10 o'clock)
  const IngredientItemData(
    assetName: 'assets/images/magic_fridge/ingredient_leaf.png',
    label: 'Leaf',
    baseSize: 0.17,
    startTrigger: 0.48,
    shelfRelativeOffset: Offset(-0.06, -0.10),
    burstOffset: Offset(-0.28, -0.22),
    targetAngle: -math.pi / 2 + (5 * math.pi / 3), // 10 o'clock
    initialRotation: 0.35,
  ),
];

/// Renders the 6 ingredients with smooth shelf emergence, orbital ring gathering,
/// and synchronous swirling rotation that leads directly into the brand reveal.
class FloatingIngredientsWidget extends StatelessWidget {
  final double progress; // Master timeline progress 0.0 to 1.0
  final double canvasWidth;
  final double canvasHeight;
  final Offset fridgeCenter;
  final double fridgeWidth;
  final double fridgeHeight;
  final double ringRotation; // Ring swirl rotation in radians
  final double ringContract; // Inward contraction progress [0.0 to 1.0]

  const FloatingIngredientsWidget({
    super.key,
    required this.progress,
    required this.canvasWidth,
    required this.canvasHeight,
    required this.fridgeCenter,
    required this.fridgeWidth,
    required this.fridgeHeight,
    this.ringRotation = 0.0,
    this.ringContract = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    if (progress < 0.27 || progress >= 0.83) return const SizedBox.shrink();

    // Radius of the orbital freshness ring
    final ringRadius = canvasWidth * 0.38;

    return Stack(
      children: kNutriIngredients.map((item) {
        return _buildIngredient(item, ringRadius);
      }).toList(),
    );
  }

  Widget _buildIngredient(IngredientItemData item, double ringRadius) {
    if (progress < item.startTrigger) return const SizedBox.shrink();

    // 1. Scene 3 Shelf Emergence: [startTrigger, 0.54]
    final emergeDuration = 0.54 - item.startTrigger;
    final emergeProg = ((progress - item.startTrigger) / emergeDuration).clamp(
      0.0,
      1.0,
    );
    final emergeCurve = Curves.easeOutBack.transform(emergeProg);

    // Initial position inside its specific shelf
    final shelfOrigin = Offset(
      fridgeCenter.dx + fridgeWidth * item.shelfRelativeOffset.dx,
      fridgeCenter.dy + fridgeHeight * item.shelfRelativeOffset.dy,
    );

    // Mid-air burst position
    final burstPos = Offset(
      fridgeCenter.dx + canvasWidth * item.burstOffset.dx,
      fridgeCenter.dy + canvasHeight * item.burstOffset.dy,
    );

    // 2. Scene 4 Gathering into Orbital Ring: [0.54, 0.68]
    final gatherProg = ((progress - 0.54) / (0.68 - 0.54)).clamp(0.0, 1.0);
    final gatherCurve = Curves.easeInOutCubic.transform(gatherProg);

    // Target position on the circular freshness ring (incorporating ring swirl & contraction)
    final currentRingRadius = ringRadius * (1.0 - 0.32 * ringContract);
    final orbitAngle = item.targetAngle + (gatherProg * 0.15) + ringRotation;
    final ringPos = Offset(
      fridgeCenter.dx + currentRingRadius * math.cos(orbitAngle),
      fridgeCenter.dy + currentRingRadius * math.sin(orbitAngle),
    );

    // 3. Scene 5 Clean Fade-out into Logo Center: [0.74, 0.82]
    double fadeOut = 1.0;
    if (progress >= 0.74) {
      final fadeProg = ((progress - 0.74) / (0.82 - 0.74)).clamp(0.0, 1.0);
      fadeOut = (1.0 - Curves.easeIn.transform(fadeProg)).clamp(0.0, 1.0);
    }

    if (fadeOut <= 0.005) return const SizedBox.shrink();

    // Interpolate position along smooth trajectory
    Offset currentPos;
    if (progress < 0.54) {
      currentPos = Offset.lerp(shelfOrigin, burstPos, emergeCurve)!;
    } else {
      currentPos = Offset.lerp(burstPos, ringPos, gatherCurve)!;
    }

    // Subtle gentle floating oscillation when not actively spinning
    final bobbingAmp = (1.0 - ringContract).clamp(0.0, 1.0) * 3.0;
    final bobbing = math.sin((progress * 14.0) + item.targetAngle) * bobbingAmp;
    currentPos = Offset(currentPos.dx, currentPos.dy + bobbing);

    // Rotation tilting with swirl
    final rotation =
        item.initialRotation * (1.0 - 0.25 * gatherProg) +
        (0.10 * math.sin(progress * 10.0)) +
        (ringRotation * 0.45);
    final itemPixelSize =
        canvasWidth *
        item.baseSize *
        (0.3 + 0.7 * emergeCurve) *
        (1.0 - 0.20 * ringContract);

    return Positioned(
      left: currentPos.dx - itemPixelSize / 2,
      top: currentPos.dy - itemPixelSize / 2,
      width: itemPixelSize,
      height: itemPixelSize,
      child: Opacity(
        opacity: (emergeProg * fadeOut).clamp(0.0, 1.0),
        child: Transform.rotate(
          angle: rotation,
          child: Image.asset(
            item.assetName,
            width: itemPixelSize,
            height: itemPixelSize,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            errorBuilder: (context, error, stackTrace) =>
                _buildFallbackIngredient(item),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackIngredient(IngredientItemData item) {
    Color color;
    IconData icon;
    switch (item.label) {
      case 'Tomato':
        color = const Color(0xFFE53935);
        icon = Icons.circle;
        break;
      case 'Broccoli':
        color = const Color(0xFF43A047);
        icon = Icons.park_rounded;
        break;
      case 'Lemon':
        color = const Color(0xFFFDD835);
        icon = Icons.brightness_1_rounded;
        break;
      case 'Avocado':
        color = const Color(0xFF558B2F);
        icon = Icons.egg_rounded;
        break;
      case 'Carrot':
        color = const Color(0xFFFF9800);
        icon = Icons.change_history_rounded;
        break;
      default:
        color = const Color(0xFF2E7D32);
        icon = Icons.eco_rounded;
    }

    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(child: Icon(icon, color: Colors.white, size: 16)),
    );
  }
}
