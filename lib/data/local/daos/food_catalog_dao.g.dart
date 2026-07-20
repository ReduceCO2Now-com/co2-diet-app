// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_catalog_dao.dart';

// ignore_for_file: type=lint
mixin _$FoodCatalogDaoMixin on DatabaseAccessor<AppDatabase> {
  $UserFoodCacheTableTable get userFoodCacheTable =>
      attachedDatabase.userFoodCacheTable;
  FoodCatalogDaoManager get managers => FoodCatalogDaoManager(this);
}

class FoodCatalogDaoManager {
  final _$FoodCatalogDaoMixin _db;
  FoodCatalogDaoManager(this._db);
  $$UserFoodCacheTableTableTableManager get userFoodCacheTable =>
      $$UserFoodCacheTableTableTableManager(
        _db.attachedDatabase,
        _db.userFoodCacheTable,
      );
}
