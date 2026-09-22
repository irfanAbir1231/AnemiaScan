import 'dart:io';
import 'package:image/image.dart' as image;

void main(List<String> args) {
  if (args.length != 1) {
    stderr.writeln('Usage: dart run tool/generate_app_icons.dart <logo.png>');
    exitCode = 64;
    return;
  }
  final decoded = image.decodePng(File(args.single).readAsBytesSync());
  if (decoded == null) throw StateError('Could not decode logo PNG');
  final logo = _trimTransparent(decoded);
  File(
    'assets/anemiascan-logo-mark.png',
  ).writeAsBytesSync(image.encodePng(logo));

  const androidSizes = <String, int>{
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
  };
  for (final entry in androidSizes.entries) {
    _writeIcon(
      'android/app/src/main/res/${entry.key}/ic_launcher.png',
      logo,
      entry.value,
    );
  }

  final ios = <String, int>{
    'Icon-App-20x20@1x.png': 20,
    'Icon-App-20x20@2x.png': 40,
    'Icon-App-20x20@3x.png': 60,
    'Icon-App-29x29@1x.png': 29,
    'Icon-App-29x29@2x.png': 58,
    'Icon-App-29x29@3x.png': 87,
    'Icon-App-40x40@1x.png': 40,
    'Icon-App-40x40@2x.png': 80,
    'Icon-App-40x40@3x.png': 120,
    'Icon-App-60x60@2x.png': 120,
    'Icon-App-60x60@3x.png': 180,
    'Icon-App-76x76@1x.png': 76,
    'Icon-App-76x76@2x.png': 152,
    'Icon-App-83.5x83.5@2x.png': 167,
    'Icon-App-1024x1024@1x.png': 1024,
  };
  for (final entry in ios.entries) {
    _writeIcon(
      'ios/Runner/Assets.xcassets/AppIcon.appiconset/${entry.key}',
      logo,
      entry.value,
    );
  }
}

image.Image _trimTransparent(image.Image source) {
  var left = source.width;
  var top = source.height;
  var right = 0;
  var bottom = 0;
  for (final pixel in source) {
    if (pixel.a < 8) continue;
    if (pixel.x < left) left = pixel.x;
    if (pixel.y < top) top = pixel.y;
    if (pixel.x > right) right = pixel.x;
    if (pixel.y > bottom) bottom = pixel.y;
  }
  return image.copyCrop(
    source,
    x: left,
    y: top,
    width: right - left + 1,
    height: bottom - top + 1,
  );
}

void _writeIcon(String path, image.Image logo, int size) {
  final canvas = image.Image(width: size, height: size, numChannels: 4);
  image.fill(canvas, color: image.ColorRgba8(208, 231, 232, 255));
  final targetWidth = (size * 0.84).round();
  final targetHeight = (targetWidth * logo.height / logo.width).round();
  final resized = image.copyResize(
    logo,
    width: targetWidth,
    height: targetHeight,
    interpolation: image.Interpolation.cubic,
  );
  image.compositeImage(
    canvas,
    resized,
    dstX: (size - resized.width) ~/ 2,
    dstY: (size - resized.height) ~/ 2,
  );
  File(path).writeAsBytesSync(image.encodePng(canvas));
}
