import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'FoodCatalogDao override precedence',
    skip: 'override-aware search not yet implemented',
    () {
      test(
        'searchLocalFoods returns the override row instead of the '
        'original when both match',
        () {},
      );

      test(
        'lookupByBarcodeWithCo2 resolves to the override when a '
        'barcode-keyed override exists',
        () {},
      );

      test(
        'original catalog row is still queryable directly by barcode when '
        'the override is reverted',
        () {},
      );
    },
  );
}
