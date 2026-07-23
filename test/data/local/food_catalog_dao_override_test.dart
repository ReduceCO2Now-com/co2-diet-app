// Tests for FoodCatalogDao override precedence (LOG-11, Plan 04-06).
//
// A personal override in UserFoodTable must take precedence over the
// catalog/cache row it overrides for both searchLocalFoods and
// lookupByBarcodeWithCo2 — without touching the original row.
//
// off_ref ATTACH is not required for these tests: the override check
// (Step 0 in lookupByBarcodeWithCo2, post-merge overlay in
// searchLocalFoods) runs independent of off_ref ATTACH state — overrides
// live entirely in co2diet.sqlite (UserFoodTable). Tests exercise the
// off_ref-sourced override case by setting overrideOfSource: 'off_ref'
// even though off_ref itself is not attached in this in-memory DB — this
// still proves Step 0 fires before the offRefPath null-check.

import 'package:co2diet/data/local/app_database.dart';
import 'package:co2diet/data/local/daos/food_catalog_dao.dart';
import 'package:co2diet/data/local/daos/user_food_dao.dart';
// isNotNull/isNull are defined in both drift and flutter_test — hide the
// drift ones so the matcher package's versions are used.
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late UserFoodDao userFoodDao;
  late FoodCatalogDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    userFoodDao = UserFoodDao(db);
    dao = FoodCatalogDao(db, userFoodDao: userFoodDao);
  });

  tearDown(() async {
    await db.close();
  });

  var idCounter = 0;

  /// Inserts a row into `user_food_cache_table` + its FTS5 index entry.
  Future<String> insertCacheRow({
    String? barcode,
    required String productName,
    double? calories100g,
  }) async {
    idCounter += 1;
    final id = 'cache-$idCounter';
    final rowid = await db
        .into(db.userFoodCacheTable)
        .insertOnConflictUpdate(
          UserFoodCacheTableCompanion.insert(
            id: id,
            productName: productName,
            barcode: Value(barcode),
            calories100g: Value(calories100g),
            hlcMillis: BigInt.from(1000),
            hlcCounter: 0,
            hlcNodeId: 'test-node',
          ),
        );
    await db.customStatement(
      'INSERT OR REPLACE INTO user_food_cache_fts'
      ' (rowid, product_name, product_name_en, brand)'
      ' VALUES (?, ?, ?, ?)',
      [rowid, productName, null, null],
    );
    return id;
  }

  /// Inserts a personal override row via [UserFoodDao.insert].
  Future<UserFoodRow> insertOverride({
    required String overrideOfRef,
    required String overrideOfSource,
    required String name,
    required double calories,
  }) {
    idCounter += 1;
    return userFoodDao.insert(
      UserFoodTableCompanion(
        id: Value('override-$idCounter'),
        hlcMillis: Value(BigInt.from(1000)),
        hlcCounter: const Value(0),
        hlcNodeId: const Value('test-node'),
        name: Value(name),
        calories: Value(calories),
        quickServingSizes: const Value([]),
        overrideOfRef: Value(overrideOfRef),
        overrideOfSource: Value(overrideOfSource),
      ),
    );
  }

  group('FoodCatalogDao.searchLocalFoods override precedence', () {
    test(
      'returns only the override row when a user_food_cache row has a '
      'personal override — never both',
      () async {
        await insertCacheRow(
          barcode: 'X123',
          productName: 'Cache Product',
          calories100g: 100,
        );
        final override = await insertOverride(
          overrideOfRef: 'X123',
          overrideOfSource: 'user_food_cache',
          name: 'Override Product',
          calories: 50,
        );

        final results = await dao.searchLocalFoods('Cache');

        expect(results, hasLength(1));
        expect(results.single.productName, equals('Override Product'));
        expect(results.single.source, equals('user_foods'));
        expect(results.single.sourceRowId, equals(override.id));
        expect(
          results.any((item) => item.productName == 'Cache Product'),
          isFalse,
        );
      },
    );

    test(
      'user_food_cache row with a null barcode is returned with '
      'source=user_food_cache and sourceRowId set to its own id',
      () async {
        final cacheId = await insertCacheRow(
          productName: 'No Barcode Product',
        );

        final results = await dao.searchLocalFoods('Barcode');

        expect(results, hasLength(1));
        expect(results.single.barcode, isNull);
        expect(results.single.source, equals('user_food_cache'));
        expect(results.single.sourceRowId, equals(cacheId));
      },
    );

    test(
      'a cache row with no override is returned unmodified with '
      'source=user_food_cache',
      () async {
        final cacheId = await insertCacheRow(
          barcode: 'X999',
          productName: 'Unmodified Product',
          calories100g: 42,
        );

        final results = await dao.searchLocalFoods('Unmodified');

        expect(results, hasLength(1));
        expect(results.single.productName, equals('Unmodified Product'));
        expect(results.single.source, equals('user_food_cache'));
        expect(results.single.sourceRowId, equals(cacheId));
      },
    );
  });

  group('FoodCatalogDao.lookupByBarcodeWithCo2 override precedence', () {
    test(
      'resolves to the override when a barcode-keyed off_ref override '
      'exists — fires before the offRefPath ATTACH check',
      () async {
        final override = await insertOverride(
          overrideOfRef: 'Y999',
          overrideOfSource: 'off_ref',
          name: 'Override From Off Ref',
          calories: 80,
        );

        final result = await dao.lookupByBarcodeWithCo2('Y999');

        expect(result, isNotNull);
        expect(result!.productName, equals('Override From Off Ref'));
        expect(result.source, equals('user_foods'));
        expect(result.sourceRowId, equals(override.id));
      },
    );

    test(
      'returns null when no override exists and offRefPath is null '
      '(behaves exactly as before this plan)',
      () async {
        final result = await dao.lookupByBarcodeWithCo2('unmatched-barcode');
        expect(result, isNull);
      },
    );

    test(
      'after the override is reverted, the override no longer intercepts '
      'the lookup (original catalog data resolution resumes)',
      () async {
        final override = await insertOverride(
          overrideOfRef: 'Z111',
          overrideOfSource: 'off_ref',
          name: 'Override To Revert',
          calories: 60,
        );

        final beforeRevert = await dao.lookupByBarcodeWithCo2('Z111');
        expect(beforeRevert, isNotNull);
        expect(beforeRevert!.productName, equals('Override To Revert'));

        await userFoodDao.revert(override.id);

        // No off_ref ATTACH in this in-memory DB, so with the override
        // gone the lookup chain falls through to the off_ref query steps,
        // which return null here (no ATTACH) — proving the override no
        // longer shadows the (would-be) original catalog row.
        final afterRevert = await dao.lookupByBarcodeWithCo2('Z111');
        expect(afterRevert, isNull);
      },
    );
  });
}
