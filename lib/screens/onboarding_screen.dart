import 'package:flutter/material.dart';
import '../data/history_repository.dart';
import '../l10n/app_language.dart';
import '../l10n/strings.dart';
import '../theme/app_theme.dart';
import '../water_ui/water_ui.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  List<_OnboardingPage> get _pages => [
    _OnboardingPage(
      icon: Icons.health_and_safety_rounded,
      accent: AppColors.teal,
      title: S.onboardingWelcome,
      body: S.onboardingWelcomeBody,
    ),
    _OnboardingPage(
      icon: Icons.center_focus_strong_rounded,
      accent: AppColors.captureAmber,
      title: S.onboardingCapture,
      body: S.onboardingCaptureBody,
    ),
    _OnboardingPage(
      icon: Icons.insights_rounded,
      accent: AppColors.riskLowColor,
      title: S.onboardingResult,
      body: S.onboardingResultBody,
    ),
  ];

  Future<void> _finish() async {
    final save = HistoryRepository.instance.completeOnboarding();
    if (!mounted) return;
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      navigator.pushReplacementNamed('/home');
    }
    await save;
  }

  void _next() {
    if (_page == _pages.length - 1) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WaterScaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: Column(
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/anemiascan-logo-mark.png',
                    width: 52,
                    height: 52,
                    fit: BoxFit.contain,
                    semanticLabel: 'AnemiaScan logo',
                  ),
                  const SizedBox(width: 10),
                  Text(S.appName, style: AppText.cardTitle),
                  const Spacer(),
                  WaterButton(
                    onTap: AppLocale.toggle,
                    borderRadius: BorderRadius.circular(999),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 9,
                      ),
                      child: Text(
                        AppLocale.isBn ? 'EN' : 'বাংলা',
                        style: const TextStyle(
                          color: AppColors.tealDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _finish,
                  child: Text(
                    S.onboardingSkip,
                    style: const TextStyle(color: AppColors.meta),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (page) => setState(() => _page = page),
                  itemBuilder: (context, index) => _Slide(page: _pages[index]),
                ),
              ),
              Semantics(
                label: 'Page ${_page + 1} of ${_pages.length}',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: index == _page ? 28 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: index == _page
                            ? AppColors.teal
                            : AppColors.headerEdge,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: WaterButton(
                  key: const Key('onboarding-primary'),
                  onTap: _next,
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    height: 58,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.teal,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _page == _pages.length - 1
                              ? S.onboardingStart
                              : S.onboardingNext,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
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
}

class _Slide extends StatelessWidget {
  const _Slide({required this.page});
  final _OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          WaterCard(
            borderRadius: BorderRadius.circular(44),
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(44),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    page.accent.withValues(alpha: 0.13),
                    Colors.white.withValues(alpha: 0.78),
                  ],
                ),
                border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ...List.generate(
                    3,
                    (index) => Container(
                      width: 104.0 + index * 38,
                      height: 76.0 + index * 28,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: page.accent.withValues(
                            alpha: 0.16 - index * 0.035,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      color: page.accent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: page.accent.withValues(alpha: 0.28),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(page.icon, color: Colors.white, size: 43),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: AppText.headline.copyWith(fontSize: 28),
          ),
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: Text(
              page.body,
              textAlign: TextAlign.center,
              style: AppText.body.copyWith(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage {
  const _OnboardingPage({
    required this.icon,
    required this.accent,
    required this.title,
    required this.body,
  });
  final IconData icon;
  final Color accent;
  final String title;
  final String body;
}
