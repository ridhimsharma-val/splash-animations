import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// 3D Candy sprinkle anchored to the parametric torus surface.
class _SurfaceSprinkle3D {
  final double u; // Azimuth angle on ring [0, 2pi)
  final double v; // Polar angle on tube [0, pi]
  final double rotation; // In-surface orientation
  final Color color;
  final double length;
  final double thickness;

  const _SurfaceSprinkle3D({
    required this.u,
    required this.v,
    required this.rotation,
    required this.color,
    required this.length,
    required this.thickness,
  });
}

/// A depth-sorted triangle primitive for the 3D mesh renderer.
class _MeshTriangle3D {
  final Offset p1;
  final Offset p2;
  final Offset p3;
  final Color c1;
  final Color c2;
  final Color c3;
  final double avgZ;

  const _MeshTriangle3D({
    required this.p1,
    required this.p2,
    required this.p3,
    required this.c1,
    required this.c2,
    required this.c3,
    required this.avgZ,
  });
}

/// High-Performance Genuine 3D Donut Mesh Renderer.
/// Renders an authentic continuous 3D torus with a physical center hole:
/// - Golden-brown baked dough continuous geometry.
/// - Physically offset strawberry-pink glaze with organic dripping boundaries.
/// - Smooth Gouraud per-vertex normal lighting for silky rounded surfaces without polygon facets.
/// - True 3D perspective projection, pitch & yaw rotation, and thickness visibility.
/// - Surface-anchored 3D candy sprinkles.
class Donut3DMeshRenderer extends CustomPainter {
  final double pitch; // X-axis tilt in radians
  final double yaw; // Y-axis spin in radians
  final double ringRadius; // Major radius R
  final double tubeRadius; // Minor radius r
  final double squashX; // Horizontal squash deformation factor
  final double squashY; // Vertical squash deformation factor
  final double focalLength; // Perspective camera distance

  // Studio lighting vectors (normalized)
  static final _lightDir = _normalize(const Offset3D(-0.45, -0.65, 0.72));
  static final _fillDir = _normalize(const Offset3D(0.40, 0.50, 0.50));

  // Color Palette
  static const Color doughBase = Color(0xFFE29E57); // Warm golden-brown baked dough
  static const Color doughShadow = Color(0xFFA6581C); // Toasted crust tone
  static const Color doughDeep = Color(0xFF6B3308); // Crevice ambient occlusion
  static const Color glazeBase = Color(0xFFF7769F); // Strawberry-pink glaze
  static const Color glazeShadow = Color(0xFFD44572); // Deep glaze shading
  static const Color glazeHighlight = Color(0xFFFFF0F5); // Specular gloss highlight

