import '../water_ui/water_ui.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import '../data/history_repository.dart';
import '../l10n/strings.dart';
import '../models/screening_result.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';
import 'result_screen.dart';

enum _Filter { all, anemia, jaundice }

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  _Filter _filter = _Filter.all;

  List<ScreeningResult> _apply(List<ScreeningResult> all) {
    switch (_filter) {
      case _Filter.anemia:
        return all.where((e) => e.mode == ScreenMode.anemia).toList();
      case _Filter.jaundice:
        return all.where((e) => e.mode == ScreenMode.jaundice).toList();
      case _Filter.all:
        return all;
    }
  }

  void _goHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      WaterPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WaterScaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: HistoryRepository.instance.listenable(),
          builder: (context, _, __) {
            final visible = _apply(HistoryRepository.instance.all());
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleIconButton(
                            icon: Icons.arrow_back_rounded,
                            onTap: () => Navigator.of(context).pop(),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                S.historyTitle,
                                style: const TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              Text(
                                S.historySubtitle,
                                style: AppText.meta.copyWith(fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _FilterChip(
                            label: S.filterAll,
                            selected: _filter == _Filter.all,
                            onTap: () => setState(() => _filter = _Filter.all),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: S.modeAnemia,
                            selected: _filter == _Filter.anemia,
                            onTap: () =>
                                setState(() => _filter = _Filter.anemia),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: S.modeJaundice,
                            selected: _filter == _Filter.jaundice,
                            onTap: () =>
                                setState(() => _filter = _Filter.jaundice),
                          ),
                        ],
                      ),
                      if (HistoryRepository.instance.all().isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _SummaryStrip(all: HistoryRepository.instance.all()),
                      ],
                    ],
                  ),
                ),
                Expanded(
                  child: visible.isEmpty
                      ? const _EmptyState()
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                S.recent,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                  color: AppColors.metaSoft,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            for (final e in visible) ...[
                              _HistoryRow(
                                result: e,
                                onTap: () {
                                  Navigator.of(context).push(
                                    WaterPageRoute(
                                      builder: (_) => ResultScreen(
                                        mode: e.mode,
                                        risk: e.risk,
                                        savedResult: e,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 10),
                            ],
                          ],
                        ),
                ),
                AppBottomNav(
                  active: NavTab.history,
                  onHome: () => _goHome(context),
                  onHistory: () {},
                  onHelp: () => Navigator.of(context).push(
                    WaterPageRoute(builder: (_) => const OnboardingScreen()),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Lightweight summary — total count + a Low/Moderate/High breakdown.
/// New addition on top of the original design (see CODEX_REDESIGN_PROMPT.md
/// "Optional addition to consider" for History) — kept small and quiet so
/// it doesn't compete with the list itself.
class _SummaryStrip extends StatelessWidget {
  final List<ScreeningResult> all;
  const _SummaryStrip({required this.all});

  @override
  Widget build(BuildContext context) {
    final low = all.where((e) => e.risk == RiskLevel.low).length;
    final moderate = all.where((e) => e.risk == RiskLevel.moderate).length;
    final high = all.where((e) => e.risk == RiskLevel.high).length;

    return WaterCard(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardEdge),
        ),
        child: Row(
          children: [
            Icon(Icons.bar_chart_rounded, size: 16, color: AppColors.metaSoft),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${all.length} ${S.screeningsCountLabel}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.meta,
                ),
              ),
            ),
            _countChip(low, kRiskStyles[RiskLevel.low]!),
            const SizedBox(width: 8),
            _countChip(moderate, kRiskStyles[RiskLevel.moderate]!),
            const SizedBox(width: 8),
            _countChip(high, kRiskStyles[RiskLevel.high]!),
          ],
        ),
      ),
    );
  }

  Widget _countChip(int count, RiskStyle style) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: style.color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: style.ink,
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.tealTint,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.list_alt_rounded,
                color: AppColors.teal,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              S.noScreeningsYet,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              S.noScreeningsSub,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.meta,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return WaterCard(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 40),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.teal : AppColors.white,
          borderRadius: BorderRadius.circular(999),
          border: selected ? null : Border.all(color: AppColors.chipEdge),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            color: selected ? Colors.white : AppColors.meta,
          ),
        ),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final ScreeningResult result;
  final VoidCallback onTap;
  const _HistoryRow({required this.result, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final style = kRiskStyles[result.risk]!;
    final isJaundice = result.mode == ScreenMode.jaundice;
    final title = S.screeningTitle(isJaundice);
    final time = TimeOfDay.fromDateTime(result.screenedAt).format(context);

    return WaterCard(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 76),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.cardEdge),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF102D37).withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCE8EA),
                  border: Border.all(color: AppColors.cardEdge),
                ),
                child: _thumb(),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: isJaundice
                              ? AppColors.jaundiceTint
                              : AppColors.tealTint,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          isJaundice
                              ? Icons.child_care_rounded
                              : Icons.remove_red_eye_rounded,
                          size: 12,
                          color: isJaundice
                              ? AppColors.jaundiceInk
                              : AppColors.teal,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    time,
                    style: const TextStyle(fontSize: 13, color: AppColors.meta),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: style.tint,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                _shortRiskLabel(result.risk),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: style.ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _thumb() {
    final file = File(result.imagePath);
    if (!file.existsSync()) {
      return const Icon(Icons.image_rounded, color: AppColors.metaSoft);
    }
    return Image.file(file, fit: BoxFit.cover);
  }

  String _shortRiskLabel(RiskLevel risk) {
    switch (risk) {
      case RiskLevel.low:
        return S.low;
      case RiskLevel.moderate:
        return S.moderate;
      case RiskLevel.high:
        return S.high;
    }
  }
}
