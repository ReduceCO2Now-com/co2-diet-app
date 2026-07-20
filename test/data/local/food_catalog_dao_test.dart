// Wave 0 stub — FoodCatalogDao tests.
//
// These tests cover LOG-01: FTS5 full-text search against the off_reference
// SQLite DB via the FoodCatalogDao. No production imports are used here
// because FoodCatalogDao does not yet exist (created in Plan 02-02).
//
// Each test body describes the intended assertion so implementors know
// exactly what to wire once the DAO is in place.

import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'FoodCatalogDao',
    skip: 'Wave 0 stub — FoodCatalogDao not yet implemented',
    () {
      test('searchLocalFoods returns FoodItem list for valid query', () {
        // Intent: given an in-memory FTS5-enabled DB seeded with sample rows,
        // FoodCatalogDao.searchLocalFoods('banana') should return a non-empty
        // List<FoodItem> where each item has a non-null productName.
        //
        // Wire-up: create AppDatabase(NativeDatabase.memory()), run schema +
        // seed, instantiate FoodCatalogDao, call searchLocalFoods('banana'),
        // assert result.isNotEmpty and result.first.productName == 'Banana'.
        fail('not implemented — remove skip when FoodCatalogDao exists');
      });

      test('searchLocalFoods returns empty list for no-match query', () {
        // Intent: querying with a string that matches nothing (e.g.
        // 'xyzzy_noresult_42') should return an empty list, not throw.
        //
        // Wire-up: same in-memory DB; call searchLocalFoods('xyzzy_noresult_42');
        // assert result.isEmpty.
        fail('not implemented — remove skip when FoodCatalogDao exists');
      });

      test('searchLocalFoods returns results from off_ref ATTACH alias', () {
        // Intent: FoodCatalogDao attaches off_reference.sqlite under the alias
        // 'off_ref'. A query targeting that schema should return rows from the
        // attached file, not only from the main co2diet.sqlite user-catalog.
        //
        // Wire-up: supply a real or mock path for off_reference.sqlite; verify
        // that FoodCatalogDao.searchLocalFoods queries the off_ref schema.
        fail('not implemented — remove skip when FoodCatalogDao exists');
      });
    },
  );
}
