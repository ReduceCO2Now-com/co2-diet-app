import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'MealEntry nutrient snapshot',
    skip: 'sugar/fiber/salt snapshot fields not yet added',
    () {
      test(
        'scaled() returns sugar/fiber/salt scaled the same way as '
        'calories/protein/carbs/fat',
        () {},
      );

      test(
        'scaled() returns null sugar/fiber/salt when the source '
        'snapshot is null (off_ref-sourced entries have no such data)',
        () {},
      );

      test(
        'copyWith sentinel pattern covers the three new nullable '
        'fields',
        () {},
      );
    },
  );
}
