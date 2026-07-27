// Tests FoodCatalogDao.searchLocalFoods' nutrition-data-completeness ranking
// boost: results with a non-null calories_100g must outrank results without
// one, regardless of raw BM25 relevance — see the doc comment on
// searchLocalFoods in food_catalog_dao.dart.
//
// Builds a real, minimal off_ref.sqlite fixture on disk (same schema as
// tools/ingest_off.py's DDL) and ATTACHes it via a real AppDatabase, rather
// than mocking — the boost is expressed entirely in the raw SQL's ORDER BY,
// so only a real SQLite/FTS5 query can prove it works.

import 'dart:io';

import 'package:co2diet/data/local/app_database.dart';
import 'package:co2diet/data/local/daos/food_catalog_dao.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as sqlite3;

/// Creates a temp off_ref.sqlite fixture with the real ingest schema
/// (tools/ingest_off.py's DDL, plus `primary_category_tag` and the two CO2
/// tables `lookupByBarcodeWithCo2`/`searchLocalFoods` join against) and the
/// given rows, returning its path.
String _buildOffRefFixture(
  Directory dir,
  List<_Product> products, {
  List<_Co2Override> overrides = const [],
  List<_Co2Factor> factors = const [],
}) {
  final path = p.join(dir.path, 'off_reference_fixture.sqlite');
  final db = sqlite3.sqlite3.open(path);
  db.execute('''
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

  final insertProduct = db.prepare('''
    INSERT INTO products
      (barcode, product_name, product_name_en, brand, calories_100g,
       primary_category_tag)
    VALUES (?, ?, ?, ?, ?, ?)
  ''');
  final insertFts = db.prepare('''
    INSERT INTO products_fts(rowid, product_name, product_name_en, brand)
    VALUES (?, ?, ?, ?)
  ''');

  for (final product in products) {
    insertProduct.execute([
      product.barcode,
      product.name,
      null,
      product.brand,
      product.calories100g,
      product.categoryTag,
    ]);
    final rowid = db.lastInsertRowId;
    insertFts.execute([rowid, product.name, null, product.brand]);
  }

  final insertOverride = db.prepare(
    'INSERT INTO food_co2_overrides (barcode, co2e_100g) VALUES (?, ?)',
  );
  for (final override in overrides) {
    insertOverride.execute([override.barcode, override.co2e100g]);
  }

  final insertFactor = db.prepare(
    'INSERT INTO co2_factors (categories_tag, co2e_median) VALUES (?, ?)',
  );
  for (final factor in factors) {
    insertFactor.execute([factor.categoryTag, factor.co2eMedian]);
  }

  insertProduct.close();
  insertFts.close();
  insertOverride.close();
  insertFactor.close();
  db.close();
  return path;
}

class _Product {
  const _Product(
    this.barcode,
    this.name,
    this.brand,
    this.calories100g, {
    this.categoryTag,
  });

  final String barcode;
  final String name;
  final String brand;
  final double? calories100g;
  final String? categoryTag;
}

class _Co2Override {
  const _Co2Override(this.barcode, this.co2e100g);

  final String barcode;
  final double co2e100g;
}

class _Co2Factor {
  const _Co2Factor(this.categoryTag, this.co2eMedian);

  final String categoryTag;
  final double co2eMedian;
}

void main() {
  late Directory tempDir;
  late AppDatabase db;
  late FoodCatalogDao dao;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('off_ref_ranking_test');
  });

  tearDown(() async {
    await db.close();
    await tempDir.delete(recursive: true);
  });

  test(
    'a short exact-name match with no nutrition data does not outrank a '
    'longer match that has nutrition data',
    () async {
      // "Milk" is a short, exact product_name match for query "milk" — BM25
      // alone ranks a short exact match very highly. Without the
      // completeness boost, this would sit above "Milk Chocolate Bar", even
      // though the latter has real nutrition data and the former doesn't.
      final offRefPath = _buildOffRefFixture(tempDir, const [
        _Product('1111111111111', 'Milk', 'GenericBrand', null),
        _Product(
          '2222222222222',
          'Milk Chocolate Bar',
          'SomeChocolateCo',
          540,
        ),
      ]);

      db = AppDatabase(NativeDatabase.memory(), offRefPath: offRefPath);
      dao = FoodCatalogDao(db);

      final results = await dao.searchLocalFoods('milk');

      expect(results, hasLength(2));
      expect(
        results.first.calories100g,
        isNotNull,
        reason:
            'the data-complete result ("Milk Chocolate Bar") should be '
            'first despite "Milk" being the closer BM25 match',
      );
      expect(results.first.productName, 'Milk Chocolate Bar');
      expect(results.last.productName, 'Milk');
      expect(results.last.calories100g, isNull);
    },
  );

  test(
    'BM25 relevance is still the tie-break within each completeness tier',
    () async {
      // Two data-complete products: "Milk" (shorter/more exact) should still
      // rank above "Whole Milk Beverage Extra" within the complete tier.
      final offRefPath = _buildOffRefFixture(tempDir, const [
        _Product('3333333333333', 'Whole Milk Beverage Extra', 'Brand', 60),
        _Product('4444444444444', 'Milk', 'Brand', 42),
        // A data-empty distractor that must sort after both complete ones.
        _Product('5555555555555', 'Milkshake Mix', 'Brand', null),
      ]);

      db = AppDatabase(NativeDatabase.memory(), offRefPath: offRefPath);
      dao = FoodCatalogDao(db);

      final results = await dao.searchLocalFoods('milk');

      expect(results, hasLength(3));
      expect(results[0].calories100g, isNotNull);
      expect(results[1].calories100g, isNotNull);
      expect(
        results[2].calories100g,
        isNull,
        reason: 'the data-empty result must sort last regardless of BM25',
      );
      expect(
        results[0].productName,
        'Milk',
        reason: 'within the complete tier, the closer BM25 match still wins',
      );
    },
  );

  group('CO2 enrichment (mirrors lookupByBarcodeWithCo2)', () {
    test(
      'a product with a direct food_co2_overrides barcode match gets '
      'co2e100g + "high" confidence from search, same as a barcode scan '
      'would return',
      () async {
        final offRefPath = _buildOffRefFixture(
          tempDir,
          const [_Product('1111111111111', 'Milk', 'Brand', 50)],
          overrides: const [_Co2Override('1111111111111', 3.2)],
        );

        db = AppDatabase(NativeDatabase.memory(), offRefPath: offRefPath);
        dao = FoodCatalogDao(db);

        final results = await dao.searchLocalFoods('milk');

        expect(results, hasLength(1));
        expect(results.first.co2e100g, 3.2);
        expect(results.first.confidenceBand, 'high');
      },
    );

    test(
      'a product with no direct override but a category match in '
      'co2_factors gets co2e100g + "medium" confidence from search',
      () async {
        final offRefPath = _buildOffRefFixture(
          tempDir,
          const [
            _Product(
              '2222222222222',
              'Milk',
              'Brand',
              50,
              categoryTag: 'en:milks',
            ),
          ],
          factors: const [_Co2Factor('en:milks', 1.1)],
        );

        db = AppDatabase(NativeDatabase.memory(), offRefPath: offRefPath);
        dao = FoodCatalogDao(db);

        final results = await dao.searchLocalFoods('milk');

        expect(results, hasLength(1));
        expect(results.first.co2e100g, 1.1);
        expect(results.first.confidenceBand, 'medium');
      },
    );

    test(
      'a direct override takes precedence over a category match when both '
      'exist for the same product',
      () async {
        final offRefPath = _buildOffRefFixture(
          tempDir,
          const [
            _Product(
              '3333333333333',
              'Milk',
              'Brand',
              50,
              categoryTag: 'en:milks',
            ),
          ],
          overrides: const [_Co2Override('3333333333333', 3.2)],
          factors: const [_Co2Factor('en:milks', 1.1)],
        );

        db = AppDatabase(NativeDatabase.memory(), offRefPath: offRefPath);
        dao = FoodCatalogDao(db);

        final results = await dao.searchLocalFoods('milk');

        expect(results.first.co2e100g, 3.2);
        expect(results.first.confidenceBand, 'high');
      },
    );

    test(
      'a product with neither an override nor a category match has null '
      'co2e100g and null confidenceBand (not a false zero)',
      () async {
        final offRefPath = _buildOffRefFixture(tempDir, const [
          _Product('4444444444444', 'Milk', 'Brand', 50),
        ]);

        db = AppDatabase(NativeDatabase.memory(), offRefPath: offRefPath);
        dao = FoodCatalogDao(db);

        final results = await dao.searchLocalFoods('milk');

        expect(results.first.co2e100g, isNull);
        expect(results.first.confidenceBand, isNull);
      },
    );
  });
}
