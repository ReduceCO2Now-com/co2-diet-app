import 'package:co2diet/domain/entities/meal_entry.dart';
import 'package:co2diet/domain/entities/meal_slot.dart';
import 'package:co2diet/domain/entities/portion_unit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MealEntry', () {
    final baseEntry = MealEntry(
      id: 'entry-1',
      mealSlot: MealSlot.lunch,
      foodRef: '1234567890123',
      foodRefSource: 'off_ref',
      quantity: 150,
      unit: PortionUnit.g,
      productNameSnapshot: 'Test Product',
      brandSnapshot: 'Test Brand',
      calories100gSnapshot: 150,
      protein100gSnapshot: 10,
      carbs100gSnapshot: 20,
      fat100gSnapshot: 5,
      co2e100gSnapshot: null,
      confidenceBandSnapshot: null,
      loggedAt: DateTime.utc(2026, 7, 23, 12),
      logDate: '2026-07-23',
    );

    test(
      'copyWith replaces only specified fields; sentinel pattern '
      'preserves nullable fields',
      () {
        final updated = baseEntry.copyWith(quantity: 200);
        expect(updated.quantity, 200);
        expect(updated.brandSnapshot, 'Test Brand');
        expect(updated.calories100gSnapshot, 150);

        final cleared = baseEntry.copyWith(brandSnapshot: null);
        expect(cleared.brandSnapshot, isNull);
        expect(cleared.quantity, baseEntry.quantity);
      },
    );

    test(
      'scaled macro calculation: 150g quantity against a 100g-basis '
      'snapshot returns 1.5x values',
      () {
        final scaled = baseEntry.scaled(150);
        expect(scaled.calories, 225);
        expect(scaled.protein, 15);
        expect(scaled.carbs, 30);
        expect(scaled.fat, 7.5);
      },
    );

    test(
      'scaled macro calculation returns null fields when the snapshot '
      'field is null (no false precision)',
      () {
        final scaled = baseEntry.scaled(150);
        expect(scaled.co2e, isNull);
      },
    );

    test('equality is based on id', () {
      final other = baseEntry.copyWith(quantity: 999);
      expect(other, equals(baseEntry));

      final differentId = baseEntry.copyWith(id: 'entry-2');
      expect(differentId, isNot(equals(baseEntry)));
    });
  });
}
