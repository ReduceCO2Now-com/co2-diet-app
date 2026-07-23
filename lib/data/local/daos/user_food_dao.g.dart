// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_food_dao.dart';

// ignore_for_file: type=lint
mixin _$UserFoodDaoMixin on DatabaseAccessor<AppDatabase> {
  $UserFoodTableTable get userFoodTable => attachedDatabase.userFoodTable;
  UserFoodDaoManager get managers => UserFoodDaoManager(this);
}

class UserFoodDaoManager {
  final _$UserFoodDaoMixin _db;
  UserFoodDaoManager(this._db);
  $$UserFoodTableTableTableManager get userFoodTable =>
      $$UserFoodTableTableTableManager(_db.attachedDatabase, _db.userFoodTable);
}
