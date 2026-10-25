import 'package:flutter/material.dart';

import '../models/design_concept.dart';
import '../theme/app_theme.dart';
import '../widgets/coming_soon_dialog.dart';
import 'donut_spin/donut_spin_screen.dart';
import 'magic_fridge/magic_fridge_screen.dart';

/// Main design-selection screen matching the Explore Designs mobile gallery style.
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final List<DesignConcept> _designs = DesignConcept.collection;
  bool _isNavigating = false;

  void _openDesign(DesignConcept concept) async {
    if (_isNavigating) return;
    _isNavigating = true;

    if (concept.status == DesignStatus.activePlaceholder) {
      if (concept.id == 'design_02') {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MagicFridgeScreen(concept: concept),
          ),
        );
      } else {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => DonutSpinScreen(concept: concept)),
        );
      }
    } else {
      showComingSoonDialog(context, concept);
    }

    if (mounted) {
      _isNavigating = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Title & Subtitle
                  const Text(
                    'Explore Designs',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      letterSpacing: -1.2,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Explore expressive first impressions and delightful onboarding experiences.',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                      height: 1.45,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Design Concepts List
                  ..._designs.map((design) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildDesignCard(design),
                    );
                  }),

                  const SizedBox(height: 24),

                  // Clean Footer
                  Center(
                    child: Column(
                      children: const [
                        Text(
                          'ONBOARDING & SPLASH ANIMATION LAB • DESIGN GALLERY',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.4,
                            color: Color(0xFF9EA3B8),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Handcrafted mobile experiences built in Flutter.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF9EA3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesignCard(DesignConcept design) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _openDesign(design),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Design ${design.number}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: Color(0xFF7C3AED),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    design.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 22,
              color: Color(0xFF9EA3B8),
            ),
          ],
        ),
      ),
    );
  }
}
