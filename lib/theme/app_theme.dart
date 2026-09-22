import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_language.dart';

/// Design tokens lifted straight from the Claude Design handoff
/// (AnemiaScreen.dc.html "Foundations" section). Keep this file as the
/// single source of truth for color/type/spacing so screens never hardcode
/// hex values inline.
class AppColors {
  AppColors._();

  // Primary
  static const teal = Color(0xFF0E7B86);
  static const tealDark = Color(0xFF0A5B64);
  static const tealTint = Color(0xFFDCEFF0);

  // Canvas / surfaces
  static const canvas = Color(0xFFDCECED);
  static const sand = Color(0xFFFBF6EE);
  static const sandEdge = Color(0xFFEFE4D4);
  static const sandInk = Color(0xFF8A6A3C);
  static const sandInkDark = Color(0xFF7C6647);
  static const ink = Color(0xFF12262E);
  static const white = Color(0xFFFFFFFF);
  static const cardEdge = Color(0xFFE6EEEE);
  static const cardEdgeSoft = Color(0xFFE2EBEB);
  static const headerBg = Color(0xFFD0E7E8);
  static const headerEdge = Color(0xFFA9CED1);
  static const chipEdge = Color(0xFFDCE7E8);
  static const secondaryBtnEdge = Color(0xFFCFE0E2);

  // Text
  static const meta = Color(0xFF5C7681);
  static const metaSoft = Color(0xFF587681);
  static const body = Color(0xFF3D5A64);
  static const navInactive = Color(0xFF587681);
  static const navActive = Color(0xFF0A5B64);
  static const navActiveBg = Color(0xFFE7F2F3);

  // Capture screen (dark)
  static const captureBg = Color(0xFF0C1A1F);
  static const captureCyan = Color(0xFF5DE2DE);
  static const captureAmber = Color(0xFFFFC76E);
  static const goodLightGreen = Color(0xFF35C483);
  static const goodLightText = Color(0xFF8FE9BF);

  // Risk levels
  static const riskLowColor = Color(0xFF1B8A5A);
  static const riskLowInk = Color(0xFF146B46);
  static const riskLowTint = Color(0xFFE4F3EB);
  static const riskLowEdge = Color(0xFFCCE7D8);

  static const riskModerateColor = Color(0xFFB4741A);
  static const riskModerateInk = Color(0xFF8A5710);
  static const riskModerateTint = Color(0xFFFBF0DC);
  static const riskModerateEdge = Color(0xFFEFDCBB);

  static const riskHighColor = Color(0xFFC0483A);
  static const riskHighInk = Color(0xFF96342A);
  static const riskHighTint = Color(0xFFFAE7E3);
  static const riskHighEdge = Color(0xFFEFD0C9);

  // Jaundice mode accent (skin/bilirubin)
  static const jaundiceTint = Color(0xFFFBF0DC);
  static const jaundiceInk = Color(0xFFB4741A);
}

/// Spacing scale from the design doc: 4 / 8 / 12 / 16 / 22 / 26.
class AppSpace {
  AppSpace._();
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 22.0;
  static const xxl = 26.0;
}

class AppText {
  AppText._();

  /// Figtree for English, Hind Siliguri for Bangla — picks the right face
  /// for whichever language is currently active (see AppLocale).
  static TextStyle _font({
    required double size,
    FontWeight weight = FontWeight.w400,
    required Color color,
    double? height,
    double? letterSpacing,
  }) {
    return AppLocale.isBn
        ? GoogleFonts.hindSiliguri(
            fontSize: size,
            fontWeight: weight,
            color: color,
            height: height,
          )
        : GoogleFonts.figtree(
            fontSize: size,
            fontWeight: weight,
            color: color,
            height: height,
            letterSpacing: letterSpacing,
          );
  }

  static TextStyle get headline => _font(
    size: 24,
    height: 1.32,
    weight: FontWeight.w600,
    letterSpacing: -0.3,
    color: AppColors.ink,
  );

  static TextStyle get cardTitle => _font(
    size: 19,
    weight: FontWeight.w700,
    letterSpacing: -0.2,
    color: AppColors.ink,
  );

  static TextStyle get body =>
      _font(size: 15, height: 1.55, color: AppColors.body);

  static TextStyle get meta =>
      _font(size: 13, weight: FontWeight.w600, color: AppColors.meta);

  static TextStyle get mono =>
      GoogleFonts.ibmPlexMono(fontSize: 11, color: AppColors.metaSoft);
}

/// Bundled risk-level styling + copy, mirroring the `RISK`/`COPY` maps in
/// AnemiaScreen.dc.html verbatim.
enum RiskLevel { low, moderate, high }

enum ScreenMode { anemia, jaundice }

class RiskStyle {
  final String label;
  final String labelBn;
  final Color color;
  final Color ink;
  final Color tint;
  final Color edge;
  const RiskStyle(
    this.label,
    this.labelBn,
    this.color,
    this.ink,
    this.tint,
    this.edge,
  );

  /// Label in whichever language is currently active.
  String get activeLabel => AppLocale.isBn ? labelBn : label;
}

