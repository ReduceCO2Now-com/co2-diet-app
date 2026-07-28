import 'package:co2diet/data/local/app_database.dart';
import 'package:co2diet/data/local/daos/backup_metadata_dao.dart';
import 'package:co2diet/domain/entities/backup_metadata.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// Thin repository over [BackupMetadataDao] (PRIV-02/PRIV-03).
///
/// Mirrors `Co2SettingsRepository`'s established shape: no separate
/// interface file — this is a simple single-table read/write consumed only
/// by `BackupExportService`, not by any UI notifier directly, so an
/// abstract interface would add indirection with no second implementation
/// ever expected.
///
/// HLC fields use Phase-1 placeholder values, matching every other
/// Phase 1-4/5 repository:
///   - `hlcNodeId` is `'local'` (Phase 7 replaces with stable device UUID)
///   - `hlcCounter` is `0` (Phase 7 implements full HLC increment logic)
final class BackupMetadataRepository {
  /// Creates a [BackupMetadataRepository] backed by the given DAO.
  const BackupMetadataRepository(this._dao);

  final BackupMetadataDao _dao;
  static const _uuid = Uuid();

  /// Returns the current [BackupMetadata], or the default (`'off'`,
  /// never backed up) when no row exists yet.
  Future<BackupMetadata> getMetadata() async {
    final row = await _dao.getMetadata();
    if (row == null) return const BackupMetadata();
    return BackupMetadata.fromRow(row);
  }

  /// Persists [metadata], reusing the existing single row's id if present
  /// or generating a fresh UUID v7 for the first-ever save (mirrors
  /// `Co2SettingsRepository.saveSettings`'s single-row-id convention).
  Future<void> saveMetadata(BackupMetadata metadata) async {
    final existing = await _dao.getMetadata();
    final id = existing?.id ?? _uuid.v7();

    final companion = BackupMetadataTableCompanion(
      id: Value(id),
      autoBackupFrequency: Value(metadata.autoBackupFrequency),
      lastBackupAt: Value(metadata.lastBackupAt),
      lastBackupPath: Value(metadata.lastBackupPath),
      // HLC Phase-1 placeholders — Phase 7 replaces with full HLC clock.
      hlcMillis: Value(BigInt.from(DateTime.now().millisecondsSinceEpoch)),
      hlcCounter: const Value(0),
      hlcNodeId: const Value('local'),
      dirty: const Value(true),
    );

    await _dao.saveMetadata(companion);
  }
}
