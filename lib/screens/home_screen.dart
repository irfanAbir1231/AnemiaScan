import '../water_ui/water_ui.dart';
import 'package:flutter/material.dart';
import '../data/history_repository.dart';
import '../l10n/app_language.dart';
import '../l10n/strings.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav.dart';
import 'capture_screen.dart';
import 'history_screen.dart';
import 'onboarding_screen.dart';
import 'samples_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _startScreening(BuildContext context, ScreenMode mode) {
    Navigator.of(
      context,
    ).push(WaterPageRoute(builder: (_) => CaptureScreen(mode: mode)));
  }

  void _goHistory(BuildContext context) {
    Navigator.of(
      context,
    ).push(WaterPageRoute(builder: (_) => const HistoryScreen()));
  }

  void _showGuide(BuildContext context) {
    Navigator.of(
      context,
    ).push(WaterPageRoute(builder: (_) => const OnboardingScreen()));
  }

  @override
  Widget build(BuildContext context) {
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
                    Container(
                      decoration: BoxDecoration(color: AppColors.headerBg),
                      padding: const EdgeInsets.fromLTRB(22, 26, 22, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: AppColors.white.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: AppColors.headerEdge,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.teal.withValues(
                                        alpha: 0.18,
                                      ),
                                      blurRadius: 14,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Image.asset(
                                    'assets/anemiascan-logo-mark.png',
                                    fit: BoxFit.contain,
                                    semanticLabel: 'AnemiaScan logo',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      S.appName,
                                      style: const TextStyle(
                                        fontSize: 21,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.2,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                    Text(
                                      S.tagline,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.meta,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const _LanguageToggle(),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Container(
                              height: 1,
                              decoration: BoxDecoration(
                                color: AppColors.headerEdge,
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.white.withValues(
                                      alpha: 0.55,
                                    ),
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: AppColors.cardEdge),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const _Dot(color: Color(0xFF1B8A5A)),
                                const SizedBox(width: 6),
                                Text(
                                  S.offline,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.meta,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 22),
                          Text(S.homeHeadline, style: AppText.headline),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Column(
                        children: [
                          _ScreeningCard(
                            icon: Icons.remove_red_eye_rounded,
                            iconBg: AppColors.tealTint,
                            iconColor: AppColors.teal,
                            title: S.screenAnemiaTitle,
                            subtitle: S.screenAnemiaDesc,
                            onTap: () =>
                                _startScreening(context, ScreenMode.anemia),
                          ),
                          const SizedBox(height: 14),
                          _ScreeningCard(
                            icon: Icons.child_care_rounded,
                            iconBg: AppColors.jaundiceTint,
                            iconColor: AppColors.jaundiceInk,
                            title: S.screenJaundiceTitle,
                            subtitle: S.screenJaundiceDesc,
                            onTap: () =>
                                _startScreening(context, ScreenMode.jaundice),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
                      child: WaterButton(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => _goHistory(context),
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 64),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.sand,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.sandEdge),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.sandEdge),
                                ),
                                child: const Icon(
                                  Icons.list_alt_rounded,
                                  size: 20,
                                  color: AppColors.sandInk,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      S.pastScreenings,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                    ValueListenableBuilder(
                                      valueListenable: HistoryRepository
                                          .instance
                                          .listenable(),
                                      builder: (context, _, __) => Text(
                                        S.savedOnPhone(
                                          HistoryRepository.instance
                                              .all()
                                              .length,
                                        ),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.sandInkDark,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                size: 20,
                                color: AppColors.sandInk,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
                      child: WaterButton(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => Navigator.of(context).push(
                          WaterPageRoute(builder: (_) => const SamplesScreen()),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.science_outlined,
                                size: 16,
                                color: AppColors.metaSoft,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  S.trySamples,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.metaSoft,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 6, 22, 6),
                      child: Text(
                        S.homeDisclaimer,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.5,
                          color: AppColors.metaSoft,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AppBottomNav(
              active: NavTab.home,
              onHome: () {},
              onHistory: () => _goHistory(context),
              onHelp: () => _showGuide(context),
            ),
          ],
        ),
      ),
    );
  }
}

/// Top-right EN / বাংলা switch — the single control that changes the whole
/// app's language (see lib/l10n/app_language.dart). Replaces the old
/// approach of stacking both languages under every label.
class _LanguageToggle extends StatelessWidget {
  const _LanguageToggle();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: AppLocale.language,
      builder: (context, lang, __) {
        return Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.cardEdge),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _segment('EN', lang == AppLanguage.en, () {
                if (lang != AppLanguage.en) AppLocale.toggle();
              }),
              _segment('বাং', lang == AppLanguage.bn, () {
                if (lang != AppLanguage.bn) AppLocale.toggle();
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _segment(String label, bool active, VoidCallback onTap) {
    return WaterButton(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minWidth: 34, minHeight: 28),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.teal : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: active ? Colors.white : AppColors.meta,
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _ScreeningCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ScreeningCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return WaterCard(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 112),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.cardEdge),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF102D37).withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: iconColor, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppText.cardTitle),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.meta,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: AppColors.canvas,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.teal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
