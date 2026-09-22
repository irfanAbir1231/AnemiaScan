import 'package:flutter/foundation.dart';

/// Global app language switch — replaces the old "show English + Bangla
/// stacked under every label" approach with a single active language and
/// a toggle (see Home screen header). `AnemiaScanApp` in main.dart rebuilds
/// the whole tree whenever this changes, so every `S.xxx` string getter and
/// the theme's font family re-evaluate against the new language.
enum AppLanguage { en, bn }

class AppLocale {
  AppLocale._();

  static final ValueNotifier<AppLanguage> language = ValueNotifier(
    AppLanguage.en,
  );

  static bool get isBn => language.value == AppLanguage.bn;

  static void toggle() {
    language.value = isBn ? AppLanguage.en : AppLanguage.bn;
  }
}
