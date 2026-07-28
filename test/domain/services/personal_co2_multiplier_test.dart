import 'package:co2diet/domain/entities/co2_settings.dart';
import 'package:co2diet/domain/services/personal_co2_multiplier_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PersonalCo2MultiplierCalculator', () {
    test(
      'returns a neutral 1.0 multiplier when Co2Settings has every '
      'field unset (regional-average fallback)',
      () {
        const settings = Co2Settings();

        expect(PersonalCo2MultiplierCalculator.compute(settings), 1.0);
      },
    );

    test(
      'multiplier changes deterministically when '
      'purchasingSource/shoppingTransport/foodWasteLevel are set',
      () {
        const neutral = Co2Settings();
        const belowNeutral = Co2Settings(
          purchasingSource: 'local_farm',
          shoppingTransport: 'walk_bike',
          foodWasteLevel: 'low',
        );
        const aboveNeutral = Co2Settings(
          purchasingSource: 'supermarket',
          shoppingTransport: 'car',
          cookingMethod: 'gas',
          foodWasteLevel: 'high',
        );

        final neutralResult = PersonalCo2MultiplierCalculator.compute(
          neutral,
        );
        final belowResult = PersonalCo2MultiplierCalculator.compute(
          belowNeutral,
        );
        final aboveResult = PersonalCo2MultiplierCalculator.compute(
          aboveNeutral,
        );

        expect(belowResult, lessThan(neutralResult));
        expect(aboveResult, greaterThan(neutralResult));

        // Deterministic: same input, same output, no randomness/hidden
        // state.
        expect(
          PersonalCo2MultiplierCalculator.compute(belowNeutral),
          belowResult,
        );
      },
    );

    test(
      "never reads or mutates any food's own co2e100g/confidenceBand "
      '-- pure settings-to-multiplier function',
      () {
        // Structural guarantee: compute's signature is (Co2Settings) ->
        // double -- there is no parameter through which a food-level
        // co2e100g/confidenceBand value could be passed. Verified by the
        // type signature itself (this line would fail to compile if a
        // second required parameter existed).
        const settings = Co2Settings(purchasingSource: 'local_farm');
        final result = PersonalCo2MultiplierCalculator.compute(settings);

        expect(result, isA<double>());
      },
    );

    test(
      'dataQuality classification is basic/good/detailed based on '
      'how many optional fields are set',
      () {
        const basic = Co2Settings(purchasingSource: 'local_farm');
        const good = Co2Settings(
          purchasingSource: 'local_farm',
          shoppingTransport: 'walk_bike',
          cookingMethod: 'induction',
        );
        const detailed = Co2Settings(
          locationCountry: 'DE',
          locationRegion: 'Bavaria',
          purchasingSource: 'local_farm',
          shoppingTransport: 'walk_bike',
          cookingMethod: 'induction',
          foodStorage: 'small_fridge',
          householdSize: 2,
          foodWasteLevel: 'low',
        );

        expect(basic.dataQuality, 'basic');
        expect(good.dataQuality, 'good');
        expect(detailed.dataQuality, 'detailed');
      },
    );

    test(
      'foodStorage/householdSize/locationCountry/locationRegion '
      'produce no numeric effect -- confirmed v1 scope narrowing '
      'per 05-CONTEXT.md addendum, not a gap',
      () {
        const withoutExtras = Co2Settings(purchasingSource: 'local_farm');
        const withExtras = Co2Settings(
          purchasingSource: 'local_farm',
          locationCountry: 'DE',
          locationRegion: 'Bavaria',
          foodStorage: 'large_fridge_freezer',
          householdSize: 4,
        );

        expect(
          PersonalCo2MultiplierCalculator.compute(withExtras),
          PersonalCo2MultiplierCalculator.compute(withoutExtras),
        );
      },
    );
  });
}
