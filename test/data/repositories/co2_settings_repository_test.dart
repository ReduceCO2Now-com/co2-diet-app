import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'Co2SettingsRepository',
    skip: 'Co2SettingsRepository not yet implemented',
    () {
      test(
        'getSettings returns a default all-unset Co2Settings when no '
        'row has ever been saved',
        () {},
      );

      test(
        'saveSettings never rewrites any already-logged MealEntry '
        '(forward-only, no retroactive recalculation)',
        () {},
      );
    },
  );
}
