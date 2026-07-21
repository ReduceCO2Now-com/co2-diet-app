import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'FoodCatalogDao.lookupByBarcodeWithCo2',
    skip: 'barcode lookup not yet implemented',
    () {
      test(
        'returns FoodItem with co2e100g and confidenceBand="high" '
        'for a barcode in food_co2_overrides',
        () {},
      );

      test(
        'returns FoodItem with confidenceBand="medium" '
        'for a barcode in products with category match',
        () {},
      );

      test(
        'returns null when barcode not found in any local source',
        () {},
      );
    },
  );
}
