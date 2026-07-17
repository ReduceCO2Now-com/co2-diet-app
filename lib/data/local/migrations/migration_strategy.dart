import 'package:co2diet/data/local/app_database.dart';
import 'package:drift/drift.dart';

/// Builds the [MigrationStrategy] for [AppDatabase].
///
/// onCreate: creates all tables on first install.
/// onUpgrade: empty for schemaVersion 1 — no upgrade paths yet.
///   Future phases add: if (from < 2) { await m.addColumn(...); }
/// beforeOpen: enables SQLite FK enforcement (OFF by default).
MigrationStrategy buildMigrationStrategy(AppDatabase db) {
  return MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      // schemaVersion 1: no upgrade paths.
    },
    beforeOpen: (_) async {
      // SQLite disables foreign key enforcement by default.
      // Enable it before every session (PRAGMA is connection-scoped).
      await db.customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
