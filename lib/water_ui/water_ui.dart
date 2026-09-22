import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'water_feedback.dart';

export 'water_feedback.dart';

/// Shared physical constants. No image filters or full-screen shaders.
class WaterTheme {
  static const deep = Color(0xFF176773);
  static const foam = Color(0xFFF5FCFC);
  static const duration = Duration(milliseconds: 1100);
}

/// A calm transition that lets the pressed surface finish before the next
/// screen settles into place.
class WaterPageRoute<T> extends PageRouteBuilder<T> {
  WaterPageRoute({required WidgetBuilder builder, super.settings})
    : super(
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 240),
        pageBuilder: (context, animation, secondaryAnimation) =>
            builder(context),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final entrance = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: const Interval(0, .82, curve: Curves.easeOut),
            ),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, .035),
                end: Offset.zero,
              ).animate(entrance),
              child: ScaleTransition(
                scale: Tween<double>(begin: .985, end: 1).animate(entrance),
                child: child,
              ),
            ),
          );
        },
      );
}

class WaterScaffold extends StatelessWidget {
  const WaterScaffold({super.key, required this.body, this.backgroundColor});
  final Widget body;
  final Color? backgroundColor;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: backgroundColor,
    body: WaterSurface(
      dark:
          backgroundColor?.computeLuminance() != null &&
          backgroundColor!.computeLuminance() < .1,
      child: body,
    ),
  );
}

class WaterSurface extends StatefulWidget {
  const WaterSurface({super.key, required this.child, this.dark = false});
  final Widget child;
  final bool dark;
  @override
  State<WaterSurface> createState() => _WaterSurfaceState();
}

class _WaterSurfaceState extends State<WaterSurface>
    with TickerProviderStateMixin {
  late final AnimationController _light = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 24),
  );
  late final AnimationController _touch = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );
  Offset? _touchOrigin;

  bool get _reduced => MediaQuery.disableAnimationsOf(context);

  void _touchDown(PointerDownEvent event) {
    if (_reduced) return;
    setState(() => _touchOrigin = event.localPosition);
    _touch.forward(from: 0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_reduced || !TickerMode.of(context)) {
      _light.stop();
      _touch.stop();
    } else {
      _light.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _light.dispose();
    _touch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Listener(
    behavior: HitTestBehavior.translucent,
    onPointerDown: _touchDown,
    child: Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          child: CustomPaint(
            painter: _SurfacePainter(
              light: _light,
              touch: _touch,
              touchOrigin: _touchOrigin,
              dark: widget.dark,
            ),
          ),
        ),
        widget.child,
      ],
    ),
  );
}

