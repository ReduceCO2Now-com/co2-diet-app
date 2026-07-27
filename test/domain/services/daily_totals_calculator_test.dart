import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'DailyTotalsCalculator',
    skip: 'DailyTotalsCalculator not yet implemented',
    () {
      test(
        "sums calories/protein/carbs/fat across today's "
        'weight-based-unit entries',
        () {},
      );

      test(
        'sugar/fiber/sodium totals are null when zero logged entries '
        'have that nutrient snapshot (no false precision)',
        () {},
      );

      test(
        'sugar/fiber/sodium totals sum only entries that have a '
        'non-null snapshot; entries with null snapshot are skipped, '
        'not treated as zero',
        () {},
      );

      test(
        'applies the personal CO2 multiplier only to the aggregate '
        'total, never per-entry',
        () {},
      );

      test(
        'piece/cup/portion-unit entries are excluded from every '
        'numeric total (documented limitation, matches '
        'MealEntryRow/RecentRow precedent)',
        () {},
      );

      test(
        'macro split (protein/carbs/fat) percentages sum to ~100% '
        'when all three are non-null',
        () {},
      );

      test(
        'computing over a pooled trailing-7-day entry list yields an '
        "explicit weekly total distinct from a single day's total",
        () {},
      );
    },
  );
}
