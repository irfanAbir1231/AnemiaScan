import '../water_ui/water_ui.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../models/screening_result.dart';
import '../theme/app_theme.dart';
import 'capture_screen.dart';

/// Shared layout for both the fresh "just screened" result and a reopened
/// history entry — mirrors `isResult`/`isFresh`/`isDetail` in the design.
class ResultScreen extends StatelessWidget {
  final ScreenMode mode;
  final RiskLevel risk;
  final bool isFresh;
  final ScreeningResult? savedResult;
  final double? confidence;
  final double? signal;

  const ResultScreen({
    super.key,
    required this.mode,
    required this.risk,
    this.isFresh = false,
    this.savedResult,
    this.confidence,
    this.signal,
  });

  bool get isDetail => savedResult != null;

  @override
  Widget build(BuildContext context) {
    final style = kRiskStyles[risk]!;
    final copy = kCopy[mode]![risk]!;
    final title = S.screeningTitle(mode == ScreenMode.jaundice);
    final meta = isDetail
        ? _formatDateTime(savedResult!.screenedAt)
        : S.justNowSaved;
    final confidenceValue = savedResult?.confidence ?? confidence ?? 0;
    final signalValue = savedResult?.signalValue ?? signal;

    return WaterScaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          WaterButton(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.cardEdge),
                              ),
                              child: const Icon(
                                Icons.arrow_back_rounded,
                                size: 20,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                Text(
                                  meta,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.meta,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          WaterCard(
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                22,
                                20,
                                22,
                              ),
                              decoration: BoxDecoration(
                                color: style.tint,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: style.edge),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: style.color,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.circle,
                                          color: Colors.white,
                                          size: 10,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              style.activeLabel,
                                              style: TextStyle(
                                                fontSize: 26,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: -0.4,
                                                height: 1.15,
                                                color: style.ink,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  Row(
                                    children: [
                                      _seg(
                                        risk == RiskLevel.low
                                            ? style.color
                                            : Colors.white,
                                      ),
                                      const SizedBox(width: 6),
                                      _seg(
                                        risk == RiskLevel.moderate
                                            ? style.color
                                            : Colors.white,
                                      ),
                                      const SizedBox(width: 6),
                                      _seg(
                                        risk == RiskLevel.high
                                            ? style.color
                                            : Colors.white,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        S.low,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF4E6B74),
                                        ),
                                      ),
                                      Text(
                                        S.moderate,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF4E6B74),
                                        ),
                                      ),
                                      Text(
                                        S.high,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF4E6B74),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.only(top: 12),
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                          color: Color(0x1512262E),
                                        ),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _metaRow(
                                          S.analysisConfidence,
                                          confidenceValue > 0
                                              ? '${(confidenceValue * 100).round()}%'
                                              : S.notRecorded,
                                        ),
                                        if (signalValue != null) ...[
                                          const SizedBox(height: 8),
                                          _metaRow(
                                            S.colourSignal(
                                              mode == ScreenMode.jaundice,
                                            ),
                                            signalValue.toStringAsFixed(1),
                                          ),
                                        ],
                                        const SizedBox(height: 8),
                                        Text(
                                          S.confidenceMeaning,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            height: 1.35,
                                            color: Color(0xFF4E6B74),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          _WhiteCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  S.whatThisMeans,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 7),
                                Text(copy.activeExplain, style: AppText.body),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          _WhiteCard(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: style.tint,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: style.color,
                                          width: 3,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        S.nextStep,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.8,
                                          color: AppColors.metaSoft,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        copy.activeAction,
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isDetail) ...[
                            const SizedBox(height: 14),
                            _WhiteCard(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFDCE8EA),
                                        border: Border.all(
                                          color: AppColors.cardEdge,
                                        ),
                                      ),
                                      child: _detailThumb(),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _metaRow(
                                          S.screened,
                                          _formatDateTime(
                                            savedResult!.screenedAt,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          if (isFresh) ...[
                            const SizedBox(height: 14),
                            WaterCard(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.riskLowTint,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppColors.riskLowEdge,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 22,
                                      height: 22,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF1B8A5A),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check_rounded,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      S.savedToHistory,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.riskLowInk,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 14),
                          WaterCard(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.sand,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.sandEdge),
                              ),
                              child: Text(
                                S.resultDisclaimer,
                                style: const TextStyle(
                                  fontSize: 13,
                                  height: 1.5,
                                  color: AppColors.sandInkDark,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              color: AppColors.canvas,
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              child: Column(
                children: [
                  WaterButton(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () =>
                        Navigator.of(context).popUntil((r) => r.isFirst),
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 58),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.teal,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.teal.withValues(alpha: 0.24),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Text(
                        S.done,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  WaterButton(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        WaterPageRoute(
                          builder: (_) => CaptureScreen(mode: mode),
                        ),
                      );
                    },
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 54),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.secondaryBtnEdge),
                      ),
                      child: Text(
                        S.screenAgain,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.tealDark,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _seg(Color c) => Expanded(
    child: Container(
      height: 12,
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(999),
      ),
    ),
  );

  Widget _detailThumb() {
    final result = savedResult;
    if (result == null)
      return const Icon(Icons.image_rounded, color: AppColors.metaSoft);
    final file = File(result.imagePath);
    if (!file.existsSync())
      return const Icon(Icons.image_rounded, color: AppColors.metaSoft);
    return Image.file(file, fit: BoxFit.cover);
  }

  static String _formatDateTime(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $hour12:$minute $ampm';
  }

  Widget _metaRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.meta),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}

class _WhiteCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const _WhiteCard({
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  @override
  Widget build(BuildContext context) {
    return WaterCard(
      child: Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cardEdge),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF102D37).withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