class _SurfacePainter extends CustomPainter {
  _SurfacePainter({
    required this.light,
    required this.touch,
    required this.touchOrigin,
    required this.dark,
  }) : super(repaint: Listenable.merge([light, touch]));
  final Animation<double> light;
  final Animation<double> touch;
  final Offset? touchOrigin;
  final bool dark;
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment(-1 + light.value * .14, -1),
          end: Alignment(1, .82 + light.value * .16),
          colors: dark
              ? const [Color(0xFF102D35), Color(0xFF091B23)]
              : const [Color(0xFFE8F5F3), Color(0xFFC6E1E3), Color(0xFFE1EFED)],
        ).createShader(rect),
    );
    final phase = light.value * math.pi * 2;
    for (int i = 0; i < 12; i++) {
      final y = size.height * i / 11;
      final path = Path()..moveTo(-30, y);
      path.cubicTo(
        size.width * .25,
        y - 35 + math.sin(phase + i * .7) * 20,
        size.width * .7,
        y + 42 + math.cos(phase * .8 + i) * 20,
        size.width + 30,
        y - 12 + math.sin(phase + i) * 9,
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.white.withValues(alpha: dark ? .025 : .16)
          ..style = PaintingStyle.stroke
          ..strokeWidth = i.isEven ? 2 : .7,
      );
    }

    final caustic = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = dark ? .7 : 1.1
      ..color = Colors.white.withValues(alpha: dark ? .028 : .12);
    for (int i = 0; i < 8; i++) {
      final x =
          (size.width * (i + .25) / 7 + light.value * 48) % (size.width + 80) -
          40;
      final y = size.height * (.12 + .105 * i) + math.sin(phase + i) * 22;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x, y),
          width: 95 + (i % 3) * 34,
          height: 24 + (i % 2) * 11,
        ),
        caustic,
      );
    }

    final origin = touchOrigin;
    if (origin != null && touch.value > 0 && touch.value < 1) {
      final eased = Curves.easeOutCubic.transform(touch.value);
      final fade = math.pow(1 - touch.value, 2).toDouble();
      for (int i = 0; i < 4; i++) {
        final delayed = ((eased - i * .075) / (1 - i * .075)).clamp(0.0, 1.0);
        if (delayed <= 0) continue;
        final radius = size.longestSide * .42 * delayed;
        canvas.drawOval(
          Rect.fromCenter(
            center: origin,
            width: radius * 2,
            height: radius * 1.36,
          ),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6
            ..color = (dark ? Colors.white : WaterTheme.deep).withValues(
              alpha: fade * (dark ? .10 : .12),
            ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_SurfacePainter old) =>
      old.dark != dark || old.touchOrigin != touchOrigin;
}

/// Gesture-arena participation prevents scroll drags and nested buttons from
/// activating parent cards. Each instance owns and disposes its bounded effect.
class WaterInteractive extends StatefulWidget {
  const WaterInteractive({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius,
    this.customBorder,
    this.clipRipple = false,
    this.pressDepth = 3,
    this.radius = 115,
    this.duration = WaterTheme.duration,
    this.intensity = 1,
    this.opacity = .32,
    this.damping = 2,
    this.decorate = true,
    this.passive = true,
    this.feedback = WaterFeedback.button,
  });
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final ShapeBorder? customBorder;
  final bool clipRipple, decorate, passive;
  final WaterFeedback feedback;
  final double pressDepth, radius, intensity, opacity, damping;
  final Duration duration;
  @override
  State<WaterInteractive> createState() => _WaterInteractiveState();
}

class _WaterInteractiveState extends State<WaterInteractive>
    with TickerProviderStateMixin {
  late final AnimationController _pressure = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 145),
    reverseDuration: const Duration(milliseconds: 480),
  );
  late final AnimationController _wave = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  Offset _origin = Offset.zero;
  Offset _tilt = Offset.zero;
  bool _focused = false;
  bool _activating = false;
  bool get _reduced => MediaQuery.disableAnimationsOf(context);
  bool get _enabled => widget.onTap != null || widget.passive;
  void _down(Offset local) {
    final box = context.findRenderObject()! as RenderBox;
    _origin = local;
    _tilt = Offset(
      (local.dx / box.size.width - .5).clamp(-.5, .5),
      (local.dy / box.size.height - .5).clamp(-.5, .5),
    );
    if (!_reduced) {
      _pressure.forward();
      _wave.forward(from: 0);
    }
  }

  void _release() => _pressure.reverse();
  Future<void> _tap() async {
    final action = widget.onTap;
    if (action == null || _activating) return;
    _activating = true;
    WaterFeedbackController.play(widget.feedback);
    if (!_reduced) {
      await _pressure.forward();
      if (!mounted) return;
      _pressure.reverse();
    }
    _activating = false;
    action();
  }

  void _activate() {
    final box = context.findRenderObject()! as RenderBox;
    _down(box.size.center(Offset.zero));
    _tap();
  }

  @override
  void didUpdateWidget(WaterInteractive old) {
    super.didUpdateWidget(old);
    _wave.duration = widget.duration;
  }

  @override
  void dispose() {
    _pressure.dispose();
    _wave.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final border = widget.borderRadius ?? BorderRadius.circular(20);
    final dark =
        context.findAncestorWidgetOfExactType<WaterSurface>()?.dark ?? false;
    return Semantics(
      button: widget.onTap != null,
      enabled: _enabled,
      child: FocusableActionDetector(
        enabled: widget.onTap != null,
        mouseCursor: widget.onTap != null
            ? SystemMouseCursors.click
            : MouseCursor.defer,
        onShowFocusHighlight: (value) => setState(() => _focused = value),
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              _activate();
              return null;
            },
          ),
        },
        child: GestureDetector(
          excludeFromSemantics: widget.onTap == null,
          behavior: HitTestBehavior.opaque,
          onTapDown: _enabled ? (event) => _down(event.localPosition) : null,
          onTapUp: _enabled
              ? (_) {
                  if (widget.onTap == null) _release();
                }
              : null,
          onTapCancel: _enabled ? _release : null,
          onTap: widget.onTap != null ? _tap : null,
          child: AnimatedBuilder(
            animation: Listenable.merge([_pressure, _wave]),
            child: widget.child,
            builder: (context, child) {
              final depth = Curves.easeOutCubic.transform(_pressure.value);
              final shape =
                  widget.customBorder ??
                  RoundedRectangleBorder(borderRadius: border);
              Widget object = Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, .001)
                  ..translateByDouble(0.0, depth * widget.pressDepth, 0.0, 1.0)
                  ..rotateX(-_tilt.dy * depth * .024)
                  ..rotateY(_tilt.dx * depth * .024)
                  ..scaleByDouble(1 - depth * .007, 1 - depth * .007, 1.0, 1.0),
                child: Container(
                  decoration: widget.decorate
                      ? ShapeDecoration(
                          shape: shape,
                          color: dark
                              ? const Color(0xFF173941)
                              : WaterTheme.foam,
                          shadows: [
                            BoxShadow(
                              color: WaterTheme.deep.withValues(
                                alpha: .20 - depth * .11,
                              ),
                              blurRadius: 25 - depth * 14,
                              offset: Offset(0, 10 - depth * 7),
                            ),
                            BoxShadow(
                              color: Colors.white.withValues(
                                alpha: .55 - depth * .30,
                              ),
                              blurRadius: 2,
                              offset: const Offset(0, -1),
                            ),
                          ],
                        )
                      : null,
                  foregroundDecoration: widget.decorate || _focused
                      ? ShapeDecoration(
                          shape: _focused
                              ? RoundedRectangleBorder(
                                  borderRadius: border,
                                  side: const BorderSide(
                                    color: WaterTheme.deep,
                                    width: 2,
                                  ),
                                )
                              : shape,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: .20 + depth * .10),
                              Colors.transparent,
                              WaterTheme.deep.withValues(
                                alpha: .035 + depth * .035,
                              ),
                            ],
                          ),
                        )
                      : null,
                  child: child,
                ),
              );
              object = CustomPaint(
                foregroundPainter: WaterRipple(
                  progress: _wave.value,
                  origin: _origin,
                  radius: widget.radius,
                  opacity: widget.opacity * widget.intensity,
                  damping: widget.damping,
                  border: border,
                  clipped: widget.clipRipple,
                  shape: widget.customBorder,
                ),
                child: object,
              );
              return object;
            },
          ),
        ),
      ),
    );
  }
}

