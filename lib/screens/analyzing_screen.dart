import '../water_ui/water_ui.dart';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import '../data/history_repository.dart';
import '../l10n/strings.dart';
import '../models/screening_result.dart';
import '../services/color_analysis.dart';
import '../theme/app_theme.dart';
import 'result_screen.dart';

class AnalyzingScreen extends StatefulWidget {
  final ScreenMode mode;
  final String imagePath;
  final bool preparedReference;
  const AnalyzingScreen({
    super.key,
    required this.mode,
    required this.imagePath,
    this.preparedReference = false,
  });

  @override
  State<AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends State<AnalyzingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1150),
  )..repeat();
  late final AnimationController _bar = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();

  String _step = 'quality'; // quality -> color -> risk -> done
  String? _error;

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    try {
      // Small staged delays so the three-step checklist reads clearly —
      // the actual analysis work happens in ColorAnalysis.analyze below.
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      setState(() => _step = 'color');

      final file = File(widget.imagePath);
      final analysis = await ColorAnalysis.analyze(
        file,
        widget.mode,
        preparedReference: widget.preparedReference,
      );

      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      setState(() => _step = 'risk');

      final result = ScreeningResult(
        id: '${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(1 << 32)}',
        mode: widget.mode,
        risk: analysis.risk,
        screenedAt: DateTime.now(),
        imagePath: widget.imagePath,
        signalValue: analysis.signal,
        confidence: analysis.confidence,
      );
      await HistoryRepository.instance.add(result);

      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        WaterPageRoute(
          builder: (_) => ResultScreen(
            mode: widget.mode,
            risk: analysis.risk,
            confidence: analysis.confidence,
            signal: analysis.signal,
            isFresh: true,
          ),
        ),
      );
    } on ImageQualityException catch (e) {
      if (!mounted) return;
      setState(() => _error = _qualityMessage(e.issue));
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '$e');
    }
  }

  String _qualityMessage(ImageQualityIssue issue) => switch (issue) {
    ImageQualityIssue.tooDark => S.photoTooDark,
    ImageQualityIssue.tooBright => S.photoTooBright,
    ImageQualityIssue.tooFlat => S.photoNotClear,
    ImageQualityIssue.noEyeStructure => S.eyeNotDetected,
    ImageQualityIssue.noSkin => S.skinNotDetected,
    ImageQualityIssue.strongColorCast => S.strongColorCast,
  };

  @override
  void dispose() {
    _spin.dispose();
    _bar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WaterScaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 26, 22, 24),
          child: Column(
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.cardEdge),
                      ),
                      child: Image.file(
                        File(widget.imagePath),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.capturedImage,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                      Text(
                        S.onDeviceAnalysis,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: AppColors.metaSoft,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Expanded(
                child: _error != null
                    ? _ErrorBody(message: _error!)
                    : _buildProgress(),
              ),
              WaterButton(
                onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
                child: SizedBox(
                  height: 52,
                  child: Center(
                    child: Text(
                      S.cancel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.meta,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgress() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 150,
          height: 150,
          child: Stack(
            alignment: Alignment.center,
            children: [
              RotationTransition(
                turns: _spin,
                child: Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.tealTint, width: 4),
                  ),
                  child: CustomPaint(painter: _SpinnerCapPainter()),
                ),
              ),
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF102D37).withValues(alpha: 0.1),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.remove_red_eye_rounded,
                  color: AppColors.teal,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),
        Text(
          S.analyzingImage,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            S.runsOnPhone,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.meta,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 26),
        SizedBox(
          width: 300,
          child: Column(
            children: [
              _stepRow(S.stepQuality, done: _step != 'quality'),
              const SizedBox(height: 12),
              _stepRow(
                S.stepColor,
                done: _step == 'risk',
                active: _step == 'color',
              ),
              const SizedBox(height: 12),
              _stepRow(S.stepRisk, done: false, active: _step == 'risk'),
            ],
          ),
        ),
        const SizedBox(height: 26),
        SizedBox(
          width: 300,
          height: 6,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Container(
              color: AppColors.cardEdgeSoft,
              child: AnimatedBuilder(
                animation: _bar,
                builder: (context, _) {
                  return Align(
                    alignment: Alignment(-1 + _bar.value * 3.6, 0),
                    child: FractionallySizedBox(
                      widthFactor: 0.4,
                      child: Container(color: AppColors.teal, height: 6),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _stepRow(String label, {required bool done, bool active = false}) {
    if (done) return _StepDone(label: label);
    if (active) return _StepActive(label: label);
    return _StepPending(label: label);
  }
}

class _ErrorBody extends StatelessWidget {
  final String message;
  const _ErrorBody({required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.error_outline_rounded,
          color: AppColors.riskHighColor,
          size: 40,
        ),
        const SizedBox(height: 14),
        Text(
          S.analysisFailedTitle,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppColors.meta),
          ),
        ),
      ],
    );
  }
}

class _SpinnerCapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.teal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final rect = Offset.zero & size;
    canvas.drawArc(rect.deflate(2), -1.57, 1.4, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StepDone extends StatelessWidget {
  final String label;
  const _StepDone({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: const BoxDecoration(
            color: Color(0xFF1B8A5A),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2E4F59),
          ),
        ),
      ],
    );
  }
}

class _StepActive extends StatelessWidget {
  final String label;
  const _StepActive({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 26,
          height: 26,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: const AlwaysStoppedAnimation(AppColors.teal),
            backgroundColor: AppColors.tealTint,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.tealDark,
          ),
        ),
      ],
    );
  }
}

class _StepPending extends StatelessWidget {
  final String label;
  const _StepPending({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFC6D6D9), width: 2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.navInactive,
          ),
        ),
      ],
    );
  }
}
