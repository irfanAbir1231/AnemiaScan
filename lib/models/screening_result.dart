import '../theme/app_theme.dart';

/// A saved screening, persisted locally via Hive (as a plain map — no
/// codegen/adapter needed) — no backend, per BUILD_PLAN.md. Replaces the
/// static `kSeedEntries` demo list once the user has actually screened
/// something.
class ScreeningResult {
  final String id;
  final ScreenMode mode;
  final RiskLevel risk;
  final DateTime screenedAt;
  final String imagePath;
  final double
  signalValue; // raw color-analysis score, kept for calibration/debugging
  final double confidence;

  const ScreeningResult({
    required this.id,
    required this.mode,
    required this.risk,
    required this.screenedAt,
    required this.imagePath,
    required this.signalValue,
    required this.confidence,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'mode': mode.name,
    'risk': risk.name,
    'screenedAt': screenedAt.toIso8601String(),
    'imagePath': imagePath,
    'signalValue': signalValue,
    'confidence': confidence,
  };

  factory ScreeningResult.fromMap(Map<dynamic, dynamic> map) => ScreeningResult(
    id: map['id'] as String,
    mode: ScreenMode.values.byName(map['mode'] as String),
    risk: RiskLevel.values.byName(map['risk'] as String),
    screenedAt: DateTime.parse(map['screenedAt'] as String),
    imagePath: map['imagePath'] as String,
    signalValue: (map['signalValue'] as num).toDouble(),
    confidence: (map['confidence'] as num?)?.toDouble() ?? 0,
  );
}
