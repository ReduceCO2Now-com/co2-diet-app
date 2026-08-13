import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group(
    'DeltaApplier',
    skip: 'Awaiting Plan 09-04 implementation',
    () {
      // TODO(Plan 09-04): applying a delta with new/changed rows makes
      // them immediately findable via products_fts text search
      // (09-RESEARCH.md Pitfall 1).
      testWidgets(
        'applying a delta with new/changed rows makes them '
        'immediately findable via products_fts text search '
        '(09-RESEARCH.md Pitfall 1)',
        (tester) async {},
      );

      // TODO(Plan 09-04): applying a delta with deleted_barcodes
      // removes the corresponding row from both products and
      // products_fts.
      testWidgets(
        'applying a delta with deleted_barcodes removes the '
        'corresponding row from both products and products_fts',
        (tester) async {},
      );

      // TODO(Plan 09-04): delta apply runs inside a single
      // transaction — a mid-apply failure leaves the previously-
      // attached data intact (all-or-nothing).
      testWidgets(
        'delta apply runs inside a single transaction — a mid-apply '
        'failure leaves the previously-attached data intact '
        '(all-or-nothing)',
        (tester) async {},
      );
    },
  );
}
