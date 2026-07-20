import 'package:co2diet/data/local/mixins/sync_safe_table.dart';
import 'package:drift/drift.dart';

/// Drift table for API-cached food entries using the [SyncSafeTable] mixin.
///
/// This table stores food products returned by the OFF API fallback path
/// (D-API-FALLBACK: "Cached results indexed: FTS5 table in co2diet.sqlite
/// indexes cached items — they appear in future local searches without
/// re-hitting the API").
///
/// Column layout mirrors the products table in off_reference.sqlite so
/// that a single UNION query in FoodCatalogDao can read from both sources
/// with identical column names.
///
/// The six SyncSafeTable columns (id, hlcMillis, hlcCounter, hlcNodeId,
/// dirty, deletedAt) are inherited via the mixin and provide Phase 7 sync
/// readiness. Primary key is [id] (UUID v7) provided by the mixin.
///
/// Column naming follows Drift's getter-syntax pattern (very_good_analysis
/// `specify_nonobvious_property_types` rule — use getters, not late final).
@DataClassName('UserFoodCacheRow')
class UserFoodCacheTable extends Table with SyncSafeTable {
  // --- Food product fields ---

  /// EAN barcode; nullable because some API results may lack a barcode.
  Column<String> get barcode => text().nullable()();

  /// Primary product name. Always present — rows with empty product_name
  /// are rejected at the repository layer before insert.
  Column<String> get productName => text()();

  /// English product name, nullable. Absent for non-English products.
  Column<String> get productNameEn => text().nullable()();

  /// Brand name, nullable.
  Column<String> get brand => text().nullable()();

  /// Energy in kcal per 100 g, nullable when not reported.
  Column<double> get calories100g => real().nullable()();

  /// Protein in g per 100 g, nullable when not reported.
  Column<double> get protein100g => real().nullable()();

  /// Carbohydrates in g per 100 g, nullable when not reported.
  Column<double> get carbs100g => real().nullable()();

  /// Fat in g per 100 g, nullable when not reported.
  Column<double> get fat100g => real().nullable()();

  /// Comma-separated OFF categories_tags, nullable.
  /// Stored for Phase 4+ category filtering — consumer not yet wired.
  Column<String> get categoriesTags => text().nullable()();
}
