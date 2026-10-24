import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Analytical calibration constants empirically measured from the 3D raymarched frames:
/// - Frame size: 320x320 px
/// - Hole center: (160.0, 160.0) — dead center
/// - Hole radius: 58.0 px — 100% transparent opening
/// - Outer rim radius: 144.0 px — golden dough & pink glaze
class DonutCalibration {
  static const double frameSize = 320.0;
  static const double holeRadius = 58.0;
  static const double outerRadius = 144.0;

  /// Inner hole radius relative to the rendered donut diameter.
  /// 58.0 / 320.0 = 0.18125.
  static const double holeRadiusRatio = holeRadius / frameSize;

  /// Outer radius relative to the rendered donut diameter.
  /// 144.0 / 320.0 = 0.450.
  static const double outerRadiusRatio = outerRadius / frameSize;
}

/// Static manager that caches the decoded 48-frame atlas in GPU memory
/// to ensure 60fps stutter-free playback and zero re-decoding overhead.
class DonutAtlasManager {
  static ui.Image? _cachedAtlas;
  static Future<ui.Image>? _loadingFuture;

  static bool get isLoaded => _cachedAtlas != null;
  static ui.Image? get atlas => _cachedAtlas;

  static Future<ui.Image> ensureLoaded() {
    if (_cachedAtlas != null) {
      return Future.value(_cachedAtlas!);
    }
    if (_loadingFuture != null) {
      return _loadingFuture!;
    }

    _loadingFuture = () async {
      try {
        final ByteData data = await rootBundle.load('assets/images/donut/donut_spin_sheet.png');
        final Uint8List bytes = data.buffer.asUint8List();
        final ui.Codec codec = await ui.instantiateImageCodec(bytes);
        final ui.FrameInfo fi = await codec.getNextFrame();
        _cachedAtlas = fi.image;
        return fi.image;
      } catch (e) {
        _loadingFuture = null;
        rethrow;
      }
    }();

    return _loadingFuture!;
  }
}

/// Individual 3D candy sprinkle resting on the strawberry glaze surface
class _SurfaceSprinkle {
  final double angle; // Polar angle on the donut ring [0, 2pi)
  final double radialOffset; // Normalized distance from center (0.64 to 0.88 of donut radius)
  final double rotation; // In-plane orientation angle
  final double length; // Length of the candy rod
  final double thickness; // Diameter of the candy rod
  final Color color; // Pastel confectionery color
  final double popDelay; // Normalized time offset [0.0, 0.45] when sprinkle pops on

  const _SurfaceSprinkle({
    required this.angle,
    required this.radialOffset,
    required this.rotation,
    required this.length,
    required this.thickness,
    required this.color,
    required this.popDelay,
  });
}

/// Dynamic 3D Donut Animator:
/// Orchestrates the 48 pre-rendered photorealistic 3D frames from the atlas,
/// squash/stretch deformation for impact bounces, and dynamic pop-in candy sprinkles.
class DonutFrameAnimator extends StatefulWidget {
  /// Active frame index (0 to 47).
  /// Frame 0: Plain golden dough at rest.
  /// Frames 1-46: True 3D diagonal 360° rotation with progressive icing.
  /// Frame 47: Fully decorated strawberry pink glazed donut.
  final int frameIndex;

  /// Rendered diameter on screen.
  final double diameter;

  /// Gooey squash/stretch factors.
  final double squashX;
  final double squashY;

  /// Surface sprinkle pop-in progress (0.0 = none, 1.0 = all popped and settled).
  final double sprinklePopProgress;

  const DonutFrameAnimator({
    super.key,
    required this.frameIndex,
    required this.diameter,
    this.squashX = 1.0,
    this.squashY = 1.0,
    this.sprinklePopProgress = 0.0,
  });

  @override
  State<DonutFrameAnimator> createState() => _DonutFrameAnimatorState();
}

