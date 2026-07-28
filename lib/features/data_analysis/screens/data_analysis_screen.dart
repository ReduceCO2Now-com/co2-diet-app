import 'dart:async';

import 'package:co2diet/core/di/meal_logging_providers.dart';
import 'package:co2diet/core/theme/color_tokens.dart';
import 'package:co2diet/core/theme/spacing_tokens.dart';
import 'package:co2diet/core/theme/text_tokens.dart';
import 'package:co2diet/domain/services/daily_totals_calculator.dart';
import 'package:co2diet/features/data_analysis/widgets/analysis_metric.dart';
import 'package:co2diet/features/data_analysis/widgets/detailed_food_analysis_panel.dart';
import 'package:co2diet/features/data_analysis/widgets/estimate_transparency_panel.dart';
import 'package:co2diet/features/data_analysis/widgets/goal_comparison_bar.dart';
import 'package:co2diet/features/data_analysis/widgets/ranked_contributors_list.dart';
import 'package:co2diet/features/data_analysis/widgets/today_breakdown_bar_chart.dart';
import 'package:co2diet/features/data_analysis/widgets/trend_section.dart';
import 'package:co2diet/features/data_analysis/widgets/weekly_total_summary.dart';
import 'package:co2diet/features/meal_logging/providers/meal_entry_notifier.dart';
import 'package:co2diet/features/profile/providers/profile_notifier.dart';
import 'package:co2diet/features/weight/widgets/weight_chart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One-shot trailing-7-day pooled [DailyTotals] (today inclusive), powering
/// [WeeklyTotalSummary] (CO2-02's explicit "weekly total" success
/// criterion) -- deliberately a second, distinct
/// `DailyTotalsCalculator.compute()` call from the one powering today's
/// breakdown, never derived from or reusing that result.
final FutureProvider<DailyTotals> _weeklyTotalsProvider =
    FutureProvider.autoDispose<DailyTotals>((ref) async {
  final repo = ref.watch(mealEntryRepositoryProvider);
  final now = DateTime.now();
  final from = DateTime(
    now.year,
    now.month,
    now.day,
  ).subtract(const Duration(days: 6));
  final entries = await repo.getEntriesInRange(from, now);
  return DailyTotalsCalculator.compute(entries);
});

/// Formats [date] as a `yyyy-MM-dd` logical log date, matching
/// `MealEntryRepository`'s established `_formatLogDate` convention.
String _logDateOf(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

/// The Data Analysis screen (INS-01/INS-02): today's stacked-bar meal
/// breakdown, an explicit weekly total, ranked Largest Contributors, a
/// goal-comparison progress bar, an independently-toggleable metric x
/// range trend chart, an aggregate Estimate Transparency panel, and a
/// per-entry expandable Detailed Food Analysis list -- plus the Weight
/// metric entry (WT-05).
///
/// Not yet wired into `app_router.dart` or reachable from the Dashboard --
/// Plan 05-18 adds the route and Dashboard-tap wiring. Plan 05-17 (next
/// wave) adds Improvement Opportunities and the Insights Timeline into
/// this same screen file.
class DataAnalysisScreen extends ConsumerWidget {
  /// Creates the [DataAnalysisScreen] pre-set to [initialMetric].
  const DataAnalysisScreen({required this.initialMetric, super.key});

  /// Which metric this screen opened pre-set to -- ranks Largest
  /// Contributors and pre-sets the trend toggle by this same metric,
  /// except [AnalysisMetric.weight], which renders an entirely distinct
  /// weight-trend body, never calorie/protein/CO2 data.
  final AnalysisMetric initialMetric;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          'Data Analysis · ${initialMetric.displayLabel}',
          style: AppTextTheme.headlineLgMobile,
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: initialMetric == AnalysisMetric.weight
            ? _WeightBody(currentMetric: initialMetric)
            : _NutritionBody(currentMetric: initialMetric),
      ),
    );
  }
}

/// Metric selector row (CO2/Calories/Protein/Weight) -- tapping any entry
/// re-enters [DataAnalysisScreen] pre-set to that metric. WT-05's explicit
/// Weight entry, generalized to every metric for one consistent
/// navigation pattern.
class _MetricSelector extends StatelessWidget {
  const _MetricSelector({required this.currentMetric});

