import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'EdSafetyNetChecker',
    skip: 'Awaiting Plan 06-03 implementation',
    () {
      // TODO(Plan 06-03): calorieTargetIsUnsafe is false at exactly 1200
      // kcal (the threshold itself is safe, not unsafe).
      test(
        'calorieTargetIsUnsafe returns false when the calorie target '
        'is exactly 1200 kcal',
        () {},
      );

      // TODO(Plan 06-03): calorieTargetIsUnsafe is true just below the
      // 1200 kcal threshold.
      test(
        'calorieTargetIsUnsafe returns true when the calorie target '
        'is 1199 kcal',
        () {},
      );

      // TODO(Plan 06-03): calorieTargetIsUnsafe is true for a severely
      // low calorie target.
      test(
        'calorieTargetIsUnsafe returns true when the calorie target '
        'is 500 kcal',
        () {},
      );

      // TODO(Plan 06-03): bmiIsUnsafe returns null (not false) when
      // heightCm is missing or zero -- cannot compute BMI without
      // height, must not silently treat as safe.
      test(
        'bmiIsUnsafe returns null when heightCm is missing or zero',
        () {},
      );

      // TODO(Plan 06-03): bmiIsUnsafe returns true below the 17.5
      // underweight threshold.
      test(
        'bmiIsUnsafe returns true when computed BMI is below 17.5',
        () {},
      );

      // TODO(Plan 06-03): bmiIsUnsafe returns false at or above the
      // 17.5 underweight threshold.
      test(
        'bmiIsUnsafe returns false when computed BMI is 17.5 or above',
        () {},
      );
    },
  );
}
