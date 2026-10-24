import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onboarding_splash/main.dart';
import 'package:onboarding_splash/models/design_concept.dart';
import 'package:onboarding_splash/screens/donut_spin/donut_spin_screen.dart';
import 'package:onboarding_splash/screens/donut_spin/widgets/app_home_placeholder.dart';
import 'package:onboarding_splash/screens/donut_spin/widgets/donut_frame_animator.dart';
import 'package:onboarding_splash/screens/gallery_screen.dart';

void main() {
  group('Onboarding & Splash Animation Lab — Design 01 Donut Spin Tests', () {
    testWidgets('Gallery displays title and Design 01 Donut Spin card',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const OnboardingSplashLabApp());
      await tester.pumpAndSettle();

      expect(find.text('Explore Designs'), findsOneWidget);
      expect(find.text('Design 01'), findsOneWidget);
      expect(find.text('Donut Spin'), findsOneWidget);
    });

    testWidgets('Design 01 Donut Spin opens, auto-plays, and finishes on AppHomePlaceholder',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(412, 884);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const OnboardingSplashLabApp());
      await tester.pumpAndSettle();

      // Tap on Donut Spin card
      final donutSpinCard = find.text('Donut Spin');
      expect(donutSpinCard, findsOneWidget);
      await tester.tap(donutSpinCard);
      await tester.pump(); // Start page route transition
      await tester.pump(const Duration(milliseconds: 350)); // Finish page route transition

      // Verify we entered DonutSpinScreen
      expect(find.byType(DonutSpinScreen), findsOneWidget);

      // Phase A: Drop in progress
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(DonutSpinScreen), findsOneWidget);

      // Phase B: 3D Spin and sprinkle rain
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.byType(DonutSpinScreen), findsOneWidget);

      // Phase C: Portal expanding
      await tester.pump(const Duration(milliseconds: 700));

      // Phase D: App Home Placeholder reveal and completion
      await tester.pump(const Duration(milliseconds: 1100));
      await tester.pumpAndSettle();

      // Verify the final screen is AppHomePlaceholder with only emblem and text
      expect(find.byType(AppHomePlaceholder), findsOneWidget);
      expect(find.text('App Home Placeholder'), findsOneWidget);
      expect(find.text('Your app starts here'), findsOneWidget);

      // Test Replay button
      final replayButton = find.byTooltip('Replay Splash Animation');
      expect(replayButton, findsOneWidget);
      await tester.tap(replayButton);
      await tester.pump(); // Restarts from beginning

      // Fast forward again to completion
      await tester.pump(const Duration(milliseconds: 2700));
      await tester.pumpAndSettle();
      expect(find.text('App Home Placeholder'), findsOneWidget);

      // Test Back navigation
      final backButton = find.byIcon(Icons.arrow_back_ios_new_rounded);
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Verify we returned to the gallery
      expect(find.byType(GalleryScreen), findsOneWidget);
      expect(find.byType(DonutSpinScreen), findsNothing);
    });

    testWidgets('Tapping coming soon design still shows informative dialog',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const OnboardingSplashLabApp());
      await tester.pumpAndSettle();

      final design02 = find.text('Minimal Fade & Scale');
      expect(design02, findsOneWidget);
      await tester.tap(design02);
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsOneWidget);
      expect(find.text('Back to Gallery'), findsOneWidget);

      await tester.tap(find.text('Back to Gallery'));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('All 8 registered designs are preserved',
        (WidgetTester tester) async {
      expect(DesignConcept.collection.length, 8);
      expect(DesignConcept.collection[0].title, 'Donut Spin');
      expect(DesignConcept.collection[1].title, 'Minimal Fade & Scale');
      expect(DesignConcept.collection[2].title, 'Cinematic Splash');
      expect(DesignConcept.collection[3].title, 'Illustrated Onboarding');
      expect(DesignConcept.collection[4].title, 'Parallax Onboarding');
      expect(DesignConcept.collection[5].title, 'Morphing Onboarding Carousel');
      expect(DesignConcept.collection[6].title, 'Liquid Page Indicators');
      expect(DesignConcept.collection[7].title, 'Staggered Content Reveal');
    });

    testWidgets('Responsive mobile view renders cleanly without overflow',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const OnboardingSplashLabApp());
      await tester.pumpAndSettle();

      expect(find.text('Explore Designs'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'DonutSpinScreen adapts cleanly to portrait 393x852 and 320x568 without overflow',
        (WidgetTester tester) async {
      for (final size in [const Size(393, 852), const Size(320, 568)]) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(
          const MaterialApp(
            home: DonutSpinScreen(),
          ),
        );

        // Check frame at 0ms (off-screen drop start)
        await tester.pump();
        expect(tester.takeException(), isNull);

        // Check Phase A (impact / gooey bounce)
        await tester.pump(const Duration(milliseconds: 450));
        expect(tester.takeException(), isNull);

        // Check Phase B (3D spin)
        await tester.pump(const Duration(milliseconds: 550));
        expect(tester.takeException(), isNull);

        // Check Phase C (Portal plunge)
        await tester.pump(const Duration(milliseconds: 600));
        expect(tester.takeException(), isNull);

        // Check Phase D (Completion)
        await tester.pump(const Duration(milliseconds: 1100));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('App Home Placeholder'), findsOneWidget);
        expect(find.text('Your app starts here'), findsOneWidget);
      }
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('Calibrated 4-phase sequence and hole geometry ratios are validated',
        (WidgetTester tester) async {
      // Analytical hole calibration ratio
      expect(DonutCalibration.holeRadiusRatio, closeTo(58.0 / 320.0, 0.0001));
      expect(DonutCalibration.outerRadiusRatio, closeTo(144.0 / 320.0, 0.0001));

      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: DonutSpinScreen(),
        ),
      );

      // Frame 0: Plain golden dough drop
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(DonutFrameAnimator), findsOneWidget);
      final plainAnimator = tester.widget<DonutFrameAnimator>(find.byType(DonutFrameAnimator));
      expect(plainAnimator.frameIndex, 0);

      // Phase 2: Diagonal 360° spin with progressive glaze
      await tester.pump(const Duration(milliseconds: 800)); // Total 1000ms (mid Phase 2)
      final midSpinAnimator = tester.widget<DonutFrameAnimator>(find.byType(DonutFrameAnimator));
      expect(midSpinAnimator.frameIndex, greaterThan(0));
      expect(midSpinAnimator.frameIndex, lessThanOrEqualTo(47));

      // Phase 3: Glazed donut with surface sprinkles pop-in
      await tester.pump(const Duration(milliseconds: 800)); // Total 1800ms (Phase 3)
      final glazedAnimator = tester.widget<DonutFrameAnimator>(find.byType(DonutFrameAnimator));
      expect(glazedAnimator.frameIndex, 47);
      expect(glazedAnimator.sprinklePopProgress, greaterThan(0.0));

      // Phase 4: Hole portal expansion to AppHomePlaceholder
      await tester.pump(const Duration(milliseconds: 1200)); // Total 3000ms (Completion)
      await tester.pumpAndSettle();
      expect(find.byType(AppHomePlaceholder), findsOneWidget);
    });
  });
}
