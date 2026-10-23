import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 3D Sprinkle model anchored to the donut's parametric torus surface.
class _Sprinkle3D {
  final double u; // Azimuth angle around the ring [0, 2pi)
  final double v; // Polar angle on the tube cross-section [-pi/4, 3pi/4] (top glaze)
  final double rotation; // In-plane orientation angle
  final Color color;

  const _Sprinkle3D({
    required this.u,
    required this.v,
    required this.rotation,
    required this.color,
  });

  static const double baseLength = 13.0;
  static const double baseThickness = 4.2;
}

/// A quad facet on the 3D parametric torus surface.
class _TorusQuad {
  final List<Offset> points;
  final double avgZ;
  final Color color;
  final bool isGlaze;

  const _TorusQuad({
    required this.points,
    required this.avgZ,
    required this.color,
    required this.isGlaze,
  });
}

/// CustomPainter that renders a 3D volumetric donut (torus) with:
/// - True 3D perspective projection and real-time pitch (X) and yaw (Y) rotation.
/// - Rich golden-brown baked dough with ambient occlusion in the inner hole.
/// - Glossy strawberry-pink glaze with organic wavy dripping edge.
/// - Specular highlight that moves with light vector.
/// - 3D-anchored sprinkles that rotate, foreshorten, and depth-sort with the donut.
class Donut3DPainter extends CustomPainter {
  final double pitch; // X-axis tilt in radians
  final double yaw; // Y-axis spin in radians
  final double ringRadius; // Major radius R
  final double tubeRadius; // Minor radius r
  final double squashX; // Horizontal squash/stretch factor
  final double squashY; // Vertical squash/stretch factor
  final double shadowOpacity; // Shadow intensity
  final double shadowScale; // Shadow radius factor
  final double holeGlow; // Soft cream-pink glow emerging from the hole (0.0 to 1.0)
  final double lightSweep; // Specular gloss sweep position (-1.0 to 1.0)
  final bool drawShadow; // Whether to paint shadow internally or via ground shadow layer

  static const double focalLength = 520.0; // Camera distance for perspective

  // Palette
  static const Color doughBase = Color(0xFFE8AB6B);
  static const Color doughShadow = Color(0xFFB5722C);
  static const Color doughDeep = Color(0xFF8C4C14);
  static const Color glazeBase = Color(0xFFF58FB3);
  static const Color glazeDeep = Color(0xFFE0628E);
  static const Color glazeHighlight = Color(0xFFFFF0F5);

