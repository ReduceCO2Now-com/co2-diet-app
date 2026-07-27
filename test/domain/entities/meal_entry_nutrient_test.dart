import 'package:co2diet/domain/entities/meal_entry.dart';
import 'package:co2diet/domain/entities/meal_slot.dart';
import 'package:co2diet/domain/entities/portion_unit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MealEntry nutrient snapshot', () {
    final baseEntry = MealEntry(
      id: 'entry-1',
      mealSlot: MealSlot.lunch,
      foodRef: 'user-food-1',
      foodRefSource: 'user_foods',
      quantity: 150,
      unit: PortionUnit.g,
      productNameSnapshot: 'Test Product',
      calories100gSnapshot: 150,
      protein100gSnapshot: 10,
      carbs100gSnapshot: 20,
      fat100gSnapshot: 5,
      sugar100gSnapshot: 8,
      fiber100gSnapshot: 2,
      saltSnapshot: 1.2,
      loggedAt: DateTime.utc(2026, 7, 23, 12),
      logDate: '2026-07-23',
    );

    test(
      'scaled() returns sugar/fiber/salt scaled the same way as '
      'calories/protein/carbs/fat',
      () {
        final scaled = baseEntry.scaled(150);
        expect(scaled.calories, 225);
        expect(scaled.sugar, 12);
        expect(scaled.fiber, 3);
        expect(scaled.salt, 1.8);
      },
    );

    test(
      'scaled() returns null sugar/fiber/salt when the source '
      'snapshot is null (off_ref-sourced entries have no such data)',
      () {
        final offRefEntry = baseEntry.copyWith(
          foodRef: '1234567890123',
          foodRefSource: 'off_ref',
          sugar100gSnapshot: null,
          fiber100gSnapshot: null,
          saltSnapshot: null,
        );
        final scaled = offRefEntry.scaled(150);
        expect(scaled.sugar, isNull);
        expect(scaled.fiber, isNull);
        expect(scaled.salt, isNull);
      },
    );

    test(
      'copyWith sentinel pattern covers the three new nullable '
      'fields',
      () {
        final updated = baseEntry.copyWith(quantity: 200);
        expect(updated.quantity, 200);
        expect(updated.sugar100gSnapshot, 8);
        expect(updated.fiber100gSnapshot, 2);
        expect(updated.saltSnapshot, 1.2);

        final cleared = baseEntry.copyWith(
          sugar100gSnapshot: null,
          fiber100gSnapshot: null,
          saltSnapshot: null,
        );
        expect(cleared.sugar100gSnapshot, isNull);
        expect(cleared.fiber100gSnapshot, isNull);
        expect(cleared.saltSnapshot, isNull);
        expect(cleared.quantity, baseEntry.quantity);
      },
    );
  });
}
