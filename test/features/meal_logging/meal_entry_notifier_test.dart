import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'MealEntryNotifier',
    skip: 'MealEntryNotifier not yet implemented',
    () {
      test(
        'build() returns entries for today grouped implicitly by logging '
        'them with slots',
        () {},
      );

      test(
        'logFood merges into an existing same-slot/same-day/same-unit '
        'entry',
        () {},
      );

      test(
        'editEntry updates slot/quantity/unit and recomputes snapshot '
        'scaling only (not the stored snapshot values)',
        () {},
      );

      test(
        'deleteEntry soft-deletes; undoDelete restores the exact prior '
        'entry',
        () {},
      );

      test(
        'duplicateEntry creates a new row bypassing merge',
        () {},
      );
    },
  );
}
