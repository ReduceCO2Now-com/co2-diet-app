import 'package:co2diet/data/local/app_database.dart';
import 'package:drift/drift.dart';

/// Builds the [MigrationStrategy] for [AppDatabase].
///
/// onCreate: creates all tables on first install, including
///   UserFoodCacheTable and the user_food_cache_fts FTS5 virtual table
///   declared in `daos/user_food_cache_fts.drift`.
/// onUpgrade: schemaVersion 1→2 adds UserFoodCacheTable +
///   user_food_cache_fts.
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
    },
    beforeOpen: (_) async {
      // SQLite disables foreign key enforcement by default.
      // Enable it before every session (PRAGMA is connection-scoped).
      await db.customStatement('PRAGMA foreign_keys = ON');

      // T-02-03-02: offRefPath is derived from path_provider only.
      // Skip ATTACH when null (unit tests pass null to avoid needing the file).
      if (offRefPath != null) {
        // Attach the read-only reference DB under alias 'off_ref' so that
        // FoodCatalogDao can query off_ref.products_fts and off_ref.products.
        await db.customStatement(
          "ATTACH DATABASE '$offRefPath' AS off_ref",
        );
      }
    },
  );
}
