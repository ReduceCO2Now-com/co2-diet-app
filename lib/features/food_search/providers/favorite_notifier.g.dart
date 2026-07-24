// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// AsyncNotifier exposing the current favorites list and the toggle /
/// one-tap-log mutation surface (LOG-08) the UI layer (Plans 04-08 through
/// 04-11) consumes exclusively — those plans never touch
/// `IMealEntryRepository` directly for favorite concerns.
///
/// Follows `ProfileNotifier`'s exact codegen shape: `build()` returns the
/// current state, every mutation method calls the repository then
/// `ref.invalidateSelf()` so the Favorites list picks up the change.

@ProviderFor(FavoriteNotifier)
final favoriteProvider = FavoriteNotifierProvider._();

/// AsyncNotifier exposing the current favorites list and the toggle /
/// one-tap-log mutation surface (LOG-08) the UI layer (Plans 04-08 through
/// 04-11) consumes exclusively — those plans never touch
/// `IMealEntryRepository` directly for favorite concerns.
///
/// Follows `ProfileNotifier`'s exact codegen shape: `build()` returns the
/// current state, every mutation method calls the repository then
/// `ref.invalidateSelf()` so the Favorites list picks up the change.
final class FavoriteNotifierProvider
    extends $AsyncNotifierProvider<FavoriteNotifier, List<Favorite>> {
  /// AsyncNotifier exposing the current favorites list and the toggle /
  /// one-tap-log mutation surface (LOG-08) the UI layer (Plans 04-08 through
  /// 04-11) consumes exclusively — those plans never touch
  /// `IMealEntryRepository` directly for favorite concerns.
  ///
  /// Follows `ProfileNotifier`'s exact codegen shape: `build()` returns the
  /// current state, every mutation method calls the repository then
  /// `ref.invalidateSelf()` so the Favorites list picks up the change.
  FavoriteNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoriteProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoriteNotifierHash();

  @$internal
  @override
  FavoriteNotifier create() => FavoriteNotifier();
}

String _$favoriteNotifierHash() => r'21bc4be86ea9a0ab18a7cda87e64423a8fa59b6a';

/// AsyncNotifier exposing the current favorites list and the toggle /
/// one-tap-log mutation surface (LOG-08) the UI layer (Plans 04-08 through
/// 04-11) consumes exclusively — those plans never touch
/// `IMealEntryRepository` directly for favorite concerns.
///
/// Follows `ProfileNotifier`'s exact codegen shape: `build()` returns the
/// current state, every mutation method calls the repository then
/// `ref.invalidateSelf()` so the Favorites list picks up the change.

abstract class _$FavoriteNotifier extends $AsyncNotifier<List<Favorite>> {
  FutureOr<List<Favorite>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Favorite>>, List<Favorite>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Favorite>>, List<Favorite>>,
              AsyncValue<List<Favorite>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
