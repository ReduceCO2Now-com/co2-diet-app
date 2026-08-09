import 'package:co2diet/domain/services/methodology_version_checker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isStale', () {
    const checker = MethodologyVersionChecker();

    test('null snapshot is never stale', () {
      expect(checker.isStale(null), isFalse);
    });

    test('snapshot equal to the current version is not stale', () {
      expect(checker.isStale(currentCo2MethodologyVersion), isFalse);
    });

    test('snapshot older than the current version is stale', () {
      expect(checker.isStale('0.9'), isTrue);
    });

    test(
      'accepts an optional currentVersion override without mutating the '
      'real constant',
      () {
        expect(
          checker.isStale('1.0', currentVersion: '1.1'),
          isTrue,
        );
        expect(
          checker.isStale('1.1', currentVersion: '1.1'),
          isFalse,
        );
        expect(checker.isStale('1.0'), isFalse);
      },
    );
  });

  group('hasAnyStale', () {
    const checker = MethodologyVersionChecker();

    test(
      'false when profile/meal/food versions are all null or current',
      () {
        expect(
          checker.hasAnyStale(
            profileVersion: null,
            mealVersions: [],
            foodVersions: [],
          ),
          isFalse,
        );
        expect(
          checker.hasAnyStale(
            profileVersion: '1.0',
            mealVersions: [null, '1.0'],
            foodVersions: [null],
          ),
          isFalse,
        );
      },
    );

    test('true when the profile version is stale', () {
      expect(
        checker.hasAnyStale(
          profileVersion: '0.9',
          mealVersions: [],
          foodVersions: [],
        ),
        isTrue,
      );
    });

    test('true when any meal-entry snapshot version is stale', () {
      expect(
        checker.hasAnyStale(
          profileVersion: '1.0',
          mealVersions: ['1.0', '0.8', null],
          foodVersions: [],
        ),
        isTrue,
      );
    });

    test('true when any user-food version is stale', () {
      expect(
        checker.hasAnyStale(
          profileVersion: '1.0',
          mealVersions: [],
          foodVersions: [null, '0.7'],
        ),
        isTrue,
      );
    });
  });
}
