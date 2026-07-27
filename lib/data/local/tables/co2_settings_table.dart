import 'package:co2diet/data/local/mixins/sync_safe_table.dart';
import 'package:drift/drift.dart';

/// Single-row table storing the user's personal-footprint settings
/// (CO2-03) — a separate layer from any per-food CO2 calculation.
///
/// All sync-safe columns (id, hlcMillis, hlcCounter, hlcNodeId,
/// dirty, deletedAt) are injected by the [SyncSafeTable] mixin. A
/// later plan's DAO enforces the single-row constraint via upsert on
/// the 'id' PK, mirroring UserProfileTable's pattern.
///
/// This table is never joined into any per-food query — every field
/// is optional and falls back to a regional average when unset.
/// Changing these values is forward-only: it never rewrites
/// already-logged `MealEntryTable` rows or their `co2e100gSnapshot`.
@DataClassName('Co2SettingsRow')
class Co2SettingsTable extends Table with SyncSafeTable {
  /// Country the user shops/lives in, used for regional CO2 averages.
  Column<String> get locationCountry => text().nullable()();

  /// Region/state within [locationCountry], used for finer regional
  /// CO2 averages when available.
  Column<String> get locationRegion => text().nullable()();

  /// Where the user primarily buys food.
  /// Values: 'supermarket', 'local_farm', 'mix'.
  Column<String> get purchasingSource => text().nullable()();

  /// How the user typically travels to buy food.
  /// Values: 'car', 'public', 'walk_bike'.
  Column<String> get shoppingTransport => text().nullable()();

  /// The user's primary cooking method.
  /// Values: 'electric', 'gas', 'induction'.
  Column<String> get cookingMethod => text().nullable()();

  /// The user's food storage setup.
  /// Values: 'small_fridge', 'large_fridge_freezer'.
  Column<String> get foodStorage => text().nullable()();

  /// Number of people in the user's household.
  Column<int> get householdSize => integer().nullable()();

  /// The user's self-reported food waste level.
  /// Values: 'low', 'medium', 'high'.
  Column<String> get foodWasteLevel => text().nullable()();
}
