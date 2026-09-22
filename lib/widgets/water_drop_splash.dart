import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Custom [InteractiveInkFeature] that replaces Material's default ripple
/// with a "water drop" effect: a soft ring expands out from the tap point
/// while a translucent teal fill blooms and fades, like a drop hitting
/// water. Wired app-wide via `splashFactory` in [buildAppTheme] so every
/// InkWell / card / nav item / button gets it for free — no per-widget
/// changes needed.
class WaterDropSplashFactory extends InteractiveInkFeatureFactory {
  const WaterDropSplashFactory();

  @override
  InteractiveInkFeature create({
    required MaterialInkController controller,
    required RenderBox referenceBox,
    required Offset position,
    required Color color,
    required TextDirection textDirection,
    bool containedInkWell = false,
    RectCallback? rectCallback,
    BorderRadius? borderRadius,
    ShapeBorder? customBorder,
    double? radius,
    VoidCallback? onRemoved,
  }) {
    return _WaterDropSplash(
      controller: controller,
      referenceBox: referenceBox,
      position: position,
      containedInkWell: containedInkWell,
      rectCallback: rectCallback,
      radius: radius,
      onRemoved: onRemoved,
    );
  }
}

class _WaterDropSplash extends InteractiveInkFeature {
  _WaterDropSplash({
    required super.controller,
    required super.referenceBox,
    required Offset position,
    this.containedInkWell = false,
    this.rectCallback,
    double? radius,
    super.onRemoved,
  }) : _position = position,
       _targetRadius = radius ?? _getTargetRadius(referenceBox, rectCallback),
       _clipRect = containedInkWell
           ? (rectCallback ?? (() => Offset.zero & referenceBox.size))
           : null,
       super(color: AppColors.teal) {
    // Ring expands past the target radius a touch, fill blooms then fades.
    _radiusController = AnimationController(
      duration: const Duration(milliseconds: 380),
      vsync: controller.vsync,
    )..addListener(controller.markNeedsPaint);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 320),
      vsync: controller.vsync,
    )..addListener(controller.markNeedsPaint);

    _radius = _radiusController.drive(
      Tween<double>(
        begin: _targetRadius * 0.28,
        end: _targetRadius * 1.08,
      ).chain(CurveTween(curve: Curves.easeOutCubic)),
    );
    _fillFade = _fadeController.drive(
      TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween(
            begin: 0.0,
            end: 0.55,
          ).chain(CurveTween(curve: Curves.easeOut)),
          weight: 35,
        ),
        TweenSequenceItem(
          tween: Tween(
            begin: 0.55,
            end: 0.0,
          ).chain(CurveTween(curve: Curves.easeIn)),
          weight: 65,
        ),
      ]),
    );
    _ringFade = _radiusController.drive(
      TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.85), weight: 20),
        TweenSequenceItem(tween: Tween(begin: 0.85, end: 0.0), weight: 80),
      ]),
    );

    controller.addInkFeature(this);
    _radiusController.forward();
    _fadeController.forward();
  }

  final bool containedInkWell;
  final RectCallback? rectCallback;
  final Offset _position;
  final double _targetRadius;
  final RectCallback? _clipRect;

  late final AnimationController _radiusController;
  late final AnimationController _fadeController;
  late final Animation<double> _radius;
  late final Animation<double> _fillFade;
  late final Animation<double> _ringFade;

  static double _getTargetRadius(
    RenderBox referenceBox,
    RectCallback? rectCallback,
  ) {
    final Size size = rectCallback != null
        ? rectCallback().size
        : referenceBox.size;
    final double d1 = size.bottomRight(Offset.zero).distance;
    final double d2 =
        (size.topRight(Offset.zero) - size.bottomLeft(Offset.zero)).distance;
    return math.max(d1, d2) / 2.0;
  }

  @override
  void dispose() {
    _radiusController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  void paintFeature(Canvas canvas, Matrix4 transform) {
    final int fillAlpha = Color.getAlphaFromOpacity(_fillFade.value);
    final int ringAlpha = Color.getAlphaFromOpacity(_ringFade.value);
    final Paint fillPaint = Paint()
      ..color = AppColors.teal.withAlpha(fillAlpha);
    final Paint ringPaint = Paint()
      ..color = AppColors.captureCyan.withAlpha(ringAlpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    canvas.save();
    canvas.transform(transform.storage);
    if (_clipRect != null) {
      canvas.clipRect(_clipRect());
    }
    canvas.drawCircle(_position, _radius.value * 0.86, fillPaint);
    canvas.drawCircle(_position, _radius.value, ringPaint);
    canvas.restore();
  }
}
