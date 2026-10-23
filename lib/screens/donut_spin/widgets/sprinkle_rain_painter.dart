import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Depth filter for sprinkle rendering, allowing sprinkles to pass
/// both behind and in front of the 3D donut silhouette for true depth.
enum SprinkleDepthFilter {
  all,
  backgroundOnly,
  foregroundOnly,
}

/// Deterministic data model for a falling 3D candy sprinkle particle.
class _CandySprinkleParticle {
  final double startX; // Relative horizontal position [-180, 180]
  final double speed; // Fall speed multiplier
  final double delay; // Normalized start time offset [0.0, 0.35]
  final double rotationSpeedZ; // In-plane angular velocity
  final double initialAngleZ; // Starting in-plane rotation
  final double tumbleSpeedX; // 3D tumbling pitch velocity
  final double initialPitchX; // Starting 3D pitch tilt
  final double length; // Length of the candy rod (e.g. 11–16 px)
  final double thickness; // Diameter/thickness of the candy rod (e.g. 3.8–4.8 px)
  final double driftAmplitude; // Horizontal oscillation amplitude
  final double driftFrequency; // Oscillation speed
  final Color color; // Pastel candy color
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
/// with cylindrical gradient shading, specular gloss highlights, rounded caps,
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
      Color(0xFFF58FB3), // Strawberry pink
      Color(0xFF70E0D0), // Mint
      Color(0xFFFFD166), // Yellow
      Color(0xFFFF8B8B), // Coral
      Color(0xFFDED2F9), // Lavender
      Color(0xFF9AD0EC), // Sky Blue
    ];

    final list = <_CandySprinkleParticle>[];
    final random = math.Random(108); // Deterministic seed

    for (int i = 0; i < 36; i++) {
      list.add(_CandySprinkleParticle(
        startX: (random.nextDouble() - 0.5) * 320.0,
        speed: 0.82 + random.nextDouble() * 0.78,
        delay: random.nextDouble() * 0.32,
        rotationSpeedZ: (random.nextDouble() - 0.5) * 7.5,
        initialAngleZ: random.nextDouble() * math.pi * 2,
        tumbleSpeedX: (random.nextDouble() - 0.5) * 9.0,
        initialPitchX: random.nextDouble() * math.pi,
        length: 11.5 + random.nextDouble() * 5.5,
        thickness: 3.8 + random.nextDouble() * 1.0,
        driftAmplitude: 6.0 + random.nextDouble() * 16.0,
        driftFrequency: 1.8 + random.nextDouble() * 3.2,
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
      if (p.hasBounce && t > 0.75) {
        final bounceT = ((t - 0.75) / 0.25).clamp(0.0, 1.0);
        final bounceHeight = 16.0 * math.sin(bounceT * math.pi);
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
          math.max(p.thickness * 1.15, p.length * (0.32 + 0.68 * cosPitch));
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

      // 1. Soft contact micro shadow
      final shadowRect = Rect.fromCenter(
        center: const Offset(1.2, 1.8),
        width: visibleLength,
        height: p.thickness,
      );
      shadowPaint.color = Colors.black.withValues(alpha: 0.12 * alpha);
      canvas.drawRRect(
        RRect.fromRectAndRadius(shadowRect, radius),
        shadowPaint,
      );

      // 2. 3D Cylindrical Shader: Shading across rod thickness
      // Highlights the curved cylinder top, rich candy color in middle, ambient occlusion at bottom
      final topColor = Color.lerp(p.color, Colors.white, 0.42)!
          .withValues(alpha: alpha);
      final crestColor = Color.lerp(p.color, Colors.white, 0.78)!
          .withValues(alpha: alpha);
      final bodyColor = p.color.withValues(alpha: alpha);
      final bottomColor = Color.lerp(p.color, Colors.black, 0.22)!
          .withValues(alpha: alpha);

      cylinderPaint.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [topColor, crestColor, bodyColor, bottomColor],
        stops: const [0.0, 0.22, 0.58, 1.0],
      ).createShader(rodRect);

      canvas.drawRRect(
        RRect.fromRectAndRadius(rodRect, radius),
        cylinderPaint,
      );

      // 3. Specular gloss highlight stripe along the length of the cylinder
      final highlightRect = Rect.fromLTWH(
        -halfLength * 0.75,
        -halfThick * 0.65,
        visibleLength * 0.75,
        p.thickness * 0.25,
      );
      highlightPaint.color =
          Colors.white.withValues(alpha: 0.55 * alpha * cosPitch);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          highlightRect,
          Radius.circular(p.thickness * 0.15),
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
