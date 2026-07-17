// Pure Dart implementation of the Mifflin-St Jéor TDEE calculator.
// Zero non-dart:core imports. Fully unit-testable in isolation.
//
// Reference: Mifflin MD, St Jeor ST, Hill LA, Scott BJ, Daugherty SA, Koh YO.
// A new predictive equation for resting energy expenditure in healthy
// individuals. Am J Clin Nutr. 1990 Feb;51(2):241-7.
//
// Manual verification for Test 1 (male, 75 kg, 175 cm, age 30, low activity):
//   BMR_male = 10×75 + 6.25×175 − 5×30 + 5
//            = 750 + 1093.75 − 150 + 5
//            = 1698.75
//   TDEE     = 1698.75 × 1.375
//            = 2335.78125

/// Biological sex used only for BMR offset.
///
/// Use [Gender.other] (or pass `null`) when a user declines to specify.
enum Gender {
  /// Male offset: BMR = base + 5.
  male,

  /// Female offset: BMR = base − 161.
  female,

  /// Average of male and female: BMR = base − 78.
  other,
}

/// Physical activity level mapped to PAL multipliers from Mifflin-St Jéor.
enum ActivityLevel {
  /// Lightly active (1–3 days/week) — PAL factor 1.375.
  low,

  /// Moderately active (3–5 days/week) — PAL factor 1.55.
  medium,

  /// Very active (6–7 days/week) — PAL factor 1.725.
  high,
}

/// Computes Total Daily Energy Expenditure (TDEE) using the Mifflin-St Jéor
/// equation.
///
/// Returns `null` when any required anthropometric field is missing, so the UI
/// can display `—` instead of false-precision values (per D-07).
///
/// Treats [gender] == `null` identically to [Gender.other] (average of
/// male and female BMR).
double? calculateTdee({
  required double? weightKg,
  required double? heightCm,
  required int? age,
  required Gender? gender,
  required ActivityLevel activityLevel,
}) {
  // Guard: return null for any missing anthropometric field.
  if (weightKg == null || heightCm == null || age == null) {
    return null;
  }

  // Mifflin-St Jéor BMR (kcal/day):
  //   Male:   (10 × weight) + (6.25 × height) − (5 × age) + 5
  //   Female: (10 × weight) + (6.25 × height) − (5 × age) − 161
  //   Other:  average of male and female
  //           = (10 × weight) + (6.25 × height) − (5 × age) − 78
  //           (derived: (+5 + −161) / 2 = −78)
  final base = (10.0 * weightKg) + (6.25 * heightCm) - (5.0 * age);

  final bmr = switch (gender ?? Gender.other) {
    Gender.male => base + 5,
    Gender.female => base - 161,
    Gender.other => base - 78, // exact average of +5 and −161
  };

  // PAL multiplier.
  final factor = switch (activityLevel) {
    ActivityLevel.low => 1.375,
    ActivityLevel.medium => 1.550,
    ActivityLevel.high => 1.725,
  };

  return bmr * factor;
}