/// Refracted paired crests and a boundary meniscus, painted outside cards but
/// explicitly masked to an individual navigation item for isolated surfaces.
class WaterRipple extends CustomPainter {
  const WaterRipple({
    required this.progress,
    required this.origin,
    required this.radius,
    required this.opacity,
    required this.damping,
    required this.border,
    required this.clipped,
    this.shape,
  });
  final double progress, radius, opacity, damping;
  final Offset origin;
  final BorderRadius border;
  final bool clipped;
  final ShapeBorder? shape;
  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    final rect = Offset.zero & size;
    canvas.save();
    if (clipped) {
      canvas.clipPath(
        (shape ?? RoundedRectangleBorder(borderRadius: border)).getOuterPath(
          rect,
        ),
      );
    } else {
      canvas.clipRect(rect.inflate(32));
    }
    final fade = math.pow(1 - progress, damping).toDouble() * opacity;
    for (int i = 0; i < 3; i++) {
      final phase = ((progress - i * .075) / (1 - i * .075)).clamp(0.0, 1.0);
      if (phase == 0) continue;
      final r = radius * Curves.easeOutCubic.transform(phase);
      final oval = Rect.fromCenter(
        center: origin,
        width: r * 2,
        height: r * 1.35,
      );
      canvas.drawOval(
        oval.translate(0, 1.5),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.3
          ..color = WaterTheme.deep.withValues(alpha: fade * .65),
      );
      canvas.drawOval(
        oval,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = Colors.white.withValues(alpha: fade),
      );
    }
    if (!clipped) {
      final rim = border.toRRect(rect.inflate(2 + progress * 12));
      canvas.drawRRect(
        rim,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.3
          ..color = Colors.white.withValues(alpha: fade * .55),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(WaterRipple old) =>
      old.progress != progress || old.origin != origin;
}

class WaterButton extends WaterInteractive {
  const WaterButton({
    super.key,
    required super.child,
    super.onTap,
    super.borderRadius,
    super.customBorder,
    super.feedback = WaterFeedback.button,
  }) : super(passive: false, pressDepth: 4, radius: 82);
}

class WaterCard extends WaterInteractive {
  const WaterCard({
    super.key,
    required super.child,
    super.onTap,
    super.borderRadius,
    super.feedback = WaterFeedback.card,
  }) : super(pressDepth: 6, radius: 180);
}

class WaterNavItem extends WaterInteractive {
  const WaterNavItem({
    super.key,
    required super.child,
    required super.onTap,
    super.borderRadius,
  }) : super(
         clipRipple: true,
         passive: false,
         decorate: false,
         pressDepth: 3,
         radius: 72,
         feedback: WaterFeedback.navigation,
       );
}
