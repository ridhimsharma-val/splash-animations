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
          child: const Center(
            child: Text(
              'Donut Spin',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Color(0xFF292536),
                letterSpacing: -0.8,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
