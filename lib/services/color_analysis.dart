import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:image/image.dart' as img;

import '../theme/app_theme.dart';

enum ImageQualityIssue {
  tooDark,
  tooBright,
  tooFlat,
  noEyeStructure,
  noSkin,
  strongColorCast,
}

class ImageQualityException implements Exception {
  const ImageQualityException(this.issue);
  final ImageQualityIssue issue;
}

class ColorAnalysisResult {
  const ColorAnalysisResult({
    required this.risk,
    required this.signal,
    required this.confidence,
  });

  final RiskLevel risk;
  final double signal;

  /// Confidence in capture quality and separation from a colour threshold.
  /// This is deliberately not a disease probability.
  final double confidence;
}

/// Small offline colour-screening pipeline with anatomy and quality gating.
/// Rejected images never receive a risk label. Accepted anemia images use the
/// red end of the palpebral-conjunctiva distribution; accepted jaundice images
/// use a trimmed b* average from skin-coloured pixels. Both signals are CIE Lab
/// (D65), cannot measure haemoglobin or bilirubin, and require confirmation.
class ColorAnalysis {
  ColorAnalysis._();

  static const double _anemiaLowMin = 35;
  static const double _anemiaModerateMin = 19;
  static const double _jaundiceModerateMin = 21.5;
  static const double _jaundiceHighMin = 32;

  static Future<ColorAnalysisResult> analyze(
    File file,
    ScreenMode mode, {
    bool preparedReference = false,
  }) async {
    final decoded = await _decode(await file.readAsBytes());
    if (decoded == null) {
      throw const FormatException('Could not decode captured image');
    }

    final metrics = _measure(_cropGuideRegion(decoded, mode), mode);
    final quality = mode == ScreenMode.anemia
        ? _validateAnemia(metrics, preparedReference: preparedReference)
        : _validateJaundice(metrics);

    if (mode == ScreenMode.anemia) {
      final signal = metrics.anemiaSignal;
      final risk = signal >= _anemiaLowMin
          ? RiskLevel.low
          : signal >= _anemiaModerateMin
          ? RiskLevel.moderate
          : RiskLevel.high;
      return ColorAnalysisResult(
        risk: risk,
        signal: signal,
        confidence: _confidence(
          quality,
          _thresholdDistance(signal, _anemiaModerateMin, _anemiaLowMin),
          ceiling: .79,
        ),
      );
    }

    final signal = metrics.jaundiceSignal;
    final risk = signal >= _jaundiceHighMin
        ? RiskLevel.high
        : signal >= _jaundiceModerateMin
        ? RiskLevel.moderate
        : RiskLevel.low;
    return ColorAnalysisResult(
      risk: risk,
      signal: signal,
      confidence: _confidence(
        quality,
        _thresholdDistance(signal, _jaundiceModerateMin, _jaundiceHighMin),
        ceiling: .76,
      ),
    );
  }

  static double _validateAnemia(
    _Metrics metrics, {
    required bool preparedReference,
  }) {
    _validateExposure(metrics);
    if (preparedReference) {
      if (metrics.redFraction < .45 || metrics.anemiaSignal < 4) {
        throw const ImageQualityException(ImageQualityIssue.noEyeStructure);
      }
      return .78;
    }
    if (metrics.luminanceSd < 6 || metrics.focus < .42) {
      throw const ImageQualityException(ImageQualityIssue.tooFlat);
    }
    final eyeVisible =
        metrics.centerDarkFraction >= .008 &&
        metrics.centerDarkFraction <= .46 &&
        metrics.centerNeutralFraction >= .025 &&
        metrics.redFraction >= .18 &&
        metrics.tissueFraction >= .24;
    if (!eyeVisible) {
      throw const ImageQualityException(ImageQualityIssue.noEyeStructure);
    }
    return _mean([
      _rangeScore(metrics.luminanceMean, 22, 52, 88),
      (metrics.luminanceSd / 16).clamp(0, 1),
      (metrics.centerDarkFraction / .05).clamp(0, 1),
      (metrics.centerNeutralFraction / .10).clamp(0, 1),
      (metrics.focus / 1.2).clamp(0, 1),
    ]);
  }

