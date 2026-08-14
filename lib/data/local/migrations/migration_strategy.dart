import 'package:co2diet/data/local/app_database.dart';
import 'package:drift/drift.dart';

/// Builds the [MigrationStrategy] for [AppDatabase].
///
/// onCreate: creates all tables on first install, including
///   UserFoodCacheTable and the user_food_cache_fts FTS5 virtual table
///   declared in `daos/user_food_cache_fts.drift`, plus MealEntryTable,
///   FavoriteTable, and UserFoodTable added in Phase 4, plus Co2SettingsTable,
///   WeightEntryTable, WeightSettingsTable, NotificationPrefsTable, and
///   BackupMetadataTable added in Phase 5.
/// onUpgrade: schemaVersion 1→2 adds UserFoodCacheTable +
///   user_food_cache_fts. schemaVersion 2→3 adds MealEntryTable,
///   FavoriteTable, and UserFoodTable (Phase 4). schemaVersion 3→4 adds
///   three nullable nutrient-snapshot columns to MealEntryTable plus
///   Co2SettingsTable, WeightEntryTable, WeightSettingsTable,
///   NotificationPrefsTable, and BackupMetadataTable (Phase 5). schemaVersion
///   4→5 retroactively adds co2_methodology_version to UserFoodTable and
///   co2_methodology_version_snapshot to MealEntryTable — a gap-fix commit
///   (d7ac765) added both columns to the Dart schema after the 2→3 step had
///   already shipped, without ever adding a migration for them; any device
///   that created these tables before that commit landed is missing the
///   columns until this step runs.
/// beforeOpen: enables FK enforcement, then ATTACHes off_reference.sqlite
///   when [offRefPath] is non-null.
///
/// T-02-03-02 mitigation: [offRefPath] is always derived from
/// getApplicationDocumentsDirectory in FirstLaunchExtractor; never from
/// user input.
MigrationStrategy buildMigrationStrategy(
  AppDatabase db, {
  String? offRefPath,
}) {
  return MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      // schemaVersion 1 → 2: add UserFoodCacheTable + user_food_cache_fts.
      if (from < 2) {
        await m.createTable(db.userFoodCacheTable);
        // The FTS5 virtual table is declared in user_food_cache_fts.drift.
        // Drift's createAll/createTable doesn't handle FTS5 virtual tables
        // directly — issue the DDL via customStatement.
        await db.customStatement('''
          CREATE VIRTUAL TABLE IF NOT EXISTS user_food_cache_fts USING fts5(
            product_name,
            product_name_en,
            brand,
            content='user_food_cache_table',
            content_rowid='rowid',
            tokenize='unicode61 remove_diacritics 2',
            prefix='2 3 4'
          )
        ''');
      }

      // schemaVersion 2 → 3: add MealEntryTable, FavoriteTable, and
      // UserFoodTable (Phase 4 meal logging core).
      if (from < 3) {
        await m.createTable(db.mealEntryTable);
        await m.createTable(db.favoriteTable);
        await m.createTable(db.userFoodTable);
      }

      // schemaVersion 3 → 4: add three nullable nutrient-snapshot columns
      // to MealEntryTable (NUTR-01) plus Co2SettingsTable, WeightEntryTable,
      // WeightSettingsTable, NotificationPrefsTable, and BackupMetadataTable
      // (Phase 5 nutrition/CO2-estimator/dashboard/weight/notifications/
      // export/local-mode work).
      if (from < 4) {
        await m.addColumn(
          db.mealEntryTable,
          db.mealEntryTable.sugar100gSnapshot,
        );
        await m.addColumn(
          db.mealEntryTable,
          db.mealEntryTable.fiber100gSnapshot,
        );
        await m.addColumn(db.mealEntryTable, db.mealEntryTable.saltSnapshot);
        await m.createTable(db.co2SettingsTable);
        await m.createTable(db.weightEntryTable);
        await m.createTable(db.weightSettingsTable);
        await m.createTable(db.notificationPrefsTable);
        await m.createTable(db.backupMetadataTable);
      }

      // schemaVersion 4 → 5: retroactively add co2_methodology_version to
      // UserFoodTable and co2_methodology_version_snapshot to MealEntryTable.
      // Both were added to the Dart schema in commit d7ac765 WITHOUT a
      // migration step or schemaVersion bump — so whether a given device's
      // on-disk table already has the column depends on the exact moment it
      // first upgraded relative to that commit, not on any stored version
      // number. `from < 5` alone would double-add the column (and crash with
      // "duplicate column name") for any device that already has it, either
      // because the `from < 3` block above just created the table fresh
      // using the current Dart class, or because it upgraded through
      // schemaVersion 3 after d7ac765 landed but before this fix shipped.
      // Checking actual column presence via pragma_table_info is the only
      // way to make this step correct for every device regardless of
      // history.
      if (from < 5) {
        await _addColumnIfMissing(
          db,
          tableName: 'user_food_table',
          columnName: 'co2_methodology_version',
          addColumn: () => m.addColumn(
            db.userFoodTable,
            db.userFoodTable.co2MethodologyVersion,
          ),
        );
        await _addColumnIfMissing(
          db,
          tableName: 'meal_entry_table',
          columnName: 'co2_methodology_version_snapshot',
          addColumn: () => m.addColumn(
            db.mealEntryTable,
            db.mealEntryTable.co2MethodologyVersionSnapshot,
          ),
        );
      }
    },
    beforeOpen: (_) async {
      // SQLite disables foreign key enforcement by default.
      // Enable it before every session (PRAGMA is connection-scoped).
      await db.customStatement('PRAGMA foreign_keys = ON');

      // T-02-03-02: offRefPath is derived from path_provider only.
      // Skip ATTACH when null (unit tests pass null to avoid needing the file).
      if (offRefPath != null) {
        // Guard against duplicate ATTACH on a reused native executor (e.g.
        // when multiple AppDatabase wrappers share one drift_flutter connection
        // in integration tests). SQLite rejects a second ATTACH with the same
        // alias; checking pragma_database_list makes the call idempotent.
        final already = await db
            .customSelect(
              "SELECT 1 FROM pragma_database_list WHERE name = 'off_ref'",
            )
            .getSingleOrNull();
        if (already == null) {
          // Attach the read-only reference DB under alias 'off_ref' so that
          // FoodCatalogDao can query off_ref.products_fts and off_ref.products.
          await db.customStatement(
            "ATTACH DATABASE '$offRefPath' AS off_ref",
          );
        }
      }
    },
  );
}

/// Runs [addColumn] only if [columnName] does not already exist on
/// [tableName], checked via `pragma_table_info` (mirrors this file's
/// existing `pragma_database_list` idempotency-check pattern for ATTACH).
///
/// Needed because the co2_methodology_version(_snapshot) columns were added
/// to the Dart schema without a schemaVersion bump (commit d7ac765) — so a
/// device's stored `from` version alone cannot tell us whether the column is
/// already present, and Drift's `addColumn` is not idempotent (throws
/// "duplicate column name" if it already exists).
Future<void> _addColumnIfMissing(
  GeneratedDatabase db, {
  required String tableName,
  required String columnName,
  required Future<void> Function() addColumn,
}) async {
  final existing = await db
      .customSelect(
        "SELECT 1 FROM pragma_table_info('$tableName') WHERE name = ?",
        variables: [Variable.withString(columnName)],
      )
      .getSingleOrNull();
  if (existing == null) {
    await addColumn();
  }
}
