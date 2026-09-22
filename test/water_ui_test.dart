import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:anemiascan/water_ui/water_ui.dart';

List<WaterRipple> waves(WidgetTester tester) => tester
    .widgetList<CustomPaint>(find.byType(CustomPaint))
    .map((w) => w.foregroundPainter)
    .whereType<WaterRipple>()
    .toList();
Widget host(Widget child, {bool reduced = false}) => MaterialApp(
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: reduced),
    child: Scaffold(body: Center(child: child)),
  ),
);
void main() {
  testWidgets('Card origin follows corner touches; releases and disposes', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      host(
        WaterCard(
          onTap: () => taps++,
          child: const SizedBox(width: 220, height: 120),
        ),
      ),
    );
    final topLeft = tester.getTopLeft(find.byType(WaterCard));
    for (final offset in [const Offset(8, 9), const Offset(205, 108)]) {
      final gesture = await tester.startGesture(topLeft + offset);
      await tester.pump(const Duration(milliseconds: 160));
      await tester.pump(const Duration(milliseconds: 100));
      expect(waves(tester).single.origin, offset);
      expect(waves(tester).single.progress, greaterThan(0));
      expect(waves(tester).single.clipped, isFalse);
      await gesture.up();
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pump(const Duration(milliseconds: 1000));
      expect(waves(tester).single.progress, 1);
    }
    expect(taps, 2);
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });
  testWidgets('Navbar touch stays in its own item even during a hold', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        WaterSurface(
          child: Center(
            child: Row(
              children: [
                WaterNavItem(
                  onTap: () {},
                  child: const SizedBox(width: 90, height: 60),
                ),
                WaterNavItem(
                  onTap: () {},
                  child: const SizedBox(width: 90, height: 60),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(WaterNavItem).first),
    );
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump(const Duration(milliseconds: 100));
    final active = waves(
      tester,
    ).where((w) => w.progress > 0 && w.progress < 1).toList();
    expect(active, hasLength(1));
    expect(active.single.clipped, isTrue);
    await gesture.up();
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('Reduced motion preserves activation without wave animation', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      host(
        WaterButton(onTap: () => taps++, child: const Text('Go')),
        reduced: true,
      ),
    );
    await tester.tap(find.text('Go'));
    await tester.pump();
    expect(taps, 1);
    expect(waves(tester).single.progress, 0);
  });
  testWidgets('Tap action waits for the pressed response to finish', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      host(WaterButton(onTap: () => taps++, child: const Text('Continue'))),
    );

    await tester.tap(find.text('Continue'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(taps, 0);

    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump();
    expect(taps, 1);
  });
  testWidgets('Water page route uses the slower settling transition', (
    tester,
  ) async {
    final route = WaterPageRoute<void>(builder: (_) => const SizedBox());

    expect(route.transitionDuration, const Duration(milliseconds: 300));
    expect(route.reverseTransitionDuration, const Duration(milliseconds: 240));
  });
  testWidgets('Dragging a card scrolls without activating', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      host(
        SizedBox(
          height: 240,
          child: ListView(
            children: [
              WaterCard(
                onTap: () => taps++,
                child: const SizedBox(height: 160),
              ),
              const SizedBox(height: 800),
            ],
          ),
        ),
      ),
    );
    await tester.drag(find.byType(WaterCard), const Offset(0, -120));
    await tester.pump(const Duration(milliseconds: 1200));
    expect(taps, 0);
    expect(tester.takeException(), isNull);
  });
}
