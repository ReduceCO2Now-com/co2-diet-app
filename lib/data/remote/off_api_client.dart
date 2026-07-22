import 'package:co2diet/domain/entities/food_item.dart';
import 'package:flutter/foundation.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

/// One-time setup for the openfoodfacts Dart client.
///
/// Must be called exactly once at app startup (in `main()`) before any
/// OFF API query. Failing to call this results in 403 responses from the
/// OFF server because no User-Agent is set (Pitfall 6 in RESEARCH.md).
///
/// T-02-04-05 mitigation: sets a valid User-Agent with the app name so
/// the OFF server can identify our requests and returns 200 responses.
void configureOff() {
  OpenFoodAPIConfiguration.userAgent = UserAgent(
    name: 'CO2Diet',
    url: 'https://reduceco2now.com',
  );
  OpenFoodAPIConfiguration.globalLanguages = [
    OpenFoodFactsLanguage.ENGLISH,
    OpenFoodFactsLanguage.GERMAN,
  ];
  OpenFoodAPIConfiguration.globalCountry = OpenFoodFactsCountry.GERMANY;
}

/// Thin wrapper over the `openfoodfacts` package for OFF API v3 product search.
///
/// Provides a single [searchOff] method that builds a
/// [ProductSearchQueryConfiguration] v3 query and maps the API response
/// to [FoodItem] domain entities.
///
/// T-02-04-01 mitigation: all Product field access uses null-safe `?.`
/// operators and fallback values; malformed or null product fields are
/// silently coerced to safe defaults rather than throwing.
///
/// T-02-04-04 mitigation: on network timeout or error the method lets the
/// exception propagate to the caller (`FoodCatalogRepository`), which
/// catches it and rethrows as `NetworkException`, surfaced as error state in
/// Plan 02-05 without blocking the UI thread.
class OffApiClient {
  /// Fetches a single product by exact [barcode] from the OFF API v3.
  ///
  /// Returns a [FoodItem] if the product is found on the OFF server, or
  /// null when the server returns a 404/not-found response.
  ///
  /// Throws on network errors — the caller
  /// (`FoodCatalogRepository.lookupByBarcode`) catches and handles them.
  ///
  /// T-03-03-01 mitigation: [barcode] is a product-identifier string passed
  /// as a URL segment (not SQL) — no injection risk at this layer.
  /// T-04-04-04 mitigation: all Product field accesses use null-safe `?.`
  /// operators to handle malformed API responses without throwing.
  Future<FoodItem?> fetchByBarcode(String barcode) async {
    final config = ProductQueryConfiguration(
      barcode,
      language: OpenFoodFactsLanguage.ENGLISH,
      fields: [
        ProductField.BARCODE,
        ProductField.NAME,
        ProductField.NAME_IN_LANGUAGES,
        ProductField.BRANDS,
        ProductField.NUTRIMENTS,
        ProductField.CATEGORIES_TAGS,
      ],
      version: ProductQueryVersion.v3,
    );

    final result = await OpenFoodAPIClient.getProductV3(config);
    if (result.product == null) return null;
    return _productToFoodItem(result.product!);
  }

  /// Searches the OFF API v3 for products matching [query].
  ///
  /// Returns up to 20 [FoodItem]s mapped from the API response.
  /// Returns an empty list (does NOT throw) when the API response contains
  /// a null products list.
  ///
  /// Throws when the network is unavailable or the API returns a non-200
  /// status. The caller (`FoodCatalogRepository.searchAndCache`) wraps such
  /// exceptions as `NetworkException`.
  Future<List<FoodItem>> searchOff(String query) async {
    final config = ProductSearchQueryConfiguration(
      parametersList: [
        SearchTerms(terms: [query]),
        const PageSize(size: 20),
        const PageNumber(page: 1),
      ],
      language: OpenFoodFactsLanguage.ENGLISH,
      fields: [
        ProductField.BARCODE,
        ProductField.NAME,
        ProductField.BRANDS,
        ProductField.NUTRIMENTS,
      ],
      version: ProductQueryVersion.v3,
    );

    final result = await OpenFoodAPIClient.searchProducts(null, config);
    return result.products?.map(_productToFoodItem).toList() ?? [];
  }

  /// Maps an OFF [Product] to a [FoodItem] domain entity.
  ///
  /// All field accesses use null-safe `?.` operators with safe fallbacks.
  /// Nutriment values are extracted via [Nutriments.getValue] for
  /// [PerSize.oneHundredGrams].
  ///
  /// T-02-04-01: null nutriments, null barcode, and null product names
  /// are each handled without throwing.
  FoodItem _productToFoodItem(Product p) {
    // TEMP DEBUG — remove after device verification
    debugPrint('[CO2-DEBUG] _productToFoodItem: barcode=${p.barcode} categoriesTags=${p.categoriesTags}');
    final nutriments = p.nutriments;
    return FoodItem(
      barcode: p.barcode,
      productName: p.productName ?? 'Unknown',
      brand: p.brands,
      calories100g:
          nutriments?.getValue(Nutrient.energyKCal, PerSize.oneHundredGrams),
      protein100g:
          nutriments?.getValue(Nutrient.proteins, PerSize.oneHundredGrams),
      carbs100g: nutriments?.getValue(
        Nutrient.carbohydrates,
        PerSize.oneHundredGrams,
      ),
      fat100g: nutriments?.getValue(Nutrient.fat, PerSize.oneHundredGrams),
      categoriesTags: p.categoriesTags,
    );
  }
}
