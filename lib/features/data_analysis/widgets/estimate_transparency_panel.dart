import 'package:co2diet/core/theme/color_tokens.dart';
import 'package:co2diet/domain/entities/meal_entry.dart';
import 'package:co2diet/domain/entities/portion_unit.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Summarizes the proportion of High vs. Medium confidence entries
/// contributing to today's aggregate CO2 total (e.g. "3 of 5 items are
/// High confidence") -- never renders a single food's `ConfidenceChip`
/// alone; this is a distinct aggregate-confidence-mix view.
class EstimateTransparencyPanel extends StatelessWidget {
  /// Creates an [EstimateTransparencyPanel] for [entries] (typically
  /// today's entries).
  const EstimateTransparencyPanel({required this.entries, super.key});

  /// The entries whose CO2 confidence bands to summarize.
  final List<MealEntry> entries;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final contributors = entries
        .where(
          (entry) => entry.unit.isWeightBased && entry.co2e100gSnapshot != null,
        )
        .toList();
    final total = contributors.length;

    if (total == 0) {
      return Text(
        'No CO₂ estimates logged today yet',
        style: textTheme.bodySmall?.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
      );
    }

    final highCount = contributors
        .where((entry) => entry.confidenceBandSnapshot == 'high')
        .length;
    final mediumCount = contributors
        .where((entry) => entry.confidenceBandSnapshot == 'medium')
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$highCount of $total items are High confidence',
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 8,
            child: Row(
              children: [
                if (highCount > 0)
                  Expanded(
                    flex: highCount,
                    child: const ColoredBox(color: AppColors.primaryContainer),
                  ),
                if (mediumCount > 0)
                  Expanded(
                    flex: mediumCount,
                    child: const ColoredBox(color: AppColors.warningAmber),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => context.push('/methodology'),
          child: const Text('Full methodology'),
        ),
      ],
    );
  }
}
