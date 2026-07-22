import 'package:co2diet/core/theme/color_tokens.dart';
import 'package:co2diet/features/barcode_scan/widgets/confidence_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ConfidenceChip', () {
    Widget buildChip({required String band, VoidCallback? onTap}) {
      return MaterialApp(
        home: Scaffold(
          body: ConfidenceChip(band: band, onTap: onTap),
        ),
      );
    }

    testWidgets(
      'renders green chip for high confidence band',
      (tester) async {
        await tester.pumpWidget(buildChip(band: 'high'));
        // Verify the container with green background exists.
        final containers = tester.widgetList<Container>(
          find.byType(Container),
        );
        final greenContainers = containers.where((c) {
          final decoration = c.decoration;
          if (decoration is BoxDecoration) {
            return decoration.color == AppColors.primaryContainer;
          }
          return false;
        });
        expect(greenContainers, isNotEmpty);
        // Verify 'High' label text exists.
        expect(find.text('High'), findsOneWidget);
      },
    );

    testWidgets(
      'renders amber chip for medium confidence band',
      (tester) async {
        await tester.pumpWidget(buildChip(band: 'medium'));
        // Verify the container with amber background exists.
        final containers = tester.widgetList<Container>(
          find.byType(Container),
        );
        final amberContainers = containers.where((c) {
          final decoration = c.decoration;
          if (decoration is BoxDecoration) {
            return decoration.color == AppColors.warningAmber;
          }
          return false;
        });
        expect(amberContainers, isNotEmpty);
        // Verify 'Medium' label text exists.
        expect(find.text('Medium'), findsOneWidget);
      },
    );

    testWidgets(
      'chip is tappable and invokes onTap callback',
      (tester) async {
        var tapped = false;
        await tester.pumpWidget(
          buildChip(band: 'high', onTap: () => tapped = true),
        );
        await tester.tap(find.byType(InkWell));
        expect(tapped, isTrue);
      },
    );
  });
}
