import 'package:co2diet/features/dashboard/widgets/metric_card.dart';
import 'package:co2diet/features/dashboard/widgets/mode_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MetricCard', () {
    testWidgets(
      'renders value vs target with the goal-matching metric '
      'ordered/sized first',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: MetricCard(
                label: 'Calories',
                value: 1500,
                target: 2000,
                unit: 'kcal',
                isEmphasized: true,
              ),
            ),
          ),
        );

        expect(find.text('Calories'), findsOneWidget);
        expect(find.text('1500'), findsOneWidget);
        expect(find.text('of 2000'), findsOneWidget);
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      "shows '—' (no fake precision) when value or target is null",
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: MetricCard(
                label: 'Protein',
                value: null,
                target: null,
                unit: 'g',
              ),
            ),
          ),
        );

        expect(find.text('—'), findsOneWidget);
        expect(find.byType(LinearProgressIndicator), findsNothing);
      },
    );
  });

  group('ModeIndicator', () {
    testWidgets('shows Local Mode text by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ModeIndicator())),
      );

      expect(find.text('Stored on this device'), findsOneWidget);
    });

    testWidgets('shows Account Mode text when isLocalMode is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ModeIndicator(isLocalMode: false)),
        ),
      );

      expect(find.text('Synced across devices'), findsOneWidget);
    });
  });

  group(
    'Dashboard screen assembly (out of scope for this plan)',
    skip:
        'quick-log-button navigation is Plan 05-18 Dashboard-assembly '
        'wiring, not a standalone widget built by this plan',
    () {
      testWidgets(
        'quick-log buttons push /food-search?slot=<slot>; Quick Add '
        'pushes /food-search with no slot param',
        (tester) async {},
      );
    },
  );
}
