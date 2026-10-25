import 'package:flutter/material.dart';

import '../models/design_concept.dart';
import '../theme/app_theme.dart';
import 'category_badge.dart';
import 'concept_preview_mockups.dart';
import 'phone_preview_frame.dart';

/// Reusable card displaying an individual animation concept in the gallery.
class DesignCard extends StatefulWidget {
  final DesignConcept concept;
  final VoidCallback onTap;

  const DesignCard({super.key, required this.concept, required this.onTap});

  @override
  State<DesignCard> createState() => _DesignCardState();
}

class _DesignCardState extends State<DesignCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final concept = widget.concept;
    final isPlaceholderReady = concept.status == DesignStatus.activePlaceholder;

    final scale = _isPressed ? 0.98 : (_isHovered ? 1.015 : 1.0);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _isHovered
                    ? (isPlaceholderReady
                          ? AppColors.deepLavender.withValues(alpha: 0.45)
                          : AppColors.primaryAccent)
                    : AppColors.border,
                width: _isHovered ? 1.5 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isHovered
                      ? const Color(0xFF292536).withValues(alpha: 0.08)
                      : const Color(0xFF292536).withValues(alpha: 0.03),
                  blurRadius: _isHovered ? 24 : 12,
                  offset: Offset(0, _isHovered ? 8 : 4),
                ),
                if (_isHovered)
                  BoxShadow(
                    color: AppColors.primaryAccent.withValues(alpha: 0.18),
                    blurRadius: 18,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Meta: Number + Category Badge + Status (Wrap ensures zero overflow)
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.softLavender,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'DESIGN ${concept.number}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: AppColors.deepLavender,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        CategoryBadge(
                          category: concept.category,
                          isCompact: true,
                        ),
                      ],
                    ),
                    StatusBadge(status: concept.status),
                  ],
                ),

                const SizedBox(height: 18),

                // Center Phone Mockup Preview Frame
                Center(
                  child: PhonePreviewFrame(
                    child: ConceptPreviewMockup(concept: concept),
                  ),
                ),

                const SizedBox(height: 18),

                // Design Title
                Text(
                  concept.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 6),

                // Description
                SizedBox(
                  height: 48,
                  child: Text(
                    concept.description,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(height: 14),

                // Bottom Action Affordance (Wrap ensures zero overflow)
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isPlaceholderReady
                            ? (_isHovered
                                  ? AppColors.deepLavender
                                  : AppColors.lavenderSurface)
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isPlaceholderReady
                              ? (_isHovered
                                    ? AppColors.deepLavender
                                    : AppColors.primaryAccent)
                              : AppColors.border,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isPlaceholderReady ? 'Preview Concept' : 'Details',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isPlaceholderReady
                                  ? (_isHovered
                                        ? Colors.white
                                        : AppColors.deepLavender)
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            isPlaceholderReady
                                ? Icons.arrow_forward_rounded
                                : Icons.info_outline_rounded,
                            size: 14,
                            color: isPlaceholderReady
                                ? (_isHovered
                                      ? Colors.white
                                      : AppColors.deepLavender)
                                : AppColors.textMuted,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      isPlaceholderReady ? 'Ready for dev' : 'Planned',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isPlaceholderReady
                            ? AppColors.deepLavender
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
