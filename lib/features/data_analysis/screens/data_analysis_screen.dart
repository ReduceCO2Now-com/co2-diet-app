import 'dart:async';

import 'package:co2diet/core/di/app_providers.dart';
import 'package:co2diet/core/di/meal_logging_providers.dart';
import 'package:co2diet/core/theme/color_tokens.dart';
import 'package:co2diet/core/theme/spacing_tokens.dart';
import 'package:co2diet/core/theme/text_tokens.dart';
import 'package:co2diet/domain/services/daily_totals_calculator.dart';
import 'package:co2diet/domain/services/improvement_opportunity_finder.dart';
import 'package:co2diet/domain/services/insights_timeline_rule_engine.dart';
import 'package:co2diet/features/data_analysis/widgets/analysis_metric.dart';
import 'package:co2diet/features/data_analysis/widgets/detailed_food_analysis_panel.dart';
import 'package:co2diet/features/data_analysis/widgets/estimate_transparency_panel.dart';
import 'package:co2diet/features/data_analysis/widgets/goal_comparison_bar.dart';
import 'package:co2diet/features/data_analysis/widgets/improvement_opportunities.dart';
import 'package:co2diet/features/data_analysis/widgets/insights_timeline.dart';
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

// CO2-06 invariant: `ImprovementOpportunities` and `InsightsTimeline`
// (imported above) are never imported by, or referenced from, anything
// under `lib/features/dashboard/` -- verified by grep and by
// `improvement_opportunities_test.dart`'s dedicated widget-tree assertion
// against `PlaceholderDashboardScreen`. Both widgets are wired exclusively
// into this screen's `_NutritionBody`, below.

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

/// One-shot Improvement Opportunities (CO2-06) computed over today's
/// entries via [ImprovementOpportunityFinder] (injected through
/// [improvementOpportunityFinderProvider]).
final FutureProvider<List<ImprovementOpportunity>>
_improvementOpportunitiesProvider =
    FutureProvider.autoDispose<List<ImprovementOpportunity>>((ref) async {
      final todayEntries = await ref.watch(mealEntryProvider.future);
      final finder = ref.watch(improvementOpportunityFinderProvider);
      return finder.findOpportunities(todayEntries);
    });

/// One-shot Insights Timeline (INS-03) computed over a trailing-7-day
/// pooled entry query via [InsightsTimelineRuleEngine] -- a second,
/// distinct trailing-7-day query from [_weeklyTotalsProvider]'s, since the
/// rule engine needs the raw per-entry list (not a pre-aggregated total)
/// to group by weekday/dinner-slot.
final FutureProvider<List<String>> _insightsTimelineProvider =
    FutureProvider.autoDispose<List<String>>((ref) async {
      final repo = ref.watch(mealEntryRepositoryProvider);
      final now = DateTime.now();
      final from = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(const Duration(days: 6));
      final entries = await repo.getEntriesInRange(from, now);
      final targets = ref.watch(profileProvider).value?.targets;
      const engine = InsightsTimelineRuleEngine();
      return engine.evaluate(entries, proteinTargetG: targets?.proteinGTarget);
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
/// range trend chart, an aggregate Estimate Transparency panel, a
/// per-entry expandable Detailed Food Analysis list, Improvement
/// Opportunities (CO2-06), and the Insights Timeline (INS-03) -- plus the
/// Weight metric entry (WT-05).
///
/// Not yet wired into `app_router.dart` or reachable from the Dashboard --
/// Plan 05-18 adds the route and Dashboard-tap wiring. Plan 05-17 adds
/// Improvement Opportunities and the Insights Timeline into
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
    final improvementOpportunitiesAsync = ref.watch(
      _improvementOpportunitiesProvider,
    );
    final insightsTimelineAsync = ref.watch(_insightsTimelineProvider);
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
            const SizedBox(height: AppSpacing.lg),

            // CO2-06: rendered ONLY here, inside Data Analysis -- never the
            // Dashboard, never a notification.
            const Text(
              'Improvement opportunities',
              style: AppTextTheme.titleMd,
            ),
            const SizedBox(height: AppSpacing.stackGap),
            improvementOpportunitiesAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (e, st) => const SizedBox.shrink(),
              data: (opportunities) =>
                  ImprovementOpportunities(opportunities: opportunities),
            ),
            const SizedBox(height: AppSpacing.lg),

            // INS-03: small fixed rule set, never a forced/fabricated line.
            const Text('Insights timeline', style: AppTextTheme.titleMd),
            const SizedBox(height: AppSpacing.stackGap),
            insightsTimelineAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (e, st) => const SizedBox.shrink(),
              data: (observations) =>
                  InsightsTimeline(observations: observations),
            ),
          ],
        );
      },
    );
  }
}
