import 'package:co2diet/app.dart';
import 'package:co2diet/core/di/providers.dart';
import 'package:co2diet/core/router/app_router.dart';
import 'package:co2diet/data/local/app_database.dart';
import 'package:co2diet/features/onboarding/providers/onboarding_gate_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('OnboardingGateNotifier (provider-level)', () {
    late ProviderContainer container;

    Future<ProviderContainer> makeContainer({
      Map<String, Object> initialValues = const {},
    }) async {
      SharedPreferences.setMockInitialValues(initialValues);
      final prefs = await SharedPreferences.getInstance();
      final c = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(c.dispose);
      return c;
    }

    test('build() returns false when no stored flag exists', () async {
      container = await makeContainer();
      expect(container.read(onboardingGateProvider), isFalse);
    });

    test('build() returns true when the stored flag is true', () async {
      container = await makeContainer(
        initialValues: {'hasCompletedOnboarding': true},
      );
      expect(container.read(onboardingGateProvider), isTrue);
    });

    test(
      'completeOnboarding() persists true and updates state synchronously',
      () async {
        container = await makeContainer();
        expect(container.read(onboardingGateProvider), isFalse);

        await container
            .read(onboardingGateProvider.notifier)
            .completeOnboarding();

        expect(container.read(onboardingGateProvider), isTrue);

        final prefs = container.read(sharedPreferencesProvider);
        expect(prefs.getBool('hasCompletedOnboarding'), isTrue);
      },
    );
  });

  group('OnboardingGate (router-redirect)', () {
    /// Pumps the real `Co2DietApp` (real `appRouterProvider`, real
    /// onboarding-gate redirect) backed by an in-memory Drift DB and a
    /// mock `SharedPreferences` seeded with [hasCompletedOnboarding].
    /// Mirrors `profile_screen_full_app_crash_test.dart`'s (Plan 06-09
    /// precedent) proof that overriding only `appDatabaseProvider` +
    /// `sharedPreferencesProvider` is enough for every route's screen
    /// (Splash/Welcome/Profile/Dashboard) to build without extra mocks.
    Future<ProviderContainer> pumpApp(
      WidgetTester tester, {
      required bool hasCompletedOnboarding,
    }) async {
      SharedPreferences.setMockInitialValues({
        'hasCompletedOnboarding': hasCompletedOnboarding,
      });
      final prefs = await SharedPreferences.getInstance();

      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const Co2DietApp(),
        ),
      );
      // Zero-duration pump: renders the initial frame without letting
      // SplashScreen's real 2s `Future.delayed` auto-advance timer fire,
      // so pre-onboarding cases can assert on Splash's actual content.
      await tester.pump();

      return container;
    }

    testWidgets(
      'first launch (no stored flag) produces no redirect at /splash '
      '(ONBD-01)',
      (tester) async {
        await pumpApp(tester, hasCompletedOnboarding: false);

        // SplashScreen's CircularProgressIndicator is unique to Splash
        // among the onboarding-flow screens (Welcome/Profile/Dashboard
        // render none).
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Dashboard'), findsNothing);

        // Flush the still-pending 2s Splash timer before teardown so the
        // "Timer still pending" test-framework invariant doesn't trip.
        await tester.pump(const Duration(seconds: 3));
      },
    );

    testWidgets(
      'a direct deep link to /dashboard before onboarding completes '
      'redirects to /splash',
      (tester) async {
        final container = await pumpApp(
          tester,
          hasCompletedOnboarding: false,
        );

        container.read(appRouterProvider).go('/dashboard');
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Dashboard'), findsNothing);

        await tester.pump(const Duration(seconds: 3));
      },
    );

    testWidgets(
      'navigating to /profile before onboarding completes produces no '
      'redirect',
      (tester) async {
        final container = await pumpApp(
          tester,
          hasCompletedOnboarding: false,
        );

        container.read(appRouterProvider).go('/profile');
        await tester.pumpAndSettle();

        expect(find.text('My Profile'), findsOneWidget);

        // Flush the still-pending 2s Splash timer (Splash was the
        // router's initial location before this test navigated away)
        // before teardown so the "Timer still pending" test-framework
        // invariant doesn't trip.
        await tester.pump(const Duration(seconds: 3));
      },
    );

    testWidgets(
      'completed onboarding redirects away from /welcome to /dashboard '
      '(ONBD-05)',
      (tester) async {
        final container = await pumpApp(
          tester,
          hasCompletedOnboarding: true,
        );

        container.read(appRouterProvider).go('/welcome');
        await tester.pumpAndSettle();

        // AppBar title is the unique 'Dashboard' occurrence -- the
        // bottom-nav destination label also renders the same text.
        expect(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.text('Dashboard'),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'a completed-onboarding user visiting /profile produces no '
      'redirect',
      (tester) async {
        final container = await pumpApp(
          tester,
          hasCompletedOnboarding: true,
        );

        container.read(appRouterProvider).go('/profile');
        await tester.pumpAndSettle();

        expect(find.text('My Profile'), findsOneWidget);
      },
    );
  });
}
