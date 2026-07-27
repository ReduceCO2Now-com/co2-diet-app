// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'co2_settings_dao.dart';

// ignore_for_file: type=lint
mixin _$Co2SettingsDaoMixin on DatabaseAccessor<AppDatabase> {
  $Co2SettingsTableTable get co2SettingsTable =>
      attachedDatabase.co2SettingsTable;
  Co2SettingsDaoManager get managers => Co2SettingsDaoManager(this);
}

class Co2SettingsDaoManager {
  final _$Co2SettingsDaoMixin _db;
  Co2SettingsDaoManager(this._db);
  $$Co2SettingsTableTableTableManager get co2SettingsTable =>
      $$Co2SettingsTableTableTableManager(
        _db.attachedDatabase,
        _db.co2SettingsTable,
      );
}
