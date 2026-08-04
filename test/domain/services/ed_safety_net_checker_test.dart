import 'package:co2diet/domain/services/ed_safety_net_checker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EdSafetyNetChecker', () {
    test(
      'calorieTargetIsUnsafe returns false when the calorie target '
      'is exactly 1200 kcal',
      () {
        expect(EdSafetyNetChecker.calorieTargetIsUnsafe(1200), isFalse);
      },
    );

    test(
      'calorieTargetIsUnsafe returns true when the calorie target '
      'is 1199 kcal',
      () {
        expect(EdSafetyNetChecker.calorieTargetIsUnsafe(1199), isTrue);
      },
    );

    test(
      'calorieTargetIsUnsafe returns true when the calorie target '
      'is 500 kcal',
      () {
        expect(EdSafetyNetChecker.calorieTargetIsUnsafe(500), isTrue);
      },
    );

    test(
      'bmiIsUnsafe returns null when heightCm is missing or zero',
      () {
        expect(
          EdSafetyNetChecker.bmiIsUnsafe(weightKg: 50),
          isNull,
        );
        expect(
          EdSafetyNetChecker.bmiIsUnsafe(weightKg: 50, heightCm: 0),
          isNull,
        );
      },
    );

    test(
      'bmiIsUnsafe returns true when computed BMI is below 17.5',
      () {
        // BMI = 50 / (1.8 * 1.8) ≈ 15.4 < 17.5
        expect(
          EdSafetyNetChecker.bmiIsUnsafe(weightKg: 50, heightCm: 180),
          isTrue,
        );
      },
    );

    test(
      'bmiIsUnsafe returns false when computed BMI is 17.5 or above',
      () {
        // BMI = 70 / (1.7 * 1.7) ≈ 24.2 >= 17.5
        expect(
          EdSafetyNetChecker.bmiIsUnsafe(weightKg: 70, heightCm: 170),
          isFalse,
        );
      },
    );
  });
}
