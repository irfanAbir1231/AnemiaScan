import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

import 'package:anemiascan/data/history_repository.dart';
import 'package:anemiascan/main.dart';

void main() {
  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('anemiascan_test_');
    await HistoryRepository.instance.initForTest(dir.path);
    await HistoryRepository.instance.completeOnboarding();
  });

  testWidgets('Home screen shows the two screening cards', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AnemiaScanApp());
    await tester.pump();

    expect(find.text('AnemiaScan'), findsOneWidget);
    expect(find.text('Screen for Anemia'), findsOneWidget);
    expect(find.text('Screen for Jaundice'), findsOneWidget);
  });
}
