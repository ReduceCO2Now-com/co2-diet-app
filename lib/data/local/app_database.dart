import 'package:co2diet/data/local/daos/backup_metadata_dao.dart';
import 'package:co2diet/data/local/daos/co2_settings_dao.dart';
import 'package:co2diet/data/local/daos/consent_records_dao.dart';
import 'package:co2diet/data/local/daos/food_catalog_dao.dart';
import 'package:co2diet/data/local/daos/meal_entry_dao.dart';
import 'package:co2diet/data/local/daos/notification_prefs_dao.dart';
import 'package:co2diet/data/local/daos/user_food_dao.dart';
import 'package:co2diet/data/local/daos/user_profile_dao.dart';
import 'package:co2diet/data/local/daos/weight_dao.dart';
import 'package:co2diet/data/local/migrations/migration_strategy.dart';
import 'package:co2diet/data/local/tables/backup_metadata_table.dart';
import 'package:co2diet/data/local/tables/co2_settings_table.dart';
import 'package:co2diet/data/local/tables/consent_records_table.dart';
import 'package:co2diet/data/local/tables/favorite_table.dart';
import 'package:co2diet/data/local/tables/meal_entry_table.dart';
import 'package:co2diet/data/local/tables/notification_prefs_table.dart';
import 'package:co2diet/data/local/tables/user_food_cache_table.dart';
import 'package:co2diet/data/local/tables/user_food_table.dart';
import 'package:co2diet/data/local/tables/user_profile_table.dart';
import 'package:co2diet/data/local/tables/weight_entry_table.dart';
import 'package:co2diet/data/local/tables/weight_settings_table.dart';
// The imports below have no direct reference in this file's source, but
// MealSlot/PortionUnit/ServingSize/WeightUnit are used as type arguments
// inside the generated `app_database.g.dart` part file. `part` files share
// this library's scope and cannot declare their own imports, so these types
// must be imported here for the generated code to resolve at compile time.
import 'package:co2diet/domain/entities/meal_slot.dart';
import 'package:co2diet/domain/entities/portion_unit.dart';
import 'package:co2diet/domain/entities/serving_size.dart';
import 'package:co2diet/domain/entities/weight_unit.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// The application's Drift database.
///
/// Tables:
///   [UserProfileTable]       — single-row user profile with sync-safe columns
///   [ConsentRecordsTable]    — append-only legal consent audit log
///   [UserFoodCacheTable]     — API-cached food entries with sync-safe columns
///   [MealEntryTable]         — logged meal entries with sync-safe columns
///   [FavoriteTable]          — favorited foods with sync-safe columns
///   [UserFoodTable]          — custom foods + personal overrides
///   [Co2SettingsTable]       — single-row personal-footprint settings
///                              (CO2-03)
///   [WeightEntryTable]       — logged weigh-in entries (WT-01)
///   [WeightSettingsTable]    — single-row weight goal + reminder config
///                              (WT-03/WT-04)
///   [NotificationPrefsTable] — single-row per-meal-slot reminder config
///                              (NOTIF-01)
///   [BackupMetadataTable]    — single-row auto-backup config + last-backup
///                              audit (PRIV-02/PRIV-03)
///
/// schemaVersion: 4 (Phase 5 adds Co2SettingsTable, WeightEntryTable,
/// WeightSettingsTable, NotificationPrefsTable, BackupMetadataTable, plus
/// three nullable nutrient-snapshot columns on MealEntryTable).
///
/// FK enforcement is enabled via PRAGMA foreign_keys = ON in [migration]
/// beforeOpen callback. ATTACH DATABASE for off_reference.sqlite is executed
/// in beforeOpen when [offRefPath] is non-null.
///
/// Do NOT use sqlite3_flutter_libs — drift_flutter handles native SQLite.
@DriftDatabase(
  tables: [
    UserProfileTable,
    ConsentRecordsTable,
    UserFoodCacheTable,
    MealEntryTable,
    FavoriteTable,
    UserFoodTable,
    Co2SettingsTable,
    WeightEntryTable,
    WeightSettingsTable,
    NotificationPrefsTable,
    BackupMetadataTable,
  ],
  daos: [
    UserProfileDao,
    ConsentRecordsDao,
    FoodCatalogDao,
    MealEntryDao,
    UserFoodDao,
    Co2SettingsDao,
    WeightDao,
    NotificationPrefsDao,
    BackupMetadataDao,
  ],
  include: {'daos/user_food_cache_fts.drift'},
)
class AppDatabase extends _$AppDatabase {
  /// Creates an [AppDatabase] with the given [QueryExecutor].
  ///
  /// [offRefPath] is the path to the decompressed off_reference.sqlite in the
  /// app documents directory. When non-null, ATTACH DATABASE is executed in
  /// beforeOpen so that [FoodCatalogDao] can query the off_ref schema.
  ///
  /// For production use the [AppDatabase.connect] named constructor.
  /// For tests, pass a [NativeDatabase.memory()] executor directly.
  AppDatabase(super.e, {this.offRefPath});

  /// Opens a persistent SQLite connection using drift_flutter.
  ///
  /// The database file is stored under the name 'co2diet' in the app's
  /// private documents directory (app-sandboxed on iOS and Android).
  ///
  /// [offRefPath] must be provided after ensureOffReferenceDb has
  /// decompressed the bundled asset to the documents directory.
  AppDatabase.connect({String? offRefPath})
    : this(driftDatabase(name: 'co2diet'), offRefPath: offRefPath);

  /// Path to the decompressed off_reference.sqlite asset, or null when
  /// running unit tests that do not need the attached reference DB.
  final String? offRefPath;

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration =>
      buildMigrationStrategy(this, offRefPath: offRefPath);
}