class _DonutFrameAnimatorState extends State<DonutFrameAnimator> {
  // 24 carefully distributed candy sprinkles on the strawberry glaze
  static const List<_SurfaceSprinkle> _surfaceSprinkles = [
    _SurfaceSprinkle(angle: 0.15, radialOffset: 0.72, rotation: 0.4, length: 13, thickness: 4.2, color: Color(0xFF70E0D0), popDelay: 0.00),
    _SurfaceSprinkle(angle: 0.42, radialOffset: 0.82, rotation: -0.6, length: 12, thickness: 4.0, color: Color(0xFFFFD166), popDelay: 0.08),
    _SurfaceSprinkle(angle: 0.68, radialOffset: 0.68, rotation: 1.1, length: 14, thickness: 4.4, color: Color(0xFFFF8B8B), popDelay: 0.16),
    _SurfaceSprinkle(angle: 0.95, radialOffset: 0.78, rotation: -0.3, length: 11, thickness: 3.8, color: Color(0xFFDED2F9), popDelay: 0.04),
    _SurfaceSprinkle(angle: 1.22, radialOffset: 0.84, rotation: 0.8, length: 13, thickness: 4.2, color: Color(0xFF9AD0EC), popDelay: 0.22),
    _SurfaceSprinkle(angle: 1.50, radialOffset: 0.70, rotation: -0.9, length: 12, thickness: 4.0, color: Color(0xFF70E0D0), popDelay: 0.12),
    _SurfaceSprinkle(angle: 1.76, radialOffset: 0.80, rotation: 0.5, length: 14, thickness: 4.2, color: Color(0xFFFFD166), popDelay: 0.28),
    _SurfaceSprinkle(angle: 2.05, radialOffset: 0.66, rotation: -0.4, length: 11, thickness: 3.8, color: Color(0xFFFF8B8B), popDelay: 0.06),
    _SurfaceSprinkle(angle: 2.32, radialOffset: 0.82, rotation: 1.2, length: 13, thickness: 4.2, color: Color(0xFFDED2F9), popDelay: 0.18),
    _SurfaceSprinkle(angle: 2.60, radialOffset: 0.74, rotation: -0.7, length: 12, thickness: 4.0, color: Color(0xFF9AD0EC), popDelay: 0.32),
    _SurfaceSprinkle(angle: 2.88, radialOffset: 0.86, rotation: 0.3, length: 14, thickness: 4.4, color: Color(0xFF70E0D0), popDelay: 0.10),
    _SurfaceSprinkle(angle: 3.14, radialOffset: 0.68, rotation: -1.1, length: 11, thickness: 3.8, color: Color(0xFFFFD166), popDelay: 0.24),
    _SurfaceSprinkle(angle: 3.42, radialOffset: 0.80, rotation: 0.6, length: 13, thickness: 4.2, color: Color(0xFFFF8B8B), popDelay: 0.02),
    _SurfaceSprinkle(angle: 3.70, radialOffset: 0.72, rotation: -0.5, length: 12, thickness: 4.0, color: Color(0xFFDED2F9), popDelay: 0.36),
    _SurfaceSprinkle(angle: 3.98, radialOffset: 0.84, rotation: 0.9, length: 14, thickness: 4.2, color: Color(0xFF9AD0EC), popDelay: 0.14),
    _SurfaceSprinkle(angle: 4.25, radialOffset: 0.66, rotation: -0.8, length: 11, thickness: 3.8, color: Color(0xFF70E0D0), popDelay: 0.26),
    _SurfaceSprinkle(angle: 4.52, radialOffset: 0.82, rotation: 0.4, length: 13, thickness: 4.2, color: Color(0xFFFFD166), popDelay: 0.40),
    _SurfaceSprinkle(angle: 4.80, radialOffset: 0.70, rotation: -0.3, length: 12, thickness: 4.0, color: Color(0xFFFF8B8B), popDelay: 0.20),
    _SurfaceSprinkle(angle: 5.08, radialOffset: 0.84, rotation: 1.0, length: 14, thickness: 4.4, color: Color(0xFFDED2F9), popDelay: 0.30),
    _SurfaceSprinkle(angle: 5.35, radialOffset: 0.68, rotation: -0.6, length: 11, thickness: 3.8, color: Color(0xFF9AD0EC), popDelay: 0.08),
    _SurfaceSprinkle(angle: 5.62, radialOffset: 0.80, rotation: 0.7, length: 13, thickness: 4.2, color: Color(0xFF70E0D0), popDelay: 0.34),
    _SurfaceSprinkle(angle: 5.88, radialOffset: 0.72, rotation: -0.9, length: 12, thickness: 4.0, color: Color(0xFFFFD166), popDelay: 0.16),
    _SurfaceSprinkle(angle: 6.12, radialOffset: 0.82, rotation: 0.2, length: 14, thickness: 4.2, color: Color(0xFFFF8B8B), popDelay: 0.42),
    _SurfaceSprinkle(angle: 0.02, radialOffset: 0.76, rotation: -0.4, length: 12, thickness: 3.9, color: Color(0xFFDED2F9), popDelay: 0.22),
  ];

