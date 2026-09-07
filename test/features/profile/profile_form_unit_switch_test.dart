// Switching the units toggle must CONVERT the stored value for display, never
// re-interpret the number already on screen as the new unit.
//
// Regression test for the 2026-09-07 device finding: a profile entered as
// 156 cm / 62 kg came back from the database as height_cm = 4754.88 and
// weight_kg = 28.122704 — exactly 156 ft and 62 lb. The displayed numbers had
// been read as imperial after the toggle flipped, then converted *up* into
// canonical metric. The consequence is not cosmetic: TargetCalculator produced
// rawKcal = 40855.68 for that profile, silently clamped to the 10000 ceiling,
// so every daily target shown to an imperial user was wrong.

import 'package:co2diet/domain/entities/user_profile.dart';
import 'package:co2diet/features/profile/widgets/profile_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

UserProfile _metricProfile() => const UserProfile(
  id: 'p1',
  age: 25,
  heightCm: 156,
  weightKg: 62,
);

/// Pumps [ProfileForm] and rebuilds it with whatever profile `onChanged`
/// reports — mirroring how ProfileScreen drives it in production, where the
/// toggle's change round-trips through state before coming back as a rebuild.
Future<void> _pumpForm(WidgetTester tester, UserProfile initial) async {
  var current = initial;
  await tester.pumpWidget(
    MaterialApp(
      home: StatefulBuilder(
        builder: (context, setState) => Scaffold(
          body: SingleChildScrollView(
            child: ProfileForm(
              profile: current,
              onChanged: (updated) => setState(() => current = updated),
            ),
          ),
        ),
      ),
    ),
  );
}

/// Reads the text currently displayed by the field carrying [suffix].
String _fieldTextBySuffix(WidgetTester tester, String suffix) {
  final field = tester.widgetList<TextField>(find.byType(TextField)).firstWhere(
    (f) => f.decoration?.suffixText == suffix,
    orElse: () => throw StateError('no field with suffix "$suffix"'),
  );
  return field.controller?.text ?? '';
}

void main() {
  group('unit switch converts rather than re-interprets', () {
    testWidgets('metric → imperial shows 156 cm as 5 ft 1 in, not 156 ft',
        (tester) async {
      await _pumpForm(tester, _metricProfile());

      expect(_fieldTextBySuffix(tester, 'cm'), '156');

      await tester.tap(find.text('Imperial (lb, ft+in)'));
      await tester.pumpAndSettle();

      // 156 cm = 61.4 in = 5 ft 1 in. The failure mode this guards is the
      // feet field still reading "156".
      expect(_fieldTextBySuffix(tester, 'ft'), '5');
      expect(_fieldTextBySuffix(tester, 'in'), '1');
    });

    testWidgets('metric → imperial shows 62 kg as 136.7 lb, not 62 lb',
        (tester) async {
      await _pumpForm(tester, _metricProfile());

      expect(_fieldTextBySuffix(tester, 'kg'), '62.0');

      await tester.tap(find.text('Imperial (lb, ft+in)'));
      await tester.pumpAndSettle();

      // 62 kg = 136.7 lb. The failure mode this guards is the field still
      // reading "62" while the suffix says lb.
      expect(_fieldTextBySuffix(tester, 'lb'), '136.7');
    });

    testWidgets('imperial → metric converts back without drift',
        (tester) async {
      await _pumpForm(
        tester,
        _metricProfile().copyWith(units: 'imperial'),
      );

      expect(_fieldTextBySuffix(tester, 'ft'), '5');
      expect(_fieldTextBySuffix(tester, 'lb'), '136.7');

      await tester.tap(find.text('Metric (kg, cm)'));
      await tester.pumpAndSettle();

      expect(_fieldTextBySuffix(tester, 'cm'), '156');
      expect(_fieldTextBySuffix(tester, 'kg'), '62.0');
    });

    testWidgets('toggling units does not mutate the stored canonical values',
        (tester) async {
      var current = _metricProfile();
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) => Scaffold(
              body: SingleChildScrollView(
                child: ProfileForm(
                  profile: current,
                  onChanged: (updated) => setState(() => current = updated),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Imperial (lb, ft+in)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Metric (kg, cm)'));
      await tester.pumpAndSettle();

      // A round trip through the toggle must be lossless. In the bug this
      // guards, height became 4754.88 and weight 28.12 after one flip.
      expect(current.heightCm, 156);
      expect(current.weightKg, 62);
    });
  });
}
