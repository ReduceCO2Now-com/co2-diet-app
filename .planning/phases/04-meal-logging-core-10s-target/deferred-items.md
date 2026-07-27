# Deferred Items — Phase 04

Out-of-scope issues discovered during plan execution but not fixed
(scope boundary: only auto-fix issues directly caused by the current
task's changes).

## From Plan 04-04

- `lib/data/local/daos/food_catalog_dao.dart` has 5 pre-existing
  `flutter analyze` info-level lints (1 `comment_references`, 4
  `lines_longer_than_80_chars`) predating this plan. Not touched by
  Plan 04-04 — file was only read for precedent, never modified.

## From Plan 04-13 (real-device checkpoint)

- **CO2 enrichment missing on the API-fallback cached-search path.**
  `FoodCatalogDao.searchLocalFoods`'s off_ref query was fixed (commit
  `2218dbb`) to LEFT JOIN `food_co2_overrides`/`co2_factors`, matching
  `lookupByBarcodeWithCo2`. The `user_food_cache_fts` query (results
  cached from an OFF API search fallback — only reached when local FTS5
  search returns nothing) is NOT enriched: cached rows don't retain a
  `primary_category_tag` to join against, since
  `FoodCatalogRepository.searchAndCache`/`lookupByBarcode`'s cache-write
  path hardcodes `categoriesTags: const Value(null)`. Fixing this needs a
  schema change (store the category tag/list at cache-write time) plus a
  per-row category lookup — the codebase's barcode-lookup path explicitly
  avoided a `json_each`-based approach for this exact kind of lookup
  (RESEARCH.md Pitfall 5), so the fix needs equivalent care, not a quick
  patch. Narrow, rare path (only hit on a cache-miss search that also
  misses locally) — tracked for its own follow-up rather than folded into
  Phase 4.

- **iOS-specific text-contrast issue on Profile/Settings screens.**
  Confirmed during real-device checkpoint testing: some text on the
  Profile/Settings screens is low-contrast/hard to read on iOS but
  displays correctly on Android. Not yet root-caused (likely a
  theme/color-scheme resolution difference between platforms, e.g. a
  color relying on a default that resolves differently under iOS's
  `CupertinoTheme` interplay with Material, or a hardcoded color that
  reads fine against Android's default surface but not iOS's). Deferred
  as unrelated to Phase 4's meal-logging scope; needs its own
  investigation.
