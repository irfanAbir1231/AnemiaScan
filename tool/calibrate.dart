// Calibration helper — NOT shipped in the app. Standalone copy of the Lab
// color-analysis math from lib/services/color_analysis.dart (that file can't
// be imported directly here: it pulls in theme/app_theme.dart -> Flutter
// material -> dart:ui, unavailable outside the Flutter runtime). Keep this
// logic in sync with the production file by hand — it's a one-off
// calibration run, not shipped code.
//
// Usage: dart run tool/calibrate.dart <path-to-calibration-folder>
import 'dart:io';
import 'dart:math' as math;
import 'package:image/image.dart' as img;

Future<void> main(List<String> args) async {
  final dir = Directory(args.isNotEmpty ? args[0] : '../calibration');
  if (!dir.existsSync()) {
    stderr.writeln('Directory not found: ${dir.path}');
    exit(1);
  }

  final files = dir
      .listSync()
      .whereType<File>()
      .where((f) => ['.jpg', '.jpeg', '.png'].any((ext) => f.path.toLowerCase().endsWith(ext)))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  print('file, mode, signal (a*=redness / b*=yellowness), L*');
  for (final file in files) {
    final name = file.uri.pathSegments.last;
    // Naming convention: "eye_*" = anemia/conjunctiva reference (a*),
    // "skin_*" = jaundice/newborn-skin reference (b*).
    final isJaundice = name.toLowerCase().startsWith('skin_');
    try {
      final bytes = await file.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) {
        print('$name, ERROR decoding (null)');
        continue;
      }
      final crop = _cropGuideRegion(decoded, isJaundice);
      final lab = _averageLab(crop);
      final signal = isJaundice ? lab.$3 : lab.$2;
      print('$name, ${isJaundice ? "jaundice" : "anemia"}, ${signal.toStringAsFixed(2)}, ${lab.$1.toStringAsFixed(1)}');
    } catch (e) {
      print('$name, ERROR, $e');
    }
  }
}

img.Image _cropGuideRegion(img.Image src, bool isJaundice) {
  final w = src.width;
  final h = src.height;
  late int cw, ch;
  if (!isJaundice) {
    cw = (w * 0.55).round();
    ch = (h * 0.28).round();
  } else {
    cw = (w * 0.45).round();
    ch = (h * 0.45).round();
  }
  final x = ((w - cw) / 2).round();
  final y = ((h - ch) / 2).round();
  return img.copyCrop(src, x: x, y: y, width: cw, height: ch);
}

(double, double, double) _averageLab(img.Image region) {
  double sumL = 0, sumA = 0, sumB = 0;
  var count = 0;
  for (final pixel in region) {
    final lab = _rgbToLab(pixel.r.toDouble(), pixel.g.toDouble(), pixel.b.toDouble());
    sumL += lab.$1;
    sumA += lab.$2;
    sumB += lab.$3;
    count++;
  }
  if (count == 0) return (0, 0, 0);
  return (sumL / count, sumA / count, sumB / count);
}

(double, double, double) _rgbToLab(double r, double g, double b) {
  double toLinear(double c) {
    c /= 255.0;
    return c <= 0.04045 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
  }

  final rl = toLinear(r), gl = toLinear(g), bl = toLinear(b);

  final x = rl * 0.4124 + gl * 0.3576 + bl * 0.1805;
  final y = rl * 0.2126 + gl * 0.7152 + bl * 0.0722;
  final z = rl * 0.0193 + gl * 0.1192 + bl * 0.9505;

  const xn = 0.95047, yn = 1.0, zn = 1.08883;
  double f(double t) => t > 0.008856 ? math.pow(t, 1 / 3).toDouble() : (7.787 * t) + (16 / 116);

  final fx = f(x / xn), fy = f(y / yn), fz = f(z / zn);

  final l = (116 * fy) - 16;
  final a = 500 * (fx - fy);
  final bStar = 200 * (fy - fz);
  return (l, a, bStar);
}
