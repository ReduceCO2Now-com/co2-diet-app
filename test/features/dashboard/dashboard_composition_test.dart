// Plan 05-18 Dashboard-assembly wiring: goal-to-emphasis mapping, the
// QuickInsightLine "largest single-slot share" selection helper, and the
// metric-card/chart-tap-to-Data-Analysis navigation behavior (DASH-08).
import 'package:co2diet/core/di/co2_settings_providers.dart';
import 'package:co2diet/core/di/meal_logging_providers.dart';
import 'package:co2diet/core/di/providers.dart';
import 'package:co2diet/domain/entities/co2_settings.dart';
import 'package:co2diet/domain/entities/meal_entry.dart';
import 'package:co2diet/domain/entities/meal_slot.dart';
import 'package:co2diet/domain/entities/portion_unit.dart';
import 'package:co2diet/domain/entities/user_profile.dart';
import 'package:co2diet/domain/repositories/i_co2_settings_repository.dart';
import 'package:co2diet/domain/repositories/i_meal_entry_repository.dart';
import 'package:co2diet/domain/repositories/i_profile_repository.dart';
import 'package:co2diet/features/dashboard/screens/placeholder_dashboard_screen.dart';
import 'package:co2diet/features/dashboard/widgets/macro_split_bar.dart';
import 'package:co2diet/features/dashboard/widgets/metric_card.dart';
import 'package:co2diet/features/dashboard/widgets/nutrient_totals_row.dart';
import 'package:co2diet/features/dashboard/widgets/trend_sparkline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class _MockMealEntryRepository extends Mock implements IMealEntryRepository {}

class _MockProfileRepository extends Mock implements IProfileRepository {}

class _MockCo2SettingsRepository extends Mock
    implements ICo2SettingsRepository {}

MealEntry _buildEntry(
  String id,
  MealSlot slot, {
  double calories100g = 200,
  double co2e100g = 2.5,
  double quantity = 150,
  double? protein100g,
  double? carbs100g,
  double? fat100g,
  double? sugar100g,
  double? fiber100g,
  double? salt100g,
}) => MealEntry(
  id: id,
  mealSlot: slot,
  foodRef: '1234567890123',
  foodRefSource: 'off_ref',
  quantity: quantity,
  unit: PortionUnit.g,
  productNameSnapshot: 'Test Food $id',
  calories100gSnapshot: calories100g,
  protein100gSnapshot: protein100g,
  carbs100gSnapshot: carbs100g,
  fat100gSnapshot: fat100g,
  sugar100gSnapshot: sugar100g,
  fiber100gSnapshot: fiber100g,
  saltSnapshot: salt100g,
  co2e100gSnapshot: co2e100g,
  loggedAt: DateTime(2026, 7, 24, 12),
  logDate: '2026-07-24',
);

