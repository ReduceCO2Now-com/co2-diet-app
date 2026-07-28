import 'package:co2diet/domain/entities/meal_entry.dart';
import 'package:co2diet/domain/entities/portion_unit.dart';
import 'package:co2diet/domain/services/personal_co2_multiplier_calculator.dart';
import 'package:flutter/foundation.dart';

/// Energy-per-gram constants reused from `TargetCalculator`'s existing
/// macro-to-energy conversion (protein/carbs 4 kcal/g, fat 9 kcal/g) --
/// the same constants, not reinvented, so macro-split percentages and
/// calorie-target math never silently diverge.
const double _kcalPerGramProtein = 4;
const double _kcalPerGramCarbs = 4;
const double _kcalPerGramFat = 9;

/// Protein/carbs/fat macro split, expressed as percentages of total
/// macro-gram-equivalent energy (normalized to sum to ~100).
@immutable
class MacroSplit {
  /// Creates an immutable [MacroSplit].
  const MacroSplit({
    required this.proteinPct,
    required this.carbsPct,
    required this.fatPct,
  });

  /// Protein's share of total macro energy, as a percentage (0-100).
  final double proteinPct;

  /// Carbs' share of total macro energy, as a percentage (0-100).
  final double carbsPct;

  /// Fat's share of total macro energy, as a percentage (0-100).
  final double fatPct;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MacroSplit &&
          other.proteinPct == proteinPct &&
          other.carbsPct == carbsPct &&
          other.fatPct == fatPct);

  @override
  int get hashCode => Object.hash(proteinPct, carbsPct, fatPct);

  @override
  String toString() =>
      'MacroSplit(proteinPct: $proteinPct, carbsPct: $carbsPct, '
      'fatPct: $fatPct)';
}

/// Aggregate totals for a set of [MealEntry] rows (typically "today" or a
/// trailing N-day window), computed by [DailyTotalsCalculator.compute].
///
/// Every nutrient field is nullable: a field is `null` when zero
/// contributing entries had a non-null snapshot for it -- never a
/// fabricated `0` (no false precision, per this app's cross-cutting
/// invariant).
@immutable
class DailyTotals {
  /// Creates an immutable [DailyTotals].
  const DailyTotals({
    this.calories,
    this.protein,
    this.carbs,
    this.fat,
    this.sugar,
    this.fiber,
    this.salt,
    this.co2e,
    this.includedEntryCount = 0,
  });

  /// Total calories, or `null` if zero entries contributed.
  final double? calories;

  /// Total protein (g), or `null` if zero entries contributed.
  final double? protein;

  /// Total carbs (g), or `null` if zero entries contributed.
  final double? carbs;

  /// Total fat (g), or `null` if zero entries contributed.
  final double? fat;

  /// Total sugar (g), or `null` if zero entries contributed.
  final double? sugar;

  /// Total fiber (g), or `null` if zero entries contributed.
  final double? fiber;

  /// Total salt (g), or `null` if zero entries contributed.
  final double? salt;

  /// Total CO2e, with the personal CO2 multiplier already applied exactly
  /// once at this aggregate level (see [DailyTotalsCalculator.compute]),
  /// or `null` if zero entries contributed.
  final double? co2e;

  /// How many weight-based-unit entries contributed to *any* field --
  /// useful for a future "N of M items counted" UI caveat.
  final int includedEntryCount;

