import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'MealEntryRepository',
    skip: 'MealEntryRepository not yet implemented',
    () {
      test(
        'logOrMerge captures a macro/CO2 snapshot at write time, not a '
        'live reference',
        () {},
      );

      test(
        'undoMergeDelta subtracts only the just-added delta, preserving '
        'pre-merge quantity',
        () {},
      );

      test(
        'duplicateEntry always creates a new row, bypassing merge even '
        'when merge criteria match',
        () {},
      );

      test(
        'softDelete + restoreEntry round-trips a deleted entry back to '
        'its prior state (Undo)',
        () {},
      );
    },
  );
}