  final AnalysisMetric currentMetric;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      children: [
        for (final metric in AnalysisMetric.values)
          ChoiceChip(
            label: Text(metric.displayLabel),
            selected: metric == currentMetric,
            onSelected: (_) {
              if (metric == currentMetric) return;
              unawaited(
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => DataAnalysisScreen(initialMetric: metric),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

/// Weight-metric body (WT-05): metric selector + the existing
/// `WeightChart` -- a genuinely distinct weight-trend view, never
/// calorie/protein/CO2 data.
class _WeightBody extends StatelessWidget {
  const _WeightBody({required this.currentMetric});

  final AnalysisMetric currentMetric;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.containerMargin),
      children: [
        _MetricSelector(currentMetric: currentMetric),
        const SizedBox(height: AppSpacing.lg),
        const Text('Weight trend', style: AppTextTheme.titleMd),
        const SizedBox(height: AppSpacing.stackGap),
        const WeightChart(),
      ],
    );
  }
}

/// CO2/Calories/Protein body: assembles every nutrition-facing section, in
/// order -- stacked-bar breakdown, weekly total, contributors, goal
/// comparison, trend, transparency, detailed food analysis.
class _NutritionBody extends ConsumerWidget {
  const _NutritionBody({required this.currentMetric});

  final AnalysisMetric currentMetric;

  double? _valueFor(AnalysisMetric metric, DailyTotals totals) =>
      switch (metric) {
        AnalysisMetric.co2 => totals.co2e,
        AnalysisMetric.calories => totals.calories,
        AnalysisMetric.protein => totals.protein,
        AnalysisMetric.weight => null,
      };

  Future<List<FlSpot>> _fetchTrendSpots(
    WidgetRef ref, {
    required AnalysisMetric metric,
    required int rangeDays,
  }) async {
    final repo = ref.read(mealEntryRepositoryProvider);
    final now = DateTime.now();
    final from = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: rangeDays - 1));
    final entries = await repo.getEntriesInRange(from, now);

    return [
      for (var i = 0; i < rangeDays; i++)
        FlSpot(
          i.toDouble(),
          _valueFor(
                metric,
                DailyTotalsCalculator.compute(
                  entries
                      .where(
                        (entry) =>
                            entry.logDate ==
                            _logDateOf(from.add(Duration(days: i))),
                      )
                      .toList(),
                ),
              ) ??
              0,
        ),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(mealEntryProvider);
    final weeklyTotalsAsync = ref.watch(_weeklyTotalsProvider);
    final targets = ref.watch(profileProvider).value?.targets;

    return entriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => const Center(child: Text('Error loading today’s data')),
      data: (todayEntries) {
        final todayTotals = DailyTotalsCalculator.compute(todayEntries);
        final goalValue = _valueFor(currentMetric, todayTotals);
        final goalTarget = switch (currentMetric) {
          AnalysisMetric.co2 => targets?.co2GTarget,
          AnalysisMetric.calories => targets?.kcalTarget,
          AnalysisMetric.protein => targets?.proteinGTarget,
          AnalysisMetric.weight => null,
        };

        return ListView(
          padding: const EdgeInsets.all(AppSpacing.containerMargin),
          children: [
            _MetricSelector(currentMetric: currentMetric),
            const SizedBox(height: AppSpacing.lg),

            const Text("Today's breakdown", style: AppTextTheme.titleMd),
            const SizedBox(height: AppSpacing.stackGap),
            TodayBreakdownBarChart(
              entries: todayEntries,
              metric: currentMetric,
            ),
            const SizedBox(height: AppSpacing.lg),

            const Text('Weekly total', style: AppTextTheme.titleMd),
            const SizedBox(height: AppSpacing.stackGap),
            weeklyTotalsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => const Text('—'),
              data: (totals) => WeeklyTotalSummary(totals: totals),
            ),
            const SizedBox(height: AppSpacing.lg),

            const Text('Largest contributors', style: AppTextTheme.titleMd),
            const SizedBox(height: AppSpacing.stackGap),
            RankedContributorsList(
              entries: todayEntries,
              metric: currentMetric,
            ),
            const SizedBox(height: AppSpacing.lg),

            Text(
              '${currentMetric.displayLabel} goal',
              style: AppTextTheme.titleMd,
            ),
            const SizedBox(height: AppSpacing.stackGap),
            GoalComparisonBar(
              value: goalValue,
              target: goalTarget,
              label: currentMetric.displayLabel,
            ),
            const SizedBox(height: AppSpacing.lg),

            const Text('Trend', style: AppTextTheme.titleMd),
            const SizedBox(height: AppSpacing.stackGap),
            TrendSection(
              initialMetric: currentMetric,
              fetchSpots: ({required metric, required rangeDays}) =>
                  _fetchTrendSpots(ref, metric: metric, rangeDays: rangeDays),
            ),
            const SizedBox(height: AppSpacing.lg),

            const Text('Estimate transparency', style: AppTextTheme.titleMd),
            const SizedBox(height: AppSpacing.stackGap),
            EstimateTransparencyPanel(entries: todayEntries),
            const SizedBox(height: AppSpacing.lg),

            const Text('Food details', style: AppTextTheme.titleMd),
            const SizedBox(height: AppSpacing.stackGap),
            for (final entry in todayEntries)
              DetailedFoodAnalysisPanel(entry: entry),
          ],
        );
      },
    );
  }
}
