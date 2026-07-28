import 'package:co2diet/features/dashboard/widgets/co2_profile_prompt_card.dart';
import 'package:co2diet/features/dashboard/widgets/trend_sparkline.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TrendSparkline', () {
    final spots = {
      DashboardMetric.co2: const [FlSpot(0, 1), FlSpot(1, 2)],
      DashboardMetric.calories: const [FlSpot(0, 100), FlSpot(1, 200)],
      DashboardMetric.protein: const [FlSpot(0, 10), FlSpot(1, 20)],
    };

    testWidgets(
      'segmented control switches which metric (CO2/Calories/ '
      'Protein) the 7-day sparkline plots',
      (tester) async {
        var selected = DashboardMetric.co2;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return TrendSparkline(
                    selectedMetric: selected,
                    onMetricChanged: (metric) =>
                        setState(() => selected = metric),
                    spots: spots,
                    onTap: () {},
                  );
                },
              ),
            ),
          ),
        );

        expect(selected, DashboardMetric.co2);

        await tester.tap(find.text('Protein'));
        await tester.pumpAndSettle();

        expect(selected, DashboardMetric.protein);
      },
    );

    testWidgets(
      'tapping the chart opens Data Analysis pre-set to the '
      'currently selected metric',
      (tester) async {
        var tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TrendSparkline(
                selectedMetric: DashboardMetric.calories,
                onMetricChanged: (_) {},
                spots: spots,
                onTap: () => tapped = true,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(LineChart));
        await tester.pumpAndSettle();

        expect(tapped, isTrue);
      },
    );
  });

  group('Co2ProfilePromptCard', () {
    testWidgets('renders only when show is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Co2ProfilePromptCard(
              show: false,
              onDismiss: () {},
              onTap: () {},
            ),
          ),
        ),
      );

      expect(
        find.text('Complete your CO₂ profile for better estimates'),
        findsNothing,
      );
    });

    testWidgets('calls onDismiss and onTap', (tester) async {
      var dismissed = false;
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Co2ProfilePromptCard(
              show: true,
              onDismiss: () => dismissed = true,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(
        find.text('Complete your CO₂ profile for better estimates'),
        findsOneWidget,
      );

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(dismissed, isTrue);

      await tester.tap(
        find.text('Complete your CO₂ profile for better estimates'),
      );
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });
  });
}
