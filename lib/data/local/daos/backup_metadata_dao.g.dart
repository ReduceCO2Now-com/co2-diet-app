// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_metadata_dao.dart';

// ignore_for_file: type=lint
mixin _$BackupMetadataDaoMixin on DatabaseAccessor<AppDatabase> {
  $BackupMetadataTableTable get backupMetadataTable =>
      attachedDatabase.backupMetadataTable;
  BackupMetadataDaoManager get managers => BackupMetadataDaoManager(this);
}

class BackupMetadataDaoManager {
  final _$BackupMetadataDaoMixin _db;
  BackupMetadataDaoManager(this._db);
  $$BackupMetadataTableTableTableManager get backupMetadataTable =>
      $$BackupMetadataTableTableTableManager(
        _db.attachedDatabase,
        _db.backupMetadataTable,
      );
}
