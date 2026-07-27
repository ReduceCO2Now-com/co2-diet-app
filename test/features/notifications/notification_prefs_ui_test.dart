import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'Meal reminder settings section',
    skip: 'meal reminder settings UI not yet implemented',
    () {
      testWidgets(
        'each of the four meal slots has an independent enable '
        'toggle and time picker',
        (tester) async {},
      );

      testWidgets(
        'toggling a reminder on when permission is denied reverts '
        'the toggle and shows an Open Settings link',
        (tester) async {},
      );
    },
  );
}
