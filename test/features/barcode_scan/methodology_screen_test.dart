import 'package:co2diet/features/barcode_scan/screens/methodology_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MethodologyScreen', () {
    Widget buildScreen() {
      return const MaterialApp(
        home: MethodologyScreen(),
      );
    }

    testWidgets(
      'displays AGRIBALYSE v3.1.1 attribution string',
      (tester) async {
        await tester.pumpWidget(buildScreen());
        await tester.pump();
        expect(find.textContaining('AGRIBALYSE v3.1.1'), findsWidgets);
      },
    );

    testWidgets(
      'displays Source ADEME credit text',
      (tester) async {
        await tester.pumpWidget(buildScreen());
        await tester.pump();
        expect(find.textContaining('Source ADEME'), findsWidgets);
      },
    );

    testWidgets(
      'displays Licence Ouverte / Open Licence text',
      (tester) async {
        await tester.pumpWidget(buildScreen());
        await tester.pump();
        expect(
          find.textContaining('Licence Ouverte'),
          findsWidgets,
        );
      },
    );

    testWidgets(
      'shows GitHub link button for full methodology doc',
      (tester) async {
        await tester.pumpWidget(buildScreen());
        await tester.pump();
        // Find the OutlinedButton that opens GitHub.
        expect(find.byType(OutlinedButton), findsAtLeastNWidgets(1));
        expect(find.textContaining('GitHub'), findsWidgets);
      },
    );
  });
}
