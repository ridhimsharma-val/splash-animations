import 'package:flutter/material.dart';

/// Renders the refrigerator cabinet body with its shelves and warm interior light.
class FridgeCabinetWidget extends StatelessWidget {
  final double width;
  final double height;
  final double interiorGlowProgress; // Kept for API compatibility

  const FridgeCabinetWidget({
    super.key,
    required this.width,
    required this.height,
    this.interiorGlowProgress = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Image.asset(
        'assets/images/magic_fridge/fridge_cabinet.png',
        width: width,
        height: height,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        errorBuilder: (context, error, stackTrace) => _buildFallbackCabinet(),
      ),
    );
  }

  /// Procedural fallback matching the approved retro mint design if asset is loading
  Widget _buildFallbackCabinet() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFA7D7A5), // Mint Green
        borderRadius: BorderRadius.circular(width * 0.18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: EdgeInsets.all(width * 0.06),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEF), // Warm interior
          borderRadius: BorderRadius.circular(width * 0.12),
        ),
      ),
    );
  }
}
