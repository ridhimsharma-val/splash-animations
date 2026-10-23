import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Enforces a portrait mobile-app viewport at all times.
/// On desktop and wide screens, it renders a centered portrait mobile device
/// with realistic curved corners, bezel, and shadows.
/// On actual mobile devices, it seamlessly fills the viewport edge-to-edge.
class MobileViewportWrapper extends StatelessWidget {
  final Widget child;

  const MobileViewportWrapper({
    super.key,
    required this.child,
  });

  static const double _targetMobileWidth = 412.0;
  static const double _targetMobileHeight = 884.0;
  static const double _phoneCornerRadius = 38.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        // On physical mobile screens or browser windows <= 500px, render full screen
        if (screenWidth <= 500) {
          return child;
        }

        // On desktop/wide screens, always present as a centered mobile device
        final phoneWidth = math.min(_targetMobileWidth, screenWidth - 32);
        final phoneHeight = math.min(_targetMobileHeight, screenHeight - 48);

        return Scaffold(
          backgroundColor: const Color(0xFFEDE8F5),
          body: Center(
            child: Container(
              width: phoneWidth,
              height: phoneHeight,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(_phoneCornerRadius),
                border: Border.all(
                  color: const Color(0xFFDCC8F5),
                  width: 3.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF292536).withValues(alpha: 0.14),
                    blurRadius: 40,
                    offset: const Offset(0, 16),
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: AppColors.primaryAccent.withValues(alpha: 0.3),
                    blurRadius: 28,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(_phoneCornerRadius - 3),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Bounded mobile MediaQuery
                    MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        size: Size(phoneWidth, phoneHeight),
                        padding: const EdgeInsets.only(top: 18, bottom: 14),
                      ),
                      child: child,
                    ),

                    // Top camera / speaker pill on mobile device frame
                    Positioned(
                      top: 8,
                      left: 0,
                      right: 0,
                      child: IgnorePointer(
                        child: Center(
                          child: Container(
                            width: 68,
                            height: 6.5,
                            decoration: BoxDecoration(
                              color: const Color(0xFF292536)
                                  .withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Bottom gesture home bar on mobile device frame
                    Positioned(
                      bottom: 6,
                      left: 0,
                      right: 0,
                      child: IgnorePointer(
                        child: Center(
                          child: Container(
                            width: 54,
                            height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFF292536)
                                  .withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