  // Deterministic 3D surface sprinkles anchored to the glaze
  static const List<_SurfaceSprinkle3D> _surfaceSprinkles = [
    _SurfaceSprinkle3D(u: 0.30, v: 0.90, rotation: 0.45, color: Color(0xFF4DD0E1), length: 13.0, thickness: 4.2),
    _SurfaceSprinkle3D(u: 0.75, v: 1.25, rotation: -0.60, color: Color(0xFFFFD54F), length: 14.0, thickness: 4.0),
    _SurfaceSprinkle3D(u: 1.20, v: 0.75, rotation: 1.10, color: Color(0xFFFF7A7A), length: 12.5, thickness: 4.0),
    _SurfaceSprinkle3D(u: 1.65, v: 1.35, rotation: -0.35, color: Color(0xFFB39DDB), length: 14.5, thickness: 4.4),
    _SurfaceSprinkle3D(u: 2.10, v: 0.95, rotation: 0.85, color: Color(0xFF81D4FA), length: 13.0, thickness: 4.0),
    _SurfaceSprinkle3D(u: 2.55, v: 1.20, rotation: -0.90, color: Color(0xFF4DD0E1), length: 14.0, thickness: 4.2),
    _SurfaceSprinkle3D(u: 3.00, v: 0.80, rotation: 0.50, color: Color(0xFFFFD54F), length: 13.5, thickness: 4.0),
    _SurfaceSprinkle3D(u: 3.45, v: 1.15, rotation: -0.45, color: Color(0xFFFF7A7A), length: 12.0, thickness: 4.0),
    _SurfaceSprinkle3D(u: 3.90, v: 0.85, rotation: 1.20, color: Color(0xFFB39DDB), length: 14.0, thickness: 4.2),
    _SurfaceSprinkle3D(u: 4.35, v: 1.30, rotation: -0.75, color: Color(0xFF81D4FA), length: 13.0, thickness: 4.0),
    _SurfaceSprinkle3D(u: 4.80, v: 0.80, rotation: 0.35, color: Color(0xFF4DD0E1), length: 14.0, thickness: 4.2),
    _SurfaceSprinkle3D(u: 5.25, v: 1.20, rotation: -1.05, color: Color(0xFFFFD54F), length: 13.0, thickness: 4.0),
    _SurfaceSprinkle3D(u: 5.70, v: 0.90, rotation: 0.65, color: Color(0xFFFF7A7A), length: 14.5, thickness: 4.4),
    _SurfaceSprinkle3D(u: 6.15, v: 1.30, rotation: -0.50, color: Color(0xFFB39DDB), length: 13.0, thickness: 4.0),
    // Inner rim sprinkles
    _SurfaceSprinkle3D(u: 0.50, v: 1.60, rotation: 0.95, color: Color(0xFF81D4FA), length: 12.0, thickness: 3.8),
    _SurfaceSprinkle3D(u: 1.45, v: 1.70, rotation: -0.75, color: Color(0xFF4DD0E1), length: 13.0, thickness: 4.0),
    _SurfaceSprinkle3D(u: 2.35, v: 1.55, rotation: 0.25, color: Color(0xFFFFD54F), length: 12.5, thickness: 3.8),
    _SurfaceSprinkle3D(u: 3.25, v: 1.65, rotation: -0.55, color: Color(0xFFFF7A7A), length: 13.5, thickness: 4.0),
    _SurfaceSprinkle3D(u: 4.15, v: 1.60, rotation: 1.05, color: Color(0xFFB39DDB), length: 12.0, thickness: 3.8),
    _SurfaceSprinkle3D(u: 5.05, v: 1.70, rotation: -0.45, color: Color(0xFF81D4FA), length: 13.0, thickness: 4.0),
    _SurfaceSprinkle3D(u: 5.95, v: 1.55, rotation: 0.70, color: Color(0xFF4DD0E1), length: 12.5, thickness: 3.8),
    // Outer rim sprinkles
    _SurfaceSprinkle3D(u: 0.95, v: 0.55, rotation: -0.25, color: Color(0xFFFFD54F), length: 12.5, thickness: 3.8),
    _SurfaceSprinkle3D(u: 1.90, v: 0.50, rotation: 0.85, color: Color(0xFFFF7A7A), length: 13.0, thickness: 4.0),
    _SurfaceSprinkle3D(u: 2.80, v: 0.60, rotation: -0.65, color: Color(0xFFB39DDB), length: 13.5, thickness: 4.0),
    _SurfaceSprinkle3D(u: 3.75, v: 0.50, rotation: 0.40, color: Color(0xFF81D4FA), length: 12.0, thickness: 3.8),
    _SurfaceSprinkle3D(u: 4.65, v: 0.55, rotation: -0.95, color: Color(0xFF4DD0E1), length: 13.0, thickness: 4.0),
    _SurfaceSprinkle3D(u: 5.55, v: 0.50, rotation: 0.55, color: Color(0xFFFFD54F), length: 13.5, thickness: 4.0),
  ];

