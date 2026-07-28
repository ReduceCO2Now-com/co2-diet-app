import 'dart:io';

import 'package:co2diet/domain/services/improvement_opportunity_finder.dart';
import 'package:co2diet/features/data_analysis/widgets/improvement_opportunities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ImprovementOpportunities widget', () {
    testWidgets('renders nothing when there are no suggestions', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ImprovementOpportunities(opportunities: [])),
        ),
      );

      expect(find.byType(Card), findsNothing);
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets(
      'shows a quantified CO2 delta in non-judgmental factual copy',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ImprovementOpportunities(
                opportunities: [
                  ImprovementOpportunity(
                    originalName: 'Beef Steak',
                    alternativeName: 'chicken',
                    deltaKg: 1.2,
                  ),
                ],
              ),
            ),
          ),
        );

        expect(
          find.textContaining(
            "Replacing today's Beef Steak with chicken would save "
            'approximately',
          ),
          findsOneWidget,
        );
        expect(find.textContaining('1.2 kg CO2'), findsOneWidget);
      },
    );

    testWidgets(
      'is never rendered on the Dashboard screen -- confirmed via a '
      "static scan of lib/features/dashboard/'s file contents",
      (tester) async {
        final dashboardDir = Directory('lib/features/dashboard');
        expect(dashboardDir.existsSync(), isTrue);

        final dashboardFiles = dashboardDir
            .listSync(recursive: true)
            .whereType<File>()
            .where((file) => file.path.endsWith('.dart'));

        for (final file in dashboardFiles) {
          final contents = file.readAsStringSync();
          expect(
            contents.contains('ImprovementOpportunities'),
            isFalse,
            reason:
                '${file.path} must never reference ImprovementOpportunities '
                '-- CO2-06 requires Data-Analysis-screen-only rendering.',
          );
          expect(
            contents.contains('InsightsTimeline'),
            isFalse,
            reason:
                '${file.path} must never reference InsightsTimeline -- '
                'INS-03/CO2-06 requires Data-Analysis-screen-only '
                'rendering.',
          );
        }
      },
    );
  });
}
