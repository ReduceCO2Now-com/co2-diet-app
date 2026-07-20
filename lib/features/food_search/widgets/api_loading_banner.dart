import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Shown during the OFF API fallback search path only.
///
/// Displays a "Searching online..." banner followed by 5 shimmer skeleton rows.
/// IMPORTANT: this widget must NOT be shown for local FTS5 results — the
/// shimmer/banner is exclusively an API-latency indicator.
///
/// Uses [Theme.of(context).colorScheme] tokens — no hardcoded colors.
class ApiLoadingBanner extends StatelessWidget {
  /// Creates an [ApiLoadingBanner].
  const ApiLoadingBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // "Searching online..." banner
        Container(
          color: colorScheme.secondaryContainer,
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Searching online...',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                    ),
              ),
            ],
          ),
        ),
        // 5 shimmer skeleton rows
        Expanded(
          child: ListView.builder(
            itemCount: 5,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return Shimmer.fromColors(
                baseColor: colorScheme.surfaceContainerHighest,
                highlightColor: colorScheme.surface,
                child: Container(
                  height: 56,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
