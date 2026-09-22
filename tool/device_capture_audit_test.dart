import 'dart:io';

import 'package:anemiascan/services/color_analysis.dart';
import 'package:anemiascan/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('report recent device captures through production analysis', () async {
    final directory = Directory('design-output/audit-captures');
    final files = directory.listSync().whereType<File>().toList()
      ..sort((a, b) => a.path.compareTo(b.path));
    for (final file in files) {
      for (final mode in ScreenMode.values) {
        try {
          final result = await ColorAnalysis.analyze(file, mode);
          // Audit output is intentionally human-readable and stays out of the app.
          // ignore: avoid_print
          print(
            '${file.uri.pathSegments.last},${mode.name},accepted,'
            '${result.risk.name},${result.signal.toStringAsFixed(2)},'
            '${(result.confidence * 100).round()}%',
          );
        } on ImageQualityException catch (error) {
          // ignore: avoid_print
          print(
            '${file.uri.pathSegments.last},${mode.name},rejected,'
            '${error.issue.name}',
          );
        }
      }
    }
  });
}
