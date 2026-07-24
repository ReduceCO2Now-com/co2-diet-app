// LOG-13 meal-logging speed benchmark integration test.
//
// This is a Dart-level regression-guard PROXY for LOG-13's <10s
// tap-to-saved requirement, not a substitute for it — per RESEARCH.md's
// Environment Availability finding, only a human tester on a physical
// mid-range device (Plan 04-13's human-verify checkpoint) can literally
// close LOG-13. This test only protects against future regressions in CI/
// on any connected device.
//
// Per RESEARCH.md Pitfall 3, this test NEVER uses unbounded
// `pumpAndSettle()` — the "Added to <Slot>" Undo snackbar's auto-dismiss
// timer (and this phase's swipe-reveal animations) are exactly the kind of
// persistent scheduled work that defeats it. All waits below use bounded
// `tester.pump(fixedDuration)` loops instead.
//
// Self-skips (matching food_search_benchmark_test.dart /
// co2_coverage_benchmark_test.dart) when off_reference.sqlite is absent.
//
// Run on physical device:
//   flutter test integration_test/meal_logging_benchmark_test.dart
//       --device-id <id>

import 'dart:async';

import 'package:co2diet/app.dart';
import 'package:co2diet/core/assets/first_launch_extractor.dart';
import 'package:co2diet/core/di/providers.dart';
import 'package:co2diet/data/remote/off_api_client.dart';
import 'package:co2diet/features/dashboard/widgets/meal_entry_row.dart';
import 'package:co2diet/features/food_search/widgets/food_result_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';

/// Max bounded-pump iterations before giving up on a wait condition.
const _maxPumpIterations = 100;

/// Fixed pump step — never `pumpAndSettle()` (RESEARCH.md Pitfall 3).
const _pumpStep = Duration(milliseconds: 100);

/// Pumps [tester] in bounded [_pumpStep] increments until [finder] locates
/// at least one matching widget, or [_maxPumpIterations] is exhausted.
/// Returns whether the widget was found — never throws, so callers can
/// assert with a descriptive `reason`.
Future<bool> _pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < _maxPumpIterations; i++) {
    if (finder.evaluate().isNotEmpty) return true;
    await tester.pump(_pumpStep);
  }
  return finder.evaluate().isNotEmpty;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const skipMsg =
      'off_reference.sqlite not available — run tools/ingest_off.py first';

  testWidgets(
    'LOG-13 proxy: tap search result to saved+visible on dashboard '
    'completes in under 10s',
    (tester) async {
      String? offRefPath;
      try {
        offRefPath = await ensureOffReferenceDb();
      } on Object {
        // ensureOffReferenceDb throws StateError (an Error, not Exception)
        // when the asset is absent — self-skip cleanly.
        markTestSkipped(skipMsg);
        return;
      }

      configureOff();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [offRefPathProvider.overrideWithValue(offRefPath)],
          child: const Co2DietApp(),
        ),
      );
      await tester.pump();

      // Navigate to the search screen directly (mirrors the real entry
      // point, Settings → "Search foods"). This setup nav happens BEFORE
      // the Stopwatch starts — LOG-13's measured window begins at the tap
      // on a search result row, not at search-screen entry.
      final initialContext = tester.element(find.byType(Scaffold).first);
      unawaited(GoRouter.of(initialContext).push('/food-search'));

      final searchFieldFinder = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.hintText == 'Search for a food...',
      );
      final foundSearchField = await _pumpUntilFound(
        tester,
        searchFieldFinder,
      );
      expect(
        foundSearchField,
        isTrue,
        reason: 'Food search screen never appeared',
      );

      // "banana" — same query used by food_search_benchmark_test.dart's
      // BM-02, guaranteed present in the DE-filtered OFF subset.
      await tester.enterText(searchFieldFinder, 'banana');
      await tester.pump();
      // Fires the TextField's onSubmitted (notifier.onQuerySubmitted),
      // which cancels any debounce and searches immediately.
      await tester.testTextInput.receiveAction(TextInputAction.search);

      final foundResults = await _pumpUntilFound(
        tester,
        find.byType(FoodResultRow),
      );
      expect(
        foundResults,
        isTrue,
        reason: '"banana" search never returned a result row',
      );

      // --- LOG-13 measured window starts here ---
      final stopwatch = Stopwatch()..start();

      await tester.tap(find.byType(FoodResultRow).first);
      await tester.pump(); // Start the modal bottom sheet's open animation.

      final logButtonFinder = find.widgetWithText(
        FilledButton,
        'Log this food',
      );
      final foundLogButton = await _pumpUntilFound(tester, logButtonFinder);
      expect(
        foundLogButton,
        isTrue,
        reason: 'Food detail sheet never opened with a "Log this food" '
            'button',
      );

      // Quantity/unit accept the form's default (100g) — one of the two
      // sanctioned paths per this task's spec ("tap a quantity chip (or
      // accept the default)").
      await tester.tap(logButtonFinder);
      await tester.pump(); // Start the sheet's dismissal + snackbar entry.

      final foundSnackbar = await _pumpUntilFound(
        tester,
        find.textContaining('Added to'),
      );

      stopwatch.stop();
      // --- LOG-13 measured window ends here ---

      expect(
        foundSnackbar,
        isTrue,
        reason: 'The "Added to <Slot>" confirmation snackbar never '
            'appeared after tapping "Log this food"',
      );
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(10000),
        reason: 'LOG-13 proxy: tap-to-saved must complete in <10s '
            '(was ${stopwatch.elapsedMilliseconds}ms)',
      );

      // Optional extra: confirm the literal "food saved and visible on
      // dashboard" chain by navigating there and finding the logged entry
      // — checked by widget type rather than exact product name text,
      // since the OFF-derived name for "banana" isn't guaranteed verbatim.
      final postLogContext = tester.element(find.byType(Scaffold).first);
      GoRouter.of(postLogContext).go('/dashboard');
      final foundDashboardEntry = await _pumpUntilFound(
        tester,
        find.byType(MealEntryRow),
      );
      expect(
        foundDashboardEntry,
        isTrue,
        reason: 'Logged entry was not visible on the dashboard after '
            'navigating there',
      );
    },
  );
}
