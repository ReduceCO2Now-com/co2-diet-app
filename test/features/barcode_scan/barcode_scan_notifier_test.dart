import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'BarcodeScanNotifier',
    skip: 'BarcodeScanNotifier not yet implemented',
    () {
      test(
        'lookup chain — high confidence path returns FoodItem '
        'with co2e100g and confidenceBand high',
        () {},
      );

      test(
        'lookup chain — medium confidence path returns FoodItem '
        'with confidenceBand medium',
        () {},
      );

      test(
        'lookup chain — no-match path returns null',
        () {},
      );

      test(
        'no-match state is emitted when all three lookup steps return null',
        () {},
      );
    },
  );
}