  const Donut3DMeshRenderer({
    required this.pitch,
    required this.yaw,
    required this.ringRadius,
    required this.tubeRadius,
    this.squashX = 1.0,
    this.squashY = 1.0,
    this.focalLength = 520.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final cosPitch = math.cos(pitch);
    final sinPitch = math.sin(pitch);
    final cosYaw = math.cos(yaw);
    final sinYaw = math.sin(yaw);

    // Mesh density: Nu segments around ring, Nv segments around tube
    const int nu = 48;
    const int nv = 24;

    // Helper: compute rotated 3D point and normal
    Offset3D rotatePoint(double x, double y, double z) {
      final rx = x * cosYaw + z * sinYaw;
      final tempZ = -x * sinYaw + z * cosYaw;
      final ry = y * cosPitch - tempZ * sinPitch;
      final rz = y * sinPitch + tempZ * cosPitch;
      return Offset3D(rx, ry, rz);
    }

    Offset3D rotateNormal(double nx, double ny, double nz) {
      final rnx = nx * cosYaw + nz * sinYaw;
      final tempNz = -nx * sinYaw + nz * cosYaw;
      final rny = ny * cosPitch - tempNz * sinPitch;
      final rnz = ny * sinPitch + tempNz * cosPitch;
      return Offset3D(rnx, rny, rnz);
    }

    // Helper: project 3D point to 2D screen with perspective and squash
    Offset projectTo2D(Offset3D p) {
      final pers = focalLength / (focalLength + p.z);
      return Offset(
        center.dx + p.x * pers * squashX,
        center.dy + p.y * pers * squashY,
      );
    }

    // Compute smooth vertex color with dual studio lighting and specular highlights
    Color computeVertexColor(Offset3D normal, bool isGlaze) {
      // Key light diffuse
      final dotKey = math.max(0.0, normal.x * _lightDir.x + normal.y * _lightDir.y + normal.z * _lightDir.z);
      // Fill light diffuse
      final dotFill = math.max(0.0, normal.x * _fillDir.x + normal.y * _fillDir.y + normal.z * _fillDir.z);

      final diffuse = 0.28 + 0.58 * dotKey + 0.18 * dotFill;

      if (isGlaze) {
        // Specular highlight (halfway vector toward viewer +Z)
        final hx = _lightDir.x;
        final hy = _lightDir.y;
        final hz = _lightDir.z + 1.0;
        final hLen = math.sqrt(hx * hx + hy * hy + hz * hz);
        final specDot = math.max(0.0, (normal.x * hx + normal.y * hy + normal.z * hz) / hLen);
        final specular = math.pow(specDot, 28).toDouble();

        final baseR = glazeBase.r;
        final baseG = glazeBase.g;
        final baseB = glazeBase.b;

        final r = (baseR * diffuse + 0.85 * specular).clamp(0.0, 1.0);
        final g = (baseG * diffuse + 0.85 * specular).clamp(0.0, 1.0);
        final b = (baseB * diffuse + 0.85 * specular).clamp(0.0, 1.0);

        return Color.from(alpha: 1.0, red: r, green: g, blue: b);
      } else {
        // Dough shading
        final baseR = doughBase.r;
        final baseG = doughBase.g;
        final baseB = doughBase.b;

        final r = (baseR * diffuse).clamp(0.0, 1.0);
        final g = (baseG * diffuse).clamp(0.0, 1.0);
        final b = (baseB * diffuse).clamp(0.0, 1.0);

        return Color.from(alpha: 1.0, red: r, green: g, blue: b);
      }
    }

    final List<_MeshTriangle3D> triangles = [];

    // 1. Generate 3D Dough & Glaze continuous mesh
    for (int i = 0; i < nu; i++) {
      final u1 = (i / nu) * 2 * math.pi;
      final u2 = ((i + 1) / nu) * 2 * math.pi;
      final cosU1 = math.cos(u1);
      final sinU1 = math.sin(u1);
      final cosU2 = math.cos(u2);
      final sinU2 = math.sin(u2);

      // Organic wavy dripping threshold for strawberry glaze
      final drip1 = 0.16 * math.sin(4 * u1) + 0.10 * math.cos(7 * u1);
      final drip2 = 0.16 * math.sin(4 * u2) + 0.10 * math.cos(7 * u2);

      for (int j = 0; j < nv; j++) {
        final v1 = (j / nv) * 2 * math.pi;
        final v2 = ((j + 1) / nv) * 2 * math.pi;
        final cosV1 = math.cos(v1);
        final sinV1 = math.sin(v1);
        final cosV2 = math.cos(v2);
        final sinV2 = math.sin(v2);

        // Torus 3D geometry formula:
        // x = (R + r * cos(v)) * cos(u)
        // y = (R + r * cos(v)) * sin(u)
        // z = r * sin(v)
        final isGlaze1 = (v1 >= (0.24 + drip1)) && (v1 <= (math.pi + 0.16 + drip1 * 0.5));
        final isGlaze2 = (v2 >= (0.24 + drip2)) && (v2 <= (math.pi + 0.16 + drip2 * 0.5));

        // Glaze has a subtle physical thickness offset (+1.6 px)
        final rOffset1 = isGlaze1 ? 1.6 : 0.0;
        final rOffset2 = isGlaze2 ? 1.6 : 0.0;

        // Vertex 1: (u1, v1)
        final p1 = rotatePoint(
          (ringRadius + (tubeRadius + rOffset1) * cosV1) * cosU1,
          (ringRadius + (tubeRadius + rOffset1) * cosV1) * sinU1,
          (tubeRadius + rOffset1) * sinV1,
        );
        final n1 = rotateNormal(cosV1 * cosU1, cosV1 * sinU1, sinV1);

        // Vertex 2: (u2, v1)
        final p2 = rotatePoint(
          (ringRadius + (tubeRadius + rOffset1) * cosV1) * cosU2,
          (ringRadius + (tubeRadius + rOffset1) * cosV1) * sinU2,
          (tubeRadius + rOffset1) * sinV1,
        );
        final n2 = rotateNormal(cosV1 * cosU2, cosV1 * sinU2, sinV1);

        // Vertex 3: (u2, v2)
        final p3 = rotatePoint(
          (ringRadius + (tubeRadius + rOffset2) * cosV2) * cosU2,
          (ringRadius + (tubeRadius + rOffset2) * cosV2) * sinU2,
          (tubeRadius + rOffset2) * sinV2,
        );
        final n3 = rotateNormal(cosV2 * cosU2, cosV2 * sinU2, sinV2);

        // Vertex 4: (u1, v2)
        final p4 = rotatePoint(
          (ringRadius + (tubeRadius + rOffset2) * cosV2) * cosU1,
          (ringRadius + (tubeRadius + rOffset2) * cosV2) * sinU1,
          (tubeRadius + rOffset2) * sinV2,
        );
        final n4 = rotateNormal(cosV2 * cosU1, cosV2 * sinU1, sinV2);

        // Backface culling on quad normal Z
        final avgZ = (p1.z + p2.z + p3.z + p4.z) / 4.0;
        final normZ = (n1.z + n2.z + n3.z + n4.z) / 4.0;
        if (normZ < -0.15) continue; // Face pointing away from camera

        final s1 = projectTo2D(p1);
        final s2 = projectTo2D(p2);
        final s3 = projectTo2D(p3);
        final s4 = projectTo2D(p4);

        final c1 = computeVertexColor(n1, isGlaze1);
        final c2 = computeVertexColor(n2, isGlaze1);
        final c3 = computeVertexColor(n3, isGlaze2);
        final c4 = computeVertexColor(n4, isGlaze2);

        // Split quad into two smooth triangles
        triangles.add(_MeshTriangle3D(p1: s1, p2: s2, p3: s3, c1: c1, c2: c2, c3: c3, avgZ: avgZ));
        triangles.add(_MeshTriangle3D(p1: s1, p2: s3, p3: s4, c1: c1, c2: c3, c3: c4, avgZ: avgZ));
      }
    }

    // Depth sort triangles back-to-front
    triangles.sort((a, b) => a.avgZ.compareTo(b.avgZ));

    // 2. Hardware-accelerated GPU triangle rendering via drawVertices
    if (triangles.isNotEmpty) {
      final positions = <Offset>[];
      final colors = <Color>[];

      for (final tri in triangles) {
        positions.add(tri.p1);
        positions.add(tri.p2);
        positions.add(tri.p3);
        colors.add(tri.c1);
        colors.add(tri.c2);
        colors.add(tri.c3);
      }

      final vertices = ui.Vertices(
        VertexMode.triangles,
        positions,
        colors: colors,
      );

      final paint = Paint()..style = PaintingStyle.fill;
      canvas.drawVertices(vertices, BlendMode.dst, paint);
    }

    // 3. Render 3D Surface Sprinkles locked to the rotating 3D glaze
    _draw3DSurfaceSprinkles(canvas, center, cosYaw, sinYaw, cosPitch, sinPitch);
  }

  void _draw3DSurfaceSprinkles(
    Canvas canvas,
    Offset center,
    double cosYaw,
    double sinYaw,
    double cosPitch,
    double sinPitch,
  ) {
    final visibleSprinkles = <Map<String, dynamic>>[];
    final sprinkleScale = (ringRadius + tubeRadius) / 110.0;

    for (final s in _surfaceSprinkles) {
      final cosV = math.cos(s.v);
      final sinV = math.sin(s.v);
      final cosU = math.cos(s.u);
      final sinU = math.sin(s.u);

      // 3D coordinates on top of the glaze
      final x = (ringRadius + (tubeRadius + 2.0) * cosV) * cosU;
      final y = (ringRadius + (tubeRadius + 2.0) * cosV) * sinU;
      final z = (tubeRadius + 2.0) * sinV;

      // Surface normal
      final nx = cosV * cosU;
      final ny = cosV * sinU;
      final nz = sinV;

      // 3D Rotation
      final rx = x * cosYaw + z * sinYaw;
      final tempZ = -x * sinYaw + z * cosYaw;
      final ry = y * cosPitch - tempZ * sinPitch;
      final rz = y * sinPitch + tempZ * cosPitch;

      final rnx = nx * cosYaw + nz * sinYaw;
      final tempNz = -nx * sinYaw + nz * cosYaw;
      final rny = ny * cosPitch - tempNz * sinPitch;
      final rnz = ny * sinPitch + tempNz * cosPitch;

      // Only visible if surface faces forward
      if (rnz <= 0.05) continue;

      final pers = focalLength / (focalLength + rz);
      final screenX = center.dx + rx * pers * squashX;
      final screenY = center.dy + ry * pers * squashY;

      final dot = math.max(0.0, rnx * _lightDir.x + rny * _lightDir.y + rnz * _lightDir.z);
      final light = 0.55 + 0.45 * dot;

      visibleSprinkles.add({
        'x': screenX,
        'y': screenY,
        'z': rz,
        'color': s.color,
        'length': s.length * sprinkleScale * pers,
        'thickness': s.thickness * sprinkleScale * pers,
        'angle': s.rotation + yaw * 0.25,
        'light': light,
      });
    }

    // Depth sort sprinkles back-to-front
    visibleSprinkles.sort((a, b) => (a['z'] as double).compareTo(b['z'] as double));

    final shadowPaint = Paint()..style = PaintingStyle.fill;
    final sprinklePaint = Paint()..style = PaintingStyle.fill;

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

      final halfThick = thick / 2;
      final radius = Radius.circular(halfThick);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);

      // Micro contact shadow on glaze
      shadowPaint.color = Colors.black.withValues(alpha: 0.14);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: const Offset(1.0, 1.5),
            width: len,
            height: thick,
          ),
          radius,
        ),
        shadowPaint,
      );

      // 3D cylindrical candy capsule
      sprinklePaint.color = litColor;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: len,
            height: thick,
          ),
          radius,
        ),
        sprinklePaint,
      );

      canvas.restore();
    }
  }

  static Offset3D _normalize(Offset3D v) {
    final len = math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
    return Offset3D(v.x / len, v.y / len, v.z / len);
  }

  @override
  bool shouldRepaint(covariant Donut3DMeshRenderer oldDelegate) {
    return oldDelegate.pitch != pitch ||
        oldDelegate.yaw != yaw ||
        oldDelegate.ringRadius != ringRadius ||
        oldDelegate.tubeRadius != tubeRadius ||
        oldDelegate.squashX != squashX ||
        oldDelegate.squashY != squashY;
  }
}

/// Helper 3D vector struct for mesh operations
class Offset3D {
  final double x;
  final double y;
  final double z;

  const Offset3D(this.x, this.y, this.z);
}
