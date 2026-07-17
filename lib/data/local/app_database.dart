import 'package:co2diet/data/local/daos/consent_records_dao.dart';
import 'package:co2diet/data/local/daos/user_profile_dao.dart';
import 'package:co2diet/data/local/migrations/migration_strategy.dart';
import 'package:co2diet/data/local/tables/consent_records_table.dart';
import 'package:co2diet/data/local/tables/user_profile_table.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// The application's Drift database.
///
/// Tables:
///   [UserProfileTable]    — single-row user profile with sync-safe columns
///   [ConsentRecordsTable] — append-only legal consent audit log
///
/// schemaVersion: 1 (Phase 1 baseline; increment for each migration).
///
/// FK enforcement is enabled via PRAGMA foreign_keys = ON in [migration]
/// beforeOpen callback.
///
/// Do NOT use sqlite3_flutter_libs — drift_flutter handles native SQLite.
@DriftDatabase(
  tables: [UserProfileTable, ConsentRecordsTable],
  daos: [UserProfileDao, ConsentRecordsDao],
)
class AppDatabase extends _$AppDatabase {
  /// Creates an [AppDatabase] with the given [QueryExecutor].
  ///
  /// For production use the [AppDatabase.connect] named constructor.
  /// For tests, pass a [NativeDatabase.memory()] executor directly.
  AppDatabase(super.e);

  /// Opens a persistent SQLite connection using drift_flutter.
  ///
  /// The database file is stored under the name 'co2diet' in the app's
  /// private documents directory (app-sandboxed on iOS and Android).
  AppDatabase.connect() : this(driftDatabase(name: 'co2diet'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => buildMigrationStrategy(this);
}
