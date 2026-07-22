// Real benchmark integration tests for FoodSearch (replaces Wave 0 stubs).
//
// Tests cover LOG-01 timing constraints and NFR-06a hit-rate:
//   BM-01: worst-case 2-char query "mi" must complete in <1s
//   BM-02: full-word query "banana" must complete in <1s
//   BM-03: no-result query "xyzzy_noresult_42" must complete in <1s
//   NFR-06a: ≥90% of 20-term German/EU benchmark food list returns results
//
// All tests self-skip when off_reference.sqlite is absent (ensureOffReferenceDb
// throws StateError with 'assets/off_reference.sqlite.gz not found').
//
// Run on physical Android device:
//   flutter test integration_test/food_search_benchmark_test.dart
//       --device-id <id>

import 'package:co2diet/core/assets/first_launch_extractor.dart';
import 'package:co2diet/data/local/app_database.dart';
import 'package:co2diet/data/remote/off_api_client.dart';
import 'package:co2diet/data/repositories/food_catalog_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Shared across all tests — created once in setUpAll, closed in tearDownAll.
  // Creating one AppDatabase per test caused drift_flutter to reuse the same
  // native executor while spawning multiple Dart wrappers, triggering duplicate
  // ATTACH DATABASE calls that silently failed and produced empty results.
  AppDatabase? db;
  FoodCatalogRepository? repo;

  setUpAll(() async {
    late String offRefPath;
    try {
      offRefPath = await ensureOffReferenceDb();
    } on Object {
      // ensureOffReferenceDb throws StateError (an Error, not Exception)
      // when the asset is absent. repo stays null → all tests self-skip.
      return;
    }

    db = AppDatabase.connect(offRefPath: offRefPath);
    repo = FoodCatalogRepository(db!.foodCatalogDao, OffApiClient());

    // Diagnostic: confirm ATTACH succeeded and products_fts has data.
    // Output appears in `flutter test ... --verbose` and `adb logcat`.
    try {
      final countRow = await db!
          .customSelect('SELECT count(*) AS n FROM off_ref.products')
          .getSingleOrNull();
      final productCount = countRow?.read<int>('n') ?? -1;
      debugPrint('[BM-diag] off_ref.products row count: $productCount');

      final ftsRow = await db!
          .customSelect('SELECT count(*) AS n FROM off_ref.products_fts')
          .getSingleOrNull();
      final ftsCount = ftsRow?.read<int>('n') ?? -1;
      debugPrint('[BM-diag] off_ref.products_fts row count: $ftsCount');
    } on Object catch (e) {
      debugPrint('[BM-diag] ATTACH or table access failed: $e');
    }
  });

  tearDownAll(() async {
    await db?.close();
    db = null;
    repo = null;
  });

  const skipMsg =
      'off_reference.sqlite not available — run tools/ingest_off.py first';

  testWidgets(
    'BM-01: worst-case 2-char prefix query < 1s',
    (tester) async {
      if (repo == null) {
        markTestSkipped(skipMsg);
        return;
      }

      final sw = Stopwatch()..start();
      final results = await repo!.searchLocal('mi');
      sw.stop();

      expect(
        sw.elapsedMilliseconds,
        lessThan(1000),
        reason: 'BM-01: worst-case 2-char query must complete in <1s '
            '(was ${sw.elapsedMilliseconds}ms)',
      );
      expect(
        results,
        isNotEmpty,
        reason: '"mi" must return results in a DE-filtered OFF subset',
      );
    },
  );

  testWidgets(
    'BM-02: full-word query < 1s',
    (tester) async {
      if (repo == null) {
        markTestSkipped(skipMsg);
        return;
      }

      final sw = Stopwatch()..start();
      final results = await repo!.searchLocal('banana');
      sw.stop();

      expect(
        sw.elapsedMilliseconds,
        lessThan(1000),
        reason: 'BM-02: full-word query must complete in <1s '
            '(was ${sw.elapsedMilliseconds}ms)',
      );
      expect(
        results,
        isNotEmpty,
        reason: '"banana" should return at least one result',
      );
    },
  );

  testWidgets(
    'BM-03: no-local-result query completes in < 1s '
    '(measures local path only)',
    (tester) async {
      if (repo == null) {
        markTestSkipped(skipMsg);
        return;
      }

      final sw = Stopwatch()..start();
      final results = await repo!.searchLocal('xyzzy_noresult_42');
      sw.stop();

      expect(
        sw.elapsedMilliseconds,
        lessThan(1000),
        reason: 'BM-03: no-match query must still complete in <1s '
            '(was ${sw.elapsedMilliseconds}ms)',
      );
      expect(
        results,
        isEmpty,
        reason:
            '"xyzzy_noresult_42" must not match any entry in the local DB',
      );
    },
  );

  testWidgets(
    'NFR-06a hit-rate benchmark: ≥90% of 20 common foods found locally',
    (tester) async {
      if (repo == null) {
        markTestSkipped(skipMsg);
        return;
      }

      // 20 representative German/EU foods as proxy for the full 200-food list.
      // Full 200-food list is a manual pre-launch acceptance test; this
      // automated test is the CI-runnable proxy (NFR-06a partial coverage).
      const benchmarkFoods = [
        'Milch',
        'Butter',
        'Joghurt',
        'Käse',
        'Brot',
        'Banane',
        'Apfel',
        'Nudeln',
        'Reis',
        'Kartoffeln',
        'Huhn',
        'Rindfleisch',
        'Lachs',
        'Tofu',
        'Haferflocken',
        'Sonnenblumenöl',
        'Tomaten',
        'Gurke',
        'Ei',
        'Zucker',
      ];

      var hitCount = 0;
      for (final term in benchmarkFoods) {
        final results = await repo!.searchLocal(term);
        if (results.isNotEmpty) hitCount++;
      }

      final hitRate = hitCount / benchmarkFoods.length;
      expect(
        hitRate,
        greaterThanOrEqualTo(0.90),
        reason: 'NFR-06a: ≥90% hit rate required. '
            'Got $hitCount/${benchmarkFoods.length} '
            '(${(hitRate * 100).toStringAsFixed(1)}%)',
      );
    },
  );
}
