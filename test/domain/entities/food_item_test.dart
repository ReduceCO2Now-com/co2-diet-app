// TDD RED — Task 1 (02-03)
// Tests for FoodItem domain entity.
// These tests fail until FoodItem is created in lib/domain/entities/food_item.dart.

import 'package:co2diet/domain/entities/food_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FoodItem', () {
    test('stores productName and returns it correctly', () {
      const item = FoodItem(
        barcode: '7612345678901',
        productName: 'Banana',
      );
      expect(item.productName, equals('Banana'));
    });

    test('accepts null productNameEn (nullable field)', () {
      const item = FoodItem(
        barcode: '7612345678901',
        productName: 'Banana',
        // productNameEn not provided — should be null
      );
      expect(item.productNameEn, isNull);
    });

    test('copyWith updates productName and preserves other fields', () {
      const item = FoodItem(
        barcode: '7612345678901',
        productName: 'Banana',
        brand: 'Chiquita',
        calories100g: 89.0,
      );
      final updated = item.copyWith(productName: 'Apple');
      expect(updated.productName, equals('Apple'));
      expect(updated.barcode, equals('7612345678901'));
      expect(updated.brand, equals('Chiquita'));
      expect(updated.calories100g, equals(89.0));
    });

    test('copyWith with null barcode returns item with null barcode', () {
      const item = FoodItem(
        barcode: '123',
        productName: 'Test',
      );
      final updated = item.copyWith(barcode: null);
      expect(updated.barcode, isNull);
    });

    test('equality is based on barcode and productName', () {
      const item1 = FoodItem(
        barcode: '7612345678901',
        productName: 'Banana',
        brand: 'Brand A',
      );
      const item2 = FoodItem(
        barcode: '7612345678901',
        productName: 'Banana',
        brand: 'Brand B', // Different brand — should still be equal
      );
      expect(item1, equals(item2));
    });

    test('items with different barcode are not equal', () {
      const item1 = FoodItem(
        barcode: '111',
        productName: 'Banana',
      );
      const item2 = FoodItem(
        barcode: '222',
        productName: 'Banana',
      );
      expect(item1, isNot(equals(item2)));
    });

    test('items with different productName are not equal', () {
      const item1 = FoodItem(
        barcode: '111',
        productName: 'Banana',
      );
      const item2 = FoodItem(
        barcode: '111',
        productName: 'Apple',
      );
      expect(item1, isNot(equals(item2)));
    });

    test('all macro fields are nullable', () {
      const item = FoodItem(productName: 'Test');
      expect(item.barcode, isNull);
      expect(item.productNameEn, isNull);
      expect(item.brand, isNull);
      expect(item.calories100g, isNull);
      expect(item.protein100g, isNull);
      expect(item.carbs100g, isNull);
      expect(item.fat100g, isNull);
    });

    // --- CO₂ fields (Plan 03-02) ---

    test('stores co2e100g and confidenceBand when provided', () {
      const item = FoodItem(
        productName: 'Test',
        co2e100g: 2.3,
        confidenceBand: 'high',
      );
      expect(item.co2e100g, equals(2.3));
      expect(item.confidenceBand, equals('high'));
    });

    test('co2e100g and confidenceBand are null by default', () {
      const item = FoodItem(productName: 'Test');
      expect(item.co2e100g, isNull);
      expect(item.confidenceBand, isNull);
    });

    test('copyWith(co2e100g: null) explicitly sets field to null (sentinel)', () {
      const item = FoodItem(
        productName: 'Test',
        co2e100g: 5.0,
        confidenceBand: 'medium',
      );
      final updated = item.copyWith(co2e100g: null);
      expect(updated.co2e100g, isNull);
      // confidenceBand should be preserved (not touched)
      expect(updated.confidenceBand, equals('medium'));
    });

    test('copyWith(confidenceBand: "medium") replaces while other fields preserved', () {
      const item = FoodItem(
        barcode: '1234567890123',
        productName: 'Beef',
        co2e100g: 27.0,
        confidenceBand: 'high',
      );
      final updated = item.copyWith(confidenceBand: 'medium');
      expect(updated.confidenceBand, equals('medium'));
      expect(updated.co2e100g, equals(27.0));
      expect(updated.barcode, equals('1234567890123'));
      expect(updated.productName, equals('Beef'));
    });

    test('copyWith without co2e100g preserves existing value', () {
      const item = FoodItem(
        productName: 'Test',
        co2e100g: 3.5,
        confidenceBand: 'high',
      );
      final updated = item.copyWith(productName: 'Updated');
      expect(updated.co2e100g, equals(3.5));
      expect(updated.confidenceBand, equals('high'));
    });

    // --- source / sourceRowId / resolvedFoodRef (Plan 04-06, LOG-11) ---

    test('source and sourceRowId are null by default', () {
      const item = FoodItem(productName: 'Test');
      expect(item.source, isNull);
      expect(item.sourceRowId, isNull);
    });

    test('omitting source/sourceRowId in constructor does not affect '
        'equality/hashCode', () {
      const withSource = FoodItem(
        barcode: '111',
        productName: 'Banana',
        source: 'user_foods',
        sourceRowId: 'row-1',
      );
      const withoutSource = FoodItem(barcode: '111', productName: 'Banana');
      expect(withSource, equals(withoutSource));
      expect(withSource.hashCode, equals(withoutSource.hashCode));
    });

    test('copyWith(source: "user_foods") sets source, preserves other '
        'fields', () {
      const item = FoodItem(barcode: '111', productName: 'Banana');
      final updated = item.copyWith(source: 'user_foods');
      expect(updated.source, equals('user_foods'));
      expect(updated.barcode, equals('111'));
      expect(updated.productName, equals('Banana'));
    });

    test('copyWith(sourceRowId: "row-1") sets sourceRowId', () {
      const item = FoodItem(productName: 'Banana');
      final updated = item.copyWith(sourceRowId: 'row-1');
      expect(updated.sourceRowId, equals('row-1'));
    });

    test('copyWith(source: null) explicitly clears source (sentinel)', () {
      const item = FoodItem(productName: 'Banana', source: 'off_ref');
      final updated = item.copyWith(source: null);
      expect(updated.source, isNull);
    });

    test('resolvedFoodRef returns barcode when both barcode and '
        'sourceRowId are set', () {
      const item = FoodItem(
        barcode: '7612345678901',
        productName: 'Banana',
        sourceRowId: 'row-1',
      );
      expect(item.resolvedFoodRef, equals('7612345678901'));
    });

    test('resolvedFoodRef returns sourceRowId when barcode is null', () {
      const item = FoodItem(
        productName: 'Custom Food',
        source: 'user_foods',
        sourceRowId: 'row-42',
      );
      expect(item.resolvedFoodRef, equals('row-42'));
    });

    test('resolvedFoodRef throws StateError when both barcode and '
        'sourceRowId are null', () {
      const item = FoodItem(productName: 'Mystery Food');
      expect(() => item.resolvedFoodRef, throwsA(isA<StateError>()));
    });
  });
}
