import 'dart:async';

import 'package:co2diet/core/di/meal_logging_providers.dart';
import 'package:co2diet/core/theme/spacing_tokens.dart';
import 'package:co2diet/domain/entities/meal_entry.dart';
import 'package:co2diet/domain/entities/meal_entry_food_item_mapping.dart';
import 'package:co2diet/domain/entities/meal_slot.dart';
import 'package:co2diet/domain/services/daily_totals_calculator.dart';
import 'package:co2diet/domain/services/personal_co2_multiplier_calculator.dart';
import 'package:co2diet/features/co2_settings/providers/co2_settings_notifier.dart';
import 'package:co2diet/features/dashboard/widgets/co2_profile_prompt_card.dart';
import 'package:co2diet/features/dashboard/widgets/meal_entry_row.dart';
import 'package:co2diet/features/dashboard/widgets/metric_card.dart';
import 'package:co2diet/features/dashboard/widgets/mode_indicator.dart';
import 'package:co2diet/features/dashboard/widgets/quick_insight_line.dart';
import 'package:co2diet/features/dashboard/widgets/trend_sparkline.dart';
import 'package:co2diet/features/food_search/widgets/food_detail_sheet.dart';
import 'package:co2diet/features/meal_logging/providers/meal_entry_notifier.dart';
import 'package:co2diet/features/profile/providers/profile_notifier.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// One-shot trailing-7-day pooled entries (today inclusive) powering the
/// Dashboard's [TrendSparkline] -- a deliberately repeated per-day
/// `DailyTotalsCalculator.compute()` aggregation (O(7) calls), acceptable
/// given this app's small expected daily entry counts. Distinct from
/// [mealEntryProvider]'s single-day scope.
final FutureProvider<List<MealEntry>> _sevenDayEntriesProvider =
    FutureProvider.autoDispose<List<MealEntry>>((ref) async {
      final repo = ref.watch(mealEntryRepositoryProvider);
      final now = DateTime.now();
      final from = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(const Duration(days: 6));
      return repo.getEntriesInRange(from, now);
    });

