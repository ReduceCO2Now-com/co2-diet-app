import 'package:co2diet/core/theme/color_tokens.dart';
import 'package:co2diet/domain/entities/meal_entry.dart';
import 'package:co2diet/domain/entities/meal_slot.dart';
import 'package:co2diet/domain/entities/portion_unit.dart';
import 'package:co2diet/features/data_analysis/widgets/analysis_metric.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// A small fixed color palette cycled per stacked segment -- reuses
/// `AppColors` tokens, no new colors invented.
const List<Color> _stackPalette = [
  AppColors.primaryContainer,
  AppColors.secondaryContainer,
  AppColors.warningAmber,
  AppColors.tertiaryContainer,
  AppColors.skyBlue,
  AppColors.leafGreen,
];

/// Today's breakdown-by-meal as a genuine stacked `fl_chart` `BarChart`
/// (REQUIREMENTS.md's literal "today's breakdown by meal (stacked bar)"):
/// exactly 4 bars (Breakfast/Lunch/Dinner/Snack), each stacked by that
/// slot's individual weight-based-unit entries via
/// [BarChartRodStackItem] -- a slot with 3 logged items shows 3 visually
/// distinct stacked segments.
///
/// An empty slot still renders a zero-height bar (not omitted) -- keeps
/// the 4-slot x-axis stable.
class TodayBreakdownBarChart extends StatelessWidget {
  /// Creates a [TodayBreakdownBarChart] for [entries] (today's entries),
  /// plotting [metric] (co2/calories/protein -- [AnalysisMetric.weight]
  /// contributes nothing, since weight isn't logged per-meal).
  const TodayBreakdownBarChart({
    required this.entries,
    required this.metric,
    super.key,
  });

  /// Today's logged entries (any slot).
  final List<MealEntry> entries;

  /// Which metric to plot -- one of co2/calories/protein.
  final AnalysisMetric metric;

  double? _valueFor(MealEntry entry) {
    if (!entry.unit.isWeightBased) return null;
    final scaled = entry.scaled(entry.quantity);
    return switch (metric) {
      AnalysisMetric.co2 => scaled.co2e,
      AnalysisMetric.calories => scaled.calories,
      AnalysisMetric.protein => scaled.protein,
      AnalysisMetric.weight => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final barGroups = <BarChartGroupData>[];

    for (var slotIndex = 0; slotIndex < MealSlot.values.length; slotIndex++) {
      final slot = MealSlot.values[slotIndex];
      final slotEntries = entries
          .where((entry) => entry.mealSlot == slot && entry.unit.isWeightBased)
          .toList();

      final stackItems = <BarChartRodStackItem>[];
      var runningTotal = 0.0;
      for (var i = 0; i < slotEntries.length; i++) {
        final value = _valueFor(slotEntries[i]) ?? 0;
        final from = runningTotal;
        final to = runningTotal + value;
        stackItems.add(
          BarChartRodStackItem(
            from,
            to,
            _stackPalette[i % _stackPalette.length],
          ),
        );
        runningTotal = to;
      }

      barGroups.add(
        BarChartGroupData(
          x: slotIndex,
          barRods: [
            BarChartRodData(
              toY: runningTotal,
              width: 22,
              rodStackItems: stackItems,
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          barGroups: barGroups,
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              // maxIncluded: false -- without this, fl_chart always forces
              // an extra label at the exact max data value in addition to
              // its regular interval-spaced labels. When the max isn't a
              // clean multiple of the interval (e.g. 850 with a 200
              // interval), that extra label lands almost on top of the
              // last regular one, rendering as overlapping/out-of-order
              // text (UAT bug #2a).
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                maxIncluded: false,
              ),
            ),
            rightTitles: const AxisTitles(),
            topTitles: const AxisTitles(),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= MealSlot.values.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      MealSlot.values[index].displayLabel,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}
