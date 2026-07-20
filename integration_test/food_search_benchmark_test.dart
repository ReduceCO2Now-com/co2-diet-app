// Wave 0 stub — FoodSearch benchmark integration tests.
//
// These tests cover LOG-01 timing constraints and NFR-06a hit-rate:
//   BM-01: worst-case 2-char query "mi" must complete in <1s
//   BM-02: full-word query "banana" must complete in <1s
//   BM-03: no-result query "xyzzy_noresult_42" must complete in <1s
//
// All three tests self-skip when off_reference.sqlite is absent (dbReady
// guard). Set dbReady = true and wire the production FoodCatalogRepository
// in Plan 02-03 / Plan 02-05 to activate the real timing assertions.

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Change to true and wire FoodCatalogRepository once off_reference.sqlite
  // is bundled (Plan 02-05 asset bundling task).
  const dbReady = false;

  testWidgets(
    'BM-01: 2-char worst-case query "mi" completes in <1s',
    (tester) async {
      if (!dbReady) {
        markTestSkipped(
          'off_reference.sqlite not yet bundled — Wave 0 stub',
        );
        return;
      }

      // Production implementation template (uncomment when dbReady = true):
      //
      // final repo = FoodCatalogRepository(/* inject DAO + API client */);
      // final sw = Stopwatch()..start();
      // final results = await repo.searchLocal('mi');
      // sw.stop();
      // expect(sw.elapsedMilliseconds, lessThan(1000),
      //     reason: 'BM-01: query "mi" must complete in <1s');
      // expect(results, isA<List>(),
      //     reason: 'BM-01: result must be a list (may be empty)');
    },
  );

  testWidgets(
    'BM-02: full-word query "banana" completes in <1s',
    (tester) async {
      if (!dbReady) {
        markTestSkipped(
          'off_reference.sqlite not yet bundled — Wave 0 stub',
        );
        return;
      }

      // Production implementation template (uncomment when dbReady = true):
      //
      // final repo = FoodCatalogRepository(/* inject DAO + API client */);
      // final sw = Stopwatch()..start();
      // final results = await repo.searchLocal('banana');
      // sw.stop();
      // expect(sw.elapsedMilliseconds, lessThan(1000),
      //     reason: 'BM-02: query "banana" must complete in <1s');
      // expect(results.isNotEmpty, isTrue,
      //     reason: 'BM-02: "banana" should return at least one result');
    },
  );

  testWidgets(
    'BM-03: no-result query "xyzzy_noresult_42" completes in <1s',
    (tester) async {
      if (!dbReady) {
        markTestSkipped(
          'off_reference.sqlite not yet bundled — Wave 0 stub',
        );
        return;
      }

      // Production implementation template (uncomment when dbReady = true):
      //
      // final repo = FoodCatalogRepository(/* inject DAO + API client */);
      // final sw = Stopwatch()..start();
      // final results = await repo.searchLocal('xyzzy_noresult_42');
      // sw.stop();
      // expect(sw.elapsedMilliseconds, lessThan(1000),
      //     reason: 'BM-03: no-match query must still complete in <1s');
      // expect(results.isEmpty, isTrue,
      //     reason: 'BM-03: non-existent term must return empty list');
    },
  );
}
