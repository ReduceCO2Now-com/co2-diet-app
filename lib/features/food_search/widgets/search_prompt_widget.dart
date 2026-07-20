import 'package:flutter/material.dart';

/// Full-width prompt shown when the user has not yet typed a query.
///
/// Displays a centered search icon and hint text. Uses only
/// [Theme.of(context).colorScheme] tokens — no hardcoded colors.
class SearchPromptWidget extends StatelessWidget {
  /// Creates a [SearchPromptWidget].
  const SearchPromptWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Search for a food...',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