  // Pre-configured deterministic sprinkles positioned on the upper glaze
  static const List<_Sprinkle3D> _sprinkles = [
    _Sprinkle3D(u: 0.25, v: 0.85, rotation: 0.4, color: Color(0xFF70E0D0)), // Mint
    _Sprinkle3D(u: 0.65, v: 1.15, rotation: -0.6, color: Color(0xFFFFD166)), // Yellow
    _Sprinkle3D(u: 1.10, v: 0.70, rotation: 1.1, color: Color(0xFFFF8B8B)), // Coral
    _Sprinkle3D(u: 1.55, v: 1.25, rotation: -0.3, color: Color(0xFFDED2F9)), // Lavender
    _Sprinkle3D(u: 1.95, v: 0.90, rotation: 0.8, color: Color(0xFF9AD0EC)), // Sky blue
    _Sprinkle3D(u: 2.40, v: 1.20, rotation: -0.9, color: Color(0xFF70E0D0)), // Mint
    _Sprinkle3D(u: 2.85, v: 0.75, rotation: 0.5, color: Color(0xFFFFD166)), // Yellow
    _Sprinkle3D(u: 3.30, v: 1.10, rotation: -0.4, color: Color(0xFFFF8B8B)), // Coral
    _Sprinkle3D(u: 3.75, v: 0.80, rotation: 1.2, color: Color(0xFFDED2F9)), // Lavender
    _Sprinkle3D(u: 4.20, v: 1.30, rotation: -0.7, color: Color(0xFF9AD0EC)), // Sky blue
    _Sprinkle3D(u: 4.65, v: 0.75, rotation: 0.3, color: Color(0xFF70E0D0)), // Mint
    _Sprinkle3D(u: 5.10, v: 1.15, rotation: -1.1, color: Color(0xFFFFD166)), // Yellow
    _Sprinkle3D(u: 5.55, v: 0.85, rotation: 0.6, color: Color(0xFFFF8B8B)), // Coral
    _Sprinkle3D(u: 6.00, v: 1.25, rotation: -0.5, color: Color(0xFFDED2F9)), // Lavender
    // Inner ring sprinkles
    _Sprinkle3D(u: 0.45, v: 1.55, rotation: 0.9, color: Color(0xFF9AD0EC)),
    _Sprinkle3D(u: 1.35, v: 1.65, rotation: -0.8, color: Color(0xFF70E0D0)),
    _Sprinkle3D(u: 2.20, v: 1.50, rotation: 0.2, color: Color(0xFFFFD166)),
    _Sprinkle3D(u: 3.05, v: 1.60, rotation: -0.5, color: Color(0xFFFF8B8B)),
    _Sprinkle3D(u: 3.90, v: 1.55, rotation: 1.0, color: Color(0xFFDED2F9)),
    _Sprinkle3D(u: 4.80, v: 1.65, rotation: -0.4, color: Color(0xFF9AD0EC)),
    _Sprinkle3D(u: 5.70, v: 1.50, rotation: 0.7, color: Color(0xFF70E0D0)),
    // Outer rim sprinkles
    _Sprinkle3D(u: 0.90, v: 0.50, rotation: -0.2, color: Color(0xFFFFD166)),
    _Sprinkle3D(u: 1.80, v: 0.45, rotation: 0.8, color: Color(0xFFFF8B8B)),
    _Sprinkle3D(u: 2.65, v: 0.55, rotation: -0.6, color: Color(0xFFDED2F9)),
    _Sprinkle3D(u: 3.55, v: 0.45, rotation: 0.4, color: Color(0xFF9AD0EC)),
    _Sprinkle3D(u: 4.45, v: 0.50, rotation: -0.9, color: Color(0xFF70E0D0)),
    _Sprinkle3D(u: 5.35, v: 0.45, rotation: 0.5, color: Color(0xFFFFD166)),
  ];

