// Regression test for the schemaVersion 4->5 migration step added to close
// a real gap: co2_methodology_version (UserFoodTable) and
// co2_methodology_version_snapshot (MealEntryTable) were added to the Dart
// schema in commit d7ac765 without ever bumping schemaVersion or adding a
// migration step. Any device whose on-disk tables were created before that
// commit landed is permanently missing these columns -- this crashed with
// "no such column: co2_methodology_version" on a real device during Phase 9
// checkpoint testing.
//
// Because the column was added without a version bump, a device's stored
// schemaVersion alone cannot tell us whether the column already exists --
// two scenarios must both be exercised:
//   1. A device whose table predates the column (missing) -- must be added.
//   2. A device whose table already has it (created after d7ac765 but
//      before this fix, still reporting schemaVersion 4) -- addColumn must
//      be skipped, not attempted a second time (Drift's addColumn is not
//      idempotent and throws "duplicate column name" otherwise).

import 'dart:io';

import 'package:co2diet/data/local/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as sqlite3;

Set<String> _rawColumnNames(String dbPath, String tableName) {
  final db = sqlite3.sqlite3.open(dbPath);
  try {
    final rows = db.select("SELECT name FROM pragma_table_info('$tableName')");
    return rows.map((row) => row['name'] as String).toSet();
  } finally {
    db.close();
  }
}

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('migration_test_');
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  test(
    'schemaVersion 4->5 adds co2_methodology_version(_snapshot) when '
    'missing (device predates the d7ac765 gap-fix commit)',
    () async {
      final dbFile = File(p.join(tempDir.path, 'old_schema_missing.sqlite'));

      // Simulate a device that upgraded through schemaVersion 4 BEFORE
      // co2_methodology_version(_snapshot) existed in the Dart schema:
      // create both tables using only the columns that existed at that
      // point in history, then set user_version = 4.
      sqlite3.sqlite3.open(dbFile.path)
        ..execute('''
          CREATE TABLE user_food_table (
            id TEXT NOT NULL PRIMARY KEY,
            name TEXT NOT NULL,
            calories REAL NOT NULL
          )
        ''')
        ..execute('''
          CREATE TABLE meal_entry_table (
            id TEXT NOT NULL PRIMARY KEY,
            food_ref TEXT NOT NULL
          )
        ''')
        ..execute('PRAGMA user_version = 4')
        ..close();

      // Re-open through the real AppDatabase/migration path -- this is the
      // same NativeDatabase(File) constructor the app uses, just pointed at
      // our simulated pre-fix file instead of a fresh :memory: db.
      final upgradedApp = AppDatabase(NativeDatabase(dbFile));
      await upgradedApp
          .customSelect('SELECT 1')
          .getSingleOrNull(); // forces the connection (and migration) open
      await upgradedApp.close();

      final userFoodColumns = _rawColumnNames(dbFile.path, 'user_food_table');
      final mealEntryColumns = _rawColumnNames(
        dbFile.path,
        'meal_entry_table',
      );

      expect(userFoodColumns, contains('co2_methodology_version'));
      expect(mealEntryColumns, contains('co2_methodology_version_snapshot'));
    },
  );

  test(
    'schemaVersion 4->5 does not crash when co2_methodology_version(_snapshot) '
    'already exists (device created its tables after d7ac765 but before '
    'this fix, still reporting schemaVersion 4)',
    () async {
      final dbFile = File(p.join(tempDir.path, 'old_schema_present.sqlite'));

      // Simulate a device that already has the columns (created after the
      // gap-fix commit landed) but whose stored user_version is still 4,
      // since that commit never bumped schemaVersion.
      sqlite3.sqlite3.open(dbFile.path)
        ..execute('''
          CREATE TABLE user_food_table (
            id TEXT NOT NULL PRIMARY KEY,
            name TEXT NOT NULL,
            calories REAL NOT NULL,
            co2_methodology_version TEXT
          )
        ''')
        ..execute('''
          CREATE TABLE meal_entry_table (
            id TEXT NOT NULL PRIMARY KEY,
            food_ref TEXT NOT NULL,
            co2_methodology_version_snapshot TEXT
          )
        ''')
        ..execute('PRAGMA user_version = 4')
        ..close();

      final upgradedApp = AppDatabase(NativeDatabase(dbFile));

      // The key assertion: this must NOT throw "duplicate column name".
      await expectLater(
        upgradedApp.customSelect('SELECT 1').getSingleOrNull(),
        completes,
      );

      await upgradedApp.close();
    },
  );

  test(
    'a brand-new device (onCreate path) has both columns from the start',
    () async {
      // onCreate always uses the live Dart schema, so a fresh in-memory
      // database gets both columns immediately -- verified on the same
      // live connection (a second, separate :memory: instance would be
      // empty and prove nothing).
      final db = AppDatabase(NativeDatabase.memory());
      final userFoodColumns = await db
          .customSelect("SELECT name FROM pragma_table_info('user_food_table')")
          .get();
      final mealEntryColumns = await db
          .customSelect(
            "SELECT name FROM pragma_table_info('meal_entry_table')",
          )
          .get();

      expect(
        userFoodColumns.map((r) => r.data['name']),
        contains('co2_methodology_version'),
      );
      expect(
        mealEntryColumns.map((r) => r.data['name']),
        contains('co2_methodology_version_snapshot'),
      );

      await db.close();
    },
  );
}
