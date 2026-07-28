import 'package:co2diet/domain/entities/meal_entry.dart';
import 'package:co2diet/domain/entities/meal_slot.dart';
import 'package:co2diet/domain/entities/portion_unit.dart';
import 'package:co2diet/domain/services/daily_totals_calculator.dart';
import 'package:co2diet/features/data_analysis/widgets/analysis_metric.dart';
import 'package:co2diet/features/data_analysis/widgets/estimate_transparency_panel.dart';
import 'package:co2diet/features/data_analysis/widgets/ranked_contributors_list.dart';
import 'package:co2diet/features/data_analysis/widgets/today_breakdown_bar_chart.dart';
import 'package:co2diet/features/data_analysis/widgets/weekly_total_summary.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Builds a minimal [MealEntry] for widget-level tests. `quantity: 100` +
/// `unit: PortionUnit.g` makes every `*100gSnapshot` field equal its scaled
/// value directly (100g / 100 == 1x), keeping test data simple to reason
/// about.
MealEntry _entry({
  required String id,
  MealSlot slot = MealSlot.lunch,
  String name = 'Test food',
  double? calories,
  double? protein,
  double? co2e,
  String? confidenceBand,
  PortionUnit unit = PortionUnit.g,
}) {
  return MealEntry(
    id: id,
    mealSlot: slot,
    foodRef: 'ref-$id',
    foodRefSource: 'off_ref',
    quantity: 100,
    unit: unit,
    productNameSnapshot: name,
    loggedAt: DateTime(2026, 1, 1, 12),
    logDate: '2026-01-01',
    calories100gSnapshot: calories,
    protein100gSnapshot: protein,
    co2e100gSnapshot: co2e,
    confidenceBandSnapshot: confidenceBand,
  );
}

void main() {
  group('TodayBreakdownBarChart', () {
    testWidgets(
      'stacks one segment per weight-based entry in a slot, and renders '
      'a zero-height bar for empty slots',
      (tester) async {
        final entries = [
          _entry(id: '1', slot: MealSlot.lunch, calories: 200),
          _entry(id: '2', slot: MealSlot.lunch, calories: 150),
          _entry(id: '3', slot: MealSlot.lunch, calories: 100),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TodayBreakdownBarChart(
                entries: entries,
                metric: AnalysisMetric.calories,
              ),
            ),
          ),
        );

        final chart = tester.widget<BarChart>(find.byType(BarChart));
        final lunchIndex = MealSlot.values.indexOf(MealSlot.lunch);
        final breakfastIndex = MealSlot.values.indexOf(MealSlot.breakfast);

        final lunchGroup = chart.data.barGroups[lunchIndex];
        expect(lunchGroup.barRods.single.rodStackItems, hasLength(3));
        expect(lunchGroup.barRods.single.toY, 450);

        final breakfastGroup = chart.data.barGroups[breakfastIndex];
        expect(breakfastGroup.barRods.single.rodStackItems, isEmpty);
        expect(breakfastGroup.barRods.single.toY, 0);

        // Always exactly 4 bars -- the x-axis never shrinks/omits slots.
        expect(chart.data.barGroups, hasLength(4));
      },
    );
  });

  group('WeeklyTotalSummary', () {
    testWidgets('displays an explicit weekly figure', (tester) async {
      const totals = DailyTotals(
        calories: 10500,
        protein: 350,
        co2e: 21.4,
        includedEntryCount: 7,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: WeeklyTotalSummary(totals: totals)),
        ),
      );

      expect(find.textContaining('This week'), findsOneWidget);
      expect(find.textContaining('10500 kcal'), findsOneWidget);
      expect(find.textContaining('350g protein'), findsOneWidget);
    });
  });

  group('RankedContributorsList', () {
    testWidgets('sorts entries by the given metric, descending', (
      tester,
    ) async {
      final entries = [
        _entry(id: 'a', name: 'Apple', calories: 50),
        _entry(id: 'b', name: 'Burger', calories: 500),
        _entry(id: 'c', name: 'Carrot', calories: 30),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RankedContributorsList(
              entries: entries,
              metric: AnalysisMetric.calories,
            ),
          ),
        ),
      );

      final titleFinder = find.byType(ListTile);
      final titles = tester
          .widgetList<ListTile>(titleFinder)
          .map((tile) => (tile.title! as Text).data)
          .toList();

      expect(titles, ['Burger', 'Apple', 'Carrot']);
    });
  });

  group('EstimateTransparencyPanel', () {
    testWidgets(
      'summarizes the High/Medium confidence mix contributing to the '
      'aggregate total',
      (tester) async {
        final entries = [
          _entry(id: '1', co2e: 1, confidenceBand: 'high'),
          _entry(id: '2', co2e: 1, confidenceBand: 'high'),
          _entry(id: '3', co2e: 1, confidenceBand: 'medium'),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: EstimateTransparencyPanel(entries: entries)),
          ),
        );

        expect(find.textContaining('2 of 3'), findsOneWidget);
      },
    );
  });
}
