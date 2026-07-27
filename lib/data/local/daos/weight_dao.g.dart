// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_dao.dart';

// ignore_for_file: type=lint
mixin _$WeightDaoMixin on DatabaseAccessor<AppDatabase> {
  $WeightEntryTableTable get weightEntryTable =>
      attachedDatabase.weightEntryTable;
  $WeightSettingsTableTable get weightSettingsTable =>
      attachedDatabase.weightSettingsTable;
  WeightDaoManager get managers => WeightDaoManager(this);
}

class WeightDaoManager {
  final _$WeightDaoMixin _db;
  WeightDaoManager(this._db);
  $$WeightEntryTableTableTableManager get weightEntryTable =>
      $$WeightEntryTableTableTableManager(
        _db.attachedDatabase,
        _db.weightEntryTable,
      );
  $$WeightSettingsTableTableTableManager get weightSettingsTable =>
      $$WeightSettingsTableTableTableManager(
        _db.attachedDatabase,
        _db.weightSettingsTable,
      );
}
