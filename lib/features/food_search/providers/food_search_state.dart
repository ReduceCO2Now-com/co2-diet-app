import 'package:co2diet/domain/entities/food_item.dart';

/// Sealed state class for the food search feature.
///
/// Four variants encode every possible UI state:
///   - [FoodSearchPrompt]           — initial; no query entered yet
///   - [FoodSearchResults]          — local FTS5 or API results available
///   - [FoodSearchOfflineNoResults] — 0 local hits and device is offline
///   - [FoodSearchNetworkError]     — API call failed with a network error
///
/// Use pattern matching (`switch`) to handle all variants exhaustively —
/// the Dart 3 `sealed` modifier guarantees the compiler warns on missing arms.
///
/// Static factory methods (e.g. `FoodSearchState.prompt()`) provide ergonomic
/// construction matching RESEARCH.md Pattern 6.
sealed class FoodSearchState {
  const FoodSearchState();

  /// Returns [FoodSearchPrompt] — the initial / empty-query state.
  static FoodSearchState prompt() => const FoodSearchPrompt();

  /// Returns [FoodSearchResults] containing [items].
  static FoodSearchState results(List<FoodItem> items) =>
      FoodSearchResults(items);

  /// Returns [FoodSearchOfflineNoResults].
  static FoodSearchState offlineNoResults() =>
      const FoodSearchOfflineNoResults();

  /// Returns [FoodSearchNetworkError] with [message].
  static FoodSearchState networkError(String message) =>
      FoodSearchNetworkError(message);
}

/// Initial / empty-query state.
///
/// Shown before the user types anything and when the query falls below the
/// 2-character minimum enforced by `FoodSearchNotifier.onQueryChanged`.
final class FoodSearchPrompt extends FoodSearchState {
  /// Creates a [FoodSearchPrompt].
  const FoodSearchPrompt();
}

/// One or more results are available (local FTS5 or API-sourced).
final class FoodSearchResults extends FoodSearchState {
  /// Creates a [FoodSearchResults] with the given [items].
  const FoodSearchResults(this.items);

  /// Non-empty list of matching [FoodItem]s.
  final List<FoodItem> items;
}

/// Local search returned 0 hits and the device has no internet connectivity.
///
/// The UI shows an offline-specific message (T-02-05-03 mitigation).
final class FoodSearchOfflineNoResults extends FoodSearchState {
  /// Creates a [FoodSearchOfflineNoResults].
  const FoodSearchOfflineNoResults();
}

/// The OFF API call failed with a network error.
///
/// The UI renders [message] alongside a "Try again" button
/// (T-02-05-04 mitigation — NetworkException is not silently swallowed).
final class FoodSearchNetworkError extends FoodSearchState {
  /// Creates a [FoodSearchNetworkError] with a human-readable [message].
  const FoodSearchNetworkError(this.message);

  /// Human-readable error description from `NetworkException.message`.
  final String message;
}
