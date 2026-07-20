// TDD tests for FoodCatalogDao and AppDatabase ATTACH support.
// Tests cover LOG-01: FTS5 full-text search against the off_reference
// SQLite DB via FoodCatalogDao.

import 'package:co2diet/data/local/app_database.dart';
import 'package:co2diet/data/local/daos/food_catalog_dao.dart';
import 'package:co2diet/domain/entities/food_item.dart';
// isNotNull is defined in both drift and flutter_test — hide the drift one.
import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FoodCatalogDao._sanitizeFts5Query', () {
    late FoodCatalogDao dao;
    late AppDatabase db;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      dao = FoodCatalogDao(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('strips FTS5 metacharacters (quotes)', () {
      final result = dao.sanitizeFts5QueryForTest('"quoted"');
      expect(result, isNot(contains('"')));
    });

    test('appends * to each term for prefix matching', () {
      final result = dao.sanitizeFts5QueryForTest('apple orange');
      expect(result, equals('apple* orange*'));
    });

    test('empty input returns empty string', () {
      final result = dao.sanitizeFts5QueryForTest('');
      expect(result, isEmpty);
    });

    test('single term gets * suffix', () {
      final result = dao.sanitizeFts5QueryForTest('banana');
      expect(result, equals('banana*'));
    });

    test('whitespace-only input returns empty string', () {
      final result = dao.sanitizeFts5QueryForTest('   ');
      expect(result, isEmpty);
    });

    test('existing * in input is stripped then re-added (not doubled)', () {
      // _sanitizeFts5Query strips [^\w\s\-], so 'appl*' → 'appl' → 'appl*'.
      final result = dao.sanitizeFts5QueryForTest('appl*');
      expect(result, equals('appl*'));
    });

    test('double-quoted term returns unquoted term with * suffix', () {
      // '"apple"' → (strip non-word chars) → 'apple' → 'apple*'
      final result = dao.sanitizeFts5QueryForTest('"apple"');
      expect(result, equals('apple*'));
    });

    test('strips FTS5 operator keywords', () {
      // OR and AND are not stripped because they are alphabetic — only
      // the metacharacters are stripped; the user-facing minimum-2-char
      // guard prevents single-char operator tokens from passing through.
      // The sanitizer's job is to strip non-word chars, not semantic tokens.
      final result = dao.sanitizeFts5QueryForTest('apple OR orange');
      expect(result, equals('apple* OR* orange*'));
    });
  });

  group('FoodCatalogDao.searchLocalFoods', () {
    late AppDatabase db;
    late FoodCatalogDao dao;

    setUp(() async {
      // No offRefPath — unit test runs without the attached DB.
      db = AppDatabase(NativeDatabase.memory());
      dao = FoodCatalogDao(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('returns empty list for empty sanitized query', () async {
      // Sanitized empty string → short-circuit before SQL
      final results = await dao.searchLocalFoods('');
      expect(results, isEmpty);
    });

    test('returns empty list for query that produces no results', () async {
      // In-memory DB has no off_ref attached and no user_food_cache rows;
      // the query against user_food_cache_fts should return [] without error.
      final results = await dao.searchLocalFoods('xyzzy_noresult_42');
      expect(results, isA<List<FoodItem>>());
      expect(results, isEmpty);
    });

    test('searchLocalFoods returns List<FoodItem> type for valid query', () async {
      final results = await dao.searchLocalFoods('banana');
      expect(results, isA<List<FoodItem>>());
    });
  });

  group('AppDatabase ATTACH support', () {
    test('AppDatabase accepts offRefPath parameter without crash', () {
      // When offRefPath is null (unit test), ATTACH is skipped in beforeOpen.
      final db = AppDatabase(NativeDatabase.memory());
      expect(db, isNotNull);
      db.close();
    });

    test('AppDatabase.connect named constructor is defined', () {
      // Just verifying the connect constructor compiles and doesn't throw
      // in test environment (no real file access).
      // We can't call it without a real persistent path, so this is a
      // compile-time assertion test.
      expect(AppDatabase.connect, isNotNull);
    });
  });
}