  static double _validateJaundice(_Metrics metrics) {
    _validateExposure(metrics);
    if (metrics.focus < .34) {
      throw const ImageQualityException(ImageQualityIssue.tooFlat);
    }
    if (metrics.tissueFraction < .58 || metrics.neutralFraction > .62) {
      throw const ImageQualityException(ImageQualityIssue.noSkin);
    }
    if (metrics.jaundiceSignal <= 0 || metrics.meanA < -2) {
      throw const ImageQualityException(ImageQualityIssue.strongColorCast);
    }
    return _mean([
      _rangeScore(metrics.luminanceMean, 22, 58, 88),
      (metrics.tissueFraction / .90).clamp(0, 1),
      (1 - metrics.neutralFraction / .62).clamp(0, 1),
      (metrics.focus / 1.1).clamp(0, 1),
    ]);
  }

  static void _validateExposure(_Metrics metrics) {
    if (metrics.luminanceMean < 22 || metrics.darkFraction > .56) {
      throw const ImageQualityException(ImageQualityIssue.tooDark);
    }
    if (metrics.luminanceMean > 90) {
      throw const ImageQualityException(ImageQualityIssue.tooBright);
    }
  }

  static double _confidence(
    double quality,
    double distance, {
    required double ceiling,
  }) {
    final value = .38 + quality * .28 + distance * .18;
    return value.clamp(.42, ceiling);
  }

  static double _thresholdDistance(double value, double first, double second) {
    final nearest = math.min((value - first).abs(), (value - second).abs());
    return (nearest / 12).clamp(0, 1);
  }

  static double _rangeScore(
    double value,
    double low,
    double ideal,
    double high,
  ) {
    if (value <= low || value >= high) return 0;
    if (value == ideal) return 1;
    return value < ideal
        ? (value - low) / (ideal - low)
        : (high - value) / (high - ideal);
  }

  static double _mean(List<double> values) =>
      values.reduce((a, b) => a + b) / values.length;

  static Future<img.Image?> _decode(Uint8List bytes) async {
    try {
      final decoded = img.decodeImage(bytes);
      if (decoded != null) return img.bakeOrientation(decoded);
    } catch (_) {
      // Fall through to the platform decoder for device-specific JPEGs.
    }
    try {
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final uiImage = frame.image;
      final byteData = await uiImage.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      if (byteData == null) return null;
      return img.Image.fromBytes(
        width: uiImage.width,
        height: uiImage.height,
        bytes: byteData.buffer,
        numChannels: 4,
        order: img.ChannelOrder.rgba,
      );
    } catch (_) {
      return null;
    }
  }

  /// Uses the same proportions as the visible camera guides.
  static img.Image _cropGuideRegion(img.Image source, ScreenMode mode) {
    final width = (source.width * (mode == ScreenMode.anemia ? .68 : .54))
        .round();
    final height = (source.height * (mode == ScreenMode.anemia ? .22 : .42))
        .round();
    return img.copyCrop(
      source,
      x: ((source.width - width) / 2).round(),
      y: ((source.height - height) / 2).round(),
      width: width,
      height: height,
    );
  }