  const Donut3DPainter({
    required this.pitch,
    required this.yaw,
    this.ringRadius = 80.0,
    this.tubeRadius = 40.0,
    this.squashX = 1.0,
    this.squashY = 1.0,
    this.shadowOpacity = 0.30,
    this.shadowScale = 1.0,
    this.holeGlow = 0.0,
    this.lightSweep = 0.0,
    this.drawShadow = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // 1. Draw contact ground shadow beneath the donut (if enabled)
    if (drawShadow) {
      _drawContactShadow(canvas, center);
    }

    // 2. Prepare 3D rotation trigonometric values
    final cosPitch = math.cos(pitch);
    final sinPitch = math.sin(pitch);
    final cosYaw = math.cos(yaw);
    final sinYaw = math.sin(yaw);

    // Light direction (top-left studio light)
    final lx = -0.35 + lightSweep * 0.2;
    const ly = -0.65;
    const lz = 0.65;
    final lLen = math.sqrt(lx * lx + ly * ly + lz * lz);
    final normLx = lx / lLen;
    final normLy = ly / lLen;
    final normLz = lz / lLen;

    // Discretize torus into grid: Nu segments around ring, Nv segments around tube
    const int nu = 40;
    const int nv = 20;
    final List<_TorusQuad> quads = [];

    // Helper: compute 3D point on parametric torus and project to 2D
    math.Point<double> projectPoint(double x, double y, double z) {
      final rx = x * cosYaw + z * sinYaw;
      final tempZ = -x * sinYaw + z * cosYaw;
      final ry = y * cosPitch - tempZ * sinPitch;
      final rz = y * sinPitch + tempZ * cosPitch;

      final pers = focalLength / (focalLength + rz);
      final px = rx * pers * squashX;
      final py = ry * pers * squashY;
      return math.Point(px, py);
    }

    double getRotatedZ(double x, double y, double z) {
      final tempZ = -x * sinYaw + z * cosYaw;
      return y * sinPitch + tempZ * cosPitch;
    }

    // Evaluate torus mesh vertices
    for (int i = 0; i < nu; i++) {
      final u1 = (i / nu) * 2 * math.pi;
      final u2 = ((i + 1) / nu) * 2 * math.pi;

      for (int j = 0; j < nv; j++) {
        final v1 = (j / nv) * 2 * math.pi;
        final v2 = ((j + 1) / nv) * 2 * math.pi;

        final cosV1 = math.cos(v1);
        final sinV1 = math.sin(v1);
        final cosV2 = math.cos(v2);
        final sinV2 = math.sin(v2);

        final p1x = (ringRadius + tubeRadius * cosV1) * math.cos(u1);
        final p1y = (ringRadius + tubeRadius * cosV1) * math.sin(u1);
        final p1z = tubeRadius * sinV1;

        final p2x = (ringRadius + tubeRadius * cosV1) * math.cos(u2);
        final p2y = (ringRadius + tubeRadius * cosV1) * math.sin(u2);
        final p2z = tubeRadius * sinV1;

        final p3x = (ringRadius + tubeRadius * cosV2) * math.cos(u2);
        final p3y = (ringRadius + tubeRadius * cosV2) * math.sin(u2);
        final p3z = tubeRadius * sinV2;

        final p4x = (ringRadius + tubeRadius * cosV2) * math.cos(u1);
        final p4y = (ringRadius + tubeRadius * cosV2) * math.sin(u1);
        final p4z = tubeRadius * sinV2;

        final midU = (u1 + u2) / 2;
        final midV = (v1 + v2) / 2;
        final cosMidV = math.cos(midV);
        final sinMidV = math.sin(midV);
        final cosMidU = math.cos(midU);
        final sinMidU = math.sin(midU);

        final midX = (ringRadius + tubeRadius * cosMidV) * cosMidU;
        final midY = (ringRadius + tubeRadius * cosMidV) * sinMidU;
        final midZ = tubeRadius * sinMidV;

        final avgZ = getRotatedZ(midX, midY, midZ);

        final nx = cosMidV * cosMidU;
        final ny = cosMidV * sinMidU;
        final nz = sinMidV;

        final rnx = nx * cosYaw + nz * sinYaw;
        final tempNz = -nx * sinYaw + nz * cosYaw;
        final rny = ny * cosPitch - tempNz * sinPitch;
        final rnz = ny * sinPitch + tempNz * cosPitch;

        // Back-face culling
        if (rnz < -0.15) continue;

        // Diffuse lighting
        final dot = math.max(0.0, rnx * normLx + rny * normLy + rnz * normLz);
        final light = 0.35 + 0.65 * dot;

        // Glaze test: upper hemisphere with organic scalloped dripping edge
        final dripOffset = 0.18 * math.sin(4 * midU) + 0.10 * math.cos(7 * midU);
        final isGlaze = (midV >= (0.28 + dripOffset)) &&
            (midV <= (math.pi + 0.12 + dripOffset * 0.5));

        Color quadColor;
        if (isGlaze) {
          final hx = normLx;
          final hy = normLy;
          final hz = normLz + 1.0;
          final hLen = math.sqrt(hx * hx + hy * hy + hz * hz);
          final specDot = math.max(
              0.0, (rnx * (hx / hLen) + rny * (hy / hLen) + rnz * (hz / hLen)));
          final specular = math.pow(specDot, 24).toDouble();

          final r = (glazeBase.r * light).clamp(0.0, 1.0);
          final g = (glazeBase.g * light).clamp(0.0, 1.0);
          final b = (glazeBase.b * light).clamp(0.0, 1.0);

          final finalR = (r + (1.0 - r) * specular * 0.85).clamp(0.0, 1.0);
          final finalG = (g + (0.94 - g) * specular * 0.85).clamp(0.0, 1.0);
          final finalB = (b + (0.96 - b) * specular * 0.85).clamp(0.0, 1.0);

          quadColor = Color.from(alpha: 1.0, red: finalR, green: finalG, blue: finalB);
        } else {
          final r = (doughBase.r * light).clamp(0.0, 1.0);
          final g = (doughBase.g * light).clamp(0.0, 1.0);
          final b = (doughBase.b * light).clamp(0.0, 1.0);
          quadColor = Color.from(alpha: 1.0, red: r, green: g, blue: b);
        }

        final pt1 = projectPoint(p1x, p1y, p1z);
        final pt2 = projectPoint(p2x, p2y, p2z);
        final pt3 = projectPoint(p3x, p3y, p3z);
        final pt4 = projectPoint(p4x, p4y, p4z);

        quads.add(_TorusQuad(
          points: [
            Offset(center.dx + pt1.x, center.dy + pt1.y),
            Offset(center.dx + pt2.x, center.dy + pt2.y),
            Offset(center.dx + pt3.x, center.dy + pt3.y),
            Offset(center.dx + pt4.x, center.dy + pt4.y),
          ],
          avgZ: avgZ,
          color: quadColor,
          isGlaze: isGlaze,
        ));
      }
    }

    // Sort quads from back to front
    quads.sort((a, b) => a.avgZ.compareTo(b.avgZ));

    final quadPaint = Paint()..style = PaintingStyle.fill;
    for (final q in quads) {
      final path = Path()
        ..moveTo(q.points[0].dx, q.points[0].dy)
        ..lineTo(q.points[1].dx, q.points[1].dy)
        ..lineTo(q.points[2].dx, q.points[2].dy)
        ..lineTo(q.points[3].dx, q.points[3].dy)
        ..close();
      quadPaint.color = q.color;
      canvas.drawPath(path, quadPaint);
    }

    // 3. Render 3D Sprinkles on the upper glaze with proportional sizing
    _drawSprinkles(canvas, center, cosYaw, sinYaw, cosPitch, sinPitch, normLx,
        normLy, normLz);

    // 4. Soft pink-cream glow inside the inner hole
    if (holeGlow > 0.0) {
      _drawHoleGlow(canvas, center);
    }
  }

  void _drawContactShadow(Canvas canvas, Offset center) {
    if (shadowOpacity <= 0.0) return;

    final shadowY = center.dy + (ringRadius + tubeRadius) * 0.85 * squashY;
    final shadowWidth = (ringRadius + tubeRadius) * 2.0 * shadowScale * squashX;
    final shadowHeight = (tubeRadius * 0.9) * shadowScale;

    final shadowRect = Rect.fromCenter(
      center: Offset(center.dx, shadowY),
      width: shadowWidth,
      height: shadowHeight,
    );

    final shadowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF5A3825).withValues(alpha: shadowOpacity * 0.7),
          const Color(0xFF5A3825).withValues(alpha: shadowOpacity * 0.35),
          const Color(0xFF5A3825).withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(shadowRect);

    canvas.drawOval(shadowRect, shadowPaint);
  }

