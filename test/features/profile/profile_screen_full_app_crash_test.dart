// Reproduction attempt #2 for the real-device-only crash: tapping ANY
// Daily Target card on ProfileScreen (empty OR filled) throws a Flutter
// framework assertion ("_dependents.isEmpty': is not true" inside
// InheritedElement.debugDeactivated) and the app has to be relaunched.
//
// Difference from `profile_screen_crash_test.dart` (which did NOT
// reproduce the crash): that test pumped `ProfileScreen` directly under a
// bare `MaterialApp(home: ...)`, skipping go_router's real navigator
// hierarchy entirely (no root Navigator vs branch Navigator split, no
// `StatefulShellRoute.indexedStack`, no `IndexedStack`-held offstage
// branches, no `NavigationBar`). Production wraps ProfileScreen far more
// deeply: `Co2DietApp` -> `MaterialApp.router` (root Navigator, driven by
// `GoRouter`) -> `StatefulShellRoute.indexedStack` -> `AppShell` ->
// `IndexedStack` branch Navigator -> `ProfileScreen`. `showDialog`
// defaults to `useRootNavigator: true`, so in production the dialog route
// is inserted on the ROOT navigator -- a different Navigator than the one
// hosting ProfileScreen's own Element. That structural gap is untested by
// the prior widget test. This test pumps the REAL `Co2DietApp` widget
// (same pattern as `test/widget_test.dart`) to close that gap.
import 'package:co2diet/app.dart';
import 'package:co2diet/core/di/providers.dart';
import 'package:co2diet/data/local/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'tapping a Daily Target card inside the full app (real go_router '
    'StatefulShellRoute navigation shell) does not throw a framework '
    'assertion',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [appDatabaseProvider.overrideWithValue(db)],
          child: const Co2DietApp(),
        ),
      );
      // Real app: initialLocation '/profile' inside StatefulShellRoute ->
      // several post-frame callbacks (locale detection etc.) need settling.
      await tester.pumpAndSettle();

      final caloriesCard = find.ancestor(
        of: find.text('Calories'),
        matching: find.byType(InkWell),
      );
      expect(caloriesCard, findsOneWidget);

      await tester.tap(caloriesCard);
      await tester.pumpAndSettle();

      expect(
        tester.takeException(),
        isNull,
        reason:
            'Tapping a Daily Target card inside the full app crashed with '
            'a framework assertion -- this is the real-device-reported '
            'crash, reproduced via the real go_router navigation shell.',
      );
    },
  );
}
