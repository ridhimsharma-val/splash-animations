import 'package:flutter/material.dart';

/// Minimal, clean placeholder screen revealed after passing through the donut portal.
/// Explicitly contains no full app functionality or decorative clutter.
class AppHomePlaceholder extends StatelessWidget {
  final double enterProgress; // 0.0 to 1.0

  const AppHomePlaceholder({
    super.key,
    required this.enterProgress,
  });

  @override
  Widget build(BuildContext context) {
    final curved = Curves.easeOutCubic.transform(enterProgress.clamp(0.0, 1.0));
    final opacity = curved;
    final scale = 0.94 + 0.06 * curved;

    return Opacity(
      opacity: opacity,
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xFFFFF6E9), // Warm vanilla cream
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Minimalist geometric emblem
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFF58FB3).withValues(alpha: 0.35),
                      width: 2.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF58FB3).withValues(alpha: 0.15),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF0F5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        size: 22,
                        color: Color(0xFFF58FB3),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Main Title
                const Text(
                  'App Home Placeholder',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF292536),
                    letterSpacing: -0.6,
                  ),
                ),

                const SizedBox(height: 8),

                // Subtitle
                const Text(
                  'Your app starts here',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF817B8D),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
