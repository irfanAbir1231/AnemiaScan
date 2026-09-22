import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:anemiascan/data/history_repository.dart';
import 'package:anemiascan/main.dart';
import 'package:anemiascan/water_ui/water_ui.dart';

void main() {
  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('onboarding_test_');
    await HistoryRepository.instance.initForTest(dir.path);
  });

  testWidgets('onboarding explains all steps and is remembered', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const AnemiaScanApp());
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Simple screening, clear next steps'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.fling(find.byType(PageView), const Offset(-350, 0), 1000);
    await tester.pump(const Duration(milliseconds: 650));
    expect(find.text('Capture the right area'), findsOneWidget);

    await tester.fling(find.byType(PageView), const Offset(-350, 0), 1000);
    await tester.pump(const Duration(milliseconds: 650));
    expect(find.text('Understand and act'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);

    tester
        .widget<WaterButton>(find.byKey(const Key('onboarding-primary')))
        .onTap!();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Screen for Anemia'), findsOneWidget);
    expect(HistoryRepository.instance.hasSeenOnboarding, isTrue);
    expect(tester.takeException(), isNull);
  });
}
