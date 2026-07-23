import 'package:co2diet/data/local/app_database.dart';
import 'package:co2diet/data/local/daos/user_food_dao.dart';
import 'package:co2diet/domain/entities/user_food.dart';
import 'package:co2diet/domain/repositories/i_user_food_repository.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// Concrete implementation of [IUserFoodRepository], backed by
/// [UserFoodDao].
///
/// T-04-05-01 mitigation: [saveCustomFood]/[saveOverride] re-validate
/// [UserFood.isValid] (and, for overrides, `overrideOfRef`) at this
/// repository boundary before calling the DAO — defense in depth beyond
/// `UserFoodDao.insert`'s own guard, since DAOs and repositories can each
/// be called independently in tests/future code paths.
///
/// HLC fields use Phase 1 placeholders (matching `FoodCatalogRepository`'s
/// established convention): `hlcNodeId` is `'local'`, `hlcCounter` is `0`.
/// Phase 7 replaces these with full HLC clock logic using a stable device
/// UUID.
final class UserFoodRepository implements IUserFoodRepository {
  /// Creates a [UserFoodRepository] backed by [_dao].
  UserFoodRepository(this._dao);

  final UserFoodDao _dao;

  static const _uuid = Uuid();

  BigInt get _nowHlcMillis =>
      BigInt.from(DateTime.now().millisecondsSinceEpoch);

  @override
  Future<UserFood> saveCustomFood(UserFood food) {
    if (!food.isValid) {
      throw ArgumentError('UserFood requires a name and a calorie value');
    }
    return _save(food);
  }

  @override
  Future<UserFood> saveOverride(UserFood override) {
    if (!override.isValid) {
      throw ArgumentError('UserFood requires a name and a calorie value');
    }
    if (override.overrideOfRef == null) {
      throw ArgumentError('An override must set overrideOfRef');
    }
    return _save(override);
  }

  /// Shared insert/update path for [saveCustomFood] and [saveOverride] —
  /// both persist to the same `user_foods` table (CONTEXT.md's "single
  /// table for both" decision). Branches on whether `food`'s `id` already
  /// exists in the DAO to decide insert vs. update.
  Future<UserFood> _save(UserFood food) async {
    final existing = food.id.isEmpty ? null : await _dao.getById(food.id);
    final id = existing?.id ?? (food.id.isEmpty ? _uuid.v7() : food.id);

    final companion = UserFoodTableCompanion(
      id: Value(id),
      hlcMillis: Value(_nowHlcMillis),
      hlcCounter: const Value(0),
      hlcNodeId: const Value('local'),
      dirty: const Value(true),
      name: Value(food.name),
      brand: Value(food.brand),
      category: Value(food.category),
      referenceAmountG: Value(food.referenceAmountG),
      // `isValid` (checked by both callers above) guarantees `calories` is
      // non-null at this point.
      calories: Value(food.calories!),
      protein: Value(food.protein),
      carbs: Value(food.carbs),
      sugar: Value(food.sugar),
      fat: Value(food.fat),
      fiber: Value(food.fiber),
      salt: Value(food.salt),
      co2e100g: Value(food.co2e100g),
      confidenceBand: Value(food.confidenceBand),
      co2Source: Value(food.co2Source),
      co2MethodologyVersion: Value(food.co2MethodologyVersion),
      barcode: Value(food.barcode),
      // Drift's `TypeConverter.json2` (Plan 04-02) already decodes this
      // column to `List<ServingSize>` — assigned directly, never
      // re-encoded/re-decoded here.
      quickServingSizes: Value(food.quickServingSizes),
      overrideOfRef: Value(food.overrideOfRef),
      overrideOfSource: Value(food.overrideOfSource),
    );

    final row = existing != null
        ? await _dao.updateFood(id, companion)
        : await _dao.insert(companion);
    return UserFood.fromRow(row);
  }

  @override
  Future<void> revertOverride(String userFoodId) => _dao.revert(userFoodId);

  @override
  Future<UserFood?> findOverrideForFoodRef(
    String foodRef,
    String foodRefSource,
  ) async {
    final row = await _dao.findOverrideByFoodRef(foodRef, foodRefSource);
    return row == null ? null : UserFood.fromRow(row);
  }

  @override
  Future<List<UserFood>> getAllAlphabetical({String? filter}) async {
    final rows = await _dao.getAllAlphabetical(filter: filter);
    return rows.map(UserFood.fromRow).toList();
  }

  @override
  Future<UserFood?> getById(String id) async {
    final row = await _dao.getById(id);
    return row == null ? null : UserFood.fromRow(row);
  }
}
