import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'UserFoodDao',
    skip: 'UserFoodDao not yet implemented',
    () {
      test(
        'insert requires name and calories; throws or rejects when either '
        'is missing',
        () {},
      );

      test(
        'insert with overrideOfRef+overrideOfSource stores an independent '
        'override row',
        () {},
      );

      test(
        'findOverrideByFoodRef returns the override row when one exists '
        'for a catalog food',
        () {},
      );

      test(
        'deleting an override row (revert) leaves the original catalog '
        'data untouched',
        () {},
      );

      test(
        'getAllAlphabetical returns rows sorted by name with optional '
        'filter substring',
        () {},
      );
    },
  );
}
