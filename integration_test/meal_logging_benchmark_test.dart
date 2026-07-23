// LOG-13 meal logging speed benchmark integration test.
//
// Asserts that tapping "Add Breakfast" through to a saved+visible entry
// on the dashboard completes in under 10 seconds.
//
// This test self-skips until the meal logging flow is fully wired
// (Plan 04-09 onward).
//
// Run on physical device:
//   flutter test integration_test/meal_logging_benchmark_test.dart
//       --device-id <id>

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'LOG-13: tap "Add Breakfast" to saved+visible on dashboard completes '
    'in under 10s',
    (tester) async {
      markTestSkipped(
        'Meal logging benchmark: run after meal logging flow is fully '
        'wired (Plan 04-09 onward)',
      );
    },
  );
}