  /// Protein/carbs/fat macro split as percentages, or `null` when
  /// [protein]/[carbs]/[fat] are all `null` (nothing to split).
  ///
  /// Computed using the same 4/4/9 kcal/g energy-conversion constants as
  /// `TargetCalculator` -- reused directly, not reinvented.
  MacroSplit? get macroSplit {
    if (protein == null && carbs == null && fat == null) {
      return null;
    }
    final proteinKcal = (protein ?? 0) * _kcalPerGramProtein;
    final carbsKcal = (carbs ?? 0) * _kcalPerGramCarbs;
    final fatKcal = (fat ?? 0) * _kcalPerGramFat;
    final totalKcal = proteinKcal + carbsKcal + fatKcal;
    if (totalKcal <= 0) {
      return const MacroSplit(proteinPct: 0, carbsPct: 0, fatPct: 0);
    }
    return MacroSplit(
      proteinPct: proteinKcal / totalKcal * 100,
      carbsPct: carbsKcal / totalKcal * 100,
      fatPct: fatKcal / totalKcal * 100,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyTotals &&
          other.calories == calories &&
          other.protein == protein &&
          other.carbs == carbs &&
          other.fat == fat &&
          other.sugar == sugar &&
          other.fiber == fiber &&
          other.salt == salt &&
          other.co2e == co2e &&
          other.includedEntryCount == includedEntryCount);

  @override
  int get hashCode => Object.hash(
    calories,
    protein,
    carbs,
    fat,
    sugar,
    fiber,
    salt,
    co2e,
    includedEntryCount,
  );

  @override
  String toString() =>
      'DailyTotals(calories: $calories, protein: $protein, carbs: $carbs, '
      'fat: $fat, sugar: $sugar, fiber: $fiber, salt: $salt, '
      'co2e: $co2e, includedEntryCount: $includedEntryCount)';
}

/// Pure Dart service that aggregates a list of [MealEntry] rows into a
/// single [DailyTotals] -- the sole implementation both the Dashboard
/// (Plan 05-11) and the Data Analysis screen (Plan 05-15) call, so their
/// numbers can never silently diverge (Architectural Responsibility Map:
/// aggregation logic belongs in a domain/service layer, not inline in
/// widgets).
///
/// Zero I/O, zero framework dependencies -- unit-testable without Flutter,
/// Drift, or Riverpod widget harnesses.
class DailyTotalsCalculator {
  // Prevent instantiation -- all methods are static (mirrors
  // TargetCalculator's private-constructor convention).
  const DailyTotalsCalculator._();

  /// Computes aggregate [DailyTotals] across [entries].
  ///
  /// Known limitation (inherited from Phase 4, not introduced here): only
  /// weight-based-unit ([PortionUnitDisplay.isWeightBased], i.e. `g`/`ml`)
  /// entries can be scaled and therefore contribute to any numeric total.
  /// `piece`/`cup`/`portion` entries have no gram-equivalent stored at log
  /// time, matching `MealEntryRow`/`RecentRow`'s existing "weight-based
  /// units only" precedent ([Phase 04-10] decision).
  ///
  /// For each of the 7 nutrient fields, only entries whose corresponding
  /// scaled value is non-null contribute to the sum; if the resulting list
  /// of contributors is empty, that field is `null` -- never a fabricated
  /// `0`.
  ///
  /// [co2Multiplier] (the personal-consumption multiplier from
  /// [PersonalCo2MultiplierCalculator], default `1.0` when omitted) is
  /// applied as a single final multiplication on the summed (unmultiplied)
  /// `co2e` total -- never per-entry, and never written back into any
  /// `MealEntry` row.
  static DailyTotals compute(
    List<MealEntry> entries, {
    double co2Multiplier = 1.0,
  }) {
    final scaledEntries = entries
        .where((entry) => entry.unit.isWeightBased)
        .map((entry) => entry.scaled(entry.quantity))
        .toList();

    double? sumField(double? Function(ScaledMacros scaled) selector) {
      final contributors = scaledEntries
          .map(selector)
          .whereType<double>()
          .toList();
      if (contributors.isEmpty) return null;
      return contributors.reduce((a, b) => a + b);
    }

    final calories = sumField((s) => s.calories);
    final protein = sumField((s) => s.protein);
    final carbs = sumField((s) => s.carbs);
    final fat = sumField((s) => s.fat);
    final sugar = sumField((s) => s.sugar);
    final fiber = sumField((s) => s.fiber);
    final salt = sumField((s) => s.salt);
    final co2eRaw = sumField((s) => s.co2e);
    final co2e = co2eRaw == null ? null : co2eRaw * co2Multiplier;

    final includedEntryCount = scaledEntries
        .where(
          (s) =>
              s.calories != null ||
              s.protein != null ||
              s.carbs != null ||
              s.fat != null ||
              s.sugar != null ||
              s.fiber != null ||
              s.salt != null ||
              s.co2e != null,
        )
        .length;

    return DailyTotals(
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      sugar: sugar,
      fiber: fiber,
      salt: salt,
      co2e: co2e,
      includedEntryCount: includedEntryCount,
    );
  }
}