const Map<RiskLevel, RiskStyle> kRiskStyles = {
  RiskLevel.low: RiskStyle(
    'Low risk',
    'ঝুঁকি কম',
    AppColors.riskLowColor,
    AppColors.riskLowInk,
    AppColors.riskLowTint,
    AppColors.riskLowEdge,
  ),
  RiskLevel.moderate: RiskStyle(
    'Moderate risk',
    'মধ্যম ঝুঁকি',
    AppColors.riskModerateColor,
    AppColors.riskModerateInk,
    AppColors.riskModerateTint,
    AppColors.riskModerateEdge,
  ),
  RiskLevel.high: RiskStyle(
    'High risk',
    'ঝুঁকি বেশি',
    AppColors.riskHighColor,
    AppColors.riskHighInk,
    AppColors.riskHighTint,
    AppColors.riskHighEdge,
  ),
};

class RiskCopy {
  final String explain;
  final String explainBn;
  final String action;
  final String actionBn;
  final String estLabel;
  final String estLabelBn;
  final String estValue;
  const RiskCopy(
    this.explain,
    this.explainBn,
    this.action,
    this.actionBn,
    this.estLabel,
    this.estLabelBn,
    this.estValue,
  );

  String get activeExplain => AppLocale.isBn ? explainBn : explain;
  String get activeAction => AppLocale.isBn ? actionBn : action;
  String get activeEstLabel => AppLocale.isBn ? estLabelBn : estLabel;
}

const Map<ScreenMode, Map<RiskLevel, RiskCopy>> kCopy = {
  ScreenMode.anemia: {
    RiskLevel.low: RiskCopy(
      'The measured eyelid colour signal is on the redder side. A photo cannot rule out anemia.',
      'চোখের পাতার মাপা রঙের সংকেত তুলনামূলকভাবে লাল। ছবি দিয়ে রক্তস্বল্পতা নিশ্চিতভাবে বাদ দেওয়া যায় না।',
      'Get a blood test if symptoms continue',
      'উপসর্গ থাকলে রক্ত পরীক্ষা করুন',
      'Haemoglobin',
      'হিমোগ্লোবিন',
      'Not measured',
    ),
    RiskLevel.moderate: RiskCopy(
      'The eyelid colour signal is near the screening threshold. Lighting and camera colour can affect this result.',
      'ভেতরের চোখের পাতা স্বাভাবিকের চেয়ে ফ্যাকাশে। এটি মৃদু থেকে মাঝারি রক্তস্বল্পতার লক্ষণ হতে পারে, প্রায়ই আয়রনের ঘাটতির কারণে।',
      'Visit a clinic within 3 days',
      '৩ দিনের মধ্যে ক্লিনিকে যান',
      'Haemoglobin',
      'হিমোগ্লোবিন',
      'Not measured',
    ),
    RiskLevel.high: RiskCopy(
      'The accepted eyelid region produced a pale colour signal. Confirm it with a haemoglobin blood test soon.',
      'ভেতরের চোখের পাতা খুব ফ্যাকাশে। এটি প্রায়ই গুরুতর রক্তস্বল্পতা নির্দেশ করে, যার জন্য দ্রুত রক্ত পরীক্ষা প্রয়োজন।',
      'Consult a doctor within 24 hours',
      '২৪ ঘণ্টার মধ্যে ডাক্তার দেখান',
      'Haemoglobin',
      'হিমোগ্লোবিন',
      'Not measured',
    ),
  },
  ScreenMode.jaundice: {
    RiskLevel.low: RiskCopy(
      'The accepted skin region produced a lower yellow-colour signal. A photo cannot rule out jaundice.',
      'শিশুর বয়স অনুযায়ী ত্বকের রঙ স্বাভাবিক দেখাচ্ছে। এই ছবিতে কোনো হলুদভাব সনাক্ত হয়নি।',
      'Screen again in 2 days',
      '২ দিন পর আবার পরীক্ষা করুন',
      'Bilirubin',
      'বিলিরুবিন',
      'Not measured',
    ),
    RiskLevel.moderate: RiskCopy(
      'The skin colour signal is near the screening threshold. Lighting and skin tone can affect this result.',
      'ত্বকে মৃদু হলুদভাব সনাক্ত হয়েছে। এই মাত্রার নবজাতক জন্ডিস সাধারণ, তবে সতর্কভাবে লক্ষ্য রাখা উচিত।',
      'Visit a clinic within 24 hours',
      '২৪ ঘণ্টার মধ্যে ক্লিনিকে যান',
      'Bilirubin',
      'বিলিরুবিন',
      'Not measured',
    ),
    RiskLevel.high: RiskCopy(
      'The accepted skin region produced a strong yellow-colour signal. Bilirubin should be checked promptly.',
      'ত্বকে তীব্র হলুদভাব সনাক্ত হয়েছে। চিকিৎসা ছাড়া নবজাতকের উচ্চ বিলিরুবিন বিপজ্জনক হতে পারে।',
      'Go to a hospital now',
      'এখনই হাসপাতালে যান',
      'Bilirubin',
      'বিলিরুবিন',
      'Not measured',
    ),
  },
};

ThemeData buildAppTheme() {
  final fontFamily = AppLocale.isBn
      ? GoogleFonts.hindSiliguri().fontFamily
      : GoogleFonts.figtree().fontFamily;
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.canvas,
    fontFamily: fontFamily,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.teal,
      primary: AppColors.teal,
      surface: AppColors.canvas,
    ),
    textTheme: AppLocale.isBn
        ? GoogleFonts.hindSiliguriTextTheme()
        : GoogleFonts.figtreeTextTheme(),
  );
}
