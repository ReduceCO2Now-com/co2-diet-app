import 'package:co2diet/data/local/mixins/sync_safe_table.dart';
import 'package:co2diet/domain/entities/meal_slot.dart';
import 'package:co2diet/domain/entities/portion_unit.dart';
import 'package:drift/drift.dart';

/// Drift table for logged meal entries using the [SyncSafeTable] mixin.
///
/// `mealSlot` and `unit` reference the [MealSlot]/[PortionUnit] enums from
/// the domain layer (Plan 04-03 — a parallel Wave 2 plan). Both plans land
/// in the same wave; this file compiles once Plan 04-03's domain entities
/// exist.
///
/// ## "Snapshot, not reference" (CONTEXT.md)
///
/// All `*Snapshot` columns are captured once, at log time, from the source
/// food (off_ref product, cached API result, or user food) and are NEVER
/// re-joined to that source at read time. Creating or editing a personal
/// override (a `UserFoodTable` row with `overrideOfRef` set) must never
/// retroactively change values already logged here — that is the entire
/// point of snapshotting instead of referencing.
///
/// [sugar100gSnapshot]/[fiber100gSnapshot]/[saltSnapshot] were added in
/// Phase 5 (NUTR-01). They remain `null` for every Phase-4-logged row
/// (migrated with no data) and remain `null` going forward for any entry
/// sourced from `off_ref`/`user_food_cache` — those tables carry no
/// sugar/fiber/salt data at all. Only `user_foods`-sourced entries (i.e.
/// custom foods and personal overrides) can ever populate these three
/// fields. Named `saltSnapshot`, not `sodium...`, per this app's
/// established EU-label "salt (g)" convention (see `UserFoodTable.salt`).
///
/// ## No cross-attached-database foreign keys (RESEARCH.md Pitfall 1)
///
/// [foodRef] is a plain text column — never a Drift `.references()` FK.
/// SQLite cannot enforce foreign keys across the `ATTACH`ed `off_ref`
/// database, and a real FK would fight the snapshot data model anyway
/// (the referenced row may later be edited or become an override without
/// this row needing to change). Validation of `foodRef`/`foodRefSource`
/// pairs happens at the application layer (DAO/repository), not via SQL
/// constraints.
@DataClassName('MealEntryRow')
class MealEntryTable extends Table with SyncSafeTable {
  /// Which meal slot this entry belongs to (breakfast/lunch/dinner/snack).
  /// Stored via `textEnum` as `Enum.name` — append-only, see [MealSlot].
  Column<String> get mealSlot => textEnum<MealSlot>()();

  /// Reference to the source food: a barcode (off_ref/user_food_cache) or
  /// a `UserFoodTable.id` (user_foods). Never a Drift `.references()` FK
  /// (RESEARCH.md Pitfall 1 — cross-attached-DB FK is impossible and would
  /// fight the snapshot data model).
  Column<String> get foodRef => text()();

  /// One of `'off_ref'`, `'user_food_cache'`, `'user_foods'` — identifies
  /// which table/database [foodRef] resolves against.
  Column<String> get foodRefSource => text()();

  /// Logged quantity, in [unit].
  Column<double> get quantity => real()();

  /// Unit the [quantity] is expressed in (g/ml/piece/cup/portion).
  Column<String> get unit => textEnum<PortionUnit>()();

  /// Product name captured at log time. See class doc for the
  /// "snapshot, not reference" principle.
  Column<String> get productNameSnapshot => text()();

  /// Brand captured at log time, nullable.
  Column<String> get brandSnapshot => text().nullable()();

  /// Energy in kcal per 100 g/ml, captured at log time.
  Column<double> get calories100gSnapshot => real().nullable()();

  /// Protein in g per 100 g/ml, captured at log time.
  Column<double> get protein100gSnapshot => real().nullable()();

  /// Carbohydrates in g per 100 g/ml, captured at log time.
  Column<double> get carbs100gSnapshot => real().nullable()();

  /// Fat in g per 100 g/ml, captured at log time.
  Column<double> get fat100gSnapshot => real().nullable()();

  /// Sugar in g per 100 g/ml, captured at log time. Added in Phase 5
  /// (NUTR-01) — see class doc for nullability rules.
  Column<double> get sugar100gSnapshot => real().nullable()();

  /// Fiber in g per 100 g/ml, captured at log time. Added in Phase 5
  /// (NUTR-01) — see class doc for nullability rules.
  Column<double> get fiber100gSnapshot => real().nullable()();

  /// Salt in g per 100 g/ml, captured at log time (this app's EU-label
  /// "sodium" convention — see class doc). Added in Phase 5 (NUTR-01) —
  /// see class doc for nullability rules.
  Column<double> get saltSnapshot => real().nullable()();

  /// kg CO2e per kg product, captured at log time.
  Column<double> get co2e100gSnapshot => real().nullable()();

  /// Confidence band ('high'/'medium'/'low'), captured at log time.
  Column<String> get confidenceBandSnapshot => text().nullable()();

  /// Version of the CO₂ calculation methodology that produced
  /// [co2e100gSnapshot], captured at log time (CO2-04 — per
  /// `01-CONTEXT.md`'s locked decision that every CO₂-bearing table
  /// created in later phases carries this column, matching
  /// `UserProfileTable.co2MethodologyVersion`'s precedent). Nullable and
  /// only meaningful alongside a non-null [co2e100gSnapshot] — a future
  /// methodology recalculation flow (Phase 7+) can identify which
  /// already-logged entries were computed under an older methodology
  /// without needing to re-derive it from [loggedAt].
  Column<String> get co2MethodologyVersionSnapshot => text().nullable()();

  /// Wall-clock timestamp of when the entry was logged.
  Column<DateTime> get loggedAt => dateTime()();

  /// `'YYYY-MM-DD'` local calendar day, computed once in Dart at write
  /// time (RESEARCH.md Pattern 3 / Pitfall 2 — never derived via SQL
  /// `strftime`). Used for the same-slot/same-day merge check and for
  /// grouping the dashboard entries list.
  Column<String> get logDate => text()();
}
