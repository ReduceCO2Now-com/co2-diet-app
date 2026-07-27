import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'TrendSparkline',
    skip: 'TrendSparkline not yet implemented',
    () {
      testWidgets(
        'segmented control switches which metric (CO2/Calories/'
        'Protein) the 7-day sparkline plots',
        (tester) async {},
      );

      testWidgets(
        'tapping the chart opens Data Analysis pre-set to the '
        'currently selected metric',
        (tester) async {},
      );
    },
  );
}
