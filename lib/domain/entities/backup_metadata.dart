import 'package:co2diet/data/local/app_database.dart';
import 'package:flutter/foundation.dart';

/// Domain entity for automatic-backup configuration and the last-backup
/// audit trail (PRIV-02/PRIV-03).
///
/// This entity never carries the backup content itself — only scheduling
/// configuration and a pointer to the most recent backup file. The actual
/// export/backup/restore file generation lives in `BackupExportService`.
@immutable
class BackupMetadata {
  /// Creates an immutable [BackupMetadata]. The no-argument form represents
  /// "no backup ever run, automatic backups off" — the default state for a
  /// fresh install.
  const BackupMetadata({
    this.autoBackupFrequency = 'off',
    this.lastBackupAt,
    this.lastBackupPath,
  });

  /// Maps a Drift [BackupMetadataRow] 1:1 onto a [BackupMetadata].
  factory BackupMetadata.fromRow(BackupMetadataRow row) => BackupMetadata(
    autoBackupFrequency: row.autoBackupFrequency,
    lastBackupAt: row.lastBackupAt,
    lastBackupPath: row.lastBackupPath,
  );

  /// How often automatic backups run. Values: `'off'`, `'daily'`,
  /// `'weekly'`.
  final String autoBackupFrequency;

  /// Wall-clock timestamp of the most recent successful backup, or `null`
  /// if a backup has never been run.
  final DateTime? lastBackupAt;

  /// Path to the most recent backup file, within the app's own documents
  /// directory — never a user-chosen external path. `null` if a backup has
  /// never been run.
  final String? lastBackupPath;

  /// Sentinel object used by [copyWith] to detect when a caller explicitly
  /// passes `null` for a nullable field vs. not providing the field at all.
  static const _sentinel = Object();

  /// Returns a copy of this [BackupMetadata] with the specified fields
  /// replaced.
  ///
  /// To explicitly set a nullable field to `null`, pass `null` explicitly —
  /// the sentinel pattern detects the override and sets the field to null
  /// rather than preserving the old value.
  BackupMetadata copyWith({
    String? autoBackupFrequency,
    Object? lastBackupAt = _sentinel,
    Object? lastBackupPath = _sentinel,
  }) {
    return BackupMetadata(
      autoBackupFrequency: autoBackupFrequency ?? this.autoBackupFrequency,
      lastBackupAt: lastBackupAt == _sentinel
          ? this.lastBackupAt
          : lastBackupAt as DateTime?,
      lastBackupPath: lastBackupPath == _sentinel
          ? this.lastBackupPath
          : lastBackupPath as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BackupMetadata &&
          runtimeType == other.runtimeType &&
          autoBackupFrequency == other.autoBackupFrequency &&
          lastBackupAt == other.lastBackupAt &&
          lastBackupPath == other.lastBackupPath;

  @override
  int get hashCode =>
      Object.hash(autoBackupFrequency, lastBackupAt, lastBackupPath);

  @override
  String toString() => 'BackupMetadata('
      'autoBackupFrequency: $autoBackupFrequency, '
      'lastBackupAt: $lastBackupAt, '
      'lastBackupPath: $lastBackupPath)';
}
