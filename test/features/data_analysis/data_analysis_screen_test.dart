import 'package:co2diet/core/di/meal_logging_providers.dart';
import 'package:co2diet/core/di/providers.dart';
import 'package:co2diet/core/di/weight_providers.dart';
import 'package:co2diet/domain/entities/favorite.dart';
import 'package:co2diet/domain/entities/meal_entry.dart';
import 'package:co2diet/domain/entities/meal_slot.dart';
import 'package:co2diet/domain/entities/portion_unit.dart';
import 'package:co2diet/domain/entities/user_profile.dart';
import 'package:co2diet/domain/entities/weight_entry.dart';
import 'package:co2diet/domain/entities/weight_settings.dart';
import 'package:co2diet/domain/repositories/i_meal_entry_repository.dart';
import 'package:co2diet/domain/repositories/i_profile_repository.dart';
import 'package:co2diet/domain/repositories/i_weight_repository.dart';
import 'package:co2diet/domain/services/daily_totals_calculator.dart';
import 'package:co2diet/features/data_analysis/screens/data_analysis_screen.dart';
import 'package:co2diet/features/data_analysis/widgets/analysis_metric.dart';
import 'package:co2diet/features/data_analysis/widgets/estimate_transparency_panel.dart';
import 'package:co2diet/features/data_analysis/widgets/goal_comparison_bar.dart';
import 'package:co2diet/features/data_analysis/widgets/ranked_contributors_list.dart';
import 'package:co2diet/features/data_analysis/widgets/today_breakdown_bar_chart.dart';
import 'package:co2diet/features/data_analysis/widgets/trend_section.dart';
import 'package:co2diet/features/data_analysis/widgets/weekly_total_summary.dart';
import 'package:co2diet/features/weight/widgets/weight_chart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory fake -- mirrors `weight_screen_test.dart`'s
/// `_FakeWeightRepository` precedent: a full [IMealEntryRepository]
/// implementation (not a mocktail `Mock`) since this test asserts on the
/// resolved widget tree after multiple async reads, which a Mock would
/// require per-call stubbing to achieve.
class _FakeMealEntryRepository implements IMealEntryRepository {
  _FakeMealEntryRepository(this.entries);

  final List<MealEntry> entries;

  @override
  Future<MealEntry> logOrMerge(MealEntry draft) async => draft;

  @override
  Future<List<MealEntry>> getEntriesForToday() async => List.of(entries);

  @override
  Future<List<MealEntry>> getEntriesInRange(
    DateTime from,
    DateTime to,
  ) async => List.of(entries);

  @override
  Future<List<MealEntry>> getRecent({int limit = 15}) async => const [];

  @override
  Future<MealEntry> editEntry(MealEntry updated) async => updated;

  @override
  Future<MealEntry> deleteEntry(String id) async =>
      entries.firstWhere((entry) => entry.id == id);

  @override
  Future<void> restoreEntry(MealEntry entry) async {}

  @override
  Future<MealEntry> duplicateEntry(String id) async =>
      entries.firstWhere((entry) => entry.id == id);

  @override
  Future<void> undoMergeDelta(String entryId, double delta) async {}

  @override
  Future<bool> isFavorite(String foodRef, String foodRefSource) async => false;

  @override
  Future<Favorite> toggleFavorite(Favorite draft) async => draft;

  @override
  Future<List<Favorite>> getFavorites() async => const [];

  @override
  Future<void> touchFavoriteUsage(
    String foodRef,
    String foodRefSource, {
    required double quantity,
    required PortionUnit unit,
  }) async {}
}

/// In-memory fake mirroring `weight_screen_test.dart`'s
/// `_FakeWeightRepository` precedent verbatim.
class _FakeWeightRepository implements IWeightRepository {
  final List<WeightEntry> _entries = [];
  WeightSettings _settings = const WeightSettings();

  @override
  Future<WeightEntry> logWeight(WeightEntry draft) async {
    final saved = draft.copyWith(id: 'w${_entries.length + 1}');
    _entries.add(saved);
    return saved;
  }

  @override
  Future<List<WeightEntry>> getEntriesInRange(WeightRange range) async =>
      List.of(_entries);

  @override
  Future<void> deleteEntry(String id) async =>
      _entries.removeWhere((entry) => entry.id == id);

  @override
  Future<WeightSettings> getSettings() async => _settings;

  @override
  Future<void> saveGoal({double? targetWeightKg, DateTime? targetDate}) async {
    _settings = _settings.copyWith(
      targetWeightKg: targetWeightKg,
      targetDate: targetDate,
    );
  }

  @override
  Future<void> saveReminderSettings({
    required String frequency,
    required bool enabled,
    int? weekday,
    String? time,
  }) async {
    _settings = _settings.copyWith(
      reminderFrequency: frequency,
      reminderEnabled: enabled,
      reminderWeekday: weekday,
      reminderTime: time,
    );
  }
}

/// No-profile-saved-yet fake -- `GoalComparisonBar` renders its honest
/// "no target set" fallback rather than a fabricated percentage.
class _FakeProfileRepository implements IProfileRepository {
  @override
  Future<UserProfile?> getProfile() async => null;

