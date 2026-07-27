---
phase: 04-meal-logging-core-10s-target
plan: 13
subsystem: verification
tags: [real-device, android, ios, human-verify, checkpoint]

# Dependency graph
requires:
  - phase: 04-12
    provides: LOG-13 Dart-level benchmark proxy + LOG-12 offline-path unit proof
provides:
  - "Signed-off human acceptance: end-to-end meal logging <10s on real Android + iOS hardware, full core flow set confirmed working offline (airplane mode), Phase 4 requirements LOG-05 through LOG-13 closed"
affects: [05]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "adb-driven live device verification (screencap + input tap/swipe + logcat/VM-service inspection) as a substitute for manual re-testing when investigating a device-reported bug — used to diagnose the Android resource-starvation false-positive on the swipe bug, and to confirm the nutrition-ranking/CO2-enrichment fixes against the real bundled off_reference.sqlite"
    - "Reproduce-before-fix for provider lifecycle bugs: the favorite-star fix was verified by first writing a test that reproduces the exact autoDispose race (`Ref used after being disposed` thrown from FavoriteNotifier.toggle), confirming the failure mode before applying the one-line ref.watch() fix"

key-files:
  created:
    - test/features/dashboard/dashboard_swipe_integration_test.dart
    - test/features/food_search/food_detail_sheet_test.dart
    - test/features/food_search/food_result_row_test.dart
  modified:
    - ios/Runner/Info.plist
    - lib/features/food_search/widgets/portion_slot_form.dart
    - lib/features/food_search/widgets/recent_favorites_list.dart
    - lib/features/dashboard/screens/placeholder_dashboard_screen.dart
    - lib/features/food_search/widgets/food_detail_sheet.dart
    - lib/data/local/daos/food_catalog_dao.dart
    - test/features/food_search/portion_slot_form_test.dart
    - test/data/local/food_catalog_dao_ranking_test.dart
    - pubspec.yaml

key-decisions:
  - "SnackBar.persist (not duration) is the actual control for auto-dismiss when an action is present — Flutter's SnackBar defaults persist to true whenever `action` is non-null, silently making `duration` alone a no-op; discovered by reading snack_bar.dart/scaffold.dart source directly after an initial duration-only fix didn't hold up on real-device retest"
  - "Nutrition-data-completeness search ranking is a strict two-tier sort `(calories_100g IS NULL), rank`, not a blended score — every product with data outranks every product without one, BM25 only breaks ties within each tier, applied before LIMIT 25 so a complete-but-lower-BM25-rank result can displace an incomplete higher-rank one"
  - "CO2 enrichment for search results uses a single LEFT JOIN (food_co2_overrides + co2_factors) rather than the barcode path's per-item lookup — appropriate given search returns up to 25 rows vs. barcode's single resolution; avoids an N+1 query"
  - "Favorite-star fix mirrors the exact ref.watch()-for-autoDispose-safety pattern already established (and documented) in PortionSlotForm/RecentFavoritesList, rather than introducing a new pattern"
  - "Two real bugs found during this checkpoint were device-environment false positives, not code bugs: the Android tablet's swipe-to-edit failure was traced to severe RAM starvation preventing the Dart isolate from ever spawning (confirmed via VM service isolate inspection), not a flutter_slidable wiring issue — resolved by freeing device memory, not a code change"

patterns-established:
  - "Realistic incremental drag helper (10-step startGesture/moveBy/pump loop) for widget tests exercising swipe/drag gestures inside a real list composition, instead of a single teleporting tester.drag() call on a bare single-widget host"
  - "Building a real, minimal off_ref.sqlite fixture on disk (matching tools/ingest_off.py's DDL exactly, including food_co2_overrides/co2_factors) via the sqlite3 package directly, ATTACHed through a real AppDatabase — used to prove SQL-level ranking/JOIN behavior that a mocked repository test cannot exercise"

requirements-completed: [LOG-05, LOG-06, LOG-07, LOG-08, LOG-09, LOG-10, LOG-11, LOG-12, LOG-13]

# Metrics
duration: multi-session (spanning 2026-07-26 to 2026-07-27)
completed: 2026-07-27
---

# Phase 4 Plan 13: Real-Device Human-Verify Checkpoint Summary

**Phase 4 closed: end-to-end meal logging confirmed under 10 seconds on real Android and iOS hardware, full core flow set (logging, Recent/Favorites, custom foods/overrides, edit/delete/duplicate, offline/airplane-mode) confirmed working on both devices, after finding and fixing six real bugs surfaced specifically by physical-device testing that no automated test or simulator had caught.**

## Devices tested

- **Android:** Samsung Galaxy Tab S7 FE, Android 14 (API 34), device id `R52RB0FSSAX`
- **iOS:** iPhone 16 Pro Max ("Kimo's 16"), iOS 26.5.2

## Performance

- **Duration:** Multi-session checkpoint spanning 2026-07-26–2026-07-27 (interleaved with bug-fix cycles between retests)
- **Completed:** 2026-07-27
- **Automated Dart-level LOG-13 benchmark proxy (Android):** 1002ms measured elapsed (well under the 10s threshold) — see commit `f499c34`'s benchmark-fixture fix for the real-device tap-miss it uncovered first
- **Human-timed real end-to-end logging:** confirmed under 10 seconds across multiple attempts on both devices per the plan's LOG-13 P0 criterion

## Accomplishments

