// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consent_records_dao.dart';

// ignore_for_file: type=lint
mixin _$ConsentRecordsDaoMixin on DatabaseAccessor<AppDatabase> {
  $ConsentRecordsTableTable get consentRecordsTable =>
      attachedDatabase.consentRecordsTable;
  ConsentRecordsDaoManager get managers => ConsentRecordsDaoManager(this);
}

class ConsentRecordsDaoManager {
  final _$ConsentRecordsDaoMixin _db;
  ConsentRecordsDaoManager(this._db);
  $$ConsentRecordsTableTableTableManager get consentRecordsTable =>
      $$ConsentRecordsTableTableTableManager(
        _db.attachedDatabase,
        _db.consentRecordsTable,
      );
}
