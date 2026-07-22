import 'package:co2diet/features/barcode_scan/utils/co2_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CO₂ formatting', () {
    test(
      'formats 4.732 as "~4.7 kg CO₂e/kg" (1 decimal, ~prefix)',
      () {
        expect(formatCo2Display(4.732), equals('~4.7 kg CO₂e/kg'));
      },
    );

    test(
      'formats 12.04 as "~12 kg CO₂e/kg" (2 significant figures)',
      () {
        expect(formatCo2Display(12.04), equals('~12 kg CO₂e/kg'));
      },
    );

    test(
      'formats 0.45 as "~0.45 kg CO₂e/kg" (2 decimal places for small values)',
      () {
        expect(formatCo2Display(0.45), equals('~0.45 kg CO₂e/kg'));
      },
    );

    test(
      'returns null for null input',
      () {
        expect(formatCo2Display(null), isNull);
      },
    );
  });
}
