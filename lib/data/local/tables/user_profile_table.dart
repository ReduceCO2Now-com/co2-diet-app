import 'package:co2diet/data/local/mixins/sync_safe_table.dart';
import 'package:drift/drift.dart';

/// Single-row table storing the user's profile in Local Mode.
///
/// All sync-safe columns (id, hlcMillis, hlcCounter, hlcNodeId,
/// dirty, deletedAt) are injected by the [SyncSafeTable] mixin.
/// The DAO enforces the single-row constraint by using upsertProfile
/// (insertOnConflictUpdate on the 'id' PK).
///
/// All profile fields are nullable: the user can save a partial
/// profile at any time. Missing Mifflin-St Jéor inputs (age, gender,
/// height, weight) result in null targets that the UI renders as
/// '—' dashes (never population-average fallbacks).
@DataClassName('UserProfileRow')
class UserProfileTable extends Table with SyncSafeTable {
  // --- Profile fields ---

  /// Age in years. Required for Mifflin-St Jéor TDEE calculation.
  Column<int> get age => integer().nullable()();

  /// Biological sex for BMR calculation.
  /// Values: 'male', 'female', 'other'.
  /// 'other' uses the average of male and female BMR variants.
  Column<String> get gender => text().nullable()();

  /// Height in centimetres. Always stored in cm; imperial conversion
  /// happens in the app layer.
  Column<double> get heightCm => real().nullable()();

  /// Weight in kilograms. Always stored in kg; imperial conversion
  /// happens in the app layer.
  Column<double> get weightKg => real().nullable()();

  /// Activity level for TDEE multiplier.
  /// Values: 'low', 'medium', 'high'.
  Column<String> get activityLevel => text().nullable()();

  /// Dietary preference.
  /// Values: 'no_preference', 'vegetarian', 'vegan',
  /// 'flexitarian', 'low_meat', 'other'.
  Column<String> get dietaryPreference => text().nullable()();

  /// User's selected goal.
  /// Values: 'reduce_co2', 'lose_weight', 'maintain_weight',
  /// 'gain_muscle', 'improve_health', 'balanced_lifestyle',
  /// 'learn_and_explore'.
  Column<String> get goal => text().nullable()();

  /// Unit system preference. Values: 'metric', 'imperial'.
  /// Default 'metric' — locale detection on first profile save
  /// sets this per D-09.
  Column<String> get units =>
      text().withDefault(const Constant('metric'))();

  // --- Auto-calculated targets ---

  /// Daily energy target in kcal. Null until all Mifflin inputs
  /// are complete.
  Column<double> get kcalTarget => real().nullable()();

  /// Daily protein target in grams. Null until TDEE is calculated.
  Column<double> get proteinGTarget => real().nullable()();

  /// Daily carbohydrate target in grams. Null until TDEE is calculated.
  Column<double> get carbsGTarget => real().nullable()();

  /// Daily fat target in grams. Null until TDEE is calculated.
  Column<double> get fatGTarget => real().nullable()();

  /// Daily CO₂ target in grams. Stored but NOT shown in UI until
  /// Phase 3. The CO₂ factor table doesn't exist until Phase 3;
  /// this column is pre-provisioned per CO2-04 so no migration
  /// is needed later.
  Column<double> get co2GTarget => real().nullable()();

  // --- Override flags (per D-06 override strategy) ---

  /// True when the user has manually overridden the kcal target.
  Column<bool> get kcalIsOverridden =>
      boolean().withDefault(const Constant(false))();

  /// True when the user has manually overridden the protein target.
  Column<bool> get proteinIsOverridden =>
      boolean().withDefault(const Constant(false))();

  /// True when the user has manually overridden the carbs target.
  Column<bool> get carbsIsOverridden =>
      boolean().withDefault(const Constant(false))();

  /// True when the user has manually overridden the fat target.
  Column<bool> get fatIsOverridden =>
      boolean().withDefault(const Constant(false))();

  /// True when the user has manually overridden the CO₂ target.
  Column<bool> get co2IsOverridden =>
      boolean().withDefault(const Constant(false))();

  // --- CO₂ methodology versioning (CO2-04) ---

  /// Version of the CO₂ calculation methodology used for this
  /// profile's targets. Defaults to '1.0' — the first methodology
  /// version in the app. This column is present from day 1 so
  /// methodology updates in Phase 7+ can trigger recalculation
  /// flows without a migration.
  Column<String> get co2MethodologyVersion =>
      text().withDefault(const Constant('1.0'))();

  // --- Locale ---

  /// BCP 47 locale tag at the time of first profile save
  /// (e.g. 'de-DE', 'en-US'). Captured once via
  /// Localizations.localeOf(context) on the first save.
  Column<String> get localeTag => text().nullable()();

  // --- Audit timestamps ---

  /// UTC timestamp of initial profile creation.
  Column<DateTime> get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  /// UTC timestamp of most recent profile update.
  /// Null until first update.
  Column<DateTime> get updatedAt => dateTime().nullable()();
}
