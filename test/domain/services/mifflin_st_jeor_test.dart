import 'package:co2diet/domain/services/mifflin_st_jeor.dart';
import 'package:test/test.dart';

void main() {
  group('calculateTdee', () {
    // Manual verification (Task 1 action note):
    // Male, 75kg, 175cm, age 30, low activity:
    //   BMR = 10×75 + 6.25×175 − 5×30 + 5 = 750 + 1093.75 − 150 + 5 = 1698.75
    //   TDEE = 1698.75 × 1.375 = 2335.78125
    test('Test 1: known male input returns exact TDEE (2335.78125)', () {
      final result = calculateTdee(
        weightKg: 75,
        heightCm: 175,
        age: 30,
        gender: Gender.male,
        activityLevel: ActivityLevel.low,
      );
      expect(result, closeTo(2335.78125, 0.001));
    });

    // Female, 60kg, 165cm, age 25, medium activity:
    //   BMR = 10×60 + 6.25×165 − 5×25 − 161 = 600 + 1031.25 − 125 − 161 = 1345.25
    //   TDEE = 1345.25 × 1.55 = 2085.1375
    test('Test 2: known female input returns exact TDEE (2085.1375)', () {
      final result = calculateTdee(
        weightKg: 60,
        heightCm: 165,
        age: 25,
        gender: Gender.female,
        activityLevel: ActivityLevel.medium,
      );
      expect(result, closeTo(2085.1375, 0.001));
    });

    test('Test 3: null weightKg returns null', () {
      final result = calculateTdee(
        weightKg: null,
        heightCm: 175,
        age: 30,
        gender: Gender.male,
        activityLevel: ActivityLevel.low,
      );
      expect(result, isNull);
    });

    test('Test 4: null heightCm returns null', () {
      final result = calculateTdee(
        weightKg: 75,
        heightCm: null,
        age: 30,
        gender: Gender.male,
        activityLevel: ActivityLevel.low,
      );
      expect(result, isNull);
    });

    test('Test 5: null age returns null', () {
      final result = calculateTdee(
        weightKg: 75,
        heightCm: 175,
        age: null,
        gender: Gender.male,
        activityLevel: ActivityLevel.low,
      );
      expect(result, isNull);
    });

    // Gender.other = average of male and female BMR:
    //   Male BMR   = 10×75 + 6.25×175 − 5×30 + 5   = 1698.75
    //   Female BMR = 10×75 + 6.25×175 − 5×30 − 161  = 1532.75
    //   Other BMR  = (1698.75 + 1532.75) / 2          = 1615.75
    //   TDEE       = 1615.75 × 1.375                  = 2221.65625
    test('Test 6: Gender.other returns average of male+female BMR', () {
      final resultOther = calculateTdee(
        weightKg: 75,
        heightCm: 175,
        age: 30,
        gender: Gender.other,
        activityLevel: ActivityLevel.low,
      );
      final resultMale = calculateTdee(
        weightKg: 75,
        heightCm: 175,
        age: 30,
        gender: Gender.male,
        activityLevel: ActivityLevel.low,
      );
      final resultFemale = calculateTdee(
        weightKg: 75,
        heightCm: 175,
        age: 30,
        gender: Gender.female,
        activityLevel: ActivityLevel.low,
      );
      expect(resultOther, isNotNull);
      expect(resultMale, isNotNull);
      expect(resultFemale, isNotNull);
      expect(resultOther!, closeTo((resultMale! + resultFemale!) / 2, 0.001));
    });

    group('Test 7: activity level factors', () {
      // Base: male, 70kg, 170cm, age 35
      // BMR = 10×70 + 6.25×170 − 5×35 + 5 = 700 + 1062.5 − 175 + 5 = 1592.5
      const weight = 70.0;
      const height = 170.0;
      const age = 35;
      const bmr = 1592.5;

      test('ActivityLevel.low maps to factor 1.375', () {
        final result = calculateTdee(
          weightKg: weight,
          heightCm: height,
          age: age,
          gender: Gender.male,
          activityLevel: ActivityLevel.low,
        );
        expect(result, closeTo(bmr * 1.375, 0.001));
      });

      test('ActivityLevel.medium maps to factor 1.55', () {
        final result = calculateTdee(
          weightKg: weight,
          heightCm: height,
          age: age,
          gender: Gender.male,
          activityLevel: ActivityLevel.medium,
        );
        expect(result, closeTo(bmr * 1.55, 0.001));
      });

      test('ActivityLevel.high maps to factor 1.725', () {
        final result = calculateTdee(
          weightKg: weight,
          heightCm: height,
          age: age,
          gender: Gender.male,
          activityLevel: ActivityLevel.high,
        );
        expect(result, closeTo(bmr * 1.725, 0.001));
      });
    });
  });
}
