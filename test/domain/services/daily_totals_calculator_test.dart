import 'package:co2diet/domain/entities/meal_entry.dart';
import 'package:co2diet/domain/entities/meal_slot.dart';
import 'package:co2diet/domain/entities/portion_unit.dart';
import 'package:co2diet/domain/services/daily_totals_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

MealEntry _entry({
  String id = 'e1',
  PortionUnit unit = PortionUnit.g,
  double quantity = 100,
  double? calories100g,
  double? protein100g,
  double? carbs100g,
  double? fat100g,
  double? co2e100g,
  double? sugar100g,
  double? fiber100g,
  double? salt,
}) => MealEntry(
  id: id,
  mealSlot: MealSlot.lunch,
  foodRef: 'ref-$id',
  foodRefSource: 'off_ref',
  quantity: quantity,
  unit: unit,
  productNameSnapshot: 'Test Food $id',
  loggedAt: DateTime.utc(2026, 7, 27, 12),
  logDate: '2026-07-27',
  calories100gSnapshot: calories100g,
  protein100gSnapshot: protein100g,
  carbs100gSnapshot: carbs100g,
  fat100gSnapshot: fat100g,
  co2e100gSnapshot: co2e100g,
  sugar100gSnapshot: sugar100g,
  fiber100gSnapshot: fiber100g,
  saltSnapshot: salt,
);

