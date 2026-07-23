import 'package:co2diet/data/local/mixins/sync_safe_table.dart';
import 'package:co2diet/domain/entities/portion_unit.dart';
import 'package:drift/drift.dart';

/// Drift table for favorited foods using the [SyncSafeTable] mixin.
///
/// `unit` references the [PortionUnit] enum from the domain layer
/// (Plan 04-03 — a parallel Wave 2 plan). Both plans land in the same
/// wave; this file compiles once Plan 04-03's domain entities exist.
///
/// Snapshot fields follow the same "snapshot, not reference" principle as
/// [MealEntryTable] (see its class doc comment) — favoriting a food does
/// not create a live link back to the source; the snapshot is refreshed
/// only when the user re-favorites or logs the food again.
///
/// One favorite row per distinct food is enforced via a `UNIQUE(food_ref,
/// food_ref_source)` constraint — toggling favorite twice on the same
/// food must update/delete the existing row, never insert a duplicate.
@DataClassName('FavoriteRow')
class FavoriteTable extends Table with SyncSafeTable {
  /// Reference to the source food: a barcode (off_ref/user_food_cache) or
  /// a `UserFoodTable.id` (user_foods). Never a Drift `.references()` FK
  /// (RESEARCH.md Pitfall 1 — cross-attached-DB FK is impossible).
  Column<String> get foodRef => text()();

  /// One of `'off_ref'`, `'user_food_cache'`, `'user_foods'` — identifies
  /// which table/database [foodRef] resolves against.
  Column<String> get foodRefSource => text()();

  /// Product name captured when favorited.
  Column<String> get productNameSnapshot => text()();

  /// Brand captured when favorited, nullable.
  Column<String> get brandSnapshot => text().nullable()();

  /// Energy in kcal per 100 g/ml, captured when favorited.
  Column<double> get calories100gSnapshot => real().nullable()();

  /// kg CO2e per kg product, captured when favorited.
  Column<double> get co2e100gSnapshot => real().nullable()();

  /// Confidence band ('high'/'medium'/'low'), captured when favorited.
  Column<String> get confidenceBandSnapshot => text().nullable()();

  /// Last quantity logged via the one-tap path from this favorite, in
  /// [lastUnit]. Null until the favorite has been logged at least once
  /// via the one-tap path; falls back to a generic default (100g) when
  /// null.
  Column<double> get lastQuantity => real().nullable()();

  /// Unit of [lastQuantity], nullable until logged at least once.
  Column<String> get lastUnit => textEnum<PortionUnit>().nullable()();

  /// Wall-clock timestamp of when the food was favorited.
  Column<DateTime> get favoritedAt => dateTime()();

  @override
  List<String> get customConstraints => [
    'UNIQUE(food_ref, food_ref_source)',
  ];
}
