// ONBD-03a: the onboarding connectivity choice.
//
// Also guards the flow wiring itself — Plan 06.1 left '/onboarding-carousel'
// unreachable (Legal Consent went straight to '/profile'), which no widget
// test caught because none asserted on the route *sequence*.

import 'package:co2diet/domain/entities/network_mode.dart';
import 'package:co2diet/features/onboarding/providers/onboarding_gate_provider.dart';
import 'package:co2diet/features/onboarding/screens/connectivity_choice_screen.dart';
import 'package:co2diet/features/settings/providers/network_mode_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences _prefs;
late List<String> _visited;

Widget _harness({double textScale = 1.0}) {
  final router = GoRouter(
    initialLocation: '/connectivity-choice',
    observers: [_RouteRecorder()],
    routes: [
      GoRoute(
        path: '/connectivity-choice',
        builder: (_, _) => const ConnectivityChoiceScreen(),
      ),
      GoRoute(
        path: '/onboarding-carousel',
        builder: (_, _) => const Scaffold(body: Text('CAROUSEL')),
      ),
    ],
  );
  return ProviderScope(
    overrides: [sharedPreferencesProvider.overrideWithValue(_prefs)],
    child: MaterialApp.router(
      routerConfig: router,
      builder: (context, child) => MediaQuery.withClampedTextScaling(
        minScaleFactor: textScale,
        maxScaleFactor: textScale,
        child: child!,
      ),
    ),
  );
}

class _RouteRecorder extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final name = route.settings.name;
    if (name != null) _visited.add(name);
  }
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    _prefs = await SharedPreferences.getInstance();
    _visited = [];
  });

  testWidgets('offers both options with no pre-selection', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    expect(find.text('Look up foods online'), findsOneWidget);
    expect(find.text('Stay offline'), findsOneWidget);

    // Continue is disabled until the user actually chooses — a default
    // selection would be a recommendation, which this screen must not make.
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('choosing offline persists offlineOnly and advances to the '
      'carousel', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Stay offline'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(
      _prefs.getString(kNetworkModeKey),
      NetworkMode.offlineOnly.name,
    );
    // The next step is the Carousel, not Profile Setup — the leg that was
    // missing before this plan.
    expect(find.text('CAROUSEL'), findsOneWidget);
  });

  testWidgets('choosing online persists onlineAllowed', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Look up foods online'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(
      _prefs.getString(kNetworkModeKey),
      NetworkMode.onlineAllowed.name,
    );
  });

  testWidgets('selection can be changed before continuing', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Stay offline'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Look up foods online'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(
      _prefs.getString(kNetworkModeKey),
      NetworkMode.onlineAllowed.name,
    );
  });

  testWidgets('renders without overflow at 1.6x text scale (ACC-02)', (
    tester,
  ) async {
    // This screen shipped with a 4px overflow at default size, caught by the
    // first test written against it. Two description-bearing cards plus a
    // heading is enough content to overflow, so the guard stays.
    tester.view.physicalSize = const Size(1080, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_harness(textScale: 1.6));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('renders without overflow on a short viewport', (tester) async {
    tester.view.physicalSize = const Size(720, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
