import 'package:co2diet/domain/entities/user_profile.dart';
import 'package:co2diet/features/profile/widgets/profile_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProfileForm text fields do not lose focus on rebuild', () {
    // Regression test for a real device-testing-only bug: every text field
    // in ProfileForm was keyed by its own current value
    // (`ValueKey('age-${p?.age}')` etc.), so the auto-save round-trip
    // (onChanged -> saveProfile -> provider rebuild -> new key) made
    // Flutter tear down and recreate the field's Element on every single
    // keystroke, dropping focus and dismissing the keyboard. `enterText`
    // alone never caught this (it sets the whole value in one shot, not
    // character-by-character), so this test instead asserts the
    // EditableTextState identity survives the exact onChanged->rebuild
    // cycle that a real keystroke triggers.
    EditableTextState stateFor(WidgetTester tester, String label) =>
        tester.state<EditableTextState>(
          find.descendant(
            of: find.widgetWithText(TextFormField, label),
            matching: find.byType(EditableText),
          ),
        );

    // Tall viewport so all 7 fields fit without a RenderFlex overflow --
    // mirrors ProfileScreen's real SingleChildScrollView wrapper and the
    // Co2SettingsScreen/WeightScreen test precedent.
    void useTallViewport(WidgetTester tester) {
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    Future<void> pumpProfileForm(WidgetTester tester) async {
      UserProfile? currentProfile;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: StatefulBuilder(
                builder: (context, setState) {
                  return ProfileForm(
                    profile: currentProfile,
                    onChanged: (updated) {
                      currentProfile = updated;
                      setState(() {});
                    },
                  );
                },
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('Age field survives an onChanged-driven rebuild', (
      tester,
    ) async {
      useTallViewport(tester);
      await pumpProfileForm(tester);

      final stateBefore = stateFor(tester, 'Age');

      // Mirrors a single real keystroke: enterText fires onChanged once,
      // which synchronously rebuilds ProfileForm with the new profile.age
      // -- exactly the sequence that broke on real devices.
      await tester.enterText(find.widgetWithText(TextFormField, 'Age'), '3');
      await tester.pump();

      final stateAfter = stateFor(tester, 'Age');

      expect(
        identical(stateBefore, stateAfter),
        isTrue,
        reason:
            'Age TextFormField was remounted (new EditableTextState) when '
            'its own value changed -- this is exactly the bug that dropped '
            'focus/dismissed the keyboard after every keystroke on real '
            'devices.',
      );
    });

    testWidgets('Weight (metric) field survives an onChanged-driven rebuild',
        (tester) async {
      useTallViewport(tester);
      await pumpProfileForm(tester);

      final stateBefore = stateFor(tester, 'Weight');

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Weight'),
        '7',
      );
      await tester.pump();

      final stateAfter = stateFor(tester, 'Weight');

      expect(identical(stateBefore, stateAfter), isTrue);
    });
  });
}