/// Formats [date] as a `yyyy-MM-dd` logical log date, matching
/// `MealEntryRepository`'s established `_formatLogDate` convention (and
/// `DataAnalysisScreen`'s own private precedent).
String _logDateOf(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

/// Reads [metric]'s value out of a computed [DailyTotals].
double? _valueFor(DashboardMetric metric, DailyTotals totals) =>
    switch (metric) {
      DashboardMetric.co2 => totals.co2e,
      DashboardMetric.calories => totals.calories,
      DashboardMetric.protein => totals.protein,
    };

/// Groups [entries] into 7 daily [DailyTotals] (oldest to newest, today
/// last) and converts each metric's series into `fl_chart` [FlSpot]s for
/// [TrendSparkline] -- the same O(7)-repeated-aggregation approach as
/// `DataAnalysisScreen._fetchTrendSpots` (Plan 05-15), acceptable given this
/// app's small expected daily entry counts.
Map<DashboardMetric, List<FlSpot>> sevenDaySpots(List<MealEntry> entries) {
  final spots = {
    for (final metric in DashboardMetric.values) metric: <FlSpot>[],
  };

  final now = DateTime.now();
  final from = DateTime(
    now.year,
    now.month,
    now.day,
  ).subtract(const Duration(days: 6));

  for (var i = 0; i < 7; i++) {
    final day = from.add(Duration(days: i));
    final dayEntries = entries
        .where((entry) => entry.logDate == _logDateOf(day))
        .toList();
    final dayTotals = DailyTotalsCalculator.compute(dayEntries);
    for (final metric in DashboardMetric.values) {
      final value = _valueFor(metric, dayTotals) ?? 0;
      spots[metric]!.add(FlSpot(i.toDouble(), value));
    }
  }

  return spots;
}

/// Maps a user's Profile `goal` to the metric emphasized/ordered first on
/// the Dashboard (CONTEXT.md Dashboard Composition) -- any goal not in this
/// list (or no goal set yet) falls back to calories.
DashboardMetric emphasizedMetricFor(String? goal) => switch (goal) {
  'reduce_co2' => DashboardMetric.co2,
  'lose_weight' => DashboardMetric.calories,
  'gain_muscle' => DashboardMetric.protein,
  _ => DashboardMetric.calories,
};

/// Orders the three metrics with [emphasized] first, preserving
/// `DashboardMetric.values`'s relative order for the remaining two.
List<DashboardMetric> orderedMetrics(DashboardMetric emphasized) => [
  emphasized,
  for (final m in DashboardMetric.values)
    if (m != emphasized) m,
];

/// Display label for [metric] in Dashboard-local copy (MetricCard labels,
/// QuickInsightLine sentences).
String metricLabel(DashboardMetric metric) => switch (metric) {
  DashboardMetric.co2 => 'CO₂',
  DashboardMetric.calories => 'Calories',
  DashboardMetric.protein => 'Protein',
};

/// Picks whichever of CO2/calories/protein had the largest single-meal-slot
/// share of today's total (CONTEXT.md: "Lunch contributed most CO2 today"),
/// naming that slot -- [QuickInsightLine]'s one pre-computed sentence.
/// Returns `null` when no metric has any data yet (e.g. no meals logged).
String? computeQuickInsight(List<MealEntry> todayEntries) {
  if (todayEntries.isEmpty) return null;

  MealSlot? bestSlot;
  DashboardMetric? bestMetric;
  var bestShare = 0.0;

  final todayTotals = DailyTotalsCalculator.compute(todayEntries);
  for (final metric in DashboardMetric.values) {
    final total = _valueFor(metric, todayTotals);
    if (total == null || total <= 0) continue;

    for (final slot in MealSlot.values) {
      final slotEntries = todayEntries
          .where((entry) => entry.mealSlot == slot)
          .toList();
      final slotTotal = _valueFor(
        metric,
        DailyTotalsCalculator.compute(slotEntries),
      );
      if (slotTotal == null) continue;

      final share = slotTotal / total;
      if (share > bestShare) {
        bestShare = share;
        bestSlot = slot;
        bestMetric = metric;
      }
    }
  }

  if (bestSlot == null || bestMetric == null) return null;
  return '${bestSlot.displayLabel} contributed most '
      '${metricLabel(bestMetric).toLowerCase()} today';
}

/// Dashboard screen (DASH-01/04/05/06 plus LOG-05/LOG-09/LOG-13): the
/// goal-emphasized metric cards, a switchable 7-day trend sparkline, a
/// quick insight line, and the mode indicator, above today's logged meal
/// entries grouped by slot -- swipeable to reveal Edit/Duplicate/Delete.
///
/// Class name kept as `PlaceholderDashboardScreen` (unchanged from Phase 1
/// through 4) even though this plan gives it its composed body --
/// CONTEXT.md: "Phase 5 extends/replaces this same list rather than
/// starting from scratch," and the class name signals its Phase-5-onward
/// provisional nature intentionally (Phase 7's Account Mode may still add
/// a sync indicator here).
class PlaceholderDashboardScreen extends ConsumerStatefulWidget {
  /// Creates the dashboard screen.
  const PlaceholderDashboardScreen({super.key});

  @override
  ConsumerState<PlaceholderDashboardScreen> createState() =>
      _PlaceholderDashboardScreenState();
}

class _PlaceholderDashboardScreenState
    extends ConsumerState<PlaceholderDashboardScreen> {
  // Controlled-component state for TrendSparkline's segmented control --
  // plain local widget state (not persisted, not a Riverpod provider),
  // mirroring WeighInReminderSection/MealReminderSettingsSection's existing
  // "session-only UI selection" precedent.
  DashboardMetric _selectedTrendMetric = DashboardMetric.co2;

  // Session-only dismissal (not persisted) for the "Complete your CO2
  // profile" prompt card -- reappears next cold start, acceptable for a
  // low-priority nudge (CONTEXT.md's explicit bottom-placement decision).
  bool _co2PromptDismissed = false;

  void _openFoodSearch({MealSlot? slot}) {
    final path = slot == null
        ? '/food-search'
        : '/food-search?slot=${slot.name}';
    unawaited(context.push(path));
  }

  void _editEntry(MealEntry entry) {
    unawaited(
      showFoodDetailSheet(
        context,
        entry.toFoodItem(),
        initialSlot: entry.mealSlot,
        initialQuantity: entry.quantity,
        initialUnit: entry.unit,
      ),
    );
  }

  void _duplicateEntry(MealEntry entry) {
    unawaited(ref.read(mealEntryProvider.notifier).duplicateEntry(entry.id));
  }

  void _deleteEntry(MealEntry entry) {
    final notifier = ref.read(mealEntryProvider.notifier);
    unawaited(notifier.deleteEntry(entry.id));

    final messenger = ScaffoldMessenger.of(context);
    // Captured via the raw ProviderContainer (not this widget's `ref`) so
    // Undo stays usable even if this widget is disposed before it's tapped
    // — same pattern as `PortionSlotForm`/`RecentFavoritesList`.
    final container = ProviderScope.containerOf(context, listen: false);
    messenger.showSnackBar(
      SnackBar(
        content: const Text('Deleted'),
        duration: const Duration(seconds: 5),
        // See PortionSlotForm._handleLogPressed — SnackBar.persist defaults
        // to true whenever an `action` is set, which no-ops the timeout.
        persist: false,
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            unawaited(container.read(mealEntryProvider.notifier).undoDelete());
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(mealEntryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: entriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) =>
            const Center(child: Text('Error loading today’s meals')),
        data: _buildBody,
      ),
    );
  }

  Widget _buildBody(List<MealEntry> entries) {
    final profile = ref.watch(profileProvider).value;
    final co2Settings = ref.watch(co2SettingsProvider).value;
    final co2Multiplier = co2Settings == null
        ? 1.0
        : PersonalCo2MultiplierCalculator.compute(co2Settings);
    final targets = profile?.targets;
    final todayTotals = DailyTotalsCalculator.compute(
      entries,
      co2Multiplier: co2Multiplier,
    );
    final emphasized = emphasizedMetricFor(profile?.goal);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.containerMargin,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ModeIndicator(),
              const SizedBox(height: AppSpacing.stackGap),
              Row(
                children: [
                  for (final metric in orderedMetrics(emphasized))
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.base / 2,
                        ),
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => context.push(
                            '/data-analysis?metric=${metric.name}',
                          ),
                          child: MetricCard(
                            label: metricLabel(metric),
                            value: _valueFor(metric, todayTotals),
                            target: switch (metric) {
                              DashboardMetric.co2 => null,
                              DashboardMetric.calories => targets?.kcalTarget,
                              DashboardMetric.protein =>
                                targets?.proteinGTarget,
                            },
                            unit: switch (metric) {
                              DashboardMetric.co2 => 'kg CO₂e',
                              DashboardMetric.calories => 'kcal',
                              DashboardMetric.protein => 'g',
                            },
                            isEmphasized: metric == emphasized,
                            isApproximate: metric == DashboardMetric.co2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.stackGap),
              Consumer(
                builder: (context, ref, _) {
                  final sevenDayAsync = ref.watch(_sevenDayEntriesProvider);
                  return sevenDayAsync.when(
                    loading: () => const SizedBox(height: 80),
                    error: (e, st) => const SizedBox.shrink(),
                    data: (sevenDayEntries) => TrendSparkline(
                      selectedMetric: _selectedTrendMetric,
                      onMetricChanged: (metric) =>
                          setState(() => _selectedTrendMetric = metric),
                      spots: sevenDaySpots(sevenDayEntries),
                      onTap: () => context.push(
                        '/data-analysis?metric=${_selectedTrendMetric.name}',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.stackGap),
              QuickInsightLine(insightText: computeQuickInsight(entries)),
              const SizedBox(height: AppSpacing.stackGap),
              _buildQuickLogRow(),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.stackGap),
        ..._buildMealListSection(entries),
        const SizedBox(height: AppSpacing.stackGap),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.containerMargin,
          ),
          child: Co2ProfilePromptCard(
            show:
                !_co2PromptDismissed &&
                (co2Settings?.dataQuality ?? 'basic') == 'basic',
            onDismiss: () => setState(() => _co2PromptDismissed = true),
            onTap: () => context.push('/co2-settings'),
          ),
        ),
      ],
    );
  }

  /// Per-slot quick-log buttons (Breakfast/Lunch/Dinner/Snack) plus a
  /// "+ Quick Add Food" secondary shortcut (DASH-02). Each pushes
  /// `/food-search?slot=<slot>`; Quick Add omits the query param entirely so
  /// the existing time-of-day auto-detect applies -- CONTEXT.md: "behaves
  /// exactly like the per-slot quick-log buttons... editable inside the
  /// sheet."
  Widget _buildQuickLogRow() {
    return Wrap(
      spacing: AppSpacing.base,
      runSpacing: AppSpacing.base,
      children: [
        for (final slot in MealSlot.values)
          FilledButton.tonal(
            onPressed: () => _openFoodSearch(slot: slot),
            child: Text(slot.displayLabel),
          ),
        OutlinedButton.icon(
          onPressed: _openFoodSearch,
          icon: const Icon(Icons.add),
          label: const Text('Quick Add Food'),
        ),
      ],
    );
  }

  List<Widget> _buildMealListSection(List<MealEntry> entries) {
    if (entries.isEmpty) {
      return [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.restaurant_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'No meals logged yet',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ];
    }

    return [
      for (final slot in MealSlot.values) ..._buildSlotSection(slot, entries),
    ];
  }

  List<Widget> _buildSlotSection(MealSlot slot, List<MealEntry> entries) {
    final slotEntries = entries
        .where((entry) => entry.mealSlot == slot)
        .toList();
    if (slotEntries.isEmpty) return const [];

    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Text(
          slot.displayLabel,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      for (final entry in slotEntries)
        MealEntryRow(
          entry: entry,
          onEdit: _editEntry,
          onDuplicate: _duplicateEntry,
          onDelete: _deleteEntry,
        ),
    ];
  }
}