  @override
  void initState() {
    super.initState();
    if (!DonutAtlasManager.isLoaded) {
      DonutAtlasManager.ensureLoaded().then((_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = DonutAtlasManager.atlas;

    return Transform.scale(
      scaleX: widget.squashX,
      scaleY: widget.squashY,
      alignment: Alignment.center,
      child: SizedBox(
        width: widget.diameter,
        height: widget.diameter,
        child: CustomPaint(
          size: Size(widget.diameter, widget.diameter),
          painter: _DonutAtlasFramePainter(
            image: image,
            frameIndex: widget.frameIndex.clamp(0, 47),
            sprinklePopProgress: widget.sprinklePopProgress,
            sprinkles: _surfaceSprinkles,
          ),
        ),
      ),
    );
  }
}

class _DonutAtlasFramePainter extends CustomPainter {
  final ui.Image? image;
  final int frameIndex;
  final double sprinklePopProgress;
  final List<_SurfaceSprinkle> sprinkles;

  _DonutAtlasFramePainter({
    required this.image,
    required this.frameIndex,
    required this.sprinklePopProgress,
    required this.sprinkles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (image == null) return;

    final int col = frameIndex % 8;
    final int row = frameIndex ~/ 8;

    const double frameW = 320.0;
    const double frameH = 320.0;

    final Rect srcRect = Rect.fromLTWH(
      col * frameW,
      row * frameH,
      frameW,
      frameH,
    );

    final Rect dstRect = Rect.fromLTWH(0, 0, size.width, size.height);

    final paint = Paint()
      ..filterQuality = FilterQuality.medium
      ..isAntiAlias = true;

    canvas.drawImageRect(image!, srcRect, dstRect, paint);

    // Dynamic 3D candy sprinkles pop-in on the glazed surface (Phase 3)
    if (sprinklePopProgress > 0.0 && frameIndex >= 45) {
      _paintSurfaceSprinkles(canvas, size);
    }
  }

  void _paintSurfaceSprinkles(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final donutRadius = size.width / 2.0;
    final scale = size.width / 320.0; // Responsive scale relative to 320 frame

    for (final s in sprinkles) {
      // Check if this sprinkle has popped
      if (sprinklePopProgress < s.popDelay) continue;

      final normalizedProgress = ((sprinklePopProgress - s.popDelay) / 0.40).clamp(0.0, 1.0);
      final bounceScale = Curves.elasticOut.transform(normalizedProgress);
      if (bounceScale <= 0.001) continue;

      // Position on the ring
      final r = donutRadius * s.radialOffset;
      final px = center.dx + r * math.cos(s.angle);
      final py = center.dy + r * math.sin(s.angle);

      final sprinkleLen = s.length * scale * bounceScale;
      final sprinkleThick = s.thickness * scale * bounceScale;

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(s.rotation);

      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: sprinkleLen,
        height: sprinkleThick,
      );
      final rrect = RRect.fromRectAndRadius(rect, Radius.circular(sprinkleThick / 2));

      // Cylindrical 3D gradient shading (light from upper-left)
      final bodyPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(s.color, Colors.white, 0.45)!, // Specular top ridge
            s.color, // Base color
            Color.lerp(s.color, Colors.black, 0.35)!, // Shadow underside
          ],
          stops: const [0.0, 0.42, 1.0],
        ).createShader(rect);

      // Cast micro contact shadow on the glaze
      final shadowPaint = Paint()
        ..color = const Color(0x33441122)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
      canvas.drawRRect(rrect.shift(Offset(0.8 * scale, 1.6 * scale)), shadowPaint);

      // Draw 3D candy rod
      canvas.drawRRect(rrect, bodyPaint);

      // Specular gloss highlight stripe along upper spine
      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.65)
        ..strokeWidth = math.max(0.8, sprinkleThick * 0.22)
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final hMargin = sprinkleThick * 0.4;
      canvas.drawLine(
        Offset(-sprinkleLen / 2 + hMargin, -sprinkleThick * 0.22),
        Offset(sprinkleLen / 2 - hMargin, -sprinkleThick * 0.22),
        highlightPaint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _DonutAtlasFramePainter oldDelegate) {
    return oldDelegate.image != image ||
        oldDelegate.frameIndex != frameIndex ||
        oldDelegate.sprinklePopProgress != sprinklePopProgress;
  }
}
