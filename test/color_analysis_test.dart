import 'dart:io';

import 'package:anemiascan/services/color_analysis.dart';
import 'package:anemiascan/screens/result_screen.dart';
import 'package:anemiascan/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'prepared clinical anemia references retain their three tiers',
    () async {
      final cases = {
        'assets/samples/anemia_low.jpg': RiskLevel.low,
        'assets/samples/anemia_moderate.jpg': RiskLevel.moderate,
        'assets/samples/anemia_high.jpg': RiskLevel.high,
      };
      for (final entry in cases.entries) {
        final result = await ColorAnalysis.analyze(
          File(entry.key),
          ScreenMode.anemia,
          preparedReference: true,
        );
        expect(result.risk, entry.value, reason: entry.key);
        expect(result.confidence, inInclusiveRange(.42, .79));
      }
    },
  );

  test('jaundice references retain low, moderate and high tiers', () async {
    final cases = {
      'assets/samples/jaundice_low.jpg': RiskLevel.low,
      'assets/samples/jaundice_moderate.jpg': RiskLevel.moderate,
      'assets/samples/jaundice_high.jpg': RiskLevel.high,
    };
    for (final entry in cases.entries) {
      final result = await ColorAnalysis.analyze(
        File(entry.key),
        ScreenMode.jaundice,
      );
      expect(result.risk, entry.value, reason: entry.key);
      expect(result.confidence, inInclusiveRange(.42, .76));
    }
  });

  test('skin photo is rejected when an eye is required', () async {
    expect(
      () => ColorAnalysis.analyze(
        File('assets/samples/jaundice_low.jpg'),
        ScreenMode.anemia,
      ),
      throwsA(
        isA<ImageQualityException>().having(
          (error) => error.issue,
          'issue',
          ImageQualityIssue.noEyeStructure,
        ),
      ),
    );
  });

  test('conjunctiva-only crop is rejected when skin is required', () async {
    expect(
      () => ColorAnalysis.analyze(
        File('assets/samples/anemia_low.jpg'),
        ScreenMode.jaundice,
      ),
      throwsA(isA<ImageQualityException>()),
    );
  });

  testWidgets('result shows confidence and measured colour signal', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ResultScreen(
          mode: ScreenMode.anemia,
          risk: RiskLevel.moderate,
          confidence: .71,
          signal: 24.2,
        ),
      ),
    );
    expect(find.text('Analysis confidence'), findsOneWidget);
    expect(find.text('71%'), findsOneWidget);
    expect(find.text('Red colour signal (Lab a*)'), findsOneWidget);
    expect(find.text('24.2'), findsOneWidget);
    expect(find.textContaining('g/dL'), findsNothing);
  });
}
