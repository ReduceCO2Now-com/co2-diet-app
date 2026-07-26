// FoodResultRow display tests: verifies the honesty-in-numbers distinction
// between "no nutrition data" (—) and a genuine zero value (0 kcal/100g,
// e.g. water) — these must never render identically.

import 'package:co2diet/domain/entities/food_item.dart';
import 'package:co2diet/features/food_search/widgets/food_result_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: child));

void main() {
  group('FoodResultRow', () {
    testWidgets(
      'shows "— kcal/100g" when calories100g is null (no data)',
      (tester) async {
        const item = FoodItem(
          productName: 'Unknown Product',
          barcode: '1111111111111',
        );

        await tester.pumpWidget(
          _wrap(FoodResultRow(item: item, onTap: () {})),
        );

        expect(find.text('— kcal/100g'), findsOneWidget);
        expect(find.text('0 kcal/100g'), findsNothing);
      },
    );

    testWidgets(
      'shows "0 kcal/100g" (not the null dash) when calories100g is a '
      'genuine zero, e.g. mineral water',
      (tester) async {
        const item = FoodItem(
          productName: 'Natural Mineral Water',
          barcode: '5200116720013',
          calories100g: 0,
        );

        await tester.pumpWidget(
          _wrap(FoodResultRow(item: item, onTap: () {})),
        );

        expect(find.text('0 kcal/100g'), findsOneWidget);
        expect(find.text('— kcal/100g'), findsNothing);
      },
    );

    testWidgets(
      'shows the rounded value for a non-null, non-zero calories100g',
      (tester) async {
        const item = FoodItem(
          productName: 'Whole Milk',
          barcode: '2222222222222',
          calories100g: 64.7,
        );

        await tester.pumpWidget(
          _wrap(FoodResultRow(item: item, onTap: () {})),
        );

        expect(find.text('65 kcal/100g'), findsOneWidget);
      },
    );
  });
}
