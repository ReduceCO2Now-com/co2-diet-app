import 'package:co2diet/core/di/meal_logging_providers.dart';
import 'package:co2diet/domain/entities/user_food.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_food_notifier.g.dart';

/// AsyncNotifier exposing the My Foods list (custom foods + overrides) and
/// the save/revert mutation surface (LOG-10/LOG-11) the UI layer (Plans
/// 04-08 through 04-11) consumes exclusively — those plans never touch
/// `IUserFoodRepository` directly.
///
/// Follows `ProfileNotifier`'s exact codegen shape: `build()` returns the
/// current state, every mutation method calls the repository then
/// `ref.invalidateSelf()` so the My Foods list and any override-precedence
/// search results refresh.
///
/// Note: `build()` is deliberately parameterless (returns the full
/// unfiltered alphabetical list) rather than a `@riverpod` family taking a
/// `{String? filter}` argument — this keeps the generated provider name
/// predictable (`userFoodProvider`, not a family requiring a call
/// argument at every `ref.watch` site). The My Foods screen (Plan 04-08)
/// filters this list client-side with a local `TextEditingController`,
/// matching the alternative explicitly sanctioned by this plan.
@riverpod
class UserFoodNotifier extends _$UserFoodNotifier {
  @override
  Future<List<UserFood>> build() =>
      ref.watch(userFoodRepositoryProvider).getAllAlphabetical();

  /// Persists [food] as a new standalone custom food, then refreshes the
  /// My Foods list.
  Future<UserFood> saveCustomFood(UserFood food) async {
    final saved = await ref.read(userFoodRepositoryProvider).saveCustomFood(
      food,
    );
    ref.invalidateSelf();
    return saved;
  }

  /// Persists [override] as an override of an existing off_ref/
  /// user_food_cache product, then refreshes the My Foods list (and any
  /// override-precedence search results that read through the same
  /// repository).
  Future<UserFood> saveOverride(UserFood override) async {
    final saved = await ref
        .read(userFoodRepositoryProvider)
        .saveOverride(override);
    ref.invalidateSelf();
    return saved;
  }

  /// Deletes the override identified by [userFoodId], reverting to the
  /// original off_ref/user_food_cache product data, then refreshes the My
  /// Foods list.
  Future<void> revertOverride(String userFoodId) async {
    await ref.read(userFoodRepositoryProvider).revertOverride(userFoodId);
    ref.invalidateSelf();
  }

  /// Returns the existing override (if any) for the product identified by
  /// [foodRef] + [foodRefSource]. Used by the sheet's "Edit this food" flow
  /// to pre-fill the form with an existing override's values if one is
  /// already being edited a second time. A plain pass-through read — does
  /// not participate in `build()`'s state or `invalidateSelf()` cycle.
  Future<UserFood?> findOverrideForFoodRef(
    String foodRef,
    String foodRefSource,
  ) => ref
      .read(userFoodRepositoryProvider)
      .findOverrideForFoodRef(foodRef, foodRefSource);
}
