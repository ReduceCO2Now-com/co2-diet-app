import 'package:co2diet/features/co2_settings/widgets/data_quality_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DataQualityIndicator', () {
    testWidgets('renders Basic Estimate label for basic quality',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DataQualityIndicator(dataQuality: 'basic'),
          ),
        ),
      );

      expect(find.text('Basic Estimate'), findsOneWidget);
    });

    testWidgets('renders Good Estimate label for good quality',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DataQualityIndicator(dataQuality: 'good'),
          ),
        ),
      );

      expect(find.text('Good Estimate'), findsOneWidget);
    });

    testWidgets('renders Detailed Estimate label for detailed quality',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DataQualityIndicator(dataQuality: 'detailed'),
          ),
        ),
      );

      expect(find.text('Detailed Estimate'), findsOneWidget);
    });
  });

  group(
    'Co2SettingsScreen',
    skip: 'Co2SettingsScreen not yet implemented',
    () {
      testWidgets(
        'all seven fields are optional; saving with everything '
        'empty succeeds',
        (tester) async {},
      );

      testWidgets(
        'data quality indicator updates as fields are filled in',
        (tester) async {},
      );
    },
  );
}
