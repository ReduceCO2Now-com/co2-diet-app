import 'package:co2diet/domain/entities/user_food.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserFood', () {
    const baseFood = UserFood(
      id: 'food-1',
      name: 'Homemade Soup',
      brand: 'Kitchen',
      calories: 250,
      protein: 10,
      referenceAmountG: 50,
    );

    test(
      'copyWith replaces only specified fields; sentinel pattern '
      'preserves nullable fields',
      () {
        final updated = baseFood.copyWith(name: 'Updated Soup');
        expect(updated.name, 'Updated Soup');
        expect(updated.brand, 'Kitchen');
        expect(updated.calories, 250);

        final cleared = baseFood.copyWith(brand: null);
        expect(cleared.brand, isNull);
        expect(cleared.name, baseFood.name);
      },
    );

    test('isValid returns false when name is empty or calories is null', () {
      expect(baseFood.isValid, isTrue);

      final emptyName = baseFood.copyWith(name: '   ');
      expect(emptyName.isValid, isFalse);

      final noCalories = baseFood.copyWith(calories: null);
      expect(noCalories.isValid, isFalse);

      const minimal = UserFood(id: 'food-2', name: 'Minimal', calories: 100);
      expect(minimal.isValid, isTrue);
    });

    test(
      'perReferenceAmount macros scale correctly when referenceAmountG '
      'differs from 100',
      () {
        expect(baseFood.caloriesPer100g, 500);
        expect(baseFood.proteinPer100g, 20);

        const defaultRef = UserFood(id: 'food-3', name: 'Default', calories: 150);
        expect(defaultRef.caloriesPer100g, 150);

        const noValue = UserFood(id: 'food-4', name: 'NoFat', calories: 100);
        expect(noValue.fatPer100g, isNull);
      },
    );

    test('equality is based on id', () {
      final other = baseFood.copyWith(name: 'Different Name');
      expect(other, equals(baseFood));

      const differentId = UserFood(
        id: 'food-999',
        name: 'Homemade Soup',
        calories: 250,
      );
      expect(differentId, isNot(equals(baseFood)));
    });
  });
}
