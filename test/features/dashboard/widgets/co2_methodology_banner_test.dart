import 'package:co2diet/domain/services/methodology_version_checker.dart';
import 'package:co2diet/features/dashboard/providers/methodology_banner_provider.dart';
import 'package:co2diet/features/dashboard/widgets/co2_methodology_banner.dart';
import 'package:co2diet/features/onboarding/providers/onboarding_gate_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Co2MethodologyBanner', () {
    /// Wraps [Co2MethodologyBanner] in a `MaterialApp.router` with a
    /// `/data-analysis` stub route (mirrors `dashboard_composition_test.dart`
    /// Plan 05-18's established GoRouter test-wrap convention). Named
    /// params (mirrors `legal_consent_screen_test.dart`'s established
    /// per-test-variance convention, since `Override` isn't a publicly
    /// exported riverpod type usable as a parameter type) flow the two
    /// axes of controllable staleness this suite exercises: overriding
    /// the composed [showMethodologyBannerProvider] directly for simple
    /// render/no-render cases, or overriding the lower-level
    /// [hasStaleMethodologyEntriesProvider] so
    /// [MethodologyBannerDismissalNotifier] runs for real against the
    /// seeded [prefs].
    Widget wrap({
      required SharedPreferences prefs,
      bool? showBanner,
      bool? hasStaleEntries,
    }) {
      final router = GoRouter(
        initialLocation: '/dashboard',
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const Scaffold(
              body: Co2MethodologyBanner(),
            ),
          ),
          GoRoute(
            path: '/data-analysis',
            builder: (context, state) => const Text('data-analysis'),
          ),
        ],
      );
      return ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          if (showBanner != null)
            showMethodologyBannerProvider.overrideWith(
              (ref) async => showBanner,
            ),
          if (hasStaleEntries != null)
            hasStaleMethodologyEntriesProvider.overrideWith(
              (ref) async => hasStaleEntries,
            ),
        ],
        child: MaterialApp.router(routerConfig: router),
      );
    }

    /// Seeds a real (mocked) `SharedPreferences` instance -- per this
    /// project's established onboarding-gate test convention -- so
    /// [MethodologyBannerDismissalNotifier] and its `dismiss()` writes
    /// exercise real persistence rather than a mocked provider.
    Future<SharedPreferences> makePrefs({
      Map<String, Object> initialValues = const {},
    }) async {
      SharedPreferences.setMockInitialValues(initialValues);
      return SharedPreferences.getInstance();
    }

    testWidgets('renders nothing when no stale entries exist', (
      tester,
    ) async {
      final prefs = await makePrefs();

      await tester.pumpWidget(wrap(prefs: prefs, showBanner: false));
      await tester.pumpAndSettle();

      expect(find.byType(Co2MethodologyBanner), findsOneWidget);
      expect(find.byIcon(Icons.eco_outlined), findsNothing);
      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets(
      'renders the banner with the interpolated methodology version when '
      'stale entries exist and the version was never dismissed',
      (tester) async {
        final prefs = await makePrefs();

        await tester.pumpWidget(wrap(prefs: prefs, showBanner: true));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.eco_outlined), findsOneWidget);
        expect(
          find.textContaining(
            'methodology v$currentCo2MethodologyVersion',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'dismissing the banner persists a per-version flag so it does not '
      'reappear for the same version',
      (tester) async {
        final prefs = await makePrefs();

        await tester.pumpWidget(wrap(prefs: prefs, hasStaleEntries: true));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.eco_outlined), findsOneWidget);

        await tester.tap(find.byIcon(Icons.close));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.eco_outlined), findsNothing);
        expect(
          prefs.getString('co2MethodologyBannerDismissedVersion'),
          currentCo2MethodologyVersion,
        );
      },
    );

    testWidgets(
      'a newer stale version reappears even after a prior version was '
      'dismissed',
      (tester) async {
        // Seeds a dismissal for a version distinct from
        // currentCo2MethodologyVersion -- simulates a prior dismiss that
        // predates a later methodology bump.
        final prefs = await makePrefs(
          initialValues: const {
            'co2MethodologyBannerDismissedVersion': 'some-old-version',
          },
        );

        await tester.pumpWidget(wrap(prefs: prefs, hasStaleEntries: true));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.eco_outlined), findsOneWidget);
      },
    );

    testWidgets('tapping Learn more navigates to /data-analysis', (
      tester,
    ) async {
      final prefs = await makePrefs();

      await tester.pumpWidget(wrap(prefs: prefs, showBanner: true));
      await tester.pumpAndSettle();

      await tester.tap(
        find.textContaining('methodology v$currentCo2MethodologyVersion'),
      );
      await tester.pumpAndSettle();

      expect(find.text('data-analysis'), findsOneWidget);
    });
  });
}