  void _drawSprinkles(
    Canvas canvas,
    Offset center,
    double cosYaw,
    double sinYaw,
    double cosPitch,
    double sinPitch,
    double normLx,
    double normLy,
    double normLz,
  ) {
    final visibleSprinkles = <Map<String, dynamic>>[];
    final sprinkleScale = (ringRadius + tubeRadius) / 100.0;

    for (final s in _sprinkles) {
      final cosV = math.cos(s.v);
      final sinV = math.sin(s.v);
      final cosU = math.cos(s.u);
      final sinU = math.sin(s.u);

      final x = (ringRadius + (tubeRadius + 1.2) * cosV) * cosU;
      final y = (ringRadius + (tubeRadius + 1.2) * cosV) * sinU;
      final z = (tubeRadius + 1.2) * sinV;

      final nx = cosV * cosU;
      final ny = cosV * sinU;
      final nz = sinV;

      final rx = x * cosYaw + z * sinYaw;
      final tempZ = -x * sinYaw + z * cosYaw;
      final ry = y * cosPitch - tempZ * sinPitch;
      final rz = y * sinPitch + tempZ * cosPitch;

      final rnx = nx * cosYaw + nz * sinYaw;
      final tempNz = -nx * sinYaw + nz * cosYaw;
      final rny = ny * cosPitch - tempNz * sinPitch;
      final rnz = ny * sinPitch + tempNz * cosPitch;

      if (rnz <= 0.08) continue;

      final pers = focalLength / (focalLength + rz);
      final screenX = center.dx + rx * pers * squashX;
      final screenY = center.dy + ry * pers * squashY;

      final dot = math.max(0.0, rnx * normLx + rny * normLy + rnz * normLz);
      final light = 0.55 + 0.45 * dot;

      visibleSprinkles.add({
        'x': screenX,
        'y': screenY,
        'z': rz,
        'color': s.color,
        'length': _Sprinkle3D.baseLength * sprinkleScale * pers,
        'thickness': _Sprinkle3D.baseThickness * sprinkleScale * pers,
        'angle': s.rotation + yaw * 0.3,
        'light': light,
      });
    }

    visibleSprinkles.sort((a, b) => (a['z'] as double).compareTo(b['z'] as double));

    final sprinklePaint = Paint()..style = PaintingStyle.fill;
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    for (final s in visibleSprinkles) {
      final x = s['x'] as double;
      final y = s['y'] as double;
      final color = s['color'] as Color;
      final len = s['length'] as double;
      final thick = s['thickness'] as double;
      final angle = s['angle'] as double;
      final light = s['light'] as double;

      final litColor = Color.from(
        alpha: 1.0,
        red: (color.r * light).clamp(0.0, 1.0),
        green: (color.g * light).clamp(0.0, 1.0),
        blue: (color.b * light).clamp(0.0, 1.0),
      );

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: const Offset(1.0, 1.5),
            width: len,
            height: thick,
          ),
          Radius.circular(thick / 2),
        ),
        shadowPaint,
      );

      sprinklePaint.color = litColor;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: len,
            height: thick,
          ),
          Radius.circular(thick / 2),
        ),
        sprinklePaint,
      );

      canvas.restore();
    }
  }

  void _drawHoleGlow(Canvas canvas, Offset center) {
    final glowRadius = (ringRadius - tubeRadius) * 1.35 * holeGlow;
    final glowRect = Rect.fromCircle(center: center, radius: glowRadius);

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFF6E9).withValues(alpha: 0.9 * holeGlow),
          const Color(0xFFF7DDEB).withValues(alpha: 0.65 * holeGlow),
          const Color(0xFFF58FB3).withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(glowRect);

    canvas.drawCircle(center, glowRadius, glowPaint);
  }

  @override
  bool shouldRepaint(covariant Donut3DPainter oldDelegate) {
    return oldDelegate.pitch != pitch ||
        oldDelegate.yaw != yaw ||
        oldDelegate.ringRadius != ringRadius ||
        oldDelegate.tubeRadius != tubeRadius ||
        oldDelegate.squashX != squashX ||
        oldDelegate.squashY != squashY ||
        oldDelegate.shadowOpacity != shadowOpacity ||
        oldDelegate.shadowScale != shadowScale ||
        oldDelegate.holeGlow != holeGlow ||
        oldDelegate.lightSweep != lightSweep ||
        oldDelegate.drawShadow != drawShadow;
  }
}

