// Tests for MealEntry/Favorite -> FoodItem reverse-mapping extensions
// (Plan 04-06, LOG-11). Verifies the resolvedFoodRef round-trip guarantee:
// entry.toFoodItem().resolvedFoodRef == entry.foodRef exactly, regardless
// of whether foodRef is a real barcode, a user_food_cache id, or a
// user_foods id.

import 'package:co2diet/domain/entities/favorite.dart';
import 'package:co2diet/domain/entities/meal_entry.dart';
import 'package:co2diet/domain/entities/meal_entry_food_item_mapping.dart';
import 'package:co2diet/domain/entities/meal_slot.dart';
import 'package:co2diet/domain/entities/portion_unit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MealEntryFoodItemMapping.toFoodItem', () {
    test(
      'round-trips a non-barcode foodRef (user_foods UUID) through '
      'resolvedFoodRef exactly',
      () {
        final entry = MealEntry(
          id: 'entry-1',
          mealSlot: MealSlot.lunch,
          foodRef: '018f1e6a-1234-7000-8000-000000000001',
          foodRefSource: 'user_foods',
          quantity: 150,
          unit: PortionUnit.g,
          productNameSnapshot: 'Homemade Soup',
          loggedAt: DateTime.utc(2026, 7, 23, 12),
          logDate: '2026-07-23',
          brandSnapshot: null,
          calories100gSnapshot: 45,
          protein100gSnapshot: 2.1,
          carbs100gSnapshot: 6.0,
          fat100gSnapshot: 1.2,
          co2e100gSnapshot: 0.8,
          confidenceBandSnapshot: 'medium',
        );

        final foodItem = entry.toFoodItem();

        expect(foodItem.resolvedFoodRef, equals(entry.foodRef));
        expect(foodItem.barcode, isNull);
        expect(foodItem.sourceRowId, equals(entry.foodRef));
        expect(foodItem.source, equals(entry.foodRefSource));
        expect(foodItem.productName, equals(entry.productNameSnapshot));
        expect(foodItem.calories100g, equals(entry.calories100gSnapshot));
        expect(foodItem.protein100g, equals(entry.protein100gSnapshot));
        expect(foodItem.carbs100g, equals(entry.carbs100gSnapshot));
        expect(foodItem.fat100g, equals(entry.fat100gSnapshot));
        expect(foodItem.co2e100g, equals(entry.co2e100gSnapshot));
        expect(
          foodItem.confidenceBand,
          equals(entry.confidenceBandSnapshot),
        );
      },
    );

    test('round-trips a real barcode foodRef exactly', () {
      final entry = MealEntry(
        id: 'entry-2',
        mealSlot: MealSlot.breakfast,
        foodRef: '5000112548167',
        foodRefSource: 'off_ref',
        quantity: 1,
        unit: PortionUnit.piece,
        productNameSnapshot: 'Cereal Bar',
        loggedAt: DateTime.utc(2026, 7, 23, 8),
        logDate: '2026-07-23',
      );

      final foodItem = entry.toFoodItem();

      expect(foodItem.resolvedFoodRef, equals(entry.foodRef));
    });
  });

  group('FavoriteFoodItemMapping.toFoodItem', () {
    test(
      'round-trips a non-barcode foodRef through resolvedFoodRef exactly',
      () {
        final favorite = Favorite(
          id: 'fav-1',
          foodRef: 'cache-row-abc',
          foodRefSource: 'user_food_cache',
          productNameSnapshot: 'Oat Milk',
          favoritedAt: DateTime.utc(2026, 7, 23),
          brandSnapshot: 'Oatly',
          calories100gSnapshot: 47,
          co2e100gSnapshot: 0.4,
          confidenceBandSnapshot: 'high',
        );

        final foodItem = favorite.toFoodItem();

        expect(foodItem.resolvedFoodRef, equals(favorite.foodRef));
        expect(foodItem.barcode, isNull);
        expect(foodItem.sourceRowId, equals(favorite.foodRef));
        expect(foodItem.source, equals(favorite.foodRefSource));
        expect(foodItem.productName, equals(favorite.productNameSnapshot));
        expect(foodItem.brand, equals(favorite.brandSnapshot));
        expect(foodItem.calories100g, equals(favorite.calories100gSnapshot));
        expect(foodItem.co2e100g, equals(favorite.co2e100gSnapshot));
        expect(
          foodItem.confidenceBand,
          equals(favorite.confidenceBandSnapshot),
        );
        // Favorite has no protein/carbs/fat snapshot fields.
        expect(foodItem.protein100g, isNull);
        expect(foodItem.carbs100g, isNull);
        expect(foodItem.fat100g, isNull);
      },
    );
  });
}
