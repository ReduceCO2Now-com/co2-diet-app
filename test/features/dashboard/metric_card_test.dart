import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'MetricCard',
    skip: 'MetricCard not yet implemented',
    () {
      testWidgets(
        'renders value vs target with the goal-matching metric '
        'ordered/sized first',
        (tester) async {},
      );

      testWidgets(
        'shows the mode indicator text for Local vs Account mode',
        (tester) async {},
      );

      testWidgets(
        'quick-log buttons push /food-search?slot=<slot>; Quick Add '
        'pushes /food-search with no slot param',
        (tester) async {},
      );

      testWidgets(
        'CO2 profile prompt card renders only when data quality is '
        'basic and is dismissible',
        (tester) async {},
      );
    },
  );
}