void main() {
  group('emphasizedMetricFor', () {
    test('reduce_co2 emphasizes CO2', () {
      expect(emphasizedMetricFor('reduce_co2'), DashboardMetric.co2);
    });

    test('lose_weight emphasizes calories', () {
      expect(emphasizedMetricFor('lose_weight'), DashboardMetric.calories);
    });

    test('gain_muscle emphasizes protein', () {
      expect(emphasizedMetricFor('gain_muscle'), DashboardMetric.protein);
    });

    test('unrecognized/null goal falls back to calories', () {
      expect(emphasizedMetricFor(null), DashboardMetric.calories);
      expect(emphasizedMetricFor('something_else'), DashboardMetric.calories);
    });
  });

  group('orderedMetrics', () {
    test('places the emphasized metric first', () {
      expect(
        orderedMetrics(DashboardMetric.protein).first,
        DashboardMetric.protein,
      );
      expect(orderedMetrics(DashboardMetric.co2).first, DashboardMetric.co2);
    });

    test('always contains all three metrics exactly once', () {
      final ordered = orderedMetrics(DashboardMetric.calories);
      expect(ordered.toSet(), DashboardMetric.values.toSet());
      expect(ordered.length, 3);
    });
  });

  group('computeQuickInsight', () {
    test('returns null when there are no entries today', () {
      expect(computeQuickInsight([]), isNull);
    });

    test(
      'names the slot contributing the largest single-slot share of a '
      'metric',
      () {
        // Breakfast alone contributes a much higher CO2 total than lunch,
        // making it the "largest single-meal share" of today's CO2.
        final entries = [
          _buildEntry(
            'e1',
            MealSlot.breakfast,
            co2e100g: 20,
            calories100g: 100,
          ),
          _buildEntry('e2', MealSlot.lunch, co2e100g: 1, calories100g: 100),
        ];

        final insight = computeQuickInsight(entries);

        expect(insight, isNotNull);
        expect(insight, contains('Breakfast'));
      },
    );
  });

  group('Dashboard screen assembly (Plan 05-18)', () {
    Widget wrap(Widget dashboard) {
      final router = GoRouter(
        initialLocation: '/dashboard',
        routes: [
          GoRoute(path: '/dashboard', builder: (context, state) => dashboard),
          GoRoute(
            path: '/data-analysis',
            builder: (context, state) =>
                Text('data-analysis:${state.uri.queryParameters['metric']}'),
          ),
        ],
      );
      return MaterialApp.router(routerConfig: router);
    }

    Future<void> pumpDashboard(WidgetTester tester) async {
      // Tall test viewport, matching this suite's other Dashboard tests --
      // the composed header (mode indicator/metric cards/sparkline/quick
      // insight) plus a full slot-grouped meal list needs more vertical
      // space than the default 800x600 test surface.
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final mockRepo = _MockMealEntryRepository();
      when(mockRepo.getEntriesForToday).thenAnswer(
        (_) async => [_buildEntry('e1', MealSlot.breakfast)],
      );
      when(
        () => mockRepo.getEntriesInRange(any(), any()),
      ).thenAnswer((_) async => []);

      final mockProfileRepo = _MockProfileRepository();
      when(mockProfileRepo.getProfile).thenAnswer(
        (_) async => const UserProfile(id: 'p1', goal: 'reduce_co2'),
      );

      final mockCo2SettingsRepo = _MockCo2SettingsRepository();
      when(
        mockCo2SettingsRepo.getSettings,
      ).thenAnswer((_) async => const Co2Settings());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mealEntryRepositoryProvider.overrideWithValue(mockRepo),
            profileRepositoryProvider.overrideWithValue(mockProfileRepo),
            co2SettingsRepositoryProvider.overrideWithValue(
              mockCo2SettingsRepo,
            ),
          ],
          child: wrap(const PlaceholderDashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets(
      'tapping the CO2 metric card pushes /data-analysis?metric=co2',
      (tester) async {
        await pumpDashboard(tester);

        final co2Card = find.byWidgetPredicate(
          (widget) => widget is MetricCard && widget.label == 'CO₂',
        );
        expect(co2Card, findsOneWidget);
        await tester.tap(co2Card);
        await tester.pumpAndSettle();

        expect(find.text('data-analysis:co2'), findsOneWidget);
      },
    );

    testWidgets(
      'tapping the trend sparkline pushes /data-analysis?metric=<selected>',
      (tester) async {
        await pumpDashboard(tester);

        await tester.tap(find.byType(TrendSparkline));
        await tester.pumpAndSettle();

        expect(find.text('data-analysis:co2'), findsOneWidget);
      },
    );
  });

  group('MacroSplitBar and NutrientTotalsRow (NUTR-04/NUTR-01 gap fix)', () {
    Widget wrap(Widget dashboard) {
      final router = GoRouter(
        initialLocation: '/dashboard',
        routes: [
          GoRoute(path: '/dashboard', builder: (context, state) => dashboard),
          GoRoute(
            path: '/data-analysis',
            builder: (context, state) => const Text('data-analysis'),
          ),
          GoRoute(
            path: '/co2-settings',
            builder: (context, state) => const Text('co2-settings'),
          ),
        ],
      );
      return MaterialApp.router(routerConfig: router);
    }

    testWidgets(
      'Dashboard renders MacroSplitBar and NutrientTotalsRow with the '
      "day's aggregated totals",
      (tester) async {
        tester.view.physicalSize = const Size(1080, 4000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final mockRepo = _MockMealEntryRepository();
        when(mockRepo.getEntriesForToday).thenAnswer(
          (_) async => [
            // 150g @ carbs/sugar/fiber/salt-per-100g below -> scaled *1.5
            _buildEntry(
              'e1',
              MealSlot.breakfast,
              protein100g: 10,
              carbs100g: 20,
              fat100g: 4,
              sugar100g: 8,
              fiber100g: 2,
              salt100g: 1,
            ),
          ],
        );
        when(
          () => mockRepo.getEntriesInRange(any(), any()),
        ).thenAnswer((_) async => []);

        final mockProfileRepo = _MockProfileRepository();
        when(mockProfileRepo.getProfile).thenAnswer((_) async => null);

        final mockCo2SettingsRepo = _MockCo2SettingsRepository();
        when(
          mockCo2SettingsRepo.getSettings,
        ).thenAnswer((_) async => const Co2Settings());

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              mealEntryRepositoryProvider.overrideWithValue(mockRepo),
              profileRepositoryProvider.overrideWithValue(mockProfileRepo),
              co2SettingsRepositoryProvider.overrideWithValue(
                mockCo2SettingsRepo,
              ),
            ],
            child: wrap(const PlaceholderDashboardScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // NUTR-04: macro split bar is rendered (non-null split, since
        // protein/carbs/fat are all provided above). Scoped to
        // MacroSplitBar's own subtree -- 'Protein'/'Carbs' otherwise
        // collide with the CO2/calories/protein MetricCard label and
        // NutrientTotalsRow's own 'Carbs' label respectively.
        final macroSplitBar = find.byType(MacroSplitBar);
        expect(macroSplitBar, findsOneWidget);
        expect(
          find.descendant(
            of: macroSplitBar,
            matching: find.textContaining('Protein'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: macroSplitBar,
            matching: find.textContaining('Carbs'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: macroSplitBar,
            matching: find.textContaining('Fat'),
          ),
          findsOneWidget,
        );

        // NUTR-01: sugar/fiber/salt daily totals (150g * per-100g values).
        expect(find.byType(NutrientTotalsRow), findsOneWidget);
        expect(find.text('12g'), findsOneWidget); // sugar: 8 * 1.5
        expect(find.text('3g'), findsOneWidget); // fiber: 2 * 1.5 (rounds)
        expect(find.text('2g'), findsOneWidget); // salt: 1 * 1.5 (rounds)
      },
    );

    testWidgets(
      'NutrientTotalsRow shows dashes when no entries have been logged',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 4000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final mockRepo = _MockMealEntryRepository();
        when(mockRepo.getEntriesForToday).thenAnswer((_) async => []);
        when(
          () => mockRepo.getEntriesInRange(any(), any()),
        ).thenAnswer((_) async => []);

        final mockProfileRepo = _MockProfileRepository();
        when(mockProfileRepo.getProfile).thenAnswer((_) async => null);

        final mockCo2SettingsRepo = _MockCo2SettingsRepository();
        when(
          mockCo2SettingsRepo.getSettings,
        ).thenAnswer((_) async => const Co2Settings());

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              mealEntryRepositoryProvider.overrideWithValue(mockRepo),
              profileRepositoryProvider.overrideWithValue(mockProfileRepo),
              co2SettingsRepositoryProvider.overrideWithValue(
                mockCo2SettingsRepo,
              ),
            ],
            child: wrap(const PlaceholderDashboardScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('No macro data yet today'), findsOneWidget);
        // Scoped to NutrientTotalsRow specifically -- the CO2/calories/
        // protein MetricCards also render '—' for their own null values,
        // which isn't what this assertion is checking.
        expect(
          find.descendant(
            of: find.byType(NutrientTotalsRow),
            matching: find.text('—'),
          ),
          findsNWidgets(4), // carbs/sugar/fiber/salt
        );
      },
    );
  });

  group('Co2ProfilePromptCard gating (Plan 05-18)', () {
    Widget wrap(Widget dashboard) {
      final router = GoRouter(
        initialLocation: '/dashboard',
        routes: [
          GoRoute(path: '/dashboard', builder: (context, state) => dashboard),
          GoRoute(
            path: '/data-analysis',
            builder: (context, state) => const Text('data-analysis'),
          ),
          GoRoute(
            path: '/co2-settings',
            builder: (context, state) => const Text('co2-settings'),
          ),
        ],
      );
      return MaterialApp.router(routerConfig: router);
    }

    Future<void> pumpDashboard(
      WidgetTester tester, {
      required Co2Settings co2Settings,
    }) async {
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final mockRepo = _MockMealEntryRepository();
      when(mockRepo.getEntriesForToday).thenAnswer((_) async => []);
      when(
        () => mockRepo.getEntriesInRange(any(), any()),
      ).thenAnswer((_) async => []);

      final mockProfileRepo = _MockProfileRepository();
      when(mockProfileRepo.getProfile).thenAnswer((_) async => null);

      final mockCo2SettingsRepo = _MockCo2SettingsRepository();
      when(
        mockCo2SettingsRepo.getSettings,
      ).thenAnswer((_) async => co2Settings);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mealEntryRepositoryProvider.overrideWithValue(mockRepo),
            profileRepositoryProvider.overrideWithValue(mockProfileRepo),
            co2SettingsRepositoryProvider.overrideWithValue(
              mockCo2SettingsRepo,
            ),
          ],
          child: wrap(const PlaceholderDashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets(
      'shown when dataQuality is basic (no settings saved yet)',
      (tester) async {
        await pumpDashboard(tester, co2Settings: const Co2Settings());

        expect(
          find.text('Complete your CO₂ profile for better estimates'),
          findsOneWidget,
        );
      },
    );

    testWidgets('hidden when dataQuality is good or detailed', (
      tester,
    ) async {
      await pumpDashboard(
        tester,
        co2Settings: const Co2Settings(
          locationCountry: 'DE',
          purchasingSource: 'local_farm',
          shoppingTransport: 'walk_bike',
          cookingMethod: 'induction',
        ),
      );

      expect(
        find.text('Complete your CO₂ profile for better estimates'),
        findsNothing,
      );
    });

    testWidgets('dismissing the card hides it for the rest of the session', (
      tester,
    ) async {
      await pumpDashboard(tester, co2Settings: const Co2Settings());

      expect(
        find.text('Complete your CO₂ profile for better estimates'),
        findsOneWidget,
      );

      await tester.tap(find.byTooltip('Dismiss'));
      await tester.pumpAndSettle();

      expect(
        find.text('Complete your CO₂ profile for better estimates'),
        findsNothing,
      );
    });

    testWidgets('tapping the card body navigates to /co2-settings', (
      tester,
    ) async {
      await pumpDashboard(tester, co2Settings: const Co2Settings());

      await tester.tap(
        find.text('Complete your CO₂ profile for better estimates'),
      );
      await tester.pumpAndSettle();

      expect(find.text('co2-settings'), findsOneWidget);
    });
  });
}
