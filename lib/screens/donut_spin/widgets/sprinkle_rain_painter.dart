import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Depth filter for sprinkle rendering, allowing sprinkles to pass
/// both behind and in front of the 3D donut silhouette for genuine spatial depth.
enum SprinkleDepthFilter {
  all,
  backgroundOnly,
  foregroundOnly,
}

/// Deterministic data model for a falling 3D candy sprinkle rod.
class _CandySprinkleParticle {
  final double startX; // Relative horizontal position [-170, 170]
  final double speed; // Fall speed multiplier
  final double delay; // Normalized start time offset [0.0, 0.32]
  final double rotationSpeedZ; // In-plane angular velocity
  final double initialAngleZ; // Starting in-plane rotation
  final double tumbleSpeedX; // 3D tumbling pitch velocity
  final double initialPitchX; // Starting 3D pitch tilt
  final double length; // Length of the candy rod (11–17 px)
  final double thickness; // Diameter of the candy rod (3.6–4.8 px)
  final double driftAmplitude; // Horizontal oscillation amplitude
  final double driftFrequency; // Oscillation speed
  final Color color; // Pastel candy confectionery color
  final bool isForeground; // True if falling in front of the donut, false if behind
  final bool hasBounce; // Select particles that bounce slightly near bottom

  const _CandySprinkleParticle({
    required this.startX,
    required this.speed,
    required this.delay,
    required this.rotationSpeedZ,
    required this.initialAngleZ,
    required this.tumbleSpeedX,
    required this.initialPitchX,
    required this.length,
    required this.thickness,
    required this.driftAmplitude,
    required this.driftFrequency,
    required this.color,
    required this.isForeground,
    required this.hasBounce,
  });
}

/// Renders a graceful cascade of realistic 3D cylindrical candy sprinkles
/// with cylindrical gradient shading, specular gloss highlights, rounded ends,
/// and accurate depth ordering around the donut.
class SprinkleRainPainter extends CustomPainter {
  /// Progress of the sprinkle rain animation (0.0 to 1.0)
  final double progress;

  /// Which depth layer to render (behind donut, in front of donut, or all)
  final SprinkleDepthFilter depthFilter;

  // 36 deterministic candy particles with diverse speeds, colors, and 3D tumbling
  static final List<_CandySprinkleParticle> _particles = _generateParticles();

  static List<_CandySprinkleParticle> _generateParticles() {
    const colors = [
      Color(0xFFF7729F), // Vibrant strawberry pink
      Color(0xFF4DD0E1), // Mint turquoise
      Color(0xFFFFD54F), // Lemon candy yellow
      Color(0xFFFF7A7A), // Coral confectionery
      Color(0xFFB39DDB), // Lavender lilac
      Color(0xFF81D4FA), // Sky blue sugar
    ];

    final list = <_CandySprinkleParticle>[];
    final random = math.Random(108); // Deterministic seed

    for (int i = 0; i < 36; i++) {
      list.add(_CandySprinkleParticle(
        startX: (random.nextDouble() - 0.5) * 320.0,
        speed: 0.85 + random.nextDouble() * 0.75,
        delay: random.nextDouble() * 0.30,
        rotationSpeedZ: (random.nextDouble() - 0.5) * 7.0,
        initialAngleZ: random.nextDouble() * math.pi * 2,
        tumbleSpeedX: (random.nextDouble() - 0.5) * 8.5,
        initialPitchX: random.nextDouble() * math.pi,
        length: 11.5 + random.nextDouble() * 5.5,
        thickness: 3.6 + random.nextDouble() * 1.0,
        driftAmplitude: 6.0 + random.nextDouble() * 15.0,
        driftFrequency: 1.8 + random.nextDouble() * 3.0,
        color: colors[i % colors.length],
        // Roughly half fall in front, half behind for realistic depth ordering
        isForeground: i % 2 == 0,
        hasBounce: i % 4 == 0,
      ));
    }
    return list;
  }

