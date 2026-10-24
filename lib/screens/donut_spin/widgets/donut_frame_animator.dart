import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Analytical calibration constants empirically measured from the reference-guided 3D frames:
/// - Frame size: 320x320 px
/// - Hole center: (161.0, 160.0) — optical center opening
/// - Hole radius: 44.5 px — 100% transparent opening (diameter 89 px)
/// - Outer rim radius: 140.0 px — golden dough & pink glaze
class DonutCalibration {
  static const double frameSize = 320.0;
  static const double holeRadius = 44.5;
  static const double outerRadius = 140.0;

  /// Inner hole radius relative to the rendered donut diameter.
  /// 44.5 / 320.0 = 0.1390625.
  static const double holeRadiusRatio = holeRadius / frameSize;

  /// Outer radius relative to the rendered donut diameter.
  /// 140.0 / 320.0 = 0.4375.
  static const double outerRadiusRatio = outerRadius / frameSize;

  /// Center X offset relative to frame center: (161.0 - 160.0) / 320.0 = 0.003125.
  static const double holeCenterOffsetX = (161.0 - 160.0) / frameSize;
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

/// Dynamic 3D Donut Animator:
/// Displays the 48 pre-rendered reference-guided photorealistic 3D frames from the atlas,
/// supporting squash/stretch deformation for impact bounces and true 3D perspective rotation.
class DonutFrameAnimator extends StatefulWidget {
  /// Active frame index (0 to 47).
  /// Frame 0: Plain golden dough at rest (matching LEFT reference).
  /// Frames 1-46: True 3D diagonal 360° rotation with progressive icing spread (matching MIDDLE reference).
  /// Frame 47: Fully decorated strawberry pink glazed donut with 3D candy sprinkles (matching RIGHT reference).
  final int frameIndex;

  /// Rendered diameter on screen.
  final double diameter;

  /// Gooey squash/stretch factors.
  final double squashX;
  final double squashY;

  const DonutFrameAnimator({
    super.key,
    required this.frameIndex,
    required this.diameter,
    this.squashX = 1.0,
    this.squashY = 1.0,
  });

  @override
  State<DonutFrameAnimator> createState() => _DonutFrameAnimatorState();
}

class _DonutFrameAnimatorState extends State<DonutFrameAnimator> {
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
          ),
        ),
      ),
    );
  }
}

class _DonutAtlasFramePainter extends CustomPainter {
  final ui.Image? image;
  final int frameIndex;

  _DonutAtlasFramePainter({
    required this.image,
    required this.frameIndex,
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
  }

  @override
  bool shouldRepaint(covariant _DonutAtlasFramePainter oldDelegate) {
    return oldDelegate.image != image || oldDelegate.frameIndex != frameIndex;
  }
}
