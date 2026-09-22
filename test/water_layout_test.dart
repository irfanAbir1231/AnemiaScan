import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:anemiascan/main.dart';
import 'package:anemiascan/data/history_repository.dart';
import 'package:anemiascan/l10n/app_language.dart';

void main() {
  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('water_layout_');
    await HistoryRepository.instance.initForTest(dir.path);
    await HistoryRepository.instance.completeOnboarding();
  });
  testWidgets('Phone layout supports English and Bangla without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const AnemiaScanApp());
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull);
    AppLocale.toggle();
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull);
    AppLocale.toggle();
    await tester.pumpWidget(const SizedBox());
  });
}
