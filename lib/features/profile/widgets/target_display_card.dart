import 'package:co2diet/core/theme/color_tokens.dart';
import 'package:co2diet/core/theme/spacing_tokens.dart';
import 'package:co2diet/core/theme/text_tokens.dart';
import 'package:co2diet/features/profile/widgets/missing_target_dash.dart';
import 'package:flutter/material.dart';

/// Displays a single macro/calorie target as a tappable card.
///
/// When [value] is null, renders [MissingTargetDash] (—).
/// When [isOverridden] is true, shows a pencil icon indicator to signal
/// the value was manually set by the user.
///
/// Tapping the card triggers [onTap], which opens an inline override dialog
/// (handled by the caller in ProfileScreen).
class TargetDisplayCard extends StatelessWidget {
  /// Creates a [TargetDisplayCard].
  const TargetDisplayCard({
    required this.label,
    required this.unit,
    this.value,
    this.isOverridden = false,
    this.onTap,
    super.key,
  });

  /// Human-readable label, e.g. 'Calories', 'Protein'.
  final String label;

  /// Unit string, e.g. 'kcal', 'g'.
  final String unit;

  /// The computed (or overridden) target value. `null` → show dash.
  final double? value;

  /// Whether this value was manually set by the user.
  final bool isOverridden;

  /// Called when the card is tapped (opens override dialog).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surfaceContainerLow,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.base * 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTextTheme.bodySm.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (value != null)
                    Text(
                      '${value!.toStringAsFixed(0)} $unit',
                      style: AppTextTheme.titleMd.copyWith(
                        color: AppColors.onSurface,
                      ),
                    )
                  else
                    const MissingTargetDash(
                      tooltip: 'Add height and weight to see targets.',
                    ),
                  if (isOverridden) ...[
                    const SizedBox(width: AppSpacing.base),
                    const Icon(
                      Icons.edit,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
