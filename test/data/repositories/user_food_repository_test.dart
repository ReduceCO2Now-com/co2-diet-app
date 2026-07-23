import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'UserFoodRepository',
    skip: 'UserFoodRepository not yet implemented',
    () {
      test(
        'saveCustomFood persists a category-estimate CO2 value with '
        'medium confidence band',
        () {},
      );

      test(
        'saveCustomFood with manual CO2 value stores no confidence band '
        '(self-entered, unbacked)',
        () {},
      );

      test(
        'saveOverride never mutates the original catalog/cache row',
        () {},
      );

      test(
        'revertOverride deletes the override row and returns void',
        () {},
      );
    },
  );
}
