import 'package:flutter/material.dart';
import '../models/design_concept.dart';
import '../theme/app_theme.dart';

/// Renders a static representative placeholder mobile UI for each design concept.
class ConceptPreviewMockup extends StatelessWidget {
  final DesignConcept concept;

  const ConceptPreviewMockup({
    super.key,
    required this.concept,
  });

  @override
  Widget build(BuildContext context) {
    switch (concept.id) {
      case 'design_01':
        return const _Design01Mockup();
      case 'design_02':
        return const _Design02Mockup();
      case 'design_03':
        return const _Design03Mockup();
      case 'design_04':
        return const _Design04Mockup();
      case 'design_05':
        return const _Design05Mockup();
      case 'design_06':
        return const _Design06Mockup();
      case 'design_07':
        return const _Design07Mockup();
      case 'design_08':
        return const _Design08Mockup();
      default:
        return const _FallbackMockup();
    }
  }
}

/// Design 01: Donut Spin (3D Splash Animation)
class _Design01Mockup extends StatelessWidget {
  const _Design01Mockup();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFF6E9), // Warm vanilla cream
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Mini Donut representation
          Stack(
            alignment: Alignment.center,
            children: [
              // Dough base
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE8AB6B),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5A3825).withValues(alpha: 0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
              // Strawberry Glaze
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0xFFFFF0F5), Color(0xFFF58FB3)],
                    stops: [0.4, 1.0],
                  ),
                ),
              ),
              // Inner donut hole
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFFF6E9),
                ),
              ),
              // Sprinkles on mini donut
              Positioned(
                top: 14,
                left: 20,
                child: Container(
                  width: 7,
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFF70E0D0),
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              ),
              Positioned(
                bottom: 15,
                right: 20,
                child: Container(
                  width: 7,
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD166),
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              ),
              Positioned(
                top: 28,
                right: 12,
                child: Container(
                  width: 3,
                  height: 7,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDED2F9),
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              ),
              Positioned(
                bottom: 26,
                left: 14,
                child: Container(
                  width: 7,
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF8B8B),
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'DONUT SPIN',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.6,
                color: Color(0xFF292536),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFF7DDEB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '3D SPLASH',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: Color(0xFFD81B60),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Design 02: Minimal Fade & Scale (Splash Screen)
class _Design02Mockup extends StatelessWidget {
  const _Design02Mockup();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border, width: 1.5),
              color: AppColors.background,
            ),
            alignment: Alignment.center,
            child: const Text(
              'M',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                fontFamily: 'serif',
              ),
            ),
          ),
          const SizedBox(height: 14),
          const FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'MINIMAL',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.0,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'fade • scale',
              style: TextStyle(
                fontSize: 9,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Soft thin loading line
          Container(
            width: 44,
            height: 2,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
            alignment: Alignment.centerLeft,
            child: Container(
              width: 22,
              height: 2,
              decoration: BoxDecoration(
                color: AppColors.primaryAccent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Design 03: Cinematic Splash (Splash Screen)
class _Design03Mockup extends StatelessWidget {
  const _Design03Mockup();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFAF7FD), Color(0xFFF6EEF8)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 68,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(40),
                  ),
                  color: AppColors.secondaryAccent.withValues(alpha: 0.5),
                ),
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  width: 50,
                  height: 2,
                  color: AppColors.deepPink.withValues(alpha: 0.4),
                ),
              ),
              Positioned(
                top: 4,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFDCC8F5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'H O R I Z O N',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.2,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'CINEMATIC INTRO',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Design 04: Illustrated Onboarding (Onboarding)
class _Design04Mockup extends StatelessWidget {
  const _Design04Mockup();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Mockup Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 14,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Skip',
                style: TextStyle(fontSize: 8, color: AppColors.textSecondary),
              ),
            ],
          ),
          // Illustration Card
          Container(
            width: double.infinity,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.lavenderSurface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 12,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFF7DDEB),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  child: Icon(
                    Icons.explore_rounded,
                    size: 34,
                    color: AppColors.deepLavender.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          // Content Lines
          Column(
            children: [
              const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Begin Journey',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderSubtle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
          // Action button
          Container(
            width: double.infinity,
            height: 22,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFDCC8F5), Color(0xFFF7DDEB)],
              ),
              borderRadius: BorderRadius.circular(11),
            ),
            alignment: Alignment.center,
            child: const FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Get Started',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Design 05: Parallax Onboarding (Onboarding)
class _Design05Mockup extends StatelessWidget {
  const _Design05Mockup();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFDFBFE),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Depth Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.pinkSurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'PARALLAX DEPTH',
                style: TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepPink,
                ),
              ),
            ),
          ),
          // Stacked parallax cards
          SizedBox(
            height: 98,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 0,
                  child: Container(
                    width: 78,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryAccent.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  child: Container(
                    width: 88,
                    height: 54,
                    decoration: BoxDecoration(
                      color: AppColors.primaryAccent.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Positioned(
                  top: 24,
                  child: Container(
                    width: 98,
                    height: 62,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.layers_rounded,
                        size: 24,
                        color: AppColors.deepLavender,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Swipe Hint
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.swipe_rounded, size: 11, color: AppColors.textSecondary),
                SizedBox(width: 3),
                Text(
                  'Swipe depth',
                  style: TextStyle(fontSize: 8, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Design 06: Morphing Onboarding Carousel (Onboarding)
class _Design06Mockup extends StatelessWidget {
  const _Design06Mockup();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Morphing shape visual
          Container(
            width: double.infinity,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.lavenderSurface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const RadialGradient(
                    colors: [Color(0xFFDCC8F5), Color(0xFFF7DDEB)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.transform_rounded,
                  size: 22,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'Morphing Flow',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          // Carousel slide dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.deepLavender,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.border,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.border,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Design 07: Liquid Page Indicators (Onboarding)
class _Design07Mockup extends StatelessWidget {
  const _Design07Mockup();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFAFAFE),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Content card
          Container(
            width: double.infinity,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: Icon(
                Icons.water_drop_rounded,
                size: 28,
                color: AppColors.deepPink.withValues(alpha: 0.7),
              ),
            ),
          ),
          const FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'Liquid Indicator',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          // Liquid Indicator simulation
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.pinkSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Stretched liquid bubble
                Container(
                  width: 16,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.deepPink,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 4),
                // Tiny trailing drop
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.deepPink.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: AppColors.border,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Design 08: Staggered Content Reveal (Onboarding)
class _Design08Mockup extends StatelessWidget {
  const _Design08Mockup();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Staggered Step 1
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.lavenderSurface,
                ),
                alignment: Alignment.center,
                child: const Text(
                  '1',
                  style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: AppColors.deepLavender),
                ),
              ),
              const SizedBox(width: 5),
              Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
          // Staggered Step 2
          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.lavenderSurface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: Icon(
                Icons.animation_rounded,
                size: 22,
                color: AppColors.deepLavender.withValues(alpha: 0.8),
              ),
            ),
          ),
          // Staggered Step 3
          Container(
            width: 70,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.secondaryAccent,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          // Staggered Step 4
          Container(
            width: double.infinity,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.softLavender,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Sequential Enter',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepLavender,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FallbackMockup extends StatelessWidget {
  const _FallbackMockup();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.smartphone_rounded,
        size: 32,
        color: AppColors.textMuted,
      ),
    );
  }
}
