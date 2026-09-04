// Widget tests for OnboardingCarouselScreen (Plan 06.1-01) -- closes the
// Wave 0 test-coverage gap for this screen.
//
// Proves the Carousel is now a pure pass-through to /profile: neither exit
// button (top-right "Skip intro" nor the last-slide button) ever calls
// OnboardingGateNotifier.completeOnboarding() -- that responsibility moved
// to ProfileScreen's forward button (Task 2). Mirrors
// reference_data_row_test.dart's MaterialApp.router + GoRouter harness
// convention.

import 'package:co2diet/features/onboarding/providers/onboarding_gate_provider.dart';
import 'package:co2diet/features/onboarding/screens/onboarding_carousel_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> _makeContainer() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  return ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
}

Widget _wrap(ProviderContainer container) {
  final router = GoRouter(
    initialLocation: '/onboarding-carousel',
    routes: [
      GoRoute(
        path: '/onboarding-carousel',
        builder: (context, state) => const OnboardingCarouselScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) =>
            const Scaffold(body: Text('PROFILE_ROUTE_MARKER')),
      ),
    ],
  );

  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  group('OnboardingCarouselScreen', () {
    testWidgets(
      '"Skip intro" navigates to /profile without completing onboarding',
      (tester) async {
        final container = await _makeContainer();
        addTearDown(container.dispose);

        await tester.pumpWidget(_wrap(container));

        await tester.tap(find.text('Skip intro'));
        await tester.pumpAndSettle();

        expect(find.text('PROFILE_ROUTE_MARKER'), findsOneWidget);

        final prefs = container.read(sharedPreferencesProvider);
        expect(prefs.getBool('hasCompletedOnboarding'), isNot(true));
      },
    );

    testWidgets(
      'last-slide button reads "Set Up Profile", not "Go to Dashboard"',
      (tester) async {
        final container = await _makeContainer();
        addTearDown(container.dispose);

        await tester.pumpWidget(_wrap(container));

        await tester.drag(find.byType(PageView), const Offset(-2000, 0));
        await tester.pump();
        await tester.drag(find.byType(PageView), const Offset(-2000, 0));
        await tester.pumpAndSettle();

        expect(find.text('Set Up Profile'), findsOneWidget);
        expect(find.text('Go to Dashboard'), findsNothing);
      },
    );

    testWidgets(
      'last-slide button navigates to /profile without completing '
      'onboarding',
      (tester) async {
        final container = await _makeContainer();
        addTearDown(container.dispose);

        await tester.pumpWidget(_wrap(container));

        await tester.drag(find.byType(PageView), const Offset(-2000, 0));
        await tester.pump();
        await tester.drag(find.byType(PageView), const Offset(-2000, 0));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Set Up Profile'));
        await tester.pumpAndSettle();

        expect(find.text('PROFILE_ROUTE_MARKER'), findsOneWidget);

        final prefs = container.read(sharedPreferencesProvider);
        expect(prefs.getBool('hasCompletedOnboarding'), isNot(true));
      },
    );
  });
}
