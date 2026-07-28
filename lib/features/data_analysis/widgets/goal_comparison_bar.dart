import 'package:co2diet/core/theme/color_tokens.dart';
import 'package:flutter/material.dart';

/// Renders a progress bar (value/target) plus a short dynamic factual
/// message (e.g. "62% of your CO2 target used today") -- never judgmental
/// language (NFR-01/NFR-02).
///
/// Renders an honest "no target set" message when [target] is `null` or
/// non-positive -- never a fabricated percentage (no false precision).
class GoalComparisonBar extends StatelessWidget {
  /// Creates a [GoalComparisonBar] comparing [value] against [target] for
  /// [label] (e.g. `'CO₂'`, `'Calories'`).
  const GoalComparisonBar({
    required this.value,
    required this.target,
    required this.label,
    super.key,
  });

  /// The metric's current value, or `null` when nothing has contributed
  /// yet.
  final double? value;

  /// The metric's target, or `null`/non-positive when no target is set.
  final double? target;

  /// The metric's display name.
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final target = this.target;

    if (target == null || target <= 0) {
      return Text(
        'No $label target set yet',
        style: textTheme.bodySmall?.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
      );
    }

    final currentValue = value ?? 0;
    final ratio = (currentValue / target).clamp(0.0, 1.0);
    final pct = (currentValue / target * 100).clamp(0, 999).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            backgroundColor: AppColors.surfaceContainerHigh,
            color: AppColors.primaryContainer,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$pct% of your $label target used today',
          style: textTheme.bodySmall,
        ),
      ],
    );
  }
}
