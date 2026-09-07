// The target-override dialog must not use its TextEditingController after
// disposing it.
//
// Root cause of the profile-daily-targets crash, found on real hardware
// 2026-09-07 after three earlier sessions failed to reproduce it. The
// controller was created by the caller and disposed on the line after
// `await showDialog(...)`. That await completes when the route is POPPED, not
// when it is GONE — so the controller was destroyed while the dialog's exit
// transition was still running and the still-mounted TextFormField was still
// rebuilding. The device log:
//
//   A TextEditingController was used after being disposed.
//   The relevant error-causing widget was: TextFormField
//   ...cascading into: '_dependents.isEmpty': is not true
//
// Every prior reproduction attempt only OPENED the dialog and dismissed it.
// The trigger is COMPLETING it — tapping Save or Reset — and then pumping far
// enough for the exit transition to rebuild the subtree. That distinction is
// why this was missed for six weeks, so these tests pump the animation out
// explicitly rather than relying on pumpAndSettle alone.

import 'package:co2diet/features/profile/widgets/target_override_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Drives a dialog exactly as ProfileScreen does, then advances the clock
/// through the exit transition frame by frame.
Future<void> _openCompleteAndAnimateOut(
  WidgetTester tester, {
  required String buttonText,
}) async {
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
  expect(find.text('Set custom target'), findsOneWidget);

  await tester.tap(find.text(buttonText));

  // Deliberately NOT pumpAndSettle in one go: the failure window is the
  // handful of frames while the route animates out and the dialog subtree is
  // still mounted and still rebuilding.
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 20));
  }
  await tester.pumpAndSettle();
}

void main() {
  late Widget harness;

  setUp(() {
    harness = MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            // Mirrors ProfileScreen's call site: a dialog whose controller
            // lifetime is owned by the dialog, awaited by the caller.
            onPressed: () => showDialog<TargetOverrideResult>(
              context: context,
              builder: (_) => const TargetOverrideDialog(initialValue: 1800),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );
  });

  testWidgets('Save: no controller-after-dispose during the exit transition',
      (tester) async {
    await tester.pumpWidget(harness);
    await _openCompleteAndAnimateOut(tester, buttonText: 'Save');

    expect(tester.takeException(), isNull);
  });

  testWidgets('Reset: no controller-after-dispose during the exit transition',
      (tester) async {
    await tester.pumpWidget(harness);
    await _openCompleteAndAnimateOut(tester, buttonText: 'Reset to calculated');

    expect(tester.takeException(), isNull);
  });

  testWidgets('dismissing without choosing is still clean', (tester) async {
    await tester.pumpWidget(harness);
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    Navigator.of(tester.element(find.text('Set custom target'))).pop();
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('reopening after a completed dialog works', (tester) async {
    await tester.pumpWidget(harness);
    await _openCompleteAndAnimateOut(tester, buttonText: 'Save');
    await _openCompleteAndAnimateOut(tester, buttonText: 'Save');

    expect(tester.takeException(), isNull);
  });
}
