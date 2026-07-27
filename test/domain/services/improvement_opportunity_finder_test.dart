import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'ImprovementOpportunityFinder',
    skip: 'ImprovementOpportunityFinder not yet implemented',
    () {
      test(
        'suggests a same-cluster protein alternative (e.g. red meat '
        '-> poultry/fish/legumes) with a quantified CO2 delta',
        () {},
      );

      test(
        'never suggests a cross-cluster swap (e.g. beef -> lettuce)',
        () {},
      );

      test(
        'returns no suggestions when today has no high-CO2 entries '
        '(opt-in, never forced)',
        () {},
      );
    },
  );
}
