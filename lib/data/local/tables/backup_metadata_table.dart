import 'package:co2diet/data/local/mixins/sync_safe_table.dart';
import 'package:drift/drift.dart';

/// Single-row table storing automatic-backup configuration and the
/// last-backup audit trail (PRIV-02/PRIV-03).
///
/// All sync-safe columns (id, hlcMillis, hlcCounter, hlcNodeId,
/// dirty, deletedAt) are injected by the [SyncSafeTable] mixin. A
/// later plan's DAO enforces the single-row constraint via upsert on
/// the 'id' PK, mirroring UserProfileTable's pattern.
@DataClassName('BackupMetadataRow')
class BackupMetadataTable extends Table with SyncSafeTable {
  /// How often automatic backups run.
  /// Values: 'off', 'daily', 'weekly'.
  Column<String> get autoBackupFrequency =>
      text().withDefault(const Constant('off'))();

  /// Wall-clock timestamp of the most recent successful backup.
  Column<DateTime> get lastBackupAt => dateTime().nullable()();

  /// Path to the most recent backup file, within the app's own
  /// documents directory — never a user-chosen external path.
  Column<String> get lastBackupPath => text().nullable()();
}
