import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'CO₂ formatting',
    skip: 'formatCo2Display function not yet implemented',
    () {
      test(
        'formats 4.732 as "~4.7 kg CO₂e/kg" (1 decimal, ~prefix)',
        () {},
      );

      test(
        'formats 12.04 as "~12 kg CO₂e/kg" (2 significant figures)',
        () {},
      );

      test(
        'returns null or empty string for null input',
        () {},
      );
    },
  );
}
