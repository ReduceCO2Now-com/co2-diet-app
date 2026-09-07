// TargetDisplayCard must not throw during layout because a value was wider
// than expected.
//
// Found on-device 2026-09-07: `A RenderFlex overflowed by 5.6 pixels on the
// right` at target_display_card.dart:66, showing as the overflow banner across
// the Calories card. The provoking value was a bogus 10000 kcal caused by a
// separate units bug (fixed in bd159bc), but the card is reachable with a wide
// value legitimately — the manual override dialog accepts any number typed.
//
// Cards live in a GridView.extent(maxCrossAxisExtent: 160), so 160 logical
// pixels is the real production constraint, not an arbitrary one.

import 'package:co2diet/features/profile/widgets/target_display_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps a card under the same width constraint the production grid applies.
Future<void> _pumpCard(
  WidgetTester tester, {
  required double? value,
  String unit = 'kcal',
  bool isOverridden = false,
  double textScale = 1.0,
  double width = 160,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: MediaQuery.withClampedTextScaling(
        minScaleFactor: textScale,
        maxScaleFactor: textScale,
        child: Scaffold(
          body: Center(
            child: SizedBox(
              width: width,
              height: width / 1.1, // childAspectRatio from the production grid
              child: TargetDisplayCard(
                label: 'Calories',
                unit: unit,
                value: value,
                isOverridden: isOverridden,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('TargetDisplayCard does not overflow', () {
    testWidgets('with a realistic value', (tester) async {
      await _pumpCard(tester, value: 1800);
      expect(tester.takeException(), isNull);
    });

    testWidgets('with the five-digit value that broke it on device',
        (tester) async {
      await _pumpCard(tester, value: 10000);
      expect(tester.takeException(), isNull);
    });

    testWidgets('with an extreme value reachable via the override dialog',
        (tester) async {
      // The dialog parses whatever the user types; nothing caps the digits.
      await _pumpCard(tester, value: 99999);
      expect(tester.takeException(), isNull);
    });

    testWidgets('with a wide value AND the override pencil icon',
        (tester) async {
      // The icon plus its gap eats ~18px of the same Row.
      await _pumpCard(tester, value: 99999, isOverridden: true);
      expect(tester.takeException(), isNull);
    });

    testWidgets('at 1.6x text scale (ACC-02 ceiling)', (tester) async {
      await _pumpCard(tester, value: 10000, textScale: 1.6);
      expect(tester.takeException(), isNull);
    });

    testWidgets('at 1.6x text scale with icon and extreme value',
        (tester) async {
      await _pumpCard(
        tester,
        value: 99999,
        isOverridden: true,
        textScale: 1.6,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders the dash without overflow when value is null',
        (tester) async {
      await _pumpCard(tester, value: null, textScale: 1.6);
      expect(tester.takeException(), isNull);
    });
  });

  group('TargetDisplayCard still shows its value', () {
    testWidgets('the full number is present, not truncated', (tester) async {
      await _pumpCard(tester, value: 99999);

      // Scaling down is acceptable; dropping digits is not. A truncated
      // calorie target reads as a different, plausible number.
      expect(find.text('99999 kcal'), findsOneWidget);
    });
  });
}
