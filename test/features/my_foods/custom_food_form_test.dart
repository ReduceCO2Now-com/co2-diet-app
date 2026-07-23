import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'CustomFoodFormScreen',
    skip: 'CustomFoodFormScreen not yet implemented',
    () {
      testWidgets(
        'Save button disabled until name and calories are provided',
        (tester) async {},
      );

      testWidgets(
        'adding a quick serving size row appends a label+grams field pair',
        (tester) async {},
      );

      testWidgets(
        'manual CO2 entry shows "user-provided" label and no '
        'ConfidenceChip',
        (tester) async {},
      );

      testWidgets(
        'Revert to original button is shown only when editing an '
        'override',
        (tester) async {},
      );
    },
  );
}
