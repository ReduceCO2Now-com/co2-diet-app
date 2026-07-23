import 'package:co2diet/domain/entities/user_food.dart';

/// Domain contract for custom-food and override persistence.
///
/// Implementations live in the data layer (Plan 04-05). T-04-03-01:
/// [UserFood.isValid] is a client-side-only check defined in the domain
/// layer — implementations of [saveCustomFood]/[saveOverride] must
/// re-validate at the DAO/repository boundary before insert (defense in
/// depth).
abstract interface class IUserFoodRepository {
  /// Persists [food] as a new standalone custom food. Throws/rejects when
  /// `!food.isValid`.
  Future<UserFood> saveCustomFood(UserFood food);

  /// Persists [override] as an override of an existing off_ref/
  /// user_food_cache product. Same validation as [saveCustomFood];
  /// `override.overrideOfRef` must be non-null.
  Future<UserFood> saveOverride(UserFood override);

  /// Deletes the override row identified by [userFoodId], reverting to
  /// the original off_ref/user_food_cache product data.
  Future<void> revertOverride(String userFoodId);

  /// Returns the override (if any) for the product identified by
  /// [foodRef] + [foodRefSource]. Used by the search/barcode integration
  /// (Plan 04-06) to check override precedence.
  Future<UserFood?> findOverrideForFoodRef(
    String foodRef,
    String foodRefSource,
  );

  /// Returns all standalone custom foods (and overrides), alphabetically
  /// ordered by name, optionally narrowed by [filter], for the My Foods
  /// list.
  Future<List<UserFood>> getAllAlphabetical({String? filter});

  /// Returns the [UserFood] identified by [id], or `null` if not found.
  Future<UserFood?> getById(String id);
}
