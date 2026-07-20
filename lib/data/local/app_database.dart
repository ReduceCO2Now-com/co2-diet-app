import 'package:co2diet/data/local/daos/consent_records_dao.dart';
import 'package:co2diet/data/local/daos/food_catalog_dao.dart';
import 'package:co2diet/data/local/daos/user_profile_dao.dart';
import 'package:co2diet/data/local/migrations/migration_strategy.dart';
import 'package:co2diet/data/local/tables/consent_records_table.dart';
import 'package:co2diet/data/local/tables/user_food_cache_table.dart';
import 'package:co2diet/data/local/tables/user_profile_table.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// The application's Drift database.
///
/// Tables:
///   [UserProfileTable]    — single-row user profile with sync-safe columns
///   [ConsentRecordsTable] — append-only legal consent audit log
///   [UserFoodCacheTable]  — API-cached food entries with sync-safe columns
///
/// schemaVersion: 2 (Phase 2 adds UserFoodCacheTable + user_food_cache_fts).
///
/// FK enforcement is enabled via PRAGMA foreign_keys = ON in [migration]
/// beforeOpen callback. ATTACH DATABASE for off_reference.sqlite is executed
/// in beforeOpen when [offRefPath] is non-null.
///
/// Do NOT use sqlite3_flutter_libs — drift_flutter handles native SQLite.
@DriftDatabase(
  tables: [UserProfileTable, ConsentRecordsTable, UserFoodCacheTable],
  daos: [UserProfileDao, ConsentRecordsDao, FoodCatalogDao],
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
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration =>
      buildMigrationStrategy(this, offRefPath: offRefPath);
}
