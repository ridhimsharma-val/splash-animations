import 'package:flutter/material.dart';

import '../models/design_concept.dart';
import '../theme/app_theme.dart';

/// Clean pill badge for Design Category (Splash Screen vs Onboarding).
class CategoryBadge extends StatelessWidget {
  final DesignCategory category;
  final bool isCompact;

  const CategoryBadge({
    super.key,
    required this.category,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isSplash = category == DesignCategory.splashScreen;
    final bgColor = isSplash
        ? AppColors.lavenderSurface
        : AppColors.pinkSurface;
    final textColor = isSplash ? AppColors.deepLavender : AppColors.deepPink;
    final borderColor = isSplash
        ? AppColors.primaryAccent
        : AppColors.secondaryAccent;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 10,
        vertical: isCompact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor.withValues(alpha: 0.6), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSplash ? Icons.bolt_rounded : Icons.view_carousel_rounded,
            size: isCompact ? 11 : 13,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            category.label,
            style: TextStyle(
              fontSize: isCompact ? 10 : 11,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Status badge indicating readiness (e.g. Active Placeholder vs Coming Soon).
class StatusBadge extends StatelessWidget {
  final DesignStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final isActive = status == DesignStatus.activePlaceholder;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.softLavender.withValues(alpha: 0.7)
            : AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? AppColors.primaryAccent : AppColors.border,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? AppColors.activeGreen : AppColors.textMuted,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
