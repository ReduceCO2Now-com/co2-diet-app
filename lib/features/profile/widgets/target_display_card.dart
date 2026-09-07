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
///
/// The value is laid out to survive an unexpectedly wide number. Cards sit in
/// a `GridView.extent(maxCrossAxisExtent: 160)`, and the override dialog
/// accepts any figure the user types, so the width of this text is not
/// something the card controls. It threw `A RenderFlex overflowed by 5.6
/// pixels` on device (2026-09-07) when a units bug produced a 10000 kcal
/// target — the bug is fixed, but a card should not be able to fail layout
/// because a number was larger than it expected.
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
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      color: colorScheme.surfaceContainerLow,
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
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              // Flexible in the Column as well as in the Row: the Row's
              // Flexible bounds width, but the card's height is fixed by the
              // grid's childAspectRatio, so at large text scales it is the
              // Column that runs out of room. Letting this row yield gives
              // the FittedBox inside it a smaller box to fit into.
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Both branches get the same treatment so they behave
                    // identically under pressure. Flexible bounds the
                    // content to the card; FittedBox shrinks it rather
                    // than clipping.
                    //
                    // Deliberately NOT ellipsis: a truncated "1000…" reads
                    // as a different, plausible target, which is worse than
                    // a smaller but correct one. scaleDown never enlarges,
                    // so ordinary values render untouched.
                    //
                    // This also contains vertical growth. At the ACC-02 1.6x
                    // text-scale ceiling the 20px value line pushes the Column
                    // past the card's height (the grid fixes it via
                    // childAspectRatio), and scaling the child down resolves
                    // that too — which is why the dash needs the same wrapper
                    // and not just the number.
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: value != null
                            ? Text(
                                '${value!.toStringAsFixed(0)} $unit',
                                maxLines: 1,
                                style: AppTextTheme.titleMd.copyWith(
                                  color: colorScheme.onSurface,
                                ),
                              )
                            : const MissingTargetDash(
                                tooltip:
                                    'Add height and weight to see targets.',
                              ),
                      ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
