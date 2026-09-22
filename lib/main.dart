import 'package:flutter/material.dart';
import 'data/history_repository.dart';
import 'l10n/app_language.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'theme/app_theme.dart';
import 'water_ui/water_ui.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HistoryRepository.instance.init();
  runApp(const AnemiaScanApp());
}

class AnemiaScanApp extends StatelessWidget {
  const AnemiaScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuilds the whole tree on every language toggle, so every S.xxx
    // string getter and the theme's font family re-evaluate fresh — see
    // lib/l10n/app_language.dart.
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: AppLocale.language,
      builder: (context, _, __) {
        return MaterialApp(
          title: 'AnemiaScan',
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(),
          onGenerateRoute: (settings) {
            if (settings.name == '/home') {
              return WaterPageRoute<void>(
                settings: settings,
                builder: (_) => const HomeScreen(),
              );
            }
            return null;
          },
          home: HistoryRepository.instance.hasSeenOnboarding
              ? const HomeScreen()
              : const OnboardingScreen(),
        );
      },
    );
  }
}
