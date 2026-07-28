import 'package:co2diet/features/data_analysis/widgets/insights_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InsightsTimeline', () {
    testWidgets('renders zero entries when no pattern threshold is met', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: InsightsTimeline(observations: [])),
        ),
      );

      expect(find.byType(Text), findsNothing);
    });

    testWidgets(
      'renders a factual, non-judgmental pattern line when a rule '
      'threshold is met',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: InsightsTimeline(
                observations: [
                  'CO2 consistently higher on Friday evenings',
                  'CO2 trending down over the trailing week',
                ],
              ),
            ),
          ),
        );

        expect(
          find.text('CO2 consistently higher on Friday evenings'),
          findsOneWidget,
        );
        expect(
          find.text('CO2 trending down over the trailing week'),
          findsOneWidget,
        );
      },
    );
  });
}
