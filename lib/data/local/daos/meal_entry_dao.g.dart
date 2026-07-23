// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_entry_dao.dart';

// ignore_for_file: type=lint
mixin _$MealEntryDaoMixin on DatabaseAccessor<AppDatabase> {
  $MealEntryTableTable get mealEntryTable => attachedDatabase.mealEntryTable;
  $FavoriteTableTable get favoriteTable => attachedDatabase.favoriteTable;
  MealEntryDaoManager get managers => MealEntryDaoManager(this);
}

class MealEntryDaoManager {
  final _$MealEntryDaoMixin _db;
  MealEntryDaoManager(this._db);
  $$MealEntryTableTableTableManager get mealEntryTable =>
      $$MealEntryTableTableTableManager(
        _db.attachedDatabase,
        _db.mealEntryTable,
      );
  $$FavoriteTableTableTableManager get favoriteTable =>
      $$FavoriteTableTableTableManager(_db.attachedDatabase, _db.favoriteTable);
}