Everything in `04-CONTEXT.md`'s scope confirmed working on both physical devices in the final approved pass:

- Barcode scanner (camera permission fix confirmed on iOS)
- Timed end-to-end meal logging, both devices <10s
- Live macro/CO2 display during quantity selection
- CO2 value display consistent between search-found and barcode-scanned foods
- "Added to [Slot]" Undo snackbar auto-dismisses (~5s)
- Double-submit guard (no duplicate/doubled entries from a fast double-tap)
- Swipe-to-edit/delete/duplicate on dashboard entries
- Recent/Favorites one-tap logging
- Favorite star visual toggle
- Custom food creation (saves and is searchable)
- Airplane-mode offline logging, full flow
- Barcode scan while offline with no local match (correct no-match screen)

## Bugs found and fixed during this checkpoint

Real-device testing surfaced six genuine bugs that unit/widget tests and simulator testing had not caught, each fixed and covered by a new regression test:

1. **iOS camera crash — missing `NSCameraUsageDescription`** (`e0f1534`). First physical iOS barcode-scan attempt crashed with Apple's privacy-usage-description error. Phase 3's barcode scanning was only ever verified on Android; the iOS Info.plist entry was never added. Audited the rest of the app for other missing usage-description keys — camera is the only privacy-sensitive API in use.

2. **Live macro/CO2 table effectively invisible during quantity entry** (`55595c6`). Sat below the quantity input in `PortionSlotForm`; the on-screen keyboard pushed it out of the visible sheet area on a real tablet. Moved above the slot/quantity controls so it's always visible without scrolling.

3. **Undo snackbar never auto-dismissed** (`784387c`). Root cause: Flutter's `SnackBar.persist` defaults to `true` whenever an `action` is set, which silently makes `duration` alone a no-op — found by reading `snack_bar.dart`/`scaffold.dart` source directly after an initial duration-only attempt didn't hold up on retest. Fixed with an explicit `persist: false` on all three Undo-style snackbars.

4. **Double-submit race could double a logged quantity** (`784387c`, same commit). No re-entry guard on `PortionSlotForm`'s "Log this food" or `RecentFavoritesList`'s one-tap rows meant a fast double-tap while the async write was in flight could fire two writes. Added `_isSubmitting`/`_isLogging` guards; verified against a never-before-logged food via direct on-device DB inspection (exactly `100.0`g persisted after a rapid double-tap, not `200.0`).

5. **Search results never showed nutrition or CO2 data** (`ef22710`, `2218dbb`). Two compounding issues: (a) BM25 relevance ranking had no preference for nutrition-data-complete rows, so common queries surfaced almost entirely `— kcal/100g` results ahead of the few complete ones — fixed with a two-tier `(calories_100g IS NULL), rank` sort; (b) the search query hardcoded `NULL AS co2e_100g`/`NULL AS confidence_band` for every row, never running the AGRIBALYSE-crosswalk/category-average enrichment `lookupByBarcodeWithCo2` (the barcode path) does — fixed by LEFT JOINing `food_co2_overrides`/`co2_factors` directly into the search query, verified against the real bundled `off_reference.sqlite` (not just a synthetic fixture).

6. **Favorite star never visually updated after a successful toggle** (`af9d9e8`). `favoriteProvider` is `autoDispose`; `_FoodDetailContentState` only ever `ref.read()` it, never `ref.watch()`. With nothing else in the tree keeping it alive (the real case: opening a detail sheet from search results, where `RecentFavoritesList` — which does watch it — isn't mounted), Riverpod disposed the notifier mid-toggle, making `ref.invalidateSelf()` throw and abort before the icon-refreshing re-read ran. The write still landed (hence the favorite correctly appearing in the Favorites list) but the icon stayed stale. Reproduced the exact exception in a test first, then applied the same `ref.watch()`-for-autoDispose-safety pattern already established elsewhere in this codebase.

One reported "bug" (swipe-to-edit not working) turned out to be a device-environment false positive, not a code issue: the Android tablet was under severe memory pressure (only ~233MB free of 5.2GB) badly enough that the Dart isolate never spawned at all (confirmed via direct VM-service isolate inspection across two clean relaunches) — resolved by freeing device memory, not a code change. A new realistic-drag regression test (`c1cac21`) was added regardless, since the existing swipe test only used a bare single-widget host and a single teleporting drag rather than the real dashboard composition.

## Deferred / follow-up (not blocking Phase 4 close)

Logged in `deferred-items.md`:

1. **CO2 enrichment still missing on the API-fallback cached-search path** (`user_food_cache_fts` — only reached when local FTS5 search returns nothing). Needs a schema change (retain category tag at cache-write time) plus a per-row lookup; deliberately not folded into this checkpoint's fix since it needs the same care the codebase already gave to avoiding a `json_each`-based approach for the barcode path.
2. **iOS-specific text-contrast issue on Profile/Settings screens**, not present on Android. Not yet root-caused; needs its own investigation.

## Verification

- `flutter test test/` — 214/214 passing
- `flutter analyze` — clean on all files touched this checkpoint (pre-existing unrelated info-level lints untouched)
- Automated LOG-13 benchmark proxy passing on Android (1002ms)
- Human sign-off: **approved** — all checklist items confirmed on both physical devices

## Requirements completed

LOG-05, LOG-06, LOG-07, LOG-08, LOG-09, LOG-10, LOG-11, LOG-12, LOG-13 — Phase 4 closed.
