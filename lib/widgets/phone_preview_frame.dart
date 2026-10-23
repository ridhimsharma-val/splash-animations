import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Reusable mobile phone mockup frame.
/// Displays an elegant portrait device frame with rounded corners,
/// a subtle camera/speaker pill at the top, and a home indicator at the bottom.
class PhonePreviewFrame extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final double borderRadius;
  final bool showNotch;
  final bool showHomeIndicator;

  const PhonePreviewFrame({
    super.key,
    required this.child,
    this.width = 156.0,
    this.height = 276.0,
    this.borderRadius = 22.0,
    this.showNotch = true,
    this.showHomeIndicator = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: AppColors.border,
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF292536).withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: AppColors.primaryAccent.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius - 2),
        child: Container(
          color: AppColors.phoneScreenBg,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Screen Body
              child,

              // Top Device Speaker / Dynamic Pill
              if (showNotch)
                Positioned(
                  top: 7,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 44,
                      height: 5.5,
                      decoration: BoxDecoration(
                        color: AppColors.phoneBezel,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),

              // Bottom Home Indicator Bar
              if (showHomeIndicator)
                Positioned(
                  bottom: 6,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 3.5,
                      decoration: BoxDecoration(
                        color: AppColors.phoneBezel,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
