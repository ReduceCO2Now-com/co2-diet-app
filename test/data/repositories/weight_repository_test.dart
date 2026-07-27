import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'WeightRepository',
    skip: 'WeightRepository not yet implemented',
    () {
      test(
        'logWeight persists a new entry; getEntriesInRange(range) '
        'supports 7d/30d/90d/1yr/all',
        () {},
      );

      test(
        'saveGoal persists targetWeightKg + targetDate independently '
        'of reminder settings',
        () {},
      );
    },
  );
}
