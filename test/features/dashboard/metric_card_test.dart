import 'package:co2diet/core/di/co2_settings_providers.dart';
import 'package:co2diet/core/di/meal_logging_providers.dart';
import 'package:co2diet/core/di/providers.dart';
import 'package:co2diet/domain/entities/co2_settings.dart';
import 'package:co2diet/domain/repositories/i_co2_settings_repository.dart';
import 'package:co2diet/domain/repositories/i_meal_entry_repository.dart';
import 'package:co2diet/domain/repositories/i_profile_repository.dart';
import 'package:co2diet/features/dashboard/screens/placeholder_dashboard_screen.dart';
import 'package:co2diet/features/dashboard/widgets/metric_card.dart';
import 'package:co2diet/features/dashboard/widgets/mode_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class _MockMealEntryRepository extends Mock implements IMealEntryRepository {}

class _MockProfileRepository extends Mock implements IProfileRepository {}

class _MockCo2SettingsRepository extends Mock
    implements ICo2SettingsRepository {}

void main() {
  group('MetricCard', () {
    testWidgets(
      'renders value vs target with the goal-matching metric '
      'ordered/sized first',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: MetricCard(
                label: 'Calories',
                value: 1500,
                target: 2000,
                unit: 'kcal',
                isEmphasized: true,
              ),
            ),
          ),
        );

        expect(find.text('Calories'), findsOneWidget);
        expect(find.text('1500'), findsOneWidget);
        expect(find.text('of 2000'), findsOneWidget);
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      "shows '—' (no fake precision) when value or target is null",
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: MetricCard(
                label: 'Protein',
                value: null,
                target: null,
                unit: 'g',
              ),
            ),
          ),
        );

        expect(find.text('—'), findsOneWidget);
        expect(find.byType(LinearProgressIndicator), findsNothing);
      },
    );
  });

  group('ModeIndicator', () {
    testWidgets('shows Local Mode text by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ModeIndicator())),
      );

      expect(find.text('Stored on this device'), findsOneWidget);
    });

    testWidgets('shows Account Mode text when isLocalMode is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ModeIndicator(isLocalMode: false)),
        ),
      );

      expect(find.text('Synced across devices'), findsOneWidget);
    });
  });

  group('Dashboard screen assembly (Plan 05-18)', () {
    Widget wrap(Widget dashboard) {
      final router = GoRouter(
        initialLocation: '/dashboard',
        routes: [
          GoRoute(path: '/dashboard', builder: (context, state) => dashboard),
          GoRoute(
            path: '/food-search',
            builder: (context, state) =>
                Text('food-search:${state.uri.queryParameters['slot']}'),
          ),
        ],
      );
      return MaterialApp.router(routerConfig: router);
    }

    Future<void> pumpDashboard(WidgetTester tester) async {
      // Tall test viewport -- matches this suite's other Dashboard tests;
      // the composed header plus quick-log row needs more vertical space
      // than the default 800x600 test surface.
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
    }

    testWidgets(
      'a per-slot quick-log button pushes /food-search?slot=<slot>',
      (tester) async {
        await pumpDashboard(tester);

        await tester.tap(find.text('Breakfast'));
        await tester.pumpAndSettle();

        expect(find.text('food-search:breakfast'), findsOneWidget);
      },
    );

    testWidgets(
      'Quick Add Food pushes /food-search with no slot param',
      (tester) async {
        await pumpDashboard(tester);

        await tester.tap(find.text('Quick Add Food'));
        await tester.pumpAndSettle();

        expect(find.text('food-search:null'), findsOneWidget);
      },
    );
  });
}
