// NFR-06(b) CO₂ coverage benchmark integration test.
//
// Asserts that ≥90% of products in off_reference.sqlite have a CO₂e estimate
// (i.e., have a primary_category_tag from the category-median mapping OR a
// direct barcode override in food_co2_overrides).
//
// Run on physical Android device:
//   flutter test integration_test/co2_coverage_benchmark_test.dart
//       --device-id <id>
//
// The test self-skips when off_reference.sqlite is absent (ensureOffReferenceDb
// throws StateError with 'assets/off_reference.sqlite.gz not found').

import 'package:co2diet/core/assets/first_launch_extractor.dart';
import 'package:co2diet/data/local/app_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  AppDatabase? db;

  setUpAll(() async {
    late String offRefPath;
    try {
      offRefPath = await ensureOffReferenceDb();
    } on Object {
      // ensureOffReferenceDb throws StateError (an Error, not Exception)
      // when the asset is absent. db stays null → test self-skips.
      return;
    }
    db = AppDatabase.connect(offRefPath: offRefPath);
  });

  tearDownAll(() async {
    await db?.close();
    db = null;
  });

  testWidgets(
    'NFR-06(b): ≥90% of products in off_reference.sqlite have a CO₂e estimate',
    (tester) async {
      if (db == null) {
        markTestSkipped(
          'off_reference.sqlite not available — run tools/ingest_off.py first',
        );
        return;
      }

      try {
        // Count products with CO₂ coverage:
        // - primary_category_tag IS NOT NULL → category-median mapping available
        // - OR barcode in food_co2_overrides → direct product-specific override
        final coveredRow = await db!
            .customSelect('''
              SELECT COUNT(*) AS n FROM off_ref.products
              WHERE primary_category_tag IS NOT NULL
                 OR barcode IN (SELECT barcode FROM off_ref.food_co2_overrides)
            ''')
            .getSingleOrNull();
        final coveredCount = coveredRow?.read<int>('n') ?? 0;

        final totalRow = await db!
            .customSelect('SELECT COUNT(*) AS n FROM off_ref.products')
            .getSingleOrNull();
        final totalCount = totalRow?.read<int>('n') ?? 0;

        final coverage =
            totalCount > 0 ? coveredCount / totalCount : 0.0;

        debugPrint(
          'CO₂ coverage: ${(coverage * 100).toStringAsFixed(1)}% '
          '($coveredCount / $totalCount products)',
        );

        expect(
          coverage,
          greaterThanOrEqualTo(0.90),
          reason:
              'NFR-06(b): ≥90% of products must have a CO₂e estimate. '
              'Got ${(coverage * 100).toStringAsFixed(1)}% '
              '($coveredCount/$totalCount). '
              'Check ingest pipeline and category mapping completeness.',
        );
      } on Exception catch (e) {
        fail('CO₂ coverage benchmark failed with exception: $e');
      }
    },
  );
}
