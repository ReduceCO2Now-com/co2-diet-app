// Rationale for avoid_print suppression: domain layer is framework-free;
// dart:developer is unavailable without Flutter. print() is the only standard
// mechanism for warning logs here. Phase 6 replaces this with structured
// logging (NFR-07).
// ignore_for_file: avoid_print

import 'package:co2diet/domain/entities/calc_targets.dart';
import 'package:co2diet/domain/services/mifflin_st_jeor.dart';

/// Macro energy distribution ratios by goal (protein %, carbs %, fat %).
///
/// Ratios are within standard AMDR ranges (protein 10–35%, carbs 45–65%,
/// fat 20–35%). Marked ASSUMED in RESEARCH.md — to be reviewed by a
/// registered dietitian before launch.
const _MacroRatios _defaultRatios = (p: 0.25, c: 0.50, f: 0.25);

const Map<String, _MacroRatios> _goalRatios = {
  'reduce_co2': (p: 0.25, c: 0.45, f: 0.30),
  'lose_weight': (p: 0.35, c: 0.35, f: 0.30),
  'maintain_weight': (p: 0.25, c: 0.50, f: 0.25),
  'gain_muscle': (p: 0.30, c: 0.45, f: 0.25),
  'improve_health': (p: 0.25, c: 0.50, f: 0.25),
  'balanced_lifestyle': (p: 0.25, c: 0.50, f: 0.25),
  'learn_and_explore': (p: 0.25, c: 0.50, f: 0.25),
};

/// Caloric safety clamp bounds (T-03-01 threat mitigation).
///
/// Values outside [[_kcalMin], [_kcalMax]] are physiologically extreme;
/// we clamp and warn rather than surfacing unsafe raw output.
/// Phase 6 will add a proper ED-safety-net warning to the UI (NFR-07).
const double _kcalMin = 500;
const double _kcalMax = 10000;

typedef _MacroRatios = ({double p, double c, double f});

/// Pure Dart service that derives [CalcTargets] from a user's profile fields.
///
/// Has zero framework dependencies — it can be unit-tested without Flutter,
/// Drift, or Riverpod.
class TargetCalculator {
  // Prevent instantiation — all methods are static.
  const TargetCalculator._();

  /// Derives macro and calorie [CalcTargets] from the supplied profile fields.
  ///
  /// Returns a [CalcTargets] with all nullable fields set to `null` when TDEE
  /// cannot be computed (any of weight/height/age is missing). The UI renders
  /// `—` in that case (D-07).
  ///
  /// If [existingTargets] has an override flag set, the overridden field is
  /// preserved rather than recalculated (D-06).
  ///
  /// TDEE output is clamped to [_kcalMin]–[_kcalMax] kcal for safety
  /// (T-03-01). Values outside this range are physiologically implausible;
  /// Phase 6 will surface a visible warning to the user (NFR-07).
  static CalcTargets derive({
    required double? weightKg,
    required double? heightCm,
    required int? age,
    required String? gender,
    required String? activityLevel,
    required String? goal,
    CalcTargets? existingTargets,
  }) {
    // 1. Map string → Gender enum (null or unknown → other).
    final genderEnum = switch (gender) {
      'male' => Gender.male,
      'female' => Gender.female,
      _ => Gender.other,
    };

    // 2. Map string → ActivityLevel enum (null or unknown → medium default).
    final activityEnum = switch (activityLevel) {
      'low' => ActivityLevel.low,
      'high' => ActivityLevel.high,
      _ => ActivityLevel.medium,
    };

    // 3. Compute TDEE via Mifflin-St Jéor.
    final rawKcal = calculateTdee(
      weightKg: weightKg,
      heightCm: heightCm,
      age: age,
      gender: genderEnum,
      activityLevel: activityEnum,
    );

    // 4. Return all-null CalcTargets when TDEE cannot be computed.
    if (rawKcal == null) {
      return const CalcTargets();
    }

    // 5. Clamp TDEE to physiologically safe bounds (T-03-01).
    final double kcal;
    if (rawKcal < _kcalMin || rawKcal > _kcalMax) {
      print(
        '[TargetCalculator] WARN: rawKcal=$rawKcal clamped to '
        '[$_kcalMin, $_kcalMax]. Phase 6 will surface ED safety warning '
        '(NFR-07).',
      );
      kcal = rawKcal.clamp(_kcalMin, _kcalMax);
    } else {
      kcal = rawKcal;
    }

    // 6. Macro ratios for the user's goal (fall back to default).
    final ratios = _goalRatios[goal] ?? _defaultRatios;

    // 7. Compute macro grams:
    //    protein (4 kcal/g), carbs (4 kcal/g), fat (9 kcal/g).
    final calculatedProtein = kcal * ratios.p / 4;
    final calculatedCarbs = kcal * ratios.c / 4;
    final calculatedFat = kcal * ratios.f / 9;

    // 8. Respect override flags: keep user-set values instead of
    //    recalculating them (D-06).
    final existing = existingTargets;
    return CalcTargets(
      kcalTarget: (existing?.kcalIsOverridden ?? false)
          ? existing!.kcalTarget
          : kcal,
      proteinGTarget: (existing?.proteinIsOverridden ?? false)
          ? existing!.proteinGTarget
          : calculatedProtein,
      carbsGTarget: (existing?.carbsIsOverridden ?? false)
          ? existing!.carbsGTarget
          : calculatedCarbs,
      fatGTarget: (existing?.fatIsOverridden ?? false)
          ? existing!.fatGTarget
          : calculatedFat,
      kcalIsOverridden: existing?.kcalIsOverridden ?? false,
      proteinIsOverridden: existing?.proteinIsOverridden ?? false,
      carbsIsOverridden: existing?.carbsIsOverridden ?? false,
      fatIsOverridden: existing?.fatIsOverridden ?? false,
    );
  }
}