  const SprinkleRainPainter({
    required this.progress,
    this.depthFilter = SprinkleDepthFilter.all,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0 || progress >= 1.0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final shadowPaint = Paint()..style = PaintingStyle.fill;
    final cylinderPaint = Paint()..style = PaintingStyle.fill;
    final highlightPaint = Paint()..style = PaintingStyle.fill;

    for (final p in _particles) {
      // Filter by depth layer if specified
      if (depthFilter == SprinkleDepthFilter.backgroundOnly && p.isForeground) {
        continue;
      }
      if (depthFilter == SprinkleDepthFilter.foregroundOnly && !p.isForeground) {
        continue;
      }

      if (progress < p.delay) continue;

      // Local progress for this particle
      final t = (progress - p.delay) / (1.0 - p.delay);
      if (t > 1.0) continue;

      // Vertical position (starts above viewport, falls through)
      final startY = -size.height * 0.50;
      final endY = size.height * 0.52;
      double curY = startY + (endY - startY) * (t * p.speed);

      // Bounce near lower edge for selected particles
      if (p.hasBounce && t > 0.76) {
        final bounceT = ((t - 0.76) / 0.24).clamp(0.0, 1.0);
        final bounceHeight = 14.0 * math.sin(bounceT * math.pi);
        curY -= bounceHeight;
      }

      // Horizontal position with gentle sine drift
      final curX = p.startX +
          p.driftAmplitude * math.sin(t * math.pi * p.driftFrequency);

      // Smooth fade-in at top and fade-out near bottom
      double alpha = 1.0;
      if (t < 0.10) {
        alpha = t / 0.10;
      } else if (t > 0.82) {
        alpha = (1.0 - t) / 0.18;
      }
      alpha = alpha.clamp(0.0, 1.0);

      // In-plane rotation and 3D tumbling pitch
      final curAngleZ = p.initialAngleZ + p.rotationSpeedZ * t;
      final curPitchX = p.initialPitchX + p.tumbleSpeedX * t;

      // 3D perspective foreshortening along length as the candy rod tumbles
      final cosPitch = math.cos(curPitchX).abs();
      final visibleLength =
          math.max(p.thickness * 1.15, p.length * (0.30 + 0.70 * cosPitch));
      final halfLength = visibleLength / 2;
      final halfThick = p.thickness / 2;
      final radius = Radius.circular(halfThick);

      canvas.save();
      canvas.translate(center.dx + curX, center.dy + curY);
      canvas.rotate(curAngleZ);

      final rodRect = Rect.fromCenter(
        center: Offset.zero,
        width: visibleLength,
        height: p.thickness,
      );

      // 1. Soft contact micro shadow beneath the cylinder
      final shadowRect = Rect.fromCenter(
        center: const Offset(1.2, 1.6),
        width: visibleLength,
        height: p.thickness,
      );
      shadowPaint.color = Colors.black.withValues(alpha: 0.10 * alpha);
      canvas.drawRRect(
        RRect.fromRectAndRadius(shadowRect, radius),
        shadowPaint,
      );

      // 2. 3D Cylindrical Shading across rod thickness:
      // Rounded highlight at top, vibrant candy core in middle, soft shadow at bottom
      final topColor = Color.lerp(p.color, Colors.white, 0.44)!
          .withValues(alpha: alpha);
      final crestColor = Color.lerp(p.color, Colors.white, 0.76)!
          .withValues(alpha: alpha);
      final bodyColor = p.color.withValues(alpha: alpha);
      final bottomColor = Color.lerp(p.color, Colors.black, 0.20)!
          .withValues(alpha: alpha);

      cylinderPaint.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [topColor, crestColor, bodyColor, bottomColor],
        stops: const [0.0, 0.20, 0.55, 1.0],
      ).createShader(rodRect);

      canvas.drawRRect(
        RRect.fromRectAndRadius(rodRect, radius),
        cylinderPaint,
      );

      // 3. Specular gloss highlight stripe along the cylinder surface
      final highlightRect = Rect.fromLTWH(
        -halfLength * 0.70,
        -halfThick * 0.60,
        visibleLength * 0.70,
        p.thickness * 0.22,
      );
      highlightPaint.color =
          Colors.white.withValues(alpha: 0.50 * alpha * cosPitch);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          highlightRect,
          Radius.circular(p.thickness * 0.12),
        ),
        highlightPaint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant SprinkleRainPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.depthFilter != depthFilter;
  }
}
