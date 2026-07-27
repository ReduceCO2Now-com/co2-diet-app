import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'FoodCatalogDao user_food_cache_fts CO2 enrichment',
    skip: 'cache-path CO2 join not yet fixed',
    () {
      test(
        'searchAndCache stores the primary (most-specific) category '
        'tag into categoriesTags instead of NULL',
        () {},
      );

      test(
        'searchLocalFoods LEFT JOINs off_ref.co2_factors for '
        'user_food_cache_fts results using the stored categoriesTags',
        () {},
      );

      test(
        'a previously API-cached product now shows a CO2 estimate on '
        'a subsequent offline local search',
        () {},
      );
    },
  );
}