/// Standalone ground contact shadow that stays fixed on the floor plane
/// while the 3D donut drops, squashes, stretches, and settles above it.
class DonutGroundShadowPainter extends CustomPainter {
  final Offset center;
  final double ringRadius;
  final double tubeRadius;
  final double squashX;
  final double shadowOpacity;
  final double shadowScale;

  const DonutGroundShadowPainter({
    required this.center,
    required this.ringRadius,
    required this.tubeRadius,
    this.squashX = 1.0,
    this.shadowOpacity = 0.30,
    this.shadowScale = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (shadowOpacity <= 0.0) return;

    final shadowY = center.dy + (ringRadius + tubeRadius) * 0.85;
    final shadowWidth = (ringRadius + tubeRadius) * 2.0 * shadowScale * squashX;
    final shadowHeight = (tubeRadius * 0.9) * shadowScale;

    final shadowRect = Rect.fromCenter(
      center: Offset(center.dx, shadowY),
      width: shadowWidth,
      height: shadowHeight,
    );

    final shadowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF5A3825).withValues(alpha: shadowOpacity * 0.7),
          const Color(0xFF5A3825).withValues(alpha: shadowOpacity * 0.35),
          const Color(0xFF5A3825).withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(shadowRect);

    canvas.drawOval(shadowRect, shadowPaint);
  }

  @override
  bool shouldRepaint(covariant DonutGroundShadowPainter oldDelegate) {
    return oldDelegate.shadowOpacity != shadowOpacity ||
        oldDelegate.shadowScale != shadowScale ||
        oldDelegate.squashX != squashX ||
        oldDelegate.ringRadius != ringRadius ||
        oldDelegate.tubeRadius != tubeRadius ||
        oldDelegate.center != center;
  }
}
