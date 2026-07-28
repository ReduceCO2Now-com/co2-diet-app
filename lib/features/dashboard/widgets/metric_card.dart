import 'package:co2diet/core/theme/color_tokens.dart';
import 'package:flutter/material.dart';

/// A single Dashboard metric summary card (DASH-01/04/05/06): shows
/// [label], a formatted [value] (or `'—'` when null -- no fake precision,
/// same convention as `CalcTargets`'s nullable fields), an optional
/// `'of {target}'` suffix,
/// and a linear progress indicator when both [value] and [target] are
/// non-null.
///
/// [isEmphasized] is the visual hook for "the metric matching the user's
/// Profile goal is ordered/sized first" (CONTEXT.md Dashboard Composition)
/// -- this widget only renders whatever emphasis flag it's given; deciding
/// *which* metric matches the user's goal is Plan 05-18's Dashboard-assembly
/// concern.
class MetricCard extends StatelessWidget {
  /// Creates a [MetricCard].
  const MetricCard({
    required this.label,
    required this.value,
    required this.target,
    required this.unit,
    this.isEmphasized = false,
    super.key,
  });

  /// The metric's display name, e.g. `'CO₂'`, `'Calories'`, `'Protein'`.
  final String label;

  /// The metric's current value, or `null` when not yet computable.
  final double? value;

  /// The metric's target, or `null` when not yet computable.
  final double? target;

  /// Unit suffix, e.g. `'kcal'`, `'g'`, `'kg CO2e'`.
  final String unit;

  /// Whether this card is the goal-matching metric -- renders larger text
  /// and a primary-accent border when `true`.
  final bool isEmphasized;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final valueText = value == null ? '—' : _formatNumber(value!);
    final progress = (value != null && target != null && target! > 0)
        ? (value! / target!).clamp(0.0, 1.0)
        : null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: isEmphasized
            ? Border.all(color: AppColors.primaryContainer, width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                valueText,
                style:
                    (isEmphasized
                            ? textTheme.headlineMedium
                            : textTheme.titleLarge)
                        ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 4),
              Text(unit, style: textTheme.bodySmall),
              if (target != null) ...[
                const SizedBox(width: 4),
                Text(
                  'of ${_formatNumber(target!)}',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
          if (progress != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: AppColors.surfaceContainerHigh,
                color: AppColors.primaryContainer,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Formats [n] without a trailing `.0` for whole numbers, matching this
  /// codebase's "no fake precision" number-display convention.
  static String _formatNumber(double n) =>
      n == n.roundToDouble() ? n.toStringAsFixed(0) : n.toStringAsFixed(1);
}
