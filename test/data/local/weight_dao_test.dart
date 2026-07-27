import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'WeightDao',
    skip: 'WeightDao not yet implemented',
    () {
      test(
        'logWeight inserts a new WeightEntryRow; getEntriesInRange '
        'filters by [from, to] inclusive',
        () {},
      );

      test(
        'getSettings/saveSettings round-trip the target weight, '
        'target date, and reminder fields',
        () {},
      );
    },
  );
}
