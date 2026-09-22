import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln('Usage: dart run tool/audit_cv.dart <image-or-directory>');
    exitCode = 64;
    return;
  }
  final entity = FileSystemEntity.typeSync(args.first);
  final files = entity == FileSystemEntityType.directory
      ? Directory(args.first)
            .listSync()
            .whereType<File>()
            .where((file) => _isImage(file.path))
            .toList()
      : [File(args.first)];
  files.sort((a, b) => a.path.compareTo(b.path));
  stdout.writeln(
    'file,mode,Lmean,Lsd,Amean,A50,A75,A90,Bmean,B50,B75,B90,'
    'dark,neutral,red,skin,centerDark,centerNeutral,focus,anemiaSignal,balancedAnemia,jaundiceSignal',
  );
  for (final file in files) {
    img.Image? decoded;
    try {
      decoded = img.decodeImage(file.readAsBytesSync());
    } catch (error) {
      stderr.writeln('${file.path}: $error');
      continue;
    }
    if (decoded == null) continue;
    for (final anemia in [true, false]) {
      final metrics = _metrics(_crop(decoded, anemia));
      stdout.writeln(
        '${file.uri.pathSegments.last},'
        '${anemia ? 'anemia' : 'jaundice'},${metrics.join(',')}',
      );
    }
  }
}

bool _isImage(String path) {
  final lower = path.toLowerCase();
  return lower.endsWith('.jpg') ||
      lower.endsWith('.jpeg') ||
      lower.endsWith('.png');
}

img.Image _crop(img.Image source, bool anemia) {
  final width = (source.width * (anemia ? .68 : .54)).round();
  final height = (source.height * (anemia ? .22 : .42)).round();
  return img.copyCrop(
    source,
    x: ((source.width - width) / 2).round(),
    y: ((source.height - height) / 2).round(),
    width: width,
    height: height,
  );
}

List<String> _metrics(img.Image region) {
  final lValues = <double>[];
  final aValues = <double>[];
  final bValues = <double>[];
  var dark = 0, neutral = 0, red = 0, skin = 0;
  var centerDark = 0, centerNeutral = 0, centerCount = 0;
  final anemiaSignals = <double>[];
  final jaundiceSignals = <double>[];
  double refR = 0, refG = 0, refB = 0;
  double edgeSum = 0;
  var edgeCount = 0;
  final step = math.max(1, math.min(region.width, region.height) ~/ 220);
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
      lValues.add(l);
      aValues.add(a);
      bValues.add(b);
      if (l < 20) dark++;
      if (l > 45 && a.abs() < 12 && b.abs() < 18) neutral++;
      if (a > 10 && a > b * .45) red++;
      if (l > 18 && l < 96 && a > 1 && a < 42 && b > 0 && b < 48) skin++;
      final inCenter =
          x > region.width * .2 &&
          x < region.width * .8 &&
          y > region.height * .18 &&
          y < region.height * .82;
      if (inCenter) {
        centerCount++;
        if (l < 20) centerDark++;
        if (l > 45 && a.abs() < 12 && b.abs() < 18) {
          centerNeutral++;
          refR += pixel.r;
          refG += pixel.g;
          refB += pixel.b;
        }
      }
      if (x > region.width * .12 &&
          x < region.width * .88 &&
          y > region.height * .30 &&
          y < region.height * .80 &&
          l > 18 &&
          l < 92 &&
          a > 0 &&
          b > -15 &&
          b < 55) {
        anemiaSignals.add(a);
      }
      if (l > 18 && l < 94 && a > 1 && a < 42 && b > 0 && b < 52) {
        jaundiceSignals.add(b);
      }
      if (previousL != null) {
        edgeSum += (l - previousL).abs();
        edgeCount++;
      }
      previousL = l;
    }
  }
  lValues.sort();
  aValues.sort();
  bValues.sort();
  final n = lValues.length;
  double mean(List<double> values) => values.reduce((a, b) => a + b) / n;
  final lMean = mean(lValues);
  final lSd = math.sqrt(
    lValues.fold<double>(0, (sum, value) => sum + math.pow(value - lMean, 2)) /
        n,
  );
  String f(double value) => value.toStringAsFixed(2);
  String fraction(int value) => f(value / n);
  double p(List<double> values, double q) =>
      values[(n * q).floor().clamp(0, n - 1)];
  final balancedSignals = <double>[];
  if (centerNeutral > 0) {
    refR /= centerNeutral;
    refG /= centerNeutral;
    refB /= centerNeutral;
    final target = (refR + refG + refB) / 3;
    for (
      var y = (region.height * .30).round();
      y < region.height * .80;
      y += step
    ) {
      for (
        var x = (region.width * .12).round();
        x < region.width * .88;
        x += step
      ) {
        final pixel = region.getPixel(x, y);
        final lab = _rgbToLab(
          (pixel.r * target / refR).clamp(0, 255),
          (pixel.g * target / refG).clamp(0, 255),
          (pixel.b * target / refB).clamp(0, 255),
        );
        if (lab.$1 > 18 &&
            lab.$1 < 92 &&
            lab.$2 > 0 &&
            lab.$3 > -15 &&
            lab.$3 < 55) {
          balancedSignals.add(lab.$2);
        }
      }
    }
  }
  return [
    f(lMean),
    f(lSd),
    f(mean(aValues)),
    f(p(aValues, .5)),
    f(p(aValues, .75)),
    f(p(aValues, .9)),
    f(mean(bValues)),
    f(p(bValues, .5)),
    f(p(bValues, .75)),
    f(p(bValues, .9)),
    fraction(dark),
    fraction(neutral),
    fraction(red),
    fraction(skin),
    f(centerCount == 0 ? 0 : centerDark / centerCount),
    f(centerCount == 0 ? 0 : centerNeutral / centerCount),
    f(edgeCount == 0 ? 0 : edgeSum / edgeCount),
    f(_trimmedMean(anemiaSignals)),
    f(_trimmedMean(balancedSignals)),
    f(_trimmedMean(jaundiceSignals)),
  ];
}

double _trimmedMean(List<double> values) {
  if (values.isEmpty) return 0;
  values.sort();
  final start = (values.length * .1).floor();
  final end = (values.length * .9).ceil();
  final kept = values.sublist(start, math.max(start + 1, end));
  return kept.reduce((a, b) => a + b) / kept.length;
}

(double, double, double) _rgbToLab(double r, double g, double b) {
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
