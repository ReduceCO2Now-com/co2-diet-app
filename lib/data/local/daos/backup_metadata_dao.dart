import 'package:co2diet/data/local/app_database.dart';
import 'package:co2diet/data/local/tables/backup_metadata_table.dart';
import 'package:drift/drift.dart';

part 'backup_metadata_dao.g.dart';

/// DAO for the single-row [BackupMetadataTable] (PRIV-02/PRIV-03).
///
/// Enforces the single-row constraint via [saveMetadata], which uses
/// insertOnConflictUpdate on the UUID v7 primary key. Callers must
/// always provide the same stable ID for the metadata row, mirroring
/// `UserProfileDao`'s established single-row pattern.
@DriftAccessor(tables: [BackupMetadataTable])
class BackupMetadataDao extends DatabaseAccessor<AppDatabase>
    with _$BackupMetadataDaoMixin {
  /// Creates a [BackupMetadataDao] bound to [attachedDatabase].
  BackupMetadataDao(super.attachedDatabase);

  /// Returns the single metadata row, or null if none exists yet.
  Future<BackupMetadataRow?> getMetadata() =>
      (select(backupMetadataTable)..limit(1)).getSingleOrNull();

  /// Upserts the metadata row (insert or update on PK conflict).
  ///
  /// This is the only write method. The single-row invariant is
  /// enforced by always using the same stable UUID v7 as the entry
  /// id value.
  Future<void> saveMetadata(BackupMetadataTableCompanion entry) =>
      into(backupMetadataTable).insertOnConflictUpdate(entry);
}
