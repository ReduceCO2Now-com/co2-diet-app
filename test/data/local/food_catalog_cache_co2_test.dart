// Tests the Phase 4 CO2 cache-path gap fix (05-02): a product cached via the
// OFF API fallback (user_food_cache_table/user_food_cache_fts) must show a
// CO2 estimate on a later offline local search when its stored categoriesTags
// value has a co2_factors match.
//
// Builds a real, minimal off_ref.sqlite fixture on disk (same schema as
// tools/ingest_off.py's DDL, following food_catalog_dao_ranking_test.dart's
// existing fixture-building pattern) and ATTACHes it via a real AppDatabase.
// Cache rows are inserted directly via Drift's Companion pattern (the same
// shape FoodCatalogRepository.lookupByBarcode/.searchAndCache use), rather
// than exercising the repository's network path.

import 'dart:io';

import 'package:co2diet/data/local/app_database.dart';
import 'package:co2diet/data/local/daos/food_catalog_dao.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as sqlite3;

/// Creates a temp off_ref.sqlite fixture with just the co2_factors table
/// this test needs (the user_food_cache_fts branch never touches
/// off_ref.products/products_fts/food_co2_overrides).
String _buildOffRefFixture(
  Directory dir, {
  List<_Co2Factor> factors = const [],
}) {
  final path = p.join(dir.path, 'off_reference_fixture.sqlite');
  final db = sqlite3.sqlite3.open(path)
    ..execute('''
    CREATE TABLE products (
      barcode               TEXT PRIMARY KEY,
      product_name          TEXT NOT NULL,
      product_name_en       TEXT,
      brand                 TEXT,
      calories_100g         REAL,
      protein_100g          REAL,
      carbs_100g            REAL,
      fat_100g               REAL,
      categories_tags       TEXT,
      primary_category_tag  TEXT
    );
    CREATE VIRTUAL TABLE products_fts USING fts5(
      product_name,
      product_name_en,
      brand,
      content='products',
      content_rowid='rowid',
      tokenize='unicode61 remove_diacritics 2',
      prefix='2 3 4'
    );
    CREATE TABLE food_co2_overrides (
      barcode    TEXT PRIMARY KEY,
      co2e_100g  REAL NOT NULL
    );
    CREATE TABLE co2_factors (
      categories_tag  TEXT PRIMARY KEY,
      co2e_median     REAL NOT NULL
    );
  ''');

  final insertFactor = db.prepare(
    'INSERT INTO co2_factors (categories_tag, co2e_median) VALUES (?, ?)',
  );
  for (final factor in factors) {
    insertFactor.execute([factor.categoryTag, factor.co2eMedian]);
  }
  insertFactor.close();
  db.close();
  return path;
}

class _Co2Factor {
  const _Co2Factor(this.categoryTag, this.co2eMedian);

  final String categoryTag;
  final double co2eMedian;
}

/// Inserts a row directly into user_food_cache_table + user_food_cache_fts,
/// mirroring the exact Companion shape FoodCatalogRepository's cache-write
/// call sites use (categoriesTags: Value(tag) instead of Value(null)).
Future<void> _insertCachedProduct(
  AppDatabase db, {
  required String productName,
  String? barcode,
  double? calories100g,
  String? categoriesTags,
}) async {
  final rowid = await db
      .into(db.userFoodCacheTable)
      .insertOnConflictUpdate(
        UserFoodCacheTableCompanion.insert(
          id: 'test-${productName.hashCode}',
          productName: productName,
          barcode: Value(barcode),
          calories100g: Value(calories100g),
          categoriesTags: Value(categoriesTags),
          hlcMillis: BigInt.from(DateTime.now().millisecondsSinceEpoch),
          hlcCounter: 0,
          hlcNodeId: 'local',
          dirty: const Value(true),
        ),
      );

  await db.customStatement(
    'INSERT OR REPLACE INTO user_food_cache_fts'
    ' (rowid, product_name, product_name_en, brand)'
    ' VALUES (?, ?, ?, ?)',
    [rowid, productName, null, null],
  );
}

void main() {
  late Directory tempDir;
  late AppDatabase db;
  late FoodCatalogDao dao;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('cache_co2_test');
  });

  tearDown(() async {
    await db.close();
    await tempDir.delete(recursive: true);
  });

  group('FoodCatalogDao user_food_cache_fts CO2 enrichment', () {
    test(
      'a cached product whose categoriesTags matches a co2_factors row '
      'gets a populated co2e100g + "medium" confidenceBand from search',
      () async {
        final offRefPath = _buildOffRefFixture(
          tempDir,
          factors: const [_Co2Factor('en:milks', 1.1)],
        );
        db = AppDatabase(NativeDatabase.memory(), offRefPath: offRefPath);
        dao = FoodCatalogDao(db);

        await _insertCachedProduct(
          db,
          productName: 'Cached Milk',
          barcode: '9999999999999',
          calories100g: 60,
          categoriesTags: 'en:milks',
        );

        final results = await dao.searchLocalFoods('cached milk');

        expect(results, hasLength(1));
        expect(results.first.co2e100g, 1.1);
        expect(results.first.confidenceBand, 'medium');
        expect(results.first.source, 'user_food_cache');
      },
    );

    test(
      'a cached product with no categoriesTags match has null co2e100g '
      'and null confidenceBand (not a false zero)',
      () async {
        final offRefPath = _buildOffRefFixture(
          tempDir,
          factors: const [_Co2Factor('en:milks', 1.1)],
        );
        db = AppDatabase(NativeDatabase.memory(), offRefPath: offRefPath);
        dao = FoodCatalogDao(db);

        await _insertCachedProduct(
          db,
          productName: 'Cached Mystery Snack',
          barcode: '8888888888888',
          calories100g: 200,
          // categoriesTags intentionally omitted (defaults to null) — no
          // category to join against, so no co2_factors match is expected.
        );

        final results = await dao.searchLocalFoods('mystery snack');

        expect(results, hasLength(1));
        expect(results.first.co2e100g, isNull);
        expect(results.first.confidenceBand, isNull);
      },
    );

    test(
      'without an ATTACHed off_ref (unit-test isolation), cached results '
      'still return plain null CO2 columns instead of erroring',
      () async {
        db = AppDatabase(NativeDatabase.memory());
        dao = FoodCatalogDao(db);

        await _insertCachedProduct(
          db,
          productName: 'Cached No Attach',
          barcode: '7777777777777',
          calories100g: 100,
          categoriesTags: 'en:milks',
        );

        final results = await dao.searchLocalFoods('cached no attach');

        expect(results, hasLength(1));
        expect(results.first.co2e100g, isNull);
        expect(results.first.confidenceBand, isNull);
      },
    );
  });
}
