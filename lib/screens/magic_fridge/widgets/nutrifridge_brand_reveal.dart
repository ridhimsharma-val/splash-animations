import 'package:flutter/material.dart';

/// Renders the official NutriFridge brand logo payoff (Scene 5 & 6)
/// as a clean, centered, crisp composition with zero visual clutter.
class NutriFridgeBrandReveal extends StatelessWidget {
  final double progress; // Scene 5 progress [0.0 to 1.0]
  final double canvasWidth;

  const NutriFridgeBrandReveal({
    super.key,
    required this.progress,
    required this.canvasWidth,
  });

  @override
  Widget build(BuildContext context) {
    if (progress <= 0.005) return const SizedBox.shrink();

    final curved = Curves.easeOutCubic.transform(progress.clamp(0.0, 1.0));
    final opacity = curved;
    final translateY = (1.0 - curved) * 18.0;
    final scale = 0.95 + 0.05 * curved;

    final logoWidth = (canvasWidth * 0.86).clamp(270.0, 370.0);

    return Opacity(
      opacity: opacity,
      child: Transform.translate(
        offset: Offset(0, translateY),
        child: Transform.scale(
          scale: scale,
          alignment: Alignment.center,
          child: Center(
            child: SizedBox(
              width: logoWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. Horizontal Brand Wordmark Asset (Emblem + "NutriFridge" + Tagline)
                  Image.asset(
                    'assets/images/magic_fridge/nutrifridge_wordmark.png',
                    width: logoWidth,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildFallbackWordmark(logoWidth),
                  ),

                  const SizedBox(height: 14),

                  // 2. High-readability Tagline Pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8EFE9), // Soft sage tint
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFA7D7A5).withValues(alpha: 0.6),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2E7D32)
                              .withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      'FRESHER FOOD • BRIGHTER DAYS',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.6,
                        color: Color(0xFF20542C), // Forest Green
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// High fidelity procedural wordmark fallback matching approved typography
  Widget _buildFallbackWordmark(double width) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Emblem Icon
        Image.asset(
          'assets/images/magic_fridge/nutrifridge_app_icon.png',
          width: width * 0.30,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.kitchen_rounded,
            size: 48,
            color: Color(0xFFA7D7A5),
          ),
        ),
        const SizedBox(width: 8),
        // Typography
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Nutri',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                  color: Color(0xFF20542C), // Deep Forest Green
                ),
              ),
              TextSpan(
                text: 'Fridge',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                  color: Color(0xFF76A04B), // Sage Green
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
