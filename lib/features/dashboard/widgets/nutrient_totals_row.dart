import 'package:co2diet/core/theme/color_tokens.dart';
import 'package:co2diet/domain/services/daily_totals_calculator.dart';
import 'package:flutter/material.dart';

/// Compact daily-total display for the four nutrients (NUTR-01) that have
/// no other aggregate-level UI surface: carbs, sugar, fiber, and salt
/// (salt, not sodium, per this codebase's existing EU-label convention --
/// see `DetailedFoodAnalysisPanel`/`CustomFoodFormScreen`'s "Salt" labels).
/// Calories and protein are already shown via Dashboard's `MetricCard`s;
/// this row fills the remaining gap rather than duplicating those two.
///
/// Reads directly off the same pre-computed [DailyTotals] the caller
/// already has (e.g. Dashboard's `todayTotals`, also passed to
/// `MacroSplitBar`) -- no recomputation, matching the rest of this
/// screen's "compute once per build" convention.
class NutrientTotalsRow extends StatelessWidget {
  /// Creates a [NutrientTotalsRow] for the pre-computed [totals].
  const NutrientTotalsRow({required this.totals, super.key});

  /// The day's pre-computed nutrient totals.
  final DailyTotals totals;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _NutrientStat(label: 'Carbs', grams: totals.carbs)),
        Expanded(child: _NutrientStat(label: 'Sugar', grams: totals.sugar)),
        Expanded(child: _NutrientStat(label: 'Fiber', grams: totals.fiber)),
        Expanded(child: _NutrientStat(label: 'Salt', grams: totals.salt)),
      ],
    );
  }
}

class _NutrientStat extends StatelessWidget {
  const _NutrientStat({required this.label, required this.grams});

  final String label;
  final double? grams;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // Dash for missing data rather than a fabricated 0 -- same "no fake
    // precision" convention as `MetricCard`/`DetailedFoodAnalysisPanel`.
    final valueText = grams == null ? '—' : '${grams!.round()}g';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        Text(
          valueText,
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
