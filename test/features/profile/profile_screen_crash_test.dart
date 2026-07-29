// Reproduction test for a real device-only crash: tapping an empty (dash)
// Daily Target value on ProfileScreen throws a Flutter framework assertion
// ("_dependents.isEmpty': is not true") and the app has to be relaunched.
//
// Hypothesis tested (FALSIFIED, do not re-attempt without new evidence):
// only the EMPTY-value path renders its dash inside a Tooltip
// (MissingTargetDash's `tooltip` param) -- the populated-value path is
// plain Text, no Tooltip. Theory was that tapping the InkWell-wrapped card
// while the Tooltip's own gesture/overlay handling is active, combined
// with `showDialog` inserting a new route, could produce an Overlay/
// Element lifecycle assertion. This test reproduces the exact real-device
// interaction (tall viewport so Daily Targets is on-screen, real
// ProfileScreen, real showDialog, tap lands confirmed via no
// "hit test" warning) and does NOT throw -- the crash does not reproduce
// here, so this specific theory is wrong. The real root cause is still
// unknown; three fix attempts (ValueKey remount, AsyncValue.loading
// mid-save, locale-detection infinite loop) have not resolved the
// real-device crash. Needs fresh investigation, ideally with the full
// crash stack trace's frame list (only the assertion message has been
// captured so far) or a way to reproduce closer to real conditions
// (e.g. after prior navigation, or with IME/keyboard state from a
// previously-focused field still active).

import 'package:co2diet/core/di/providers.dart';
import 'package:co2diet/domain/entities/user_profile.dart';
import 'package:co2diet/domain/repositories/i_profile_repository.dart';
import 'package:co2diet/features/profile/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory fake so `getProfile()` reflects whatever was last saved --
/// a plain mocktail Mock that always returns null from `getProfile()`
/// would make ProfileScreen's null-profile locale-detection effect
/// re-fire forever (a test-only infinite loop, distinct from the
/// production bug already fixed), which isn't what this reproduction
/// needs to isolate.
class _FakeProfileRepository implements IProfileRepository {
  UserProfile? _stored;

  @override
  Future<UserProfile?> getProfile() async => _stored;

  @override
  Future<void> saveProfile(UserProfile profile) async => _stored = profile;

  @override
  Stream<UserProfile?> watchProfile() => Stream.value(_stored);
}

void main() {
  testWidgets(
    'tapping an empty (dash) Daily Target does not throw a framework '
    'assertion',
    (tester) async {
      // Tall viewport so the Daily Targets section (below all 7 form
      // fields) is actually on-screen and hit-testable -- the default
      // 800x600 test surface left it off-screen, causing tap() to silently
      // miss and this test to pass for the wrong reason.
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repo = _FakeProfileRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [profileRepositoryProvider.overrideWithValue(repo)],
          child: const MaterialApp(home: ProfileScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // With no saved profile, calories/protein/carbs/fat targets are all
      // null -> each TargetDisplayCard renders the Tooltip-wrapped
      // MissingTargetDash ("—"), exactly the real-device reproduction
      // (Profile -> empty Daily Targets -> tap Calories).
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
            'Tapping an empty target crashed with a framework assertion -- '
            'this is the real-device-reported crash, now reproduced in a '
            'widget test.',
      );
    },
  );
}
