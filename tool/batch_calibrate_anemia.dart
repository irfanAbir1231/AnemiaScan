// Dev tool — NOT shipped. Batch-analyzes the real CP-AnemiC dataset
// (Mendeley Data, DOI 10.17632/m53vz6b7fx.1, CC BY 4.0 — 710 real clinical
// conjunctiva ROI photos, Hb-labeled Anemic/Non-anemic) through the same
// Lab a* math as the production pipeline, to get real threshold statistics.
//
// These images are pre-cropped ROI extracts (irregular strip shape on a
// white/transparent background), so unlike calibrate.dart this averages
// the WHOLE image but skips background pixels (transparent, or near-white)
// rather than doing a percentage center-crop.
//
// Usage: dart run tool/batch_calibrate_anemia.dart <path-to-cp_anemic_extracted>
import 'dart:io';
import 'dart:math' as math;
import 'package:image/image.dart' as img;

void main(List<String> args) {
  final root = Directory(args.isNotEmpty ? args[0] : '../calibration/cp_anemic_extracted');
  final anemicDir = Directory('${root.path}/Anemic');
  final nonAnemicDir = Directory('${root.path}/Non-anemic');

  final anemicResults = _analyzeDir(anemicDir);
  final nonAnemicResults = _analyzeDir(nonAnemicDir);

  _report('Anemic', anemicResults.map((r) => r.$2).toList());
  _report('Non-anemic', nonAnemicResults.map((r) => r.$2).toList());

  anemicResults.sort((a, b) => a.$2.compareTo(b.$2));
  nonAnemicResults.sort((a, b) => a.$2.compareTo(b.$2));

  print('\nMost pallid (lowest a*) Anemic examples — good "High risk" demo picks:');
  for (final r in anemicResults.take(5)) {
    print('  ${r.$1}  a*=${r.$2.toStringAsFixed(2)}');
  }
  print('\nReddest (highest a*) Non-anemic examples — good "Low risk" demo picks:');
  for (final r in nonAnemicResults.reversed.take(5)) {
    print('  ${r.$1}  a*=${r.$2.toStringAsFixed(2)}');
  }
  print('\nMid-range Anemic examples — good "Moderate risk" demo picks:');
  final mid = anemicResults.length ~/ 2;
  for (final r in anemicResults.skip(mid - 2).take(5)) {
    print('  ${r.$1}  a*=${r.$2.toStringAsFixed(2)}');
  }
}

List<(String, double)> _analyzeDir(Directory dir) {
  final vals = <(String, double)>[];
  final files = dir.listSync().whereType<File>().where((f) => f.path.toLowerCase().endsWith('.png')).toList();
  for (final file in files) {
    try {
      final decoded = img.decodeImage(file.readAsBytesSync());
      if (decoded == null) continue;
      final aStar = _averageAStarSkippingBackground(decoded);
      if (aStar != null) vals.add((file.uri.pathSegments.last, aStar));
    } catch (_) {
      // skip unreadable files
    }
  }
  return vals;
}

double? _averageAStarSkippingBackground(img.Image image) {
  double sum = 0;
  var count = 0;
  for (final pixel in image) {
    final alpha = image.numChannels >= 4 ? pixel.a.toDouble() : 255.0;
    final r = pixel.r.toDouble();
    final g = pixel.g.toDouble();
    final b = pixel.b.toDouble();
    final nearWhite = r > 240 && g > 240 && b > 240;
    if (alpha < 128 || nearWhite) continue; // background
    sum += _rgbToAStar(r, g, b);
    count++;
  }
  if (count == 0) return null;
  return sum / count;
}

double _rgbToAStar(double r, double g, double b) {
  double toLinear(double c) {
    c /= 255.0;
    return c <= 0.04045 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
  }

  final rl = toLinear(r), gl = toLinear(g), bl = toLinear(b);
  final x = rl * 0.4124 + gl * 0.3576 + bl * 0.1805;
  final y = rl * 0.2126 + gl * 0.7152 + bl * 0.0722;

  const xn = 0.95047, yn = 1.0;
  double f(double t) => t > 0.008856 ? math.pow(t, 1 / 3).toDouble() : (7.787 * t) + (16 / 116);
  final fx = f(x / xn), fy = f(y / yn);
  return 500 * (fx - fy);
}

void _report(String label, List<double> vals) {
  if (vals.isEmpty) {
    print('$label: no images analyzed');
    return;
  }
  vals.sort();
  final n = vals.length;
  final mean = vals.reduce((a, b) => a + b) / n;
  final median = vals[n ~/ 2];
  final p25 = vals[(n * 0.25).floor()];
  final p75 = vals[(n * 0.75).floor()];
  print('$label: n=$n  mean=${mean.toStringAsFixed(2)}  median=${median.toStringAsFixed(2)}  '
      'p25=${p25.toStringAsFixed(2)}  p75=${p75.toStringAsFixed(2)}  '
      'min=${vals.first.toStringAsFixed(2)}  max=${vals.last.toStringAsFixed(2)}');
}
