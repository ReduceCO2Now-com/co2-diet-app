import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'NFR-06(b): ≥90% of products in off_reference.sqlite have a CO₂e estimate',
    (tester) async {
      markTestSkipped(
        'CO₂ coverage benchmark: run after ingest pipeline produces co2_factors table',
      );
    },
  );
}
