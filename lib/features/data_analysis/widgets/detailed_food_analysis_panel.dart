import 'package:co2diet/core/theme/color_tokens.dart';
import 'package:co2diet/domain/entities/meal_entry.dart';
import 'package:co2diet/domain/entities/portion_unit.dart';
import 'package:flutter/material.dart';

/// Expands in place under a `MealEntryRow`-shaped header (name + quantity/
/// unit summary) to reveal per-serving (scaled) and per-100g (raw
/// snapshot) values for every one of the 8 nutrient/CO2 fields [MealEntry]
/// carries (05-04) -- reuses the entry's existing snapshot fields, no new
/// data source. Renders `'—'` for any null field rather than a fabricated
/// `0`.
class DetailedFoodAnalysisPanel extends StatefulWidget {
  /// Creates a [DetailedFoodAnalysisPanel] for [entry].
  const DetailedFoodAnalysisPanel({required this.entry, super.key});

  /// The logged entry to reveal detail for.
  final MealEntry entry;

  @override
  State<DetailedFoodAnalysisPanel> createState() =>
      _DetailedFoodAnalysisPanelState();
}

class _DetailedFoodAnalysisPanelState
    extends State<DetailedFoodAnalysisPanel> {
  static String _formatQuantity(double value) =>
      value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toString();

  static String _formatValue(double? value, String unit) =>
      value == null ? '—' : '${value.toStringAsFixed(1)}$unit';

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final scaled = entry.unit.isWeightBased
        ? entry.scaled(entry.quantity)
        : const ScaledMacros();
    final textTheme = Theme.of(context).textTheme;

    return ExpansionTile(
      title: Text(entry.productNameSnapshot),
      subtitle: Text(
        '${_formatQuantity(entry.quantity)}${entry.unit.displayLabel}',
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(1.2),
              2: FlexColumnWidth(1.2),
            },
            children: [
              TableRow(
                children: [
                  const SizedBox.shrink(),
                  Text(
                    'Per serving',
                    style: textTheme.labelSmall,
                    textAlign: TextAlign.end,
                  ),
                  Text(
                    'Per 100g',
                    style: textTheme.labelSmall,
                    textAlign: TextAlign.end,
                  ),
                ],
              ),
              _nutrientRow(
                textTheme,
                'Calories',
                scaled.calories,
                entry.calories100gSnapshot,
                ' kcal',
              ),
              _nutrientRow(
                textTheme,
                'Protein',
                scaled.protein,
                entry.protein100gSnapshot,
                'g',
              ),
              _nutrientRow(
                textTheme,
                'Carbs',
                scaled.carbs,
                entry.carbs100gSnapshot,
                'g',
              ),
              _nutrientRow(
                textTheme,
                'Fat',
                scaled.fat,
                entry.fat100gSnapshot,
                'g',
              ),
              _nutrientRow(
                textTheme,
                'Sugar',
                scaled.sugar,
                entry.sugar100gSnapshot,
                'g',
              ),
              _nutrientRow(
                textTheme,
                'Fiber',
                scaled.fiber,
                entry.fiber100gSnapshot,
                'g',
              ),
              _nutrientRow(
                textTheme,
                'Salt',
                scaled.salt,
                entry.saltSnapshot,
                'g',
              ),
              _nutrientRow(
                textTheme,
                'CO₂e',
                scaled.co2e,
                entry.co2e100gSnapshot,
                ' kg',
              ),
            ],
          ),
        ),
      ],
    );
  }

  TableRow _nutrientRow(
    TextTheme textTheme,
    String label,
    double? perServing,
    double? per100g,
    String unit,
  ) {
    final labelStyle = textTheme.bodySmall?.copyWith(
      color: AppColors.onSurfaceVariant,
    );
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(label, style: labelStyle),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            _formatValue(perServing, unit),
            textAlign: TextAlign.end,
            style: textTheme.bodySmall,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            _formatValue(per100g, unit),
            textAlign: TextAlign.end,
            style: textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