void main() {
  group('DailyTotalsCalculator', () {
    test(
      "sums calories/protein/carbs/fat across today's "
      'weight-based-unit entries',
      () {
        final entries = [
          _entry(
            id: 'a',
            calories100g: 200,
            protein100g: 10,
            carbs100g: 20,
            fat100g: 5,
          ),
          _entry(
            id: 'b',
            unit: PortionUnit.ml,
            quantity: 200,
            calories100g: 50,
            protein100g: 2,
            carbs100g: 8,
            fat100g: 1,
          ),
          // Non-weight-based -- must be excluded entirely.
          _entry(
            id: 'c',
            unit: PortionUnit.piece,
            quantity: 1,
            calories100g: 999,
            protein100g: 999,
            carbs100g: 999,
            fat100g: 999,
          ),
        ];

        final totals = DailyTotalsCalculator.compute(entries);

        // a: 200 kcal * 100/100 = 200. b: 50 kcal * 200/100 = 100.
        expect(totals.calories, 300);
        expect(totals.protein, 10 + 4);
        expect(totals.carbs, 20 + 16);
        expect(totals.fat, 5 + 2);
      },
    );

    test(
      'sugar/fiber/sodium totals are null when zero logged entries '
      'have that nutrient snapshot (no false precision)',
      () {
        final entries = [
          _entry(id: 'a', calories100g: 200),
          _entry(id: 'b', calories100g: 100),
        ];

        final totals = DailyTotalsCalculator.compute(entries);

        expect(totals.sugar, isNull);
        expect(totals.fiber, isNull);
        expect(totals.salt, isNull);
      },
    );

    test(
      'sugar/fiber/sodium totals sum only entries that have a '
      'non-null snapshot; entries with null snapshot are skipped, '
      'not treated as zero',
      () {
        final entries = [
          _entry(id: 'a', sugar100g: 10, fiber100g: 2, salt: 1),
          // No sugar/fiber/salt snapshot -- must not contribute a 0.
          _entry(id: 'b'),
          _entry(id: 'c', sugar100g: 5, fiber100g: 1, salt: 0.5),
        ];

        final totals = DailyTotalsCalculator.compute(entries);

        expect(totals.sugar, 15);
        expect(totals.fiber, 3);
        expect(totals.salt, 1.5);
      },
    );

    test(
      'applies the personal CO2 multiplier only to the aggregate '
      'total, never per-entry',
      () {
        final entries = [
          _entry(id: 'a', co2e100g: 100),
          _entry(id: 'b', co2e100g: 200),
        ];

        final unmultiplied = DailyTotalsCalculator.compute(entries);
        final multiplied = DailyTotalsCalculator.compute(
          entries,
          co2Multiplier: 0.9,
        );

        // Raw sum: 100 + 200 = 300.
        expect(unmultiplied.co2e, 300);
        // Multiplier applied once to the aggregate, not per entry
        // (300 * 0.9, not (100*0.9) then some other compounding).
        expect(multiplied.co2e, closeTo(270, 0.0001));
      },
    );

    test(
      'piece/cup/portion-unit entries are excluded from every '
      'numeric total (documented limitation, matches '
      'MealEntryRow/RecentRow precedent)',
      () {
        final entries = [
          _entry(
            id: 'a',
            unit: PortionUnit.piece,
            quantity: 1,
            calories100g: 500,
            co2e100g: 500,
            sugar100g: 500,
          ),
          _entry(
            id: 'b',
            unit: PortionUnit.cup,
            quantity: 1,
            calories100g: 500,
          ),
          _entry(
            id: 'c',
            unit: PortionUnit.portion,
            quantity: 1,
            calories100g: 500,
          ),
        ];

        final totals = DailyTotalsCalculator.compute(entries);

        expect(totals.calories, isNull);
        expect(totals.co2e, isNull);
        expect(totals.sugar, isNull);
        expect(totals.includedEntryCount, 0);
      },
    );

    test(
      'macro split (protein/carbs/fat) percentages sum to ~100% '
      'when all three are non-null',
      () {
        final entries = [
          _entry(
            id: 'a',
            protein100g: 25,
            carbs100g: 50,
            fat100g: 10,
          ),
        ];

        final totals = DailyTotalsCalculator.compute(entries);
        final split = totals.macroSplit;

        expect(split, isNotNull);
        expect(
          split!.proteinPct + split.carbsPct + split.fatPct,
          closeTo(100, 0.0001),
        );
        // protein 25g*4=100kcal, carbs 50g*4=200kcal, fat 10g*9=90kcal.
        // total = 390kcal.
        expect(split.proteinPct, closeTo(100 / 390 * 100, 0.0001));
        expect(split.carbsPct, closeTo(200 / 390 * 100, 0.0001));
        expect(split.fatPct, closeTo(90 / 390 * 100, 0.0001));
      },
    );

    test(
      'computing over a pooled trailing-7-day entry list yields an '
      "explicit weekly total distinct from a single day's total",
      () {
        final today = [_entry(id: 'today', calories100g: 200)];
        final week = [
          _entry(id: 'd1', calories100g: 200),
          _entry(id: 'd2', calories100g: 200),
          _entry(id: 'd3', calories100g: 200),
          _entry(id: 'd4', calories100g: 200),
          _entry(id: 'd5', calories100g: 200),
          _entry(id: 'd6', calories100g: 200),
          _entry(id: 'd7', calories100g: 200),
        ];

        final todayTotals = DailyTotalsCalculator.compute(today);
        final weekTotals = DailyTotalsCalculator.compute(week);

        expect(todayTotals.calories, 200);
        expect(weekTotals.calories, 1400);
        expect(weekTotals.calories, isNot(equals(todayTotals.calories)));
      },
    );

    test('macroSplit is null when protein/carbs/fat are all null', () {
      final entries = [_entry(id: 'a', calories100g: 200)];

      final totals = DailyTotalsCalculator.compute(entries);

      expect(totals.macroSplit, isNull);
    });

    test('empty entry list produces all-null totals', () {
      final totals = DailyTotalsCalculator.compute([]);

      expect(totals.calories, isNull);
      expect(totals.protein, isNull);
      expect(totals.carbs, isNull);
      expect(totals.fat, isNull);
      expect(totals.sugar, isNull);
      expect(totals.fiber, isNull);
      expect(totals.salt, isNull);
      expect(totals.co2e, isNull);
      expect(totals.includedEntryCount, 0);
    });
  });
}
