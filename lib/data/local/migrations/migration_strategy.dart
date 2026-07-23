import 'package:co2diet/data/local/app_database.dart';
import 'package:drift/drift.dart';

/// Builds the [MigrationStrategy] for [AppDatabase].
///
/// onCreate: creates all tables on first install, including
///   UserFoodCacheTable and the user_food_cache_fts FTS5 virtual table
///   declared in `daos/user_food_cache_fts.drift`, plus MealEntryTable,
///   FavoriteTable, and UserFoodTable added in Phase 4.
/// onUpgrade: schemaVersion 1→2 adds UserFoodCacheTable +
///   user_food_cache_fts. schemaVersion 2→3 adds MealEntryTable,
///   FavoriteTable, and UserFoodTable (Phase 4).
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
