import 'dart:async';

import 'package:co2diet/domain/entities/food_item.dart';
import 'package:co2diet/features/barcode_scan/utils/co2_formatter.dart';
import 'package:co2diet/features/barcode_scan/widgets/confidence_chip.dart';
import 'package:flutter/material.dart';

/// Displays a read-only bottom sheet with [item]'s name, brand, per-100g
/// macros, and a CO₂e row when data is available.
///
/// CO₂ row is shown when [FoodItem.co2e100g] is non-null; hidden entirely
/// (no placeholder '—') when null — per CONTEXT.md "No CO₂ shown rather
/// than a Low-confidence guess".
/// The "Log this food" action button is deferred to Phase 4.
///
/// Use [showFoodDetailSheet] to present the sheet from a [BuildContext].
void showFoodDetailSheet(BuildContext context, FoodItem item) {
  unawaited(
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FoodDetailContent(item: item),
    ),
  );
}

class _FoodDetailContent extends StatelessWidget {
  const _FoodDetailContent({required this.item});

  final FoodItem item;

  @override
  Widget build(BuildContext context) {
    final hasBrand = item.brand != null && item.brand!.isNotEmpty;

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
          // Product name
          Text(
            item.productName,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          // Brand (optional)
          if (hasBrand) ...[
            const SizedBox(height: 4),
            Text(
              item.brand!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
          const Divider(height: 24),
          // Per-100g macro table
          _MacroRow(
            label: 'Calories',
            value: '${item.calories100g?.round() ?? '—'} kcal',
          ),
          _MacroRow(
            label: 'Protein',
            value: '${item.protein100g?.toStringAsFixed(1) ?? '—'} g',
          ),
          _MacroRow(
            label: 'Carbohydrates',
            value: '${item.carbs100g?.toStringAsFixed(1) ?? '—'} g',
          ),
          _MacroRow(
            label: 'Fat',
            value: '${item.fat100g?.toStringAsFixed(1) ?? '—'} g',
          ),
          // CO₂ row — only shown when co2e100g is non-null (CO2-01).
          // Hidden entirely (not '—') when null per CONTEXT.md design decision.
          if (item.co2e100g != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'CO₂e estimate:',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        formatCo2Display(item.co2e100g)!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (item.confidenceBand != null) ...[
                        const SizedBox(width: 6),
                        ConfidenceChip(
                          band: item.confidenceBand!,
                          onTap: () => ConfidenceChip.showExplanation(
                            context,
                            item.confidenceBand!,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            'per 100g',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          // TODO(phase-4): Add 'Log this food' FilledButton here.
        ],
      ),
    );
  }
}

/// A single label/value row in the macro table inside [_FoodDetailContent].
class _MacroRow extends StatelessWidget {
  const _MacroRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
