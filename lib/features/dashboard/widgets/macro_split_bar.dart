import 'package:co2diet/core/theme/color_tokens.dart';
import 'package:co2diet/domain/services/daily_totals_calculator.dart';
import 'package:flutter/material.dart';

/// Renders [DailyTotals.macroSplit] (NUTR-04) as a single horizontal bar
/// with three proportional colored segments (protein/carbs/fat) and a
/// legend below. Renders an empty-state message when [split] is `null`
/// (nothing logged today, or macro fields all null).
class MacroSplitBar extends StatelessWidget {
  /// Creates a [MacroSplitBar] for [split].
  const MacroSplitBar({required this.split, super.key});

  /// The macro split to render, or `null` for the empty state.
  final MacroSplit? split;

  static const Color _proteinColor = AppColors.primaryContainer;
  static const Color _carbsColor = AppColors.secondaryContainer;
  static const Color _fatColor = AppColors.warningAmber;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final split = this.split;

    if (split == null) {
      return Text(
        'No macro data yet today',
        style: textTheme.bodySmall?.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 10,
            child: Row(
              children: [
                Expanded(
                  flex: (split.proteinPct * 10).round().clamp(0, 1000),
                  child: const ColoredBox(color: _proteinColor),
                ),
                Expanded(
                  flex: (split.carbsPct * 10).round().clamp(0, 1000),
                  child: const ColoredBox(color: _carbsColor),
                ),
                Expanded(
                  flex: (split.fatPct * 10).round().clamp(0, 1000),
                  child: const ColoredBox(color: _fatColor),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          children: [
            _LegendEntry(
              color: _proteinColor,
              label: 'Protein ${split.proteinPct.round()}%',
            ),
            _LegendEntry(
              color: _carbsColor,
              label: 'Carbs ${split.carbsPct.round()}%',
            ),
            _LegendEntry(
              color: _fatColor,
              label: 'Fat ${split.fatPct.round()}%',
            ),
          ],
        ),
      ],
    );
  }
}

class _LegendEntry extends StatelessWidget {
  const _LegendEntry({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