  static _Metrics _measure(img.Image region, ScreenMode mode) {
    final luminance = <double>[];
    final anemiaValues = <double>[];
    final jaundiceValues = <double>[];
    var dark = 0, neutral = 0, tissue = 0, red = 0;
    var centerCount = 0, centerDark = 0, centerNeutral = 0;
    double sumA = 0, edgeSum = 0;
    var edgeCount = 0;
    final step = math.max(
      1,
      math.sqrt(region.width * region.height / 120000).ceil(),
    );

    for (var y = 0; y < region.height; y += step) {
      double? previousL;
      for (var x = 0; x < region.width; x += step) {
        final pixel = region.getPixel(x, y);
        final lab = _rgbToLab(
          pixel.r.toDouble(),
          pixel.g.toDouble(),
          pixel.b.toDouble(),
        );
        final l = lab.$1, a = lab.$2, b = lab.$3;
        luminance.add(l);
        sumA += a;
        if (l < 20) dark++;
        if (l > 45 && a.abs() < 12 && b.abs() < 18) neutral++;
        if (a > 10 && a > b * .45) red++;
        final isTissue = l > 18 && l < 94 && a > 1 && a < 42 && b > 0 && b < 52;
        if (isTissue) {
          tissue++;
          jaundiceValues.add(b);
        }
        final inCenter =
            x > region.width * .2 &&
            x < region.width * .8 &&
            y > region.height * .18 &&
            y < region.height * .82;
        if (inCenter) {
          centerCount++;
          if (l < 20) centerDark++;
          if (l > 45 && a.abs() < 12 && b.abs() < 18) centerNeutral++;
        }
        final inPalpebralBand =
            x > region.width * .12 &&
            x < region.width * .88 &&
            y > region.height * .30 &&
            y < region.height * .80;
        if (inPalpebralBand && l > 18 && l < 92 && a > 0 && b > -15 && b < 55) {
          anemiaValues.add(a);
        }
        if (previousL != null) {
          edgeSum += (l - previousL).abs();
          edgeCount++;
        }
        previousL = l;
      }
    }

    if (luminance.isEmpty ||
        (mode == ScreenMode.anemia && anemiaValues.isEmpty) ||
        (mode == ScreenMode.jaundice && jaundiceValues.isEmpty)) {
      throw const ImageQualityException(ImageQualityIssue.strongColorCast);
    }
    if (anemiaValues.isEmpty) anemiaValues.add(0);
    if (jaundiceValues.isEmpty) jaundiceValues.add(0);
    luminance.sort();
    anemiaValues.sort();
    final count = luminance.length;
    final meanL = luminance.reduce((a, b) => a + b) / count;
    final variance =
        luminance.fold<double>(
          0,
          (sum, value) => sum + math.pow(value - meanL, 2),
        ) /
        count;
    final anemiaStart = (anemiaValues.length * .78).floor();

    return _Metrics(
      luminanceMean: meanL,
      luminanceSd: math.sqrt(variance),
      meanA: sumA / count,
      darkFraction: dark / count,
      neutralFraction: neutral / count,
      redFraction: red / count,
      tissueFraction: tissue / count,
      centerDarkFraction: centerCount == 0 ? 0 : centerDark / centerCount,
      centerNeutralFraction: centerCount == 0 ? 0 : centerNeutral / centerCount,
      focus: edgeCount == 0 ? 0 : edgeSum / edgeCount,
      anemiaSignal: _trimmedMean(anemiaValues.sublist(anemiaStart)),
      jaundiceSignal: _trimmedMean(jaundiceValues),
    );
  }

  static double _trimmedMean(List<double> values) {
    if (values.isEmpty) return 0;
    values.sort();
    final start = (values.length * .08).floor();
    final end = (values.length * .92).ceil();
    final kept = values.sublist(start, math.max(start + 1, end));
    return kept.reduce((a, b) => a + b) / kept.length;
  }

  static (double, double, double) _rgbToLab(double r, double g, double b) {
    double linear(double value) {
      value /= 255;
      return value <= .04045
          ? value / 12.92
          : math.pow((value + .055) / 1.055, 2.4).toDouble();
    }

    final rl = linear(r), gl = linear(g), bl = linear(b);
    final x = rl * .4124 + gl * .3576 + bl * .1805;
    final y = rl * .2126 + gl * .7152 + bl * .0722;
    final z = rl * .0193 + gl * .1192 + bl * .9505;
    double f(double value) => value > .008856
        ? math.pow(value, 1 / 3).toDouble()
        : 7.787 * value + 16 / 116;
    final fx = f(x / .95047), fy = f(y), fz = f(z / 1.08883);
    return (116 * fy - 16, 500 * (fx - fy), 200 * (fy - fz));
  }
}

class _Metrics {
  const _Metrics({
    required this.luminanceMean,
    required this.luminanceSd,
    required this.meanA,
    required this.darkFraction,
    required this.neutralFraction,
    required this.redFraction,
    required this.tissueFraction,
    required this.centerDarkFraction,
    required this.centerNeutralFraction,
    required this.focus,
    required this.anemiaSignal,
    required this.jaundiceSignal,
  });

  final double luminanceMean;
  final double luminanceSd;
  final double meanA;
  final double darkFraction;
  final double neutralFraction;
  final double redFraction;
  final double tissueFraction;
  final double centerDarkFraction;
  final double centerNeutralFraction;
  final double focus;
  final double anemiaSignal;
  final double jaundiceSignal;
}
