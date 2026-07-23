import 'package:co2diet/data/local/app_database.dart';
import 'package:co2diet/data/local/daos/user_food_dao.dart';
import 'package:co2diet/data/local/tables/user_food_cache_table.dart';
import 'package:co2diet/domain/entities/food_item.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

part 'food_catalog_dao.g.dart';

/// DAO for food catalog queries.
///
/// Performs a UNION ALL of two FTS5 sources:
/// 1. `off_ref.products_fts` — the bundled OFF reference DB (ATTACHed).
/// 2. `user_food_cache_fts` — API-cached results in co2diet.sqlite
///    (D-API-FALLBACK per CONTEXT.md: "Cached results indexed: FTS5 table
///    in co2diet.sqlite indexes cached items — they appear in future local
///    searches without re-hitting the API").
///
/// T-02-03-01 mitigation: [_sanitizeFts5Query] strips all FTS5 metacharacters
/// before building the MATCH expression; query is parameterized via
/// Variable.withString (not string interpolation).
///
/// T-03-02-01/02 mitigation: [lookupByBarcodeWithCo2] uses
/// Variable.withString for the barcode parameter and applies a max-length
/// guard (EAN-13 = 13 chars max) before any DB access.
///
/// LOG-11 override precedence: when [_userFoodDao] is provided, both
/// [searchLocalFoods] and [lookupByBarcodeWithCo2] check `UserFoodTable`
/// for a personal override of a matched off_ref/user_food_cache row and
/// substitute the override's data when found — the original catalog/cache
/// row is never mutated, only shadowed in read results (T-04-06-02).
@DriftAccessor(tables: [UserFoodCacheTable])
class FoodCatalogDao extends DatabaseAccessor<AppDatabase>
    with _$FoodCatalogDaoMixin {
  /// Creates a [FoodCatalogDao] bound to [attachedDatabase].
  ///
  /// [userFoodDao] is nullable so existing unit tests that construct
  /// `FoodCatalogDao(db)` directly (without a [UserFoodDao]) keep
  /// compiling unchanged — when `null`, override-checking is skipped,
  /// matching the existing `offRefPath == null` unit-test-isolation
  /// convention already used throughout this DAO.
  FoodCatalogDao(super.attachedDatabase, {UserFoodDao? userFoodDao})
    : _userFoodDao = userFoodDao;

  final UserFoodDao? _userFoodDao;

  // ---------------------------------------------------------------------------
  // FTS5 name search
  // ---------------------------------------------------------------------------

  /// Searches local FTS5 indexes and returns up to 25 [FoodItem]s.
  ///
  /// Queries both `off_ref.products_fts` (when [AppDatabase.offRefPath] is
  /// non-null) and `user_food_cache_fts`, deduplicates results by barcode,
  /// and caps the total at 25.
  ///
  /// Returns [] if [query] sanitizes to empty (T-02-03-03: early return
  /// for DoS mitigation — caller enforces the 2-char minimum).
  Future<List<FoodItem>> searchLocalFoods(String query) async {
    final sanitized = _sanitizeFts5Query(query);
    if (sanitized.isEmpty) return [];

    final results = <FoodItem>[];
    final seenBarcodes = <String>{};

    // --- off_ref query (skipped in unit tests without ATTACH) ---
    if (attachedDatabase.offRefPath != null) {
      try {
        // bm25 weights: product_name=10.0, product_name_en=8.0, brand=3.0.
        // ORDER BY rank ASC: bm25 returns negative — most relevant first.
        final offRows = await attachedDatabase.customSelect(
          '''
          SELECT
            p.barcode,
            p.product_name,
            p.product_name_en,
            p.brand,
            p.calories_100g,
            p.protein_100g,
            p.carbs_100g,
            p.fat_100g,
            NULL AS co2e_100g,
            NULL AS confidence_band,
            'off_ref' AS source,
            NULL AS source_row_id,
            bm25(products_fts, 10.0, 8.0, 3.0) AS rank
          FROM off_ref.products_fts
          JOIN off_ref.products p ON off_ref.products_fts.rowid = p.rowid
          WHERE products_fts MATCH ?
          ORDER BY rank
          LIMIT 25
          ''',
          variables: [Variable.withString(sanitized)],
          readsFrom: {},
        ).get();

        for (final row in offRows) {
          final item = FoodItem.fromQueryRow(row);
          final key = item.barcode;
          if (key != null) {
            if (seenBarcodes.add(key)) results.add(item);
          } else {
            results.add(item);
          }
        }
      } on Exception catch (e) {
        // Fall through to user cache. Logged so failures are visible in
        // device logs (adb logcat / flutter test --verbose) without crashing.
        debugPrint('[FoodCatalogDao] off_ref query error: $e');
      }
    }

    // --- user_food_cache_fts query (D-API-FALLBACK) ---
    if (results.length < 25) {
      try {
        final cacheRows = await attachedDatabase.customSelect(
          '''
          SELECT
            t.barcode,
            t.product_name,
            t.product_name_en,
            t.brand,
            t.calories100g AS calories_100g,
            t.protein100g AS protein_100g,
            t.carbs100g AS carbs_100g,
            t.fat100g AS fat_100g,
            NULL AS co2e_100g,
            NULL AS confidence_band,
            'user_food_cache' AS source,
            t.id AS source_row_id,
            0.0 AS rank
          FROM user_food_cache_fts
          JOIN user_food_cache_table t
            ON user_food_cache_fts.rowid = t.rowid
          WHERE user_food_cache_fts MATCH ?
          LIMIT 25
          ''',
          variables: [Variable.withString(sanitized)],
          readsFrom: {attachedDatabase.userFoodCacheTable},
        ).get();

        for (final row in cacheRows) {
          if (results.length >= 25) break;
          final item = FoodItem.fromQueryRow(row);
          final key = item.barcode;
          if (key != null) {
            if (seenBarcodes.add(key)) results.add(item);
          } else {
            results.add(item);
          }
        }
      } on Exception catch (e) {
        debugPrint('[FoodCatalogDao] user_food_cache_fts query error: $e');
      }
    }

    // --- LOG-11: personal override precedence ---
    // For each result with a barcode, check whether a personal override
    // exists for it and substitute the override's data if so. Per-item
    // async check (not batched) — acceptable given the existing 25-item
    // result cap.
    if (_userFoodDao != null) {
      for (var i = 0; i < results.length; i++) {
        final item = results[i];
        final barcode = item.barcode;
        final source = item.source;
        if (barcode == null || source == null) continue;
        final override = await _userFoodDao.findOverrideByFoodRef(
          barcode,
          source,
        );
        if (override != null) {
          results[i] = _foodItemFromUserFoodRow(override);
        }
      }
    }

    return results;
  }

  // ---------------------------------------------------------------------------
  // Barcode lookup with CO₂ enrichment
  // ---------------------------------------------------------------------------

  /// Looks up a food item by [barcode] and enriches the result with CO₂ data.
  ///
  /// Implements the two-step CO₂ lookup chain:
  ///
  /// **Step 1 — High confidence:** Queries `off_ref.food_co2_overrides` for
  /// a direct AGRIBALYSE barcode crosswalk match. Returns a [FoodItem] with
  /// `confidenceBand = 'high'` if found.
  ///
  /// **Step 2 — Medium confidence:** Falls back to `off_ref.products` joined
  /// with `off_ref.co2_factors` on `primary_category_tag`. Returns a
  /// [FoodItem] with `confidenceBand = 'medium'` if found.
  ///
  /// Returns null if:
  /// - [barcode] is empty or longer than 13 chars (T-03-02-02 DoS guard:
  ///   EAN-13 = 13 chars, EAN-8 = 8, UPC-A = 12 — reject >13).
  /// - [AppDatabase.offRefPath] is null (no ATTACH — unit test isolation)
  ///   AND no personal override exists (Step 0 below).
  /// - No match found in Step 0, Step 1, or Step 2.
  ///
  /// **Step 0 — Personal override (LOG-11):** When [_userFoodDao] is
  /// provided, checks `UserFoodTable` for an override of this barcode
  /// before touching `off_ref` at all — runs before the [offRefPath] null
  /// check since overrides live in `co2diet.sqlite`, independent of the
  /// ATTACHed off_ref database. Returns the override's data immediately
  /// when found, skipping Steps 1–2 entirely.
  ///
  /// T-03-02-01 mitigation: [barcode] is always passed as
  /// `Variable.withString(barcode)` — parameterized query prevents SQL
  /// injection.
  Future<FoodItem?> lookupByBarcodeWithCo2(String barcode) async {
    // T-03-02-02: Max-length guard — EAN-13 is the longest valid product
    // barcode at 13 chars. Reject oversized or empty inputs immediately.
    if (barcode.isEmpty || barcode.length > 13) return null;

    // Step 0 — personal override check (LOG-11), independent of off_ref
    // ATTACH state.
    final userFoodDao = _userFoodDao;
    if (userFoodDao != null) {
      final personalOverride = await userFoodDao.findOverrideByFoodRef(
        barcode,
        'off_ref',
      );
      if (personalOverride != null) {
        return _foodItemFromUserFoodRow(personalOverride);
      }
    }

    // No ATTACH — skip all DB queries (unit test isolation pattern).
    if (attachedDatabase.offRefPath == null) return null;

    try {
      // Step 1 — High confidence: direct barcode match in food_co2_overrides.
      final overrideRows = await attachedDatabase.customSelect(
        '''
        SELECT
          p.barcode,
          p.product_name,
          p.product_name_en,
          p.brand,
          p.calories_100g,
          p.protein_100g,
          p.carbs_100g,
          p.fat_100g,
          ov.co2e_100g,
          'high' AS confidence_band,
          'off_ref' AS source,
          NULL AS source_row_id
        FROM off_ref.food_co2_overrides ov
        JOIN off_ref.products p ON p.barcode = ov.barcode
        WHERE ov.barcode = ?
        LIMIT 1
        ''',
        variables: [Variable.withString(barcode)],
        readsFrom: {},
      ).get();

      if (overrideRows.isNotEmpty) {
        return FoodItem.fromQueryRow(overrideRows.first);
      }

      // Step 2 — Medium confidence: category average via primary_category_tag.
      // The ingest pipeline (Task 2) adds primary_category_tag to products —
      // avoids the json_each approach (Pitfall 5 in RESEARCH.md).
      final catRows = await attachedDatabase.customSelect(
        '''
        SELECT
          p.barcode,
          p.product_name,
          p.product_name_en,
          p.brand,
          p.calories_100g,
          p.protein_100g,
          p.carbs_100g,
          p.fat_100g,
          cf.co2e_median AS co2e_100g,
          'medium' AS confidence_band,
          'off_ref' AS source,
          NULL AS source_row_id
        FROM off_ref.products p
        JOIN off_ref.co2_factors cf
          ON cf.categories_tag = p.primary_category_tag
        WHERE p.barcode = ?
        LIMIT 1
        ''',
        variables: [Variable.withString(barcode)],
        readsFrom: {},
      ).get();

      if (catRows.isNotEmpty) {
        return FoodItem.fromQueryRow(catRows.first);
      }
    } on Exception catch (e) {
      debugPrint('[FoodCatalogDao] barcode lookup error: $e');
    }

    return null;
  }

  /// Enriches an already-fetched API [FoodItem] with CO₂ data from
  /// `off_ref.co2_factors` using [FoodItem.categoriesTags] from the API.
  ///
  /// Iterates [apiResult.categoriesTags] most-specific-first (OFF API order)
  /// and returns on the first hit in co2_factors. This avoids a circular
  /// barcode→products subquery that always fails for items not in the local DB.
  ///
  /// Returns [apiResult] unchanged when no category match is found, when
  /// [FoodItem.categoriesTags] is null/empty, or when [AppDatabase.offRefPath]
  /// is null.
  Future<FoodItem> lookupByBarcodeFromApi(
    String barcode,
    FoodItem apiResult,
  ) async {
    if (barcode.isEmpty || barcode.length > 13) return apiResult;
    if (attachedDatabase.offRefPath == null) return apiResult;

    final tags = apiResult.categoriesTags;
    // TEMP DEBUG — remove after device verification
    debugPrint('[CO2-DEBUG] lookupByBarcodeFromApi: barcode=$barcode tags=$tags');
    if (tags == null || tags.isEmpty) {
      debugPrint('[CO2-DEBUG] no categoriesTags on apiResult — returning unenriched');
      return apiResult;
    }

    // Iterate tags most-specific-first (OFF API order) — return on first hit.
    try {
      for (final tag in tags) {
        final rows = await attachedDatabase.customSelect(
          'SELECT co2e_median AS co2e_100g'
          ' FROM off_ref.co2_factors'
          ' WHERE categories_tag = ?'
          ' LIMIT 1',
          variables: [Variable.withString(tag)],
          readsFrom: {},
        ).get();

        // TEMP DEBUG
        debugPrint('[CO2-DEBUG] tag=$tag hit=${rows.isNotEmpty}');
        if (rows.isNotEmpty) {
          final co2e = rows.first.read<double?>('co2e_100g');
          if (co2e != null) {
            debugPrint('[CO2-DEBUG] matched tag=$tag co2e=$co2e — returning enriched');
            return apiResult.copyWith(
              co2e100g: co2e,
              confidenceBand: 'medium',
            );
          }
        }
      }
      debugPrint('[CO2-DEBUG] no co2_factors match for any tag — returning unenriched');
    } on Exception catch (e) {
      debugPrint('[FoodCatalogDao] API barcode CO₂ enrichment error: $e');
    }

    return apiResult;
  }

  // ---------------------------------------------------------------------------
  // Personal override mapping (LOG-11)
  // ---------------------------------------------------------------------------

  /// Maps a [UserFoodRow] (a personal override or custom food) onto a
  /// [FoodItem].
  ///
  /// Kept local to [FoodCatalogDao] since it is a cross-domain,
  /// off_ref-interop-specific concern (translating an override row into
  /// the same [FoodItem] shape search/barcode lookup callers already
  /// expect), not part of `UserFood`'s own domain contract.
  ///
  /// Sets `source: 'user_foods'` and `sourceRowId: row.id` — [row.id] is
  /// the `UserFoodTable` row's own primary key, i.e. the "catalog/custom-
  /// food ID" CONTEXT.md's merge-key rule refers to. `barcode: row.barcode`
  /// preserves the override's own optional user-entered barcode (may be
  /// null) so a future scan of that barcode still resolves correctly.
  FoodItem _foodItemFromUserFoodRow(UserFoodRow row) {
    return FoodItem(
      barcode: row.barcode,
      productName: row.name,
      brand: row.brand,
      calories100g: row.calories,
      protein100g: row.protein,
      carbs100g: row.carbs,
      fat100g: row.fat,
      co2e100g: row.co2e100g,
      confidenceBand: row.confidenceBand,
      source: 'user_foods',
      sourceRowId: row.id,
    );
  }

  // ---------------------------------------------------------------------------
  // FTS5 query sanitization
  // ---------------------------------------------------------------------------

  /// Strips FTS5 metacharacters and appends '*' to each term.
  ///
  /// T-02-03-01: Removes all chars that are not alphanumeric, space, or hyphen.
  /// Splits on whitespace, filters empty tokens, appends '*' per term.
  /// Returns empty string when no valid terms remain (caller returns []).
  ///
  /// Exposed as package-private via [sanitizeFts5QueryForTest] for unit tests.
  String _sanitizeFts5Query(String raw) {
    final cleaned = raw.trim().replaceAll(RegExp(r'[^\w\s\-]'), '');
    final terms = cleaned
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .map((t) => '$t*')
        .toList();
    return terms.join(' ');
  }

  /// Test-only accessor for [_sanitizeFts5Query].
  ///
  /// Allows unit tests to verify sanitization logic without running SQL.
  String sanitizeFts5QueryForTest(String raw) => _sanitizeFts5Query(raw);
}
