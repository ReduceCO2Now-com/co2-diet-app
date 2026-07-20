// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_search_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod AsyncNotifier that drives the food search UI.
///
/// State-transition diagram (from CONTEXT.md / RESEARCH.md):
///
/// ```none
///   initial                → AsyncData(FoodSearchPrompt)
///   query.length < 2       → AsyncData(FoodSearchPrompt) [debounce cancelled]
///   query.length >= 2      → 300ms debounce → _search(query)
///   onQuerySubmitted(>=2)  → debounce cancelled → _search(query) immediately
///
///   _search internals:
///     local.isNotEmpty      → AsyncData(FoodSearchResults) — no AsyncLoading
///     local.isEmpty+offline → AsyncData(FoodSearchOfflineNoResults)
///     local.isEmpty+online  → AsyncLoading
///                  success  → AsyncData(FoodSearchResults)
///                  failure  → AsyncData(FoodSearchNetworkError)
/// ```
///
/// Security mitigations (T-02-05-x):
///   T-02-05-01 (timer spam)    debounce cancels prior timer on each keystroke
///   T-02-05-02 (short query)   2-char minimum in [onQueryChanged]
///   T-02-05-03 (offline API)   connectivity check gates the API call
///   T-02-05-04 (swallowed err) [NetworkException] to [FoodSearchNetworkError]

@ProviderFor(FoodSearchNotifier)
final foodSearchProvider = FoodSearchNotifierProvider._();

/// Riverpod AsyncNotifier that drives the food search UI.
///
/// State-transition diagram (from CONTEXT.md / RESEARCH.md):
///
/// ```none
///   initial                → AsyncData(FoodSearchPrompt)
///   query.length < 2       → AsyncData(FoodSearchPrompt) [debounce cancelled]
///   query.length >= 2      → 300ms debounce → _search(query)
///   onQuerySubmitted(>=2)  → debounce cancelled → _search(query) immediately
///
///   _search internals:
///     local.isNotEmpty      → AsyncData(FoodSearchResults) — no AsyncLoading
///     local.isEmpty+offline → AsyncData(FoodSearchOfflineNoResults)
///     local.isEmpty+online  → AsyncLoading
///                  success  → AsyncData(FoodSearchResults)
///                  failure  → AsyncData(FoodSearchNetworkError)
/// ```
///
/// Security mitigations (T-02-05-x):
///   T-02-05-01 (timer spam)    debounce cancels prior timer on each keystroke
///   T-02-05-02 (short query)   2-char minimum in [onQueryChanged]
///   T-02-05-03 (offline API)   connectivity check gates the API call
///   T-02-05-04 (swallowed err) [NetworkException] to [FoodSearchNetworkError]
final class FoodSearchNotifierProvider
    extends $AsyncNotifierProvider<FoodSearchNotifier, FoodSearchState> {
  /// Riverpod AsyncNotifier that drives the food search UI.
  ///
  /// State-transition diagram (from CONTEXT.md / RESEARCH.md):
  ///
  /// ```none
  ///   initial                → AsyncData(FoodSearchPrompt)
  ///   query.length < 2       → AsyncData(FoodSearchPrompt) [debounce cancelled]
  ///   query.length >= 2      → 300ms debounce → _search(query)
  ///   onQuerySubmitted(>=2)  → debounce cancelled → _search(query) immediately
  ///
  ///   _search internals:
  ///     local.isNotEmpty      → AsyncData(FoodSearchResults) — no AsyncLoading
  ///     local.isEmpty+offline → AsyncData(FoodSearchOfflineNoResults)
  ///     local.isEmpty+online  → AsyncLoading
  ///                  success  → AsyncData(FoodSearchResults)
  ///                  failure  → AsyncData(FoodSearchNetworkError)
  /// ```
  ///
  /// Security mitigations (T-02-05-x):
  ///   T-02-05-01 (timer spam)    debounce cancels prior timer on each keystroke
  ///   T-02-05-02 (short query)   2-char minimum in [onQueryChanged]
  ///   T-02-05-03 (offline API)   connectivity check gates the API call
  ///   T-02-05-04 (swallowed err) [NetworkException] to [FoodSearchNetworkError]
  FoodSearchNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'foodSearchProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$foodSearchNotifierHash();

  @$internal
  @override
  FoodSearchNotifier create() => FoodSearchNotifier();
}

String _$foodSearchNotifierHash() =>
    r'f44f6560c06538f9ca3194429083714bbb4b63d1';

/// Riverpod AsyncNotifier that drives the food search UI.
///
/// State-transition diagram (from CONTEXT.md / RESEARCH.md):
///
/// ```none
///   initial                → AsyncData(FoodSearchPrompt)
///   query.length < 2       → AsyncData(FoodSearchPrompt) [debounce cancelled]
///   query.length >= 2      → 300ms debounce → _search(query)
///   onQuerySubmitted(>=2)  → debounce cancelled → _search(query) immediately
///
///   _search internals:
///     local.isNotEmpty      → AsyncData(FoodSearchResults) — no AsyncLoading
///     local.isEmpty+offline → AsyncData(FoodSearchOfflineNoResults)
///     local.isEmpty+online  → AsyncLoading
///                  success  → AsyncData(FoodSearchResults)
///                  failure  → AsyncData(FoodSearchNetworkError)
/// ```
///
/// Security mitigations (T-02-05-x):
///   T-02-05-01 (timer spam)    debounce cancels prior timer on each keystroke
///   T-02-05-02 (short query)   2-char minimum in [onQueryChanged]
///   T-02-05-03 (offline API)   connectivity check gates the API call
///   T-02-05-04 (swallowed err) [NetworkException] to [FoodSearchNetworkError]

abstract class _$FoodSearchNotifier extends $AsyncNotifier<FoodSearchState> {
  FutureOr<FoodSearchState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<FoodSearchState>, FoodSearchState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<FoodSearchState>, FoodSearchState>,
              AsyncValue<FoodSearchState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
