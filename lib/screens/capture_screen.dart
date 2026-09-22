import '../water_ui/water_ui.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../l10n/strings.dart';
import '../theme/app_theme.dart';
import 'analyzing_screen.dart';

class CaptureScreen extends StatefulWidget {
  final ScreenMode mode;
  const CaptureScreen({super.key, required this.mode});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

enum _CamState { loading, ready, noCamera, permissionDenied, error }

class _CaptureScreenState extends State<CaptureScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  _CamState _state = _CamState.loading;
  String? _errorMessage;
  bool _torchOn = false;
  bool _capturing = false;
  List<CameraDescription> _cameras = [];
  CameraLensDirection _lens = CameraLensDirection.back;

  double _minZoom = 1.0;
  double _maxZoom = 1.0;
  double _zoom = 1.0;
  double _zoomGestureStart = 1.0;

  // Default zoom on open — guided capture needs the lens close to the eye
  // (or newborn's skin), and most phone cameras' 1x field of view is too wide.
  static const double _defaultZoom = 2.0;

  bool get isAnemia => widget.mode == ScreenMode.anemia;
  bool get _hasMultipleCameras =>
      _cameras.map((c) => c.lensDirection).toSet().length > 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupCamera();
  }

  Future<void> _setupCamera() async {
    try {
      final cameras = _cameras.isNotEmpty ? _cameras : await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _state = _CamState.noCamera);
        return;
      }
      debugPrint(
        '[AnemiaScan] availableCameras: '
        '${cameras.map((c) => '${c.name}/${c.lensDirection}').join(', ')}',
      );
      final chosen = cameras.firstWhere(
        (c) => c.lensDirection == _lens,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        chosen,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();
      final minZoom = await controller.getMinZoomLevel();
      final maxZoom = await controller.getMaxZoomLevel();
      final startZoom = _defaultZoom.clamp(minZoom, maxZoom);
      await controller.setZoomLevel(startZoom);
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _cameras = cameras;
        _lens = chosen.lensDirection;
        _controller = controller;
        _state = _CamState.ready;
        _torchOn = false;
        _minZoom = minZoom;
        _maxZoom = maxZoom;
        _zoom = startZoom;
      });
    } on CameraException catch (e) {
      if (!mounted) return;
      setState(() {
        _state =
            e.code == 'CameraAccessDenied' ||
                e.code == 'CameraAccessDeniedWithoutPrompt'
            ? _CamState.permissionDenied
            : _CamState.error;
        _errorMessage = e.description ?? e.code;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _state = _CamState.error;
        _errorMessage = '$e';
      });
    }
  }

  void _onZoomStart(ScaleStartDetails details) {
    _zoomGestureStart = _zoom;
  }

  Future<void> _onZoomUpdate(ScaleUpdateDetails details) async {
    final controller = _controller;
    if (controller == null || _maxZoom <= _minZoom) return;
    final next = (_zoomGestureStart * details.scale).clamp(_minZoom, _maxZoom);
    if ((next - _zoom).abs() < 0.02) return;
    setState(() => _zoom = next);
    await controller.setZoomLevel(next);
  }

  Future<void> _switchCamera() async {
    if (!_hasMultipleCameras) return;
    final old = _controller;
    _controller = null;
    setState(() {
      _state = _CamState.loading;
      _lens = _lens == CameraLensDirection.back
          ? CameraLensDirection.front
          : CameraLensDirection.back;
    });
    await old?.dispose();
    await _setupCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      controller.dispose();
      _controller = null;
    } else if (state == AppLifecycleState.resumed) {
      _setupCamera();
    }
  }

  Future<void> _toggleTorch() async {
    final controller = _controller;
    if (controller == null) return;
    final next = !_torchOn;
    try {
      await controller.setFlashMode(next ? FlashMode.torch : FlashMode.off);
      setState(() => _torchOn = next);
    } catch (_) {
      // Some devices/emulators don't support torch — fail silently, it's a convenience control.
    }
  }

  Future<void> _doCapture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _capturing)
      return;
    setState(() => _capturing = true);
    try {
      final file = await controller.takePicture();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        WaterPageRoute(
          builder: (_) =>
              AnalyzingScreen(mode: widget.mode, imagePath: file.path),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _capturing = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(S.captureFailed('$e'))));
    }
  }

  Future<void> _pickFromGallery() async {
    if (_capturing) return;
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked == null || !mounted) return;
      setState(() => _capturing = true);
      Navigator.of(context).pushReplacement(
        WaterPageRoute(
          builder: (_) =>
              AnalyzingScreen(mode: widget.mode, imagePath: picked.path),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(S.galleryFailed('$e'))));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WaterScaffold(
      backgroundColor: AppColors.captureBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      WaterButton(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (isAnemia
                                      ? AppColors.teal
                                      : AppColors.jaundiceInk)
                                  .withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          isAnemia ? S.modeAnemia : S.modeJaundice,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (_hasMultipleCameras)
                        WaterButton(
                          borderRadius: BorderRadius.circular(14),
                          onTap: _state == _CamState.loading
                              ? null
                              : _switchCamera,
                          child: Container(
                            width: 44,
                            height: 44,
                            margin: const EdgeInsets.only(left: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.cameraswitch_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      if (_state == _CamState.ready)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 13,
                            vertical: 8,
                          ),
                          margin: const EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                            color: AppColors.goodLightGreen.withValues(
                              alpha: 0.18,
                            ),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: const Color(
                                0xFF35C483,
                              ).withValues(alpha: 0.5),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const _PulsingDot(),
                              const SizedBox(width: 7),
                              Text(
                                S.goodLighting,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.goodLightText,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isAnemia ? S.instructionAnemia : S.instructionJaundice,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A2B31), Color(0xFF16252B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: _buildPreview(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SideAction(
                    icon: _torchOn
                        ? Icons.flash_on_rounded
                        : Icons.flash_off_rounded,
                    label: S.torch,
                    active: _torchOn,
                    onTap: _toggleTorch,
                  ),
                  WaterButton(
                    customBorder: const CircleBorder(),
                    feedback: WaterFeedback.capture,
                    onTap: _state == _CamState.ready ? _doCapture : null,
                    child: Container(
                      width: 88,
                      height: 88,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.85),
                          width: 5,
                        ),
                      ),
                      child: _capturing
                          ? const SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.white,
                              ),
                            )
                          : Container(
                              width: 66,
                              height: 66,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.captureCyan.withValues(
                                      alpha: 0.18,
                                    ),
                                    blurRadius: 0,
                                    spreadRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                  _SideAction(
                    icon: Icons.photo_library_rounded,
                    label: S.upload,
                    onTap: _pickFromGallery,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    switch (_state) {
      case _CamState.loading:
        return const Center(
          child: CircularProgressIndicator(color: AppColors.captureCyan),
        );
      case _CamState.noCamera:
        return _CamMessage(
          icon: Icons.no_photography_rounded,
          message: S.noCameraFound,
        );
      case _CamState.permissionDenied:
        return _CamMessage(
          icon: Icons.lock_outline_rounded,
          message: S.cameraPermissionNeeded,
        );
      case _CamState.error:
        return _CamMessage(
          icon: Icons.error_outline_rounded,
          message: S.cameraStartFailed(_errorMessage ?? ''),
        );
      case _CamState.ready:
        final controller = _controller!;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onScaleStart: _onZoomStart,
          onScaleUpdate: _onZoomUpdate,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: controller.value.previewSize?.height ?? 1,
                    height: controller.value.previewSize?.width ?? 1,
                    child: CameraPreview(controller),
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0, -0.1),
                      radius: 0.9,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.35),
                      ],
                    ),
                  ),
                ),
              ),
              // Deliberately NOT wrapped in Positioned.fill — this must keep
              // its own size (computed below from available space), not
              // stretch to fill.
              LayoutBuilder(
                builder: (context, constraints) {
                  if (isAnemia) {
                    final w = constraints.maxWidth * 0.68;
                    final h = w * (150 / 272);
                    return _AnemiaGuide(width: w, height: h);
                  }
                  final size =
                      (constraints.maxWidth < constraints.maxHeight
                          ? constraints.maxWidth
                          : constraints.maxHeight) *
                      0.62;
                  return _JaundiceGuide(size: size);
                },
              ),
              if (_maxZoom > _minZoom)
                Positioned(
                  left: 14,
                  bottom: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${_zoom.toStringAsFixed(1)}x',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
    }
  }
}

