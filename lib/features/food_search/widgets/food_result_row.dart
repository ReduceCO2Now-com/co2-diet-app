import 'package:co2diet/domain/entities/food_item.dart';
import 'package:flutter/material.dart';

/// Compact list row showing name (bold), brand (secondary), calories/100g.
///
/// Tapping the row calls [onTap] — the caller is responsible for opening the
/// food detail sheet (see `showFoodDetailSheet` in food_detail_sheet.dart).
///
/// Layout: [ListTile] with bold product name as title, and a [Row] subtitle
/// containing brand (omitted if null/empty) + spacer + calorie count.
///
/// All colors come from [Theme.of(context).colorScheme] — no hardcoded hex.
class FoodResultRow extends StatelessWidget {
  /// Creates a [FoodResultRow] for [item].
  const FoodResultRow({required this.item, required this.onTap, super.key});

  /// The food item to display.
  final FoodItem item;

  /// Called when the row is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(
        item.productName,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(fontWeight: FontWeight.bold),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: _buildSubtitle(context),
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    final secondaryStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        );

    final calText = item.calories100g != null
        ? '${item.calories100g!.round()} kcal/100g'
        : '— kcal/100g';

    final hasBrand = item.brand != null && item.brand!.isNotEmpty;

    return Row(
      children: [
        if (hasBrand) ...[
          Flexible(
            child: Text(
              item.brand!,
              style: secondaryStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Spacer(),
        ] else
          const Spacer(),
        Text(calText, style: secondaryStyle),
      ],
    );
  }
}
