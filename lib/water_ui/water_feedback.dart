import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

enum WaterFeedback { none, button, card, navigation, capture }

/// Plays a short semantic sound and matching system haptic. Failures are
/// intentionally silent so interaction is never blocked by device settings.
class WaterFeedbackController {
  WaterFeedbackController._();

  static final Map<WaterFeedback, AudioPlayer> _players = {};

  static void play(WaterFeedback feedback) {
    if (feedback == WaterFeedback.none) return;
    unawaited(_playSafely(feedback));
  }

  static Future<void> _playSafely(WaterFeedback feedback) async {
    try {
      switch (feedback) {
        case WaterFeedback.button:
          await HapticFeedback.lightImpact();
          break;
        case WaterFeedback.card:
          await HapticFeedback.mediumImpact();
          break;
        case WaterFeedback.navigation:
          await HapticFeedback.selectionClick();
          break;
        case WaterFeedback.capture:
          await HapticFeedback.heavyImpact();
          break;
        case WaterFeedback.none:
          return;
      }

      final player = _players.putIfAbsent(
        feedback,
        () => AudioPlayer(playerId: 'water-${feedback.name}'),
      );
      await player.stop();
      await player.play(
        AssetSource(_assetFor(feedback)),
        mode: PlayerMode.lowLatency,
        volume: _volumeFor(feedback),
      );
    } catch (_) {
      // Audio and haptics are enhancements; the action must still complete.
    }
  }

  static String _assetFor(WaterFeedback feedback) => switch (feedback) {
    WaterFeedback.button => 'audio/water_tap.wav',
    WaterFeedback.card => 'audio/water_card.wav',
    WaterFeedback.navigation => 'audio/water_nav.wav',
    WaterFeedback.capture => 'audio/camera_shutter.wav',
    WaterFeedback.none => '',
  };

  static double _volumeFor(WaterFeedback feedback) => switch (feedback) {
    WaterFeedback.button => .38,
    WaterFeedback.card => .48,
    WaterFeedback.navigation => .34,
    WaterFeedback.capture => .62,
    WaterFeedback.none => 0,
  };
}
