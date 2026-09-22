import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/screening_result.dart';

/// Local-only persistence for screening history. One Hive box, keyed by
/// screening id, values stored as plain maps (see ScreeningResult.toMap).
class HistoryRepository {
  HistoryRepository._();
  static final HistoryRepository instance = HistoryRepository._();

  static const _boxName = 'screening_history';
  static const _settingsBoxName = 'app_settings';
  static const _onboardingKey = 'onboarding_complete';
  Box? _box;
  Box? _settingsBox;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);
  }

  /// Test-only entry point: skips the platform-channel-backed `initFlutter`
  /// (unavailable in plain widget tests) in favor of a plain filesystem path.
  Future<void> initForTest(String path) async {
    Hive.init(path);
    _box = await Hive.openBox(_boxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);
  }

  Box get _b {
    final box = _box;
    if (box == null) {
      throw StateError('HistoryRepository.init() must be awaited before use');
    }
    return box;
  }

  Box get _settings {
    final box = _settingsBox;
    if (box == null) {
      throw StateError('HistoryRepository.init() must be awaited before use');
    }
    return box;
  }

  bool get hasSeenOnboarding =>
      _settings.get(_onboardingKey, defaultValue: false) as bool;

  Future<void> completeOnboarding() => _settings.put(_onboardingKey, true);

  Future<void> add(ScreeningResult result) => _b.put(result.id, result.toMap());

  /// Notifies listeners on every add/remove — wire screens to this via
  /// ValueListenableBuilder so Home's count and History's list stay live
  /// without any manual refresh plumbing.
  ValueListenable<Box> listenable() => _b.listenable();

  List<ScreeningResult> all() {
    return _b.values.cast<Map>().map(ScreeningResult.fromMap).toList()
      ..sort((a, b) => b.screenedAt.compareTo(a.screenedAt));
  }
}
