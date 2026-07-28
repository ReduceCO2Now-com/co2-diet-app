import 'package:co2diet/domain/entities/co2_settings.dart';
import 'package:co2diet/domain/services/daily_totals_calculator.dart';

/// Neutral baseline multiplier -- the regional-average fallback used when
/// no [Co2Settings] fields are set (CO2-03).
const double _baseline = 1;

/// Safety-clamp bounds mirroring `TargetCalculator`'s existing
/// physiologically-safe-range precedent: no combination of settings deltas
/// can push the personal multiplier to an implausible value.
const double _multiplierMin = 0.7;
const double _multiplierMax = 1.3;

/// Pure Dart service that derives a deterministic personal-consumption CO2
/// multiplier from [Co2Settings] (CO2-02/CO2-03).
///
/// This is a strictly separate layer from any individual food's own CO2
/// data. The function signature accepts only [Co2Settings] and returns
/// only a `double` -- it has no parameter through which a
/// `MealEntry`/`FoodItem`/`co2e100g` value could be passed, structurally
/// enforcing 05-CONTEXT.md's separate-layer invariant: this multiplier is
/// applied only once, by [DailyTotalsCalculator.compute]'s `co2Multiplier`
/// parameter, at the aggregate-total level -- never re-applied per entry
/// and never written back into any `MealEntry` row.
///
/// Zero I/O, zero framework dependencies.
class PersonalCo2MultiplierCalculator {
  // Prevent instantiation -- all methods are static (mirrors
  // TargetCalculator's private-constructor convention).
  const PersonalCo2MultiplierCalculator._();

  // 3 of 7 settings factors (foodStorage, householdSize, location) have no
  // numeric effect in v1 -- confirmed acceptable per 05-CONTEXT.md's
  // Planning Addendum, not a gap to fill silently later.
  /// Derives the personal-consumption CO2 multiplier for [settings].
  ///
  /// Starts from a neutral `1.0` baseline (regional-average fallback,
  /// CO2-03) and applies small, documented, additive percentage deltas per
  /// set field. Every constant below is marked ASSUMED -- to be reviewed,
  /// matching `TargetCalculator`'s existing "Marked ASSUMED... to be
  /// reviewed" precedent for its macro ratios:
  ///
  /// - `purchasingSource`: `'local_farm'` -0.08, `'mix'` -0.03,
  ///   `'supermarket'`/unset 0.0.
  /// - `shoppingTransport`: `'walk_bike'` -0.05, `'public'` -0.02,
  ///   `'car'`/unset 0.0.
  /// - `cookingMethod`: `'induction'` -0.02, `'electric'`/unset 0.0,
  ///   `'gas'` +0.02.
  /// - `foodWasteLevel`: `'low'` -0.05, `'medium'`/unset 0.0,
  ///   `'high'` +0.10.
  /// - `foodStorage`/`householdSize`/`locationCountry`/`locationRegion`:
  ///   no numeric effect in this first cut (see the confirmed-decision
  ///   comment directly above this doc comment).
  ///
  /// The sum of all applicable deltas is added to the `1.0` baseline, then
  /// clamped to `[0.7, 1.3]` so no combination of settings can produce an
  /// implausible multiplier (mirrors `TargetCalculator`'s safety-clamp
  /// precedent).
  static double compute(Co2Settings settings) {
    var multiplier = _baseline;

    multiplier += switch (settings.purchasingSource) {
      'local_farm' => -0.08,
      'mix' => -0.03,
      _ => 0.0,
    };

    multiplier += switch (settings.shoppingTransport) {
      'walk_bike' => -0.05,
      'public' => -0.02,
      _ => 0.0,
    };

    multiplier += switch (settings.cookingMethod) {
      'induction' => -0.02,
      'gas' => 0.02,
      _ => 0.0,
    };

    multiplier += switch (settings.foodWasteLevel) {
      'low' => -0.05,
      'high' => 0.10,
      _ => 0.0,
    };

    return multiplier.clamp(_multiplierMin, _multiplierMax);
  }
}
