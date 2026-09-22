// Dev tool — NOT shipped. Prepares a pre-extracted ROI image (irregular
// strip on white/transparent background, like the CP-AnemiC dataset) for
// use as an in-app demo sample: crops to content bounding box, then fills
// any remaining background pixels with the MEASURED MEAN COLOR of the real
// tissue pixels in that same photo — not an invented color. This matches
// what the production pipeline's "fill the guide" capture actually assumes
// (a frame filled with the target tissue), since the original irregular
// strip shape doesn't fill a rectangular crop.
//
// Note: use setPixelRgba with alpha=255 explicitly, not setPixelRgb — the
// source PNGs are RGBA with alpha=0 on background, and encodeJpg composites
// transparent pixels toward white internally even though JPEG itself has
// no alpha channel. Leaving old alpha=0 on "filled" pixels silently
// produced white output despite correct RGB values (confirmed via
// pixel-level debug print before finding this).
//
// Usage: dart run tool/prep_roi_sample.dart <input.png> <output.jpg>
import 'dart:io';
import 'package:image/image.dart' as img;

bool _isBackground(img.Pixel p, int numChannels) {
  final alpha = numChannels >= 4 ? p.a.toDouble() : 255.0;
  final nearWhite = p.r > 240 && p.g > 240 && p.b > 240;
  return alpha < 128 || nearWhite;
}

void main(List<String> args) {
  final decoded = img.decodeImage(File(args[0]).readAsBytesSync())!;

  double sumR = 0, sumG = 0, sumB = 0;
  var count = 0;
  int minX = decoded.width, minY = decoded.height, maxX = 0, maxY = 0;
  for (var y = 0; y < decoded.height; y++) {
    for (var x = 0; x < decoded.width; x++) {
      final p = decoded.getPixel(x, y);
      if (_isBackground(p, decoded.numChannels)) continue;
      sumR += p.r;
      sumG += p.g;
      sumB += p.b;
      count++;
      if (x < minX) minX = x;
      if (x > maxX) maxX = x;
      if (y < minY) minY = y;
      if (y > maxY) maxY = y;
    }
  }
  if (count == 0) {
    stderr.writeln('No foreground pixels found in ${args[0]}');
    exit(1);
  }
  final meanR = sumR / count, meanG = sumG / count, meanB = sumB / count;

  // NOTE: tried shrinking further inward to reduce background fraction, but
  // these ROI strips are crescent-shaped — content sits near the bounding
  // box's perimeter, not its center, so inward shrinking walks toward the
  // empty middle and makes things worse. Bounding-box crop + background
  // fill (below) is the right amount of preprocessing for this shape.
  const pad = 4;
  minX = (minX - pad).clamp(0, decoded.width - 1);
  minY = (minY - pad).clamp(0, decoded.height - 1);
  maxX = (maxX + pad).clamp(0, decoded.width - 1);
  maxY = (maxY + pad).clamp(0, decoded.height - 1);
  final cropped = img.copyCrop(decoded, x: minX, y: minY, width: maxX - minX, height: maxY - minY);

  for (var y = 0; y < cropped.height; y++) {
    for (var x = 0; x < cropped.width; x++) {
      final p = cropped.getPixel(x, y);
      if (_isBackground(p, cropped.numChannels)) {
        cropped.setPixelRgba(x, y, meanR.round(), meanG.round(), meanB.round(), 255);
      }
    }
  }

  File(args[1]).writeAsBytesSync(img.encodeJpg(cropped, quality: 92));
  print('${args[0]} -> ${args[1]}: fg=$count px, mean=(${meanR.toStringAsFixed(0)},'
      '${meanG.toStringAsFixed(0)},${meanB.toStringAsFixed(0)}), '
      'size ${cropped.width}x${cropped.height}');
}