class _CamMessage extends StatelessWidget {
  final IconData icon;
  final String message;
  const _CamMessage({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.7), size: 40),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SideAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;
  const _SideAction({
    required this.icon,
    required this.label,
    this.active = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return WaterButton(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: SizedBox(
        width: 76,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active ? Colors.white.withValues(alpha: 0.16) : null,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.28),
                  width: 2,
                ),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(
        begin: 1.0,
        end: 0.35,
      ).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut)),
      child: const SizedBox(
        width: 8,
        height: 8,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.goodLightGreen,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _AnemiaGuide extends StatefulWidget {
  final double width;
  final double height;
  const _AnemiaGuide({required this.width, required this.height});

  @override
  State<_AnemiaGuide> createState() => _AnemiaGuideState();
}

class _AnemiaGuideState extends State<_AnemiaGuide>
    with SingleTickerProviderStateMixin {
  // "Gently pull the lower eyelid down" hint — plays 3 times (2s each) when
  // the capture screen opens, transparent overlay on the live camera feed.
  late final AnimationController _hint = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  );

  @override
  void initState() {
    super.initState();
    _playHintRepeats();
  }

  Future<void> _playHintRepeats() async {
    for (var i = 0; i < 3 && mounted; i++) {
      await _hint.forward(from: 0);
      if (i < 2 && mounted)
        await Future.delayed(const Duration(milliseconds: 250));
    }
  }

  @override
  void dispose() {
    _hint.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(widget.width, widget.height),
            painter: _DashedShapePainter(
              color: AppColors.captureCyan,
              radius: Radius.elliptical(widget.width / 2, widget.height / 2),
            ),
          ),
          ..._corners(AppColors.captureCyan),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0C1A1F).withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              S.innerEyelid,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ),
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _hint,
              builder: (context, _) => CustomPaint(
                size: Size(widget.width, widget.height),
                painter: _EyePullHintPainter(progress: _hint.value),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Illustrates the capture technique once, transparently, for 2s: a simple
/// eye sits in the guide; a finger drags the lower lid down, revealing the
/// pink inner-eyelid strip underneath — exactly what "gently pull the lower
/// eyelid down and fill the guide" means, shown rather than just said.
class _EyePullHintPainter extends CustomPainter {
  final double progress; // 0..1 over the 2s animation
  const _EyePullHintPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    double opacity;
    if (progress < 0.12) {
      opacity = progress / 0.12;
    } else if (progress > 0.82) {
      opacity = (1 - progress) / 0.18;
    } else {
      opacity = 1.0;
    }
    opacity = opacity.clamp(0.0, 1.0);
    if (opacity <= 0) return;

    // Lid motion reaches "fully pulled" partway through, then holds open
    // for a beat so the end state actually registers before fading out.
    final motionT = Curves.easeInOut.transform(
      (progress / 0.6).clamp(0.0, 1.0),
    );

    canvas.saveLayer(
      Offset.zero & size,
      Paint()..color = Color.fromRGBO(0, 0, 0, opacity),
    );

    final cx = size.width / 2;
    final cy = size.height / 2;
    final eyeR = size.height * 0.32;
    final eyeRect = Rect.fromCircle(center: Offset(cx, cy), radius: eyeR);

    // Pink conjunctiva strip, revealed below the eyeball as the lid pulls
    // away — grows into view with motionT, drawn UNDER the lid flap.
    final pinkH = eyeR * 0.55 * motionT;
    if (pinkH > 0.5) {
      final pinkRect = Rect.fromLTWH(
        cx - eyeR * 0.92,
        cy + eyeR * 0.55,
        eyeR * 1.84,
        pinkH,
      );
      final pinkPath = Path()
        ..addRRect(
          RRect.fromRectAndCorners(
            pinkRect,
            bottomLeft: Radius.circular(pinkH),
            bottomRight: Radius.circular(pinkH),
          ),
        );
      canvas.drawPath(pinkPath, Paint()..color = const Color(0xFFC97A72));
    }

    // Eyeball, clipped so lids can cleanly cover/uncover it.
    canvas.save();
    canvas.clipPath(Path()..addOval(eyeRect));
    canvas.drawOval(eyeRect, Paint()..color = const Color(0xFFF3EDE7));
    canvas.drawCircle(
      Offset(cx, cy),
      eyeR * 0.46,
      Paint()..color = const Color(0xFF5B4636),
    );
    canvas.drawCircle(
      Offset(cx, cy),
      eyeR * 0.2,
      Paint()..color = const Color(0xFF1A1310),
    );
    canvas.drawCircle(
      Offset(cx - eyeR * 0.12, cy - eyeR * 0.14),
      eyeR * 0.06,
      Paint()..color = Colors.white70,
    );
    // Static upper lid.
    canvas.drawRect(
      Rect.fromLTWH(cx - eyeR, cy - eyeR, eyeR * 2, eyeR * 0.62),
      Paint()..color = const Color(0xFFB98860),
    );
    // Animated lower lid — starts covering the bottom half (t=0, "closed"),
    // slides down and off the eyeball as motionT -> 1.
    final lidTop = cy + (motionT * eyeR * 1.9) - eyeR * 0.05;
    canvas.drawRect(
      Rect.fromLTWH(cx - eyeR, lidTop, eyeR * 2, eyeR * 2),
      Paint()..color = const Color(0xFFB98860),
    );
    canvas.restore();

    canvas.drawOval(
      eyeRect,
      Paint()
        ..color = const Color(0xFF2A2019).withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Fingertip pressing the lid's leading edge, dragging it down together.
    final fingerY = lidTop.clamp(cy - eyeR * 0.1, cy + eyeR * 2.4);
    final fingerPath = Path()
      ..moveTo(cx - eyeR * 0.16, fingerY + eyeR * 0.9)
      ..quadraticBezierTo(cx - eyeR * 0.2, fingerY, cx, fingerY - eyeR * 0.08)
      ..quadraticBezierTo(
        cx + eyeR * 0.2,
        fingerY,
        cx + eyeR * 0.16,
        fingerY + eyeR * 0.9,
      )
      ..close();
    canvas.drawPath(fingerPath, Paint()..color = const Color(0xFFD9A17E));
    canvas.drawPath(
      fingerPath,
      Paint()
        ..color = const Color(0xFF9C6E4A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _EyePullHintPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _JaundiceGuide extends StatelessWidget {
  final double size;
  const _JaundiceGuide({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _DashedShapePainter(
              color: AppColors.captureAmber,
              radius: const Radius.circular(28),
            ),
          ),
          Container(
            width: size * 0.3,
            height: size * 0.3,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.captureAmber.withValues(alpha: 0.85),
                width: 3,
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF0C1A1F).withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                S.skinPatch,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dashed rounded-rect/ellipse outline matching the design spec's CSS
/// `border: 3px dashed` guide shapes (elliptical for the eyelid oval,
/// square-rounded for the skin patch), with a faint tint fill.
class _DashedShapePainter extends CustomPainter {
  final Color color;
  final Radius radius;
  const _DashedShapePainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(1.5);
    final rrect = RRect.fromRectAndRadius(rect, radius);

    canvas.drawRRect(rrect, Paint()..color = color.withValues(alpha: 0.07));

    final dashPath = Path();
    const dashWidth = 8.0, dashGap = 6.0;
    for (final metric in (Path()..addRRect(rrect)).computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        dashPath.addPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          Offset.zero,
        );
        distance = next + dashGap;
      }
    }
    canvas.drawPath(
      dashPath,
      Paint()
        ..color = color.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant _DashedShapePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

List<Widget> _corners(Color color) {
  const size = 26.0;
  const thickness = 4.0;
  Widget corner({
    required double? left,
    required double? top,
    required double? right,
    required double? bottom,
    required BorderRadius radius,
    required Border border,
  }) {
    return Positioned(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(border: border, borderRadius: radius),
      ),
    );
  }

  return [
    corner(
      left: -10,
      top: -10,
      right: null,
      bottom: null,
      radius: const BorderRadius.only(topLeft: Radius.circular(8)),
      border: Border(
        left: BorderSide(color: color, width: thickness),
        top: BorderSide(color: color, width: thickness),
      ),
    ),
    corner(
      left: null,
      top: -10,
      right: -10,
      bottom: null,
      radius: const BorderRadius.only(topRight: Radius.circular(8)),
      border: Border(
        right: BorderSide(color: color, width: thickness),
        top: BorderSide(color: color, width: thickness),
      ),
    ),
    corner(
      left: -10,
      top: null,
      right: null,
      bottom: -10,
      radius: const BorderRadius.only(bottomLeft: Radius.circular(8)),
      border: Border(
        left: BorderSide(color: color, width: thickness),
        bottom: BorderSide(color: color, width: thickness),
      ),
    ),
    corner(
      left: null,
      top: null,
      right: -10,
      bottom: -10,
      radius: const BorderRadius.only(bottomRight: Radius.circular(8)),
      border: Border(
        right: BorderSide(color: color, width: thickness),
        bottom: BorderSide(color: color, width: thickness),
      ),
    ),
  ];
}