  @override
  Future<void> saveProfile(UserProfile profile) async {}

  @override
  Stream<UserProfile?> watchProfile() => Stream.value(null);
}

/// Tall viewport so the whole `ListView` (breakdown chart, weekly total,
/// contributors, goal bar, trend, transparency, food details) is within
/// cache extent -- mirrors `weight_screen_test.dart`/`co2_settings_screen_
/// test.dart`'s established precedent (default 800x600 test surface plus
/// Flutter's sliver-list cache-extent hides far-down `ListView` items from
/// `find.byType`/`find.text`).
void _useTallViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 6000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Widget _buildTestable({
  required List<MealEntry> entries,
  required Widget child,
  IWeightRepository? weightRepo,
}) {
  return ProviderScope(
    overrides: [
      mealEntryRepositoryProvider.overrideWithValue(
        _FakeMealEntryRepository(entries),
      ),
      profileRepositoryProvider.overrideWithValue(_FakeProfileRepository()),
      if (weightRepo != null)
        weightRepositoryProvider.overrideWithValue(weightRepo),
    ],
    child: MaterialApp(home: child),
  );
}

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
          _entry(id: '1', calories: 200),
          _entry(id: '2', calories: 150),
          _entry(id: '3', calories: 100),
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

  group('DataAnalysisScreen', () {
    testWidgets(
      "shows today's stacked-bar breakdown by meal, an explicit "
      'weekly total, ranked contributors, and a goal-comparison '
      'progress bar',
      (tester) async {
        _useTallViewport(tester);
        final entries = [
          _entry(
            id: '1',
            slot: MealSlot.breakfast,
            calories: 300,
            co2e: 1.2,
            confidenceBand: 'high',
          ),
          _entry(id: '2', calories: 500, co2e: 2, confidenceBand: 'medium'),
        ];

        await tester.pumpWidget(
          _buildTestable(
            entries: entries,
            child: const DataAnalysisScreen(
              initialMetric: AnalysisMetric.calories,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(TodayBreakdownBarChart), findsOneWidget);
        expect(find.byType(WeeklyTotalSummary), findsOneWidget);
        expect(find.byType(RankedContributorsList), findsOneWidget);
        expect(find.byType(GoalComparisonBar), findsOneWidget);
        expect(find.textContaining('This week'), findsOneWidget);
      },
    );

    testWidgets(
      'trend section metric and range toggles are independently '
      'selectable',
      (tester) async {
        _useTallViewport(tester);
        final entries = [
          _entry(id: '1', slot: MealSlot.breakfast, calories: 300, co2e: 1.2),
        ];

        await tester.pumpWidget(
          _buildTestable(
            entries: entries,
            child: const DataAnalysisScreen(
              initialMetric: AnalysisMetric.calories,
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('30d'));
        await tester.pumpAndSettle();

        var rangeButton = tester.widget<SegmentedButton<int>>(
          find.byType(SegmentedButton<int>),
        );
        expect(rangeButton.selected, {30});

        await tester.tap(
          find.descendant(
            of: find.byType(SegmentedButton<AnalysisMetric>),
            matching: find.text('Protein'),
          ),
        );
        await tester.pumpAndSettle();

        final metricButton = tester.widget<SegmentedButton<AnalysisMetric>>(
          find.byType(SegmentedButton<AnalysisMetric>),
        );
        expect(metricButton.selected, {AnalysisMetric.protein});

        // Range selection is untouched by switching metric.
        rangeButton = tester.widget<SegmentedButton<int>>(
          find.byType(SegmentedButton<int>),
        );
        expect(rangeButton.selected, {30});
      },
    );

    testWidgets(
      'opening from the Weight metric shows a weight trend '
      'breakdown, not calorie/protein/CO2 data',
      (tester) async {
        _useTallViewport(tester);
        await tester.pumpWidget(
          _buildTestable(
            entries: const [],
            weightRepo: _FakeWeightRepository(),
            child: const DataAnalysisScreen(
              initialMetric: AnalysisMetric.weight,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(WeightChart), findsOneWidget);
        expect(find.byType(TodayBreakdownBarChart), findsNothing);
        expect(find.byType(TrendSection), findsNothing);
        expect(find.byType(WeeklyTotalSummary), findsNothing);
      },
    );

    testWidgets(
      'Estimate Transparency shows the mix of High/Medium '
      'confidence items contributing to the aggregate total',
      (tester) async {
        _useTallViewport(tester);
        final entries = [
          _entry(id: '1', co2e: 1, confidenceBand: 'high'),
          _entry(id: '2', co2e: 1, confidenceBand: 'high'),
          _entry(id: '3', co2e: 1, confidenceBand: 'medium'),
        ];

        await tester.pumpWidget(
          _buildTestable(
            entries: entries,
            child: const DataAnalysisScreen(
              initialMetric: AnalysisMetric.co2,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(EstimateTransparencyPanel), findsOneWidget);
        expect(find.textContaining('2 of 3'), findsOneWidget);
      },
    );
  });
}
