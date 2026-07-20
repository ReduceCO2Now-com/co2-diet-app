import 'package:flutter/material.dart';

/// Variants for [NoResultsWidget] — each maps to a distinct no-results state.
enum NoResultsVariant {
  /// Local FTS5 returned zero hits and the user is online.
  genuine,

  /// Local FTS5 returned zero hits and the device is offline.
  offline,

  /// The OFF API call failed with a network error.
  networkError,
}

/// Displays one of three "no results" states for the food search screen.
///
/// - [NoResultsVariant.genuine] — "No results for '...'"
/// - [NoResultsVariant.offline] — "No results — connect to the internet…"
/// - [NoResultsVariant.networkError] — "Couldn't reach the food database…"
///   with a "Try again" button when [onRetry] is non-null.
///
/// All text uses [Theme.of(context)] tokens — no hardcoded colors.
class NoResultsWidget extends StatelessWidget {
  /// Creates a [NoResultsWidget].
  const NoResultsWidget({
    required this.variant,
    required this.query,
    this.onRetry,
    super.key,
  });

  /// Which no-results state to render.
  final NoResultsVariant variant;

  /// The search query that produced no results (used in the genuine variant).
  final String query;

  /// Callback for the "Try again" button; only shown when non-null.
  ///
  /// Only relevant for [NoResultsVariant.networkError].
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final secondaryStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        );

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              variant == NoResultsVariant.networkError
                  ? Icons.wifi_off
                  : Icons.search_off,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              _message(),
              textAlign: TextAlign.center,
              style: secondaryStyle,
            ),
            if (variant == NoResultsVariant.networkError &&
                onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: onRetry,
                child: const Text('Try again'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _message() {
    return switch (variant) {
      NoResultsVariant.genuine => 'No results for "$query"',
      NoResultsVariant.offline =>
        'No results — connect to the internet to search more',
      NoResultsVariant.networkError =>
        "Couldn't reach the food database — check your connection",
    };
  }
}
