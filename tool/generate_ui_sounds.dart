import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

const _sampleRate = 44100;
const _tau = math.pi * 2;

void main() {
  final directory = Directory('assets/audio')..createSync(recursive: true);
  _writeWave('${directory.path}/water_tap.wav', .11, (time, progress, noise) {
    final frequency = 350 - 155 * progress;
    return .68 * math.sin(_tau * frequency * time) * math.exp(-31 * time) +
        .08 * noise() * math.exp(-85 * time);
  });
  _writeWave('${directory.path}/water_card.wav', .18, (time, progress, noise) {
    final body = math.sin(_tau * (118 - 34 * progress) * time);
    final sub = math.sin(_tau * 61 * time);
    return (.58 * body + .25 * sub) * math.exp(-18 * time) +
        .05 * noise() * math.exp(-46 * time);
  });
  _writeWave('${directory.path}/water_nav.wav', .13, (time, progress, noise) {
    final drop = math.sin(_tau * (610 - 275 * progress) * time);
    return .54 * drop * math.exp(-27 * time) +
        .05 * noise() * math.exp(-80 * time);
  });
  _writeWave('${directory.path}/camera_shutter.wav', .20, (
    time,
    progress,
    noise,
  ) {
    final first = time < .055 ? math.exp(-80 * time) : 0.0;
    final secondTime = time - .07;
    final second = secondTime >= 0 ? math.exp(-72 * secondTime) : 0.0;
    final mechanism = math.sin(_tau * 145 * time) * math.exp(-19 * time);
    return .48 * noise() * first + .42 * noise() * second + .24 * mechanism;
  });
}

typedef Sample =
    double Function(double time, double progress, double Function() noise);

void _writeWave(String path, double seconds, Sample makeSample) {
  final count = (_sampleRate * seconds).round();
  final bytes = ByteData(44 + count * 2);
  _ascii(bytes, 0, 'RIFF');
  bytes.setUint32(4, 36 + count * 2, Endian.little);
  _ascii(bytes, 8, 'WAVEfmt ');
  bytes.setUint32(16, 16, Endian.little);
  bytes.setUint16(20, 1, Endian.little);
  bytes.setUint16(22, 1, Endian.little);
  bytes.setUint32(24, _sampleRate, Endian.little);
  bytes.setUint32(28, _sampleRate * 2, Endian.little);
  bytes.setUint16(32, 2, Endian.little);
  bytes.setUint16(34, 16, Endian.little);
  _ascii(bytes, 36, 'data');
  bytes.setUint32(40, count * 2, Endian.little);

  var seed = 0x5eeda11;
  double noise() {
    seed = (1664525 * seed + 1013904223) & 0x7fffffff;
    return seed / 0x3fffffff - 1;
  }

  for (var i = 0; i < count; i++) {
    final time = i / _sampleRate;
    final envelope = math.sin(math.pi * (i / count)).clamp(0.0, 1.0);
    final sample = (makeSample(time, i / count, noise) * envelope).clamp(
      -1.0,
      1.0,
    );
    bytes.setInt16(44 + i * 2, (sample * 32767).round(), Endian.little);
  }
  File(path).writeAsBytesSync(bytes.buffer.asUint8List());
}

void _ascii(ByteData data, int offset, String value) {
  for (var i = 0; i < value.length; i++) {
    data.setUint8(offset + i, value.codeUnitAt(i));
  }
}
