import 'dart:async';

import 'package:co2diet/core/di/app_providers.dart';
import 'package:co2diet/data/repositories/food_catalog_repository.dart';
import 'package:co2diet/features/food_search/providers/food_search_state.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'food_search_notifier.g.dart';

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
@riverpod
class FoodSearchNotifier extends _$FoodSearchNotifier {
  Timer? _debounce;

  @override
  Future<FoodSearchState> build() async {
    // Cancel any pending debounce timer when the notifier is disposed to
    // prevent dart:async leaks (T-02-05-01 mitigation).
    ref.onDispose(() => _debounce?.cancel());
    return const FoodSearchPrompt();
  }

  /// Called on every keystroke in the search field.
  ///
  /// Enforces a 2-character minimum (T-02-05-02) and a 300ms debounce
  /// (T-02-05-01) before firing the underlying search.
  void onQueryChanged(String query) {
    // Cancel any in-flight debounce (T-02-05-01).
    _debounce?.cancel();

    if (query.length < 2) {
      // Below threshold — reset to prompt state immediately; no Timer starts.
      state = const AsyncData(FoodSearchPrompt());
      return;
    }

    _debounce = Timer(
      const Duration(milliseconds: 300),
      () => unawaited(_search(query)),
    );
  }

  /// Called when the user presses the keyboard "Search" / "Done" action.
  ///
  /// Cancels any pending debounce and fires the search immediately so the
  /// Enter key always feels responsive.
  void onQuerySubmitted(String query) {
    _debounce?.cancel();
    if (query.length >= 2) {
      unawaited(_search(query));
    }
  }

  /// Immediately retries the search for [query] without any debounce delay.
  ///
  /// Intended for the "Try again" button shown in the
  /// [FoodSearchNetworkError] state.
  void retry(String query) => unawaited(_search(query));

  /// Core search logic: local FTS5 first, API fallback when necessary.
  ///
  /// Local path emits no AsyncLoading — FTS5 is near-instant.
  /// API path emits AsyncLoading first because real network latency exists.
  Future<void> _search(String query) async {
    final repo = ref.read(foodCatalogRepositoryProvider);

    // 1. Local FTS5 — no loading indicator (design decision from CONTEXT.md).
    final local = await repo.searchLocal(query);
    if (local.isNotEmpty) {
      state = AsyncData(FoodSearchResults(local));
      return;
    }

    // 2. Offline check — connectivity_plus 7.x returns
    //    List<ConnectivityResult>; empty list = no connectivity (T-02-05-03).
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.isEmpty ||
        connectivity.contains(ConnectivityResult.none)) {
      state = const AsyncData(FoodSearchOfflineNoResults());
      return;
    }

    // 3. API fallback — emit loading now (real network latency is expected).
    try {
      state = const AsyncLoading();
      final apiItems = await repo.searchAndCache(query);
      state = AsyncData(FoodSearchResults(apiItems));
    } on NetworkException catch (e) {
      // T-02-05-04: map typed NetworkException to an explicit error state
      // instead of propagating as AsyncError — the UI shows a retry button.
      state = AsyncData(FoodSearchNetworkError(e.message));
    } on Exception catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
