// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_food_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(UserFoodNotifier)
final userFoodProvider = UserFoodNotifierProvider._();

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
final class UserFoodNotifierProvider
    extends $AsyncNotifierProvider<UserFoodNotifier, List<UserFood>> {
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
  UserFoodNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userFoodProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userFoodNotifierHash();

  @$internal
  @override
  UserFoodNotifier create() => UserFoodNotifier();
}

String _$userFoodNotifierHash() => r'491c236839030aa30ff75d6624c558d1787e017d';

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

abstract class _$UserFoodNotifier extends $AsyncNotifier<List<UserFood>> {
  FutureOr<List<UserFood>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<UserFood>>, List<UserFood>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<UserFood>>, List<UserFood>>,
              AsyncValue<List<UserFood>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
