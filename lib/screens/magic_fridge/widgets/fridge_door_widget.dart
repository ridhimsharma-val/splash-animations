import 'package:flutter/material.dart';

/// Renders the refrigerator door.
///
/// When the magical reveal begins, the door fades away smoothly in-place
/// without any rotating, swinging, or translating away, magically revealing
/// the illuminated interior shelves underneath.
class FridgeDoorWidget extends StatelessWidget {
  final double width;
  final double height;
  final double
  doorOpacity; // 1.0 (fully closed) down to 0.0 (completely dissolved)

  const FridgeDoorWidget({
    super.key,
    required this.width,
    required this.height,
    required this.doorOpacity,
  });

  @override
  Widget build(BuildContext context) {
    if (doorOpacity <= 0.005) return const SizedBox.shrink();

    final clampedOpacity = doorOpacity.clamp(0.0, 1.0);
    // Subtle in-place dissolve scale (keeps door precisely anchored in place)
    final dissolveScale = 0.98 + 0.02 * clampedOpacity;

    return Opacity(
      opacity: clampedOpacity,
      child: Transform.scale(
        scale: dissolveScale,
        alignment: Alignment.center,
        child: SizedBox(
          width: width,
          height: height,
          child: Image.asset(
            'assets/images/magic_fridge/fridge_door.png',
            width: width,
            height: height,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            errorBuilder: (context, error, stackTrace) => _buildFallbackDoor(),
          ),
        ),
      ),
    );
  }

  /// Procedural fallback matching the approved retro mint door with vertical handle
  Widget _buildFallbackDoor() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFA7D7A5), // Mint Green
        borderRadius: BorderRadius.circular(width * 0.18),
        border: Border.all(color: const Color(0xFF8DC48A), width: 2.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.22),
            blurRadius: 16,
            offset: const Offset(-2, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Two green leaves brand emblem
          Positioned(
            top: height * 0.32,
            left: width * 0.28,
            child: Icon(
              Icons.eco_rounded,
              color: const Color(0xFF2E7D32),
              size: width * 0.22,
            ),
          ),

          // Metallic vertical handle
          Positioned(
            right: width * 0.12,
            top: height * 0.40,
            bottom: height * 0.40,
            width: width * 0.10,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8E0),
                borderRadius: BorderRadius.circular(width * 0.05),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 4,
                    offset: const Offset(1, 2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
