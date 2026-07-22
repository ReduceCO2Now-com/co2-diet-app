import 'dart:async';

import 'package:co2diet/core/theme/color_tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A pill-shaped chip widget showing the CO₂ confidence band ('high' or 'medium').
///
/// - High → green background ([AppColors.primaryContainer])
/// - Medium → amber background ([AppColors.warningAmber])
///
/// ACC-04: Color-blind friendly — not relying on red/green alone. The amber
/// chip is visually distinct from the green chip in both color and label.
///
/// Tapping the chip invokes [onTap] — callers typically open [ConfidenceChip.showExplanation].
class ConfidenceChip extends StatelessWidget {
  /// Creates a [ConfidenceChip] for the given [band] ('high' or 'medium').
  const ConfidenceChip({
    required this.band,
    this.onTap,
    super.key,
  });

  /// The CO₂ confidence band — 'high' or 'medium'.
  final String band;

  /// Optional tap callback. If null, tapping has no effect.
  final VoidCallback? onTap;

  /// Shows the explanation bottom sheet for [band] via [showModalBottomSheet].
  ///
  /// This is a convenience static helper — callers can pass it directly as
  /// the [onTap] callback:
  /// ```dart
  /// ConfidenceChip(
  ///   band: item.confidenceBand!,
  ///   onTap: () => ConfidenceChip.showExplanation(context, item.confidenceBand!),
  /// )
  /// ```
  static void showExplanation(BuildContext context, String band) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        builder: (ctx) => ConfidenceExplanationSheet(band: band),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isHigh = band == 'high';
    final backgroundColor =
        isHigh ? AppColors.primaryContainer : AppColors.warningAmber;
    // Use white text on dark green; dark text on amber for contrast.
    final textColor = isHigh ? Colors.white : Colors.black87;
    final icon = isHigh ? Icons.check_circle_outline : Icons.info_outline;
    final label = isHigh ? 'High' : 'Medium';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet content explaining the CO₂ confidence band.
///
/// Shown when a [ConfidenceChip] is tapped. Provides plain-language context
/// for the confidence band and a 'Full methodology' link to [MethodologyScreen].
class ConfidenceExplanationSheet extends StatelessWidget {
  /// Creates a [ConfidenceExplanationSheet] for the given [band].
  const ConfidenceExplanationSheet({required this.band, super.key});

  /// The CO₂ confidence band — 'high' or 'medium'.
  final String band;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isHigh = band == 'high';
    final bandLabel = isHigh ? 'High' : 'Medium';
    final explanationText = isHigh
        ? 'Product-specific LCA value from AGRIBALYSE v3.1.1 '
            '(direct barcode match).'
        : 'Category-average estimate from AGRIBALYSE v3.1.1 '
            "(your product's category median).";

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'CO₂ Confidence: $bandLabel',
            style: textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(explanationText, style: textTheme.bodyMedium),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.push('/methodology'),
            child: const Text('Full methodology'),
          ),
        ],
      ),
    );
  }
}
