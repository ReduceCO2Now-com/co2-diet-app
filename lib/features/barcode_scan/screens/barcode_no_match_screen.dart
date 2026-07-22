import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Shown when all four barcode lookup steps return null.
///
/// Satisfies LOG-04: no dead-end UX when a scan finds no match.
/// Presents two distinct messages:
///   - Genuine miss: "No product found for this barcode"
///   - Network error: "Couldn't reach the food database — check your
///     connection"
///
/// Two CTAs:
///   - [FilledButton] "Add as custom food" → `/custom-food-stub?barcode=…`
///   - [TextButton] "Try name search instead" → `/food-search`
class BarcodeScanNoMatchScreen extends StatelessWidget {
  /// Creates [BarcodeScanNoMatchScreen].
  const BarcodeScanNoMatchScreen({
    required this.barcode,
    required this.wasNetworkError,
    super.key,
  });

  /// The barcode that produced no match.
  final String barcode;

  /// Whether the miss was caused by a network error (device offline / API
  /// unreachable) vs. a genuine product-not-found response.
  final bool wasNetworkError;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final message = wasNetworkError
        ? "Couldn't reach the food database — check your connection"
        : 'No product found for this barcode';

    return Scaffold(
      appBar: AppBar(title: const Text('No Product Found')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off,
                size: 72,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 24),
              Text(
                message,
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Barcode: $barcode',
                style: textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () => context.push(
                  '/custom-food-stub?barcode=${Uri.encodeComponent(barcode)}',
                ),
                child: const Text('Add as custom food'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.go('/food-search'),
                child: const Text('Try name search instead'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
