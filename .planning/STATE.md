---
gsd_state_version: 1.0
milestone: v1
milestone_name: v1 launch
status: executing
last_updated: "2026-07-28T07:58:43.485Z"
progress:
  total_phases: 9
  completed_phases: 4
  total_plans: 51
  completed_plans: 40
  percent: 44
---

# STATE: CO₂ Diet

**Last updated:** 2026-07-16
**Session:** Initialization complete; roadmap created

---

## Project Reference

See: `.planning/PROJECT.md` (updated 2026-07-16)

- **Core value:** A user must be able to log a meal in under 10 seconds — everything else is secondary to that speed and privacy guarantee.
- **What this is:** Privacy-first, offline-first Flutter mobile app (iOS + Android) tracking nutrition + estimated CO₂ footprint of food choices. Free forever, zero ads, zero behavioral data, on-device by default, optional self-hosted account sync.
- **Sole Flutter dev:** Ali. Backend (Spring Boot + PostgreSQL + Keycloak) is a parallel workstream owned by Tomris.
- **Package:** `com.reduceco2now.co2diet`
- **Launch market:** EU / Germany (English-only for v1)
- **Current focus:** Roadmap complete → Phase 1 planning next

---

## Current Position

- **Milestone:** v1 launch
- **Phase:** 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable — IN PROGRESS (8 of 19 plans done)
- **Plan:** 9 of 19 (05-08 complete — fl_chart/flutter_local_notifications/timezone/flutter_timezone installed, NotificationPrefs domain layer, NotificationService, rootNavigatorKey, main.dart wiring)
- **Status:** Ready to execute
- **Progress:** [████████░░] 78%
- **v1 requirements:** 34 / 75 delivered (CO2-01, CO2-02, CO2-03, CO2-04, LEG-05, LOG-01 through LOG-12, NFR-05, NFR-06, PROF-01 through PROF-05, PRIV-07) — Phase 4 fully closed (04-13 real-device checkpoint approved on both platforms); 05-02 closes the Phase-4 CO2 cache-path gap (CO2-02, NFR-05); 05-03 adds the Phase 5 Drift schema foundation (schema-only); 05-04 wires sugar/fiber/salt through FoodItem/MealEntry/repository (NUTR-01 still not fully delivered — daily-totals rollup is 05-10-PLAN.md, dashboard/insights UI later still); 05-05 adds the DAO layer for CO2 Settings/Weight/Notifications/Backup; 05-06 delivers the CO2 Settings domain layer (CO2-03 now fully delivered); 05-07 delivers the Weight Tracking domain layer (WT-01 through WT-04 still NOT fully delivered — the screen doesn't exist until 05-13, domain layer only so far); 05-08 installs fl_chart/flutter_local_notifications/timezone/flutter_timezone and delivers NotificationService + NotificationPrefs domain layer (NOTIF-01/02/03 still NOT fully delivered — the meal-reminder/weigh-in-reminder UI doesn't exist until 05-13/05-14/05-18, service/domain layer only so far; PRIV-02, PRIV-03 still not fully delivered — repository/UI plans pending); remaining Phase 5 requirements are test-stub-scaffolded only so far

```
[███████░░░] 71%
```

### Initialization Progress

- [x] PROJECT.md created and committed
- [x] config.json created and committed (mode: interactive, granularity: fine, model: quality)
- [x] Research completed (STACK, FEATURES, ARCHITECTURE, PITFALLS, SUMMARY — all committed)
- [x] REQUIREMENTS.md — defined (75 v1 requirements)
- [x] ROADMAP.md — 9 phases, 100% requirement coverage
- [x] Phase 1 planning — complete (7 plans created)
- [x] Plan 01-01 — Flutter scaffold + pubspec + theme module — COMPLETE
- [x] Plan 01-02 — Sync-safe Drift schema (HLC + SyncSafeTable + DAOs + codegen) — COMPLETE
- [x] Plan 01-03 — Domain layer: UserProfile, CalcTargets, TargetCalculator, IProfileRepository — COMPLETE
- [x] Plan 01-04 — Repository layer + DI providers + ProfileNotifier AsyncNotifier — COMPLETE
- [x] Plan 01-05 — go_router + ProfileScreen (7 fields, unit-aware, auto-save, targets, override) + SettingsScreen (PRIV-07) — COMPLETE
- [x] Plan 01-06 — CI privacy pipeline (.privacy-blocklist.yaml + check_privacy_deps.dart + GitHub Actions ci.yml) — COMPLETE
- [x] Plan 01-07 — Wave 0 test suite: 6 test files, 34 tests green (Mifflin TDEE, Drift DAOs, schema, blocklist subprocess, theme tokens) — COMPLETE

---

## Performance Metrics

- Requirements defined: 75 v1 (+ 15 deferred to v2)
- Requirements mapped to phases: 75 / 75 (100% coverage)
- Phases planned: 9 (target: fine granularity 8–12) ✓
- Plans executed: 7 (01-01 through 01-07 complete — Phase 1 DONE)
- Verifications passed: 9
- Total sessions: 4

---

## Accumulated Context

### Key Decisions Locked

- **Local DB:** Drift (SQLite) — Hive rejected (unmaintained, no FTS5, brittle migrations). Sync-safe schema mandatory from v1.
- **Auth:** Keycloak OIDC + PKCE via `flutter_appauth` — no Firebase/Supabase.
- **Barcode scanning:** P0 — must be verified on real iOS + Android devices before launch.
- **GitHub sign-in:** dropped for v1.
- **Passkeys:** deferred to v1.1 (AUTH-V2-01).
- **16+ age gate:** self-declaration checkbox on Legal Consent screen.
- **Monthly aggregate view:** out of scope for v1 (30-day rolling trend is sufficient).
- **Admin profile:** out of scope for the mobile app (web/backoffice only).
- **Recent = individual items** (not combo entries) — confirmed via live build.
- **CO₂ profile factors** live in CO₂ Calculation Settings, not Profile Setup.
- **freezed 3.2.6-dev.1 (not stable 3.2.5):** 3.2.5 requires analyzer >=9 <11 which conflicts with riverpod_lint 3.1.4 (^12); dev.1 aligns with ^12 [01-01]
- **custom_lint removed from stack:** riverpod_lint 3.1.4 migrated to analysis_server_plugin; custom_lint 0.8.1 analyzer ^8 is incompatible with riverpod_lint 3.1.4 analyzer ^12 [01-01]
- **Dark theme:** Material 3 inverse-surface convention — inverseSurface as dark canvas, inversePrimary as accent; DESIGN.md has no dark token set; flagged for Phase 6 accessibility audit [01-01]
- **Font loading:** TTFs bundled as local assets via fonts.gstatic.com static download + committed to git; no google_fonts runtime network calls (privacy constraint) [01-01]
- **SyncSafeTable mixin:** Uses getter syntax `Column<T> get field => ...` (not `late final`) to satisfy very_good_analysis `specify_nonobvious_property_types` rule [01-02]
- **int64() → Column<BigInt>:** Drift's `int64()` column builder returns `Column<BigInt>`, not `Column<int>` — used for hlcMillis [01-02]
- **AppDatabase.connect() named constructor:** Replaces static `openConnection()` factory per very_good_analysis `prefer_constructors_over_static_methods` rule [01-02]
- **drift_dev schema dump CLI broken vs drift 2.34.2:** Use `tool/generate_schema_v1.dart` (flutter test + NativeDatabase.memory() + sqlite_master) to regenerate schema_v1.json after any schema change [01-02]
- **CI blocklist prefix matching (not exact names):** catches all transitive firebase_* packages automatically; 14 prefixes committed for PRIV-07 [01-06]
- **check_privacy_deps.dart manual YAML parsing (no yaml package):** script runs before pub get completes; 2-space indent for list items (not 4-space) [01-06]
- **CI blocklist audit runs BEFORE flutter analyze:** blocked deps fail fast without wasting compile time [01-06]
- **DriftProfileRepository imports app_database.dart:** UserProfileTableCompanion and UserProfileRow live in the generated app_database.g.dart part file — the DAO file alone does not re-export them [01-04]
- **AsyncValue.value not valueOrNull in Riverpod 3.3.2:** valueOrNull does not exist; use state.value which returns T? (null in loading/error states) [01-04]
- **HLC Phase-1 placeholders:** hlcNodeId='local', hlcCounter=0 in DriftProfileRepository; Phase 7 replaces with full HLC clock using stable device UUID [01-04]

### Open Decisions to Resolve During Execution

- **Mode Choice visual weighting** — design intent is equal-weight cards; live build shows bias. Audit and fix in Phase 6.
- **Weight Tracking placement** — Settings-only vs. also Insights tab. To be resolved during Phase 5 planning.

### Cross-Cutting Invariants (all phases must respect)

- No third-party analytics / ad / behavioral tracking SDKs — CI blocklist enforced from Phase 1.
- Offline-first: core flows must work with zero network.
- Non-judgmental copy; no streak-shame, no false-precision CO₂ numbers, no dark-pattern account nudging.
- All CO₂ values displayed with confidence bands (High / Medium / Low), never single false-precision numbers.
- All personal data on-device by default; Local Mode never contacts backend without explicit user action.

### Backend Coordination (Tomris)

- Backend readiness is a **Phase 7 dependency, not earlier**. Phases 1–6 ship without any backend contact.
- Coordinate before Phase 7: Keycloak realm + Apple/Google IdPs; `offline_access` scope defaults; GDPR endpoints (`/me/export`, `DELETE /me/account`); sync endpoints (outbox push, delta pull with HLC).

### Blockers

- None.

### Todos (Pre-Phase 1)

- Confirm Flutter 3.27+ / Dart 3.6+ versions against `flutter pub outdated` before scaffolding.
- Verify Open Food Facts export current size and license before designing seed pack (Phase 2 concern, but useful early).
- Line up external Fachanwalt IT-Recht (€1–3k) and LCA methodology peer reviewer (€2–5k) — engagement needed before Phase 6 closes.

---

## Session Continuity

**Last session:** 2026-07-28T07:58:43.480Z
**Stopped at:** Completed 05-08-PLAN.md -- NotificationService, NotificationPrefs domain layer, rootNavigatorKey, main.dart wiring delivered
**Next action:** Execute Plan 05-08
**Suggested next command:** `/gsd:execute-phase 5`

**Phase 1 scope reminder:** Sync-safe Drift schema (HLC, tombstones, dirty flags, `consent_records`, `co2_methodology_version`) + DI/router/theme + CI dependency-audit pipeline + thinnest E2E vertical slice (manual food add → meal entry → placeholder dashboard shows CO₂). Requirements: PROF-01–05, PRIV-07, CO2-04, LEG-04.

**Do not skip Phase 1 sync-safe schema work.** The HLC / tombstone / dirty / consent columns cannot be retrofitted later without data loss. This is the single highest-priority architectural constraint in the project.

---

*State updated: 2026-07-17 after Plan 01-07 execution — Phase 1 COMPLETE*

## Decisions

- [Phase 01-05]: Riverpod 3.x @riverpod class ProfileNotifier generates profileProvider (not profileNotifierProvider)
- [Phase 01-05]: DropdownButtonFormField.initialValue replaces deprecated .value (Flutter 3.33+)
- [Phase 01-05]: withValues(alpha:) over withOpacity() for Color (deprecated)
- [Phase 01-05]: unawaited() for fire-and-forget Riverpod notifier calls in UI callbacks
- [Phase 01-07]: flutter test required for Drift DAO tests — app_database.dart imports drift_flutter which imports dart:ui; pure dart test cannot run Flutter-dependent test files
- [Phase 01-07]: Drift table names include _table suffix (user_profile_table, consent_records_table) — Drift converts class name to snake_case verbatim including "Table" suffix
- [Phase 01-07]: import 'package:drift/drift.dart' hide isNotNull — avoids matcher name collision when both drift and flutter_test are imported
- [Phase ?]: Freezed 3.x abstract class pattern
- [Phase ?]: TDEE safety clamp for pathological inputs
- [Phase 02-01]: build.yaml uses targets.$default so drift_dev FTS5 options apply globally without enumerating individual Dart files
- [Phase 02-01]: Wave 0 unit stubs use group-level skip for atomic failure detection when production class is absent
- [Phase 02-01]: Integration benchmark stubs use markTestSkipped() inside testWidgets body (not skip: arg) to exit cleanly without device
- [Phase 02-02]: VACUUM requires explicit commit before call — cannot VACUUM inside open SQLite transaction (sqlite3.OperationalError)
- [Phase 02-02]: product_name_en extracted as p.get('product_name_en') or None to coerce empty strings to NULL (Q1 resolution confirmed 2026-07-20)
- [Phase 02-02]: EU_COUNTRY_TAGS includes Switzerland (not EU) alongside all 27 EU member states for DE/AT/CH German-speaking market
- [Phase 02-03]: FoodItem uses @immutable + sentinel copyWith pattern for nullable fields (barcode, brand, macros all nullable)
- [Phase 02-03]: Exception (not FlutterError) in first_launch_extractor catch clause — FlutterError is not catchable in Dart catch-on syntax
- [Phase 02-03]: AppDatabase schemaVersion bumped to 2 for UserFoodCacheTable addition
- [Phase 02-03]: path: ^1.9.1 declared as direct dependency per very_good_analysis depend_on_referenced_packages rule
- [Phase 02-03]: ATTACH DATABASE skipped when offRefPath == null — unit test isolation pattern
- [Phase 02-04]: app_providers.dart created as separate file — food catalog providers cohesive unit, keeps providers.dart focused on core infrastructure
- [Phase 02-04]: offRefPathProvider added to providers.dart (not app_providers.dart) — AppDatabase init needs the path, lives with the database provider
- [Phase 02-04]: NetworkException defined in food_catalog_repository.dart (same file) — simpler for Phase 2, avoids premature file proliferation
- [Phase 02-04]: UserFoodCacheTableCompanion.insert takes raw BigInt/int/String for hlcMillis/hlcCounter/hlcNodeId — not Value<>-wrapped (constructor wraps them internally)
- [Phase 02-04]: on Exception catch (not bare catch) in main.dart — very_good_analysis avoid_catches_without_on_clauses rule
- [Phase 02-06]: foodSearchProvider (not foodSearchNotifierProvider) — @riverpod strips "Notifier" suffix from class name for the generated provider variable
- [Phase 02-06]: NoResultsVariant doc comment references use enum name (not [NoResultsWidget.genuine]) — enum variants are accessed via [NoResultsVariant.genuine]
- [Phase 02-06]: avoid_types_on_closure_parameters forbids explicit types in .when() callbacks; type inference works from provider type arguments once correct provider name is used
- [Phase 02-07]: ProviderContainer.listen + Completer preferred over pumpEventQueue for awaiting Riverpod AsyncNotifier build — pumpEventQueue does not flush Riverpod scheduler timers reliably in non-widget tests
- [Phase 02-07]: TestDefaultBinaryMessengerBinding.setMockMethodCallHandler used to mock connectivity_plus channel (dev.fluttercommunity.plus/connectivity) so Connectivity().checkConnectivity() works in unit tests without MissingPluginException
- [Phase 02-07]: bare catch (e) in buildTestRepo() catches StateError from ensureOffReferenceDb without triggering avoid_catching_errors lint (which targets explicit on Error type names)
- [Phase 03-01]: Phase 3 Wave 0 unit stubs follow group-level skip pattern — group skip: arg on group(), not individual tests (same as Phase 2 Wave 0 stubs)
- [Phase 03-01]: Integration stub co2_coverage_benchmark_test.dart uses markTestSkipped() inside testWidgets body — consistent with Phase 2 food_search_benchmark_test.dart Wave 0 stub pattern
- [Phase 03-03]: BarcodeScanScreen uses _showItemSheet helper with showModalBottomSheet directly (not showFoodDetailSheet void wrapper) to track sheet dismissal for camera resume
- [Phase 03-03]: MobileScanner 7.4.0 errorBuilder has 2-arg signature Widget Function(BuildContext, MobileScannerException) — no child parameter
- [Phase 03-03]: MobileScannerController.dispose() returns Future<void> — wrapped with unawaited() in State.dispose() per discarded_futures lint
- [Phase 03-03]: BarcodeScanState uses plain Dart sealed class (not Freezed) — variants are simple records with no copyWith/toJson needs
- [Phase 03-04]: formatCo2Display lives in dedicated co2_formatter.dart (not inline in food_detail_sheet.dart) — public function importable from tests without widget tree
- [Phase 03-04]: CO2 row hidden entirely (no '—' placeholder) when co2e100g is null — per CONTEXT.md design decision, no false-precision
- [Phase 03-04]: ConfidenceChip.showExplanation static helper pattern — callers provide BuildContext, chip does not navigate itself
- [Phase 03-04]: url_launcher ^6.3.1 added; LaunchMode.externalApplication preferred over in-app WebView for methodology link (privacy-safe)
- [Phase 03-04]: NFR-06(b) benchmark self-skips when off_reference.sqlite absent via setUpAll try/on Object catch — consistent with food_search_benchmark_test.dart pattern
- [Phase 03-05]: Macro+CO₂ merge: fall through to API when local result has null calories100g; merge API macros + local CO₂/confidence on success; serve local CO₂-only on offline error (off_ref.products has macro data for ~3% of products only)
- [Phase 03-05]: NFR-06(b) result: 94.6% CO₂ coverage on Galaxy Tab S7 FE (Android 14) — exceeds 90% threshold; Phase 3 P0 barcode criterion satisfied
- [Phase 04-01]: Reused Phase 2/3 Wave 0 stub conventions verbatim (group-level skip for unit/widget, markTestSkipped() body for integration) for Phase 4 test stubs
- [Phase 04-02]: `app_database.dart` must directly import `meal_slot.dart`/`portion_unit.dart`/`serving_size.dart` even though those types are only used inside table files — `app_database.g.dart` is `part of 'app_database.dart'` and part files share the enclosing library's import scope (they cannot declare their own imports); Dart CFE requires the types resolvable from the main library file's own imports
- [Phase 04-02]: Minimal stand-in `MealSlot`/`PortionUnit`/`ServingSize` domain files created (enum values only for the first two; functionally complete for `ServingSize` since its `decodeList`/`encodeList` are directly invoked by `UserFoodTable`'s type converter) — Plan 04-03 owns the authoritative versions and should extend/review rather than assume unimplemented
- [Phase 04-03]: `detectMealSlotForTime` boundaries: <11:00 breakfast, 11:00–15:00 lunch, 15:00–18:00 snack, >=18:00 dinner — single shared implementation in `meal_slot.dart` for Plan 04-09/04-10 to consume
- [Phase 04-03]: `IMealEntryRepository.toggleFavorite` contract: returns the `Favorite` row that now exists after toggling; callers must call `isFavorite` separately to disambiguate insert-vs-delete outcomes
- [Phase 04-03]: `ServingSize` required no code changes vs. Plan 04-02's stand-in — already matched the round-trip + malformed-input spec; only the stand-in doc-comment note was removed
- [Phase 04, pre-04-04 gap fix]: Added `co2MethodologyVersionSnapshot` (`MealEntryTable`/`MealEntry`) and `co2MethodologyVersion` (`UserFoodTable`/`UserFood`) — Plan 04-02 had missed the locked CO2-04 decision (`01-CONTEXT.md`: "Column added to `user_profile` and to every CO₂-bearing table as it's created in later phases"). Both nullable, mirroring `confidenceBand(Snapshot)`'s nullability rule — null when CO₂ is absent or `co2Source == 'manual'`. Plan 04-04's DAO (and 04-05/04-07/04-09 onward) must populate/carry this column through insert/merge alongside `confidenceBand(Snapshot)`.
- [Phase 04-04]: `UserFoodDao.insert`'s required-field guard checks `.present` on `name`/`calories` Companion fields, not `.value == null` — `Value<T>.value` throws a `TypeError` (`null as double`) when the field is absent for a non-nullable `T`, so `.present` is the only safe way to detect "never provided"
- [Phase 04-04]: `UserFoodDao`'s update method is named `updateFood`, not `update` — `DatabaseAccessor` already declares a generic `update<Tbl,R>(TableInfo)` builder method; a same-named method with an incompatible signature is an `invalid_override` compile error, not a harmless shadow
- [Phase 04-04]: Raw `customSelect` rows are converted back to typed data classes via `TableInfo.map(QueryRow.data)` (e.g. `mealEntryTable.map(rows.first.data)`) — avoids a second typed-select round trip after a raw merge-check query
- [Phase 04-04]: `getRecent`'s SQL uses the SQLite "bare column in aggregate query" idiom (`SELECT *, MAX(logged_at) ... GROUP BY food_ref, food_ref_source`) to pick the full row for the max `logged_at` per group — non-standard SQL but well-defined SQLite behavior, avoids a window-function subquery
- [Phase 04-04]: `UserFoodDao.revert` is a real hard `DELETE`, not the `SyncSafeTable` soft-delete convention — CONTEXT.md requires the original catalog/cache food to reappear in search immediately on revert, which a `deletedAt` tombstone can't satisfy; flagged as a Phase 7 sync follow-up (hard deletes need their own propagation path since there's no tombstone row to sync)
- [Phase 04-05]: `MealEntry.fromRow`/`Favorite.fromRow`/`UserFood.fromRow` live as factory constructors directly on the domain entities (not a separate mapper class) — the exclusive, committed home for the Drift-row-to-entity mapping direction, since Plan 04-03 never imports `package:drift`
- [Phase 04-05]: `co2MethodologyVersionSnapshot`/`co2MethodologyVersion` are pure pass-through fields at the repository layer — this plan never computes/derives a methodology version string, it only carries whatever the caller already populated through to the Drift row and back, mirroring `confidenceBand(Snapshot)`'s existing handling; the actual CO2-estimate-driven population happens in later plans (04-07+)
- [Phase 04-05]: `toggleFavorite` returns the row it attempted to persist rather than re-querying after the toggle — `MealEntryDao.toggleFavorite` returns `void` and already does its own insert-vs-delete presence check; callers must call `isFavorite` separately per `IMealEntryRepository`'s documented contract
- [Phase 04-05]: Repository tests mock the concrete DAO classes directly via mocktail (`class _MockX extends Mock implements XDao {}`) rather than a hand-rolled minimal-interface wrapper, since assertions need to inspect the exact `MealEntryRow`/`UserFoodTableCompanion` passed through byte-for-byte
- [Phase 04-05]: `import 'package:drift/drift.dart' hide isNull;` needed in test files that import both drift and flutter_test and use the `isNull` matcher — drift's top-level `isNull` collides with `matcher`'s `isNull` (sibling of the existing Phase 01-07 `hide isNotNull` precedent)
- [Phase 04-06]: `FoodItem.resolvedFoodRef` is the single authoritative merge-key rule (`barcode ?? sourceRowId`, throws `StateError` when both null) — every future plan reading a `MealEntry.foodRef`/`Favorite.foodRef` from a `FoodItem` must call this getter, never read `barcode`/`productName` directly
- [Phase 04-06]: `lookupByBarcodeWithCo2`'s Step 0 (personal override check) runs before the `offRefPath` ATTACH null-check — overrides live in `co2diet.sqlite`, independent of off_ref ATTACH state, so this ordering makes override precedence testable/functional without a real off_ref file
- [Phase 04-06]: Drift's camelCase→snake_case column naming does NOT insert an underscore before a digit-led suffix like "100g" — `UserFoodCacheTable.calories100g` generates column `calories100g` (no underscore), not `calories_100g`; only genuinely snake_case-authored external tables (e.g. off_ref.products from `tools/ingest_off.py`) use the underscored form — a pre-existing `food_catalog_dao.dart` query bug from this mismatch was fixed in this plan (see 04-06-SUMMARY.md Deviations)
- [Phase 04-07]: UserFoodNotifier.build() is parameterless (no @riverpod family {String? filter}) to keep generated provider name (userFoodProvider) predictable; My Foods screen (04-08) filters client-side
- [Phase 04-07]: FavoriteNotifier.logFromFavorite composes with MealEntryNotifier via ref.read(mealEntryProvider.notifier).logFood(draft) rather than re-implementing merge/persist logic, keeping the one-tap-log write path singular
- [Phase 04-08]: `CustomFoodFormScreen` takes barcode/name/overrideOf/overrideOfSource/userFoodId as constructor params (router builder passes `state.uri.queryParameters[...]` through) rather than reading `GoRouterState.of(context)` directly — keeps the screen widget-testable with a plain `MaterialApp` host, no `GoRouter` needed in tests
- [Phase 04-08]: Revert-to-original visibility is driven by `_overrideOfRef != null` (set by either a resolved existing override row or a fresh `overrideOf` route param); the tap handler only calls `revertOverride` when a concrete id is already known, otherwise it just pops — covers "editing a saved override" and "about to create a first override, changed my mind" without a crash
- [Phase 04-08]: `co2MethodologyVersion` left null on category-estimate saves — no methodology-version constant exists anywhere in the codebase yet; mirrors the field's current all-null state everywhere else rather than inventing an unbacked value
- [Phase 04-08]: Widget tests reusing the same tester across multiple `pumpWidget` calls must keep an identical `ProviderScope` override-list shape (Riverpod forbids adding/removing overrides on update) and must use a distinct `Key` per call if `initState`-driven async setup needs to re-run (Flutter reconciles same-position widgets via `didUpdateWidget`, not a fresh mount)
- [Phase 04-09]: `showFoodDetailSheet` returns the real `Future<void>` from `showModalBottomSheet` (no more `unawaited()` swallow); `_BarcodeScanDetailSheet`/its private `_MacroRow` deleted — both search and barcode-scan entry points render the single shared `_FoodDetailContent` again, restoring Phase 3's original no-divergence intent
- [Phase 04-09]: `PortionSlotForm`'s "Edit this food" resolves any existing override via `UserFoodNotifier.findOverrideForFoodRef` first, redirecting to `/custom-food-stub?userFoodId=` when one exists rather than always creating a new one via `?overrideOf=&overrideOfSource=` — prevents duplicate override rows on repeat edits (flagged as a follow-up in 04-08-SUMMARY.md)
- [Phase 04-09]: `ServingSize.label` (free text, no unit tag) maps to `PortionUnit` via keyword match — 'cup' -> `cup`, 'piece'/'slice' -> `piece`, anything else -> `portion` (the generic user-configured-serving catch-all)
- [Phase 04-09]: `mealEntryProvider` (autoDispose, no `keepAlive`) needs an active `ref.watch` for the duration of any mutation that calls `ref.invalidateSelf()` after an `await` — without one (true today, since Phase 4's dashboard is still a placeholder and nothing else watches it), the provider can be disposed mid-flight and crash. `PortionSlotForm` now `ref.watch(mealEntryProvider)`s in `build()`, and its Undo `SnackBarAction` reads through a captured `ProviderContainer` (`ProviderScope.containerOf(context, listen: false)`) rather than the state's own `ref`, since the sheet is already disposed by the time Undo can be tapped. Any future one-off `ref.read(...).notifier).mutatingMethod()` call site on an autoDispose notifier should apply the same pattern.
- [Phase 04-10]: MealEntryNotifier.logFromRecent added (mirrors FavoriteNotifier.logFromFavorite) for Recent's one-tap-log path; Recent row calorie/CO2 summary only computed for weight-based units (g/ml) since piece/cup/portion needs a weight-per-unit conversion not available at this call site
- [Phase 04-11]: flutter_slidable (^4.0.3) approved via blocking-human package-legitimacy checkpoint (pub.dev score 150/160, flutter-favorite badge, verified publisher romainrastel.com, MIT license, active repo) — pub.dev/Dart isn't a slopcheck-supported ecosystem, so independent-signal review + explicit human approval was required before install
- [Phase 04-11]: PlaceholderDashboardScreen extracted out of app_router.dart into its own file (lib/features/dashboard/screens/) now that it has a real body — matches every other screen's file-per-screen convention
- [Phase 04-11]: MealEntryRow's scaled calorie/CO2 display only computed for weight-based units (g/ml), mirroring Plan 04-10's RecentRow precedent for non-weight units (piece/cup/portion)
- [Phase 04-12]: Offline test overrides appDatabaseProvider (in-memory) + offApiClientProvider (throwing mock) rather than the repository providers directly, so the real MealEntryRepository/UserFoodRepository/DAOs run unmocked
- [Phase 04-12]: Post-mutation assertions re-read container.read(xProvider.future) instead of the synchronous .value, since ref.invalidateSelf() reruns build() asynchronously and .value can race a still-loading rebuild
- [Phase 04-12]: meal_logging_benchmark_test.dart's Stopwatch window starts immediately before the tap on the first search-result row, not at food-search-screen entry, per this plan's task spec
- [Phase 05-01]: Group-level skip pattern (test() and testWidgets() alike) reused verbatim from Phase 2-4 precedent for all 25 Wave 0 stubs, including testWidgets bodies wrapped inside a skipped group()
- [Phase 05-02]: lookupByBarcode's macro-merge branch reads apiResult.categoriesTags (not enriched.categoriesTags) as the cache-write tag source, since copyWith() never touches categoriesTags
- [Phase 05-02]: user_food_cache_fts CO2 join only ever reaches 'medium' confidence (no per-cached-item override table exists), mirroring off_ref.products' category-average tier
- [Phase 05-03]: saltSnapshot (not sodiumSnapshot) on MealEntryTable -- matches this app's established EU-label 'salt (g)' convention from UserFoodTable.salt; no unit conversion invented
- [Phase 05-03]: Phase 5 singleton settings tables (Co2SettingsTable/WeightSettingsTable/NotificationPrefsTable/BackupMetadataTable) all reuse UserProfileTable's upsert-on-PK convention; DAOs deliberately deferred to a later plan
- [Phase 05-04]: FoodItem.fromQueryRow never populates sugar100g/fiber100g/salt100g -- off_ref/user_food_cache tables have no such columns; documented permanent null, not an oversight
- [Phase 05-04]: No referenceAmountG rescale added to FoodCatalogDao._foodItemFromUserFoodRow for the new nutrient fields -- mirrors this method's existing non-rescaled treatment of every other macro field (pre-existing Phase 4 simplification, out of scope)
- [Phase 05-05]: WeightDao.deleteEntry is a hard DELETE, not the SyncSafeTable soft-delete convention -- mirrors UserFoodDao.revert's precedent (Phase 04-04); a mis-logged weigh-in has no sync-relevant tombstone need
- [Phase 05-05]: Test files importing both drift and flutter_test must hide BOTH isNull and isNotNull from drift.dart when the test uses both matchers -- extends the Phase 04-05 'hide isNull' precedent
- [Phase 05-05]: DateTime round-trip assertions use isAtSameMomentAs, not equals -- Drift's SQLite dateTime() column deserializes to a local-time DateTime that is the same instant as a UTC input but not flagged UTC, so equals spuriously fails off-UTC machines
- [Phase 05-06]: Co2Settings entity has no id field -- Co2SettingsRepository owns id lifecycle internally (reuse existing single row's id, or generate UUID v7 on first save)
- [Phase 05-07]: WeightSettings has no derived pace/on-track/projection field -- CONTEXT.md explicitly rejects deriving one; saveGoal/saveReminderSettings on WeightRepository each read-modify-write the single settings row so neither ever clobbers the other's fields
- [Phase ?]: [Phase 05-08]: notificationServiceProvider constructs its own FlutterLocalNotificationsPlugin() instance separate from main.dart's pre-runApp initialize() instance -- both share the same platform method channel, so only one initialize() call is needed globally
- [Phase ?]: [Phase 05-08]: scheduleWeighInReminder's biweekly/monthly frequencies have no native recurrence primitive in flutter_local_notifications -- schedules only the next single occurrence each call, idempotent via the fixed notification id 200; Plan 05-18's AppLifecycleState.resumed observer keeps it fresh

## Performance Metrics

| Phase | Plan | Duration | Notes |
|-------|------|----------|-------|
| Phase 02 P01 | 6 | 3 tasks | 5 files |
| Phase 02-food-catalog-ingest-search P02 | 3 | 2 tasks | 2 files |
| Phase 02-food-catalog-ingest-search P03 | 11m 54s | 2 tasks | 12 files |
| Phase 02-food-catalog-ingest-search P04 | ~15m | 2 tasks | 8 files |
| Phase 02-food-catalog-ingest-search P06 | ~20m | 2 tasks | 8 files |
| Phase 02-food-catalog-ingest-search P07 | ~25m | 2 tasks | 3 files |
| Phase 03-barcode-scanning-co-factor-table P01 | 2m 13s | 2 tasks | 6 files |
| Phase 03 P02 | 90min | 2 tasks | 6 files |
| Phase 03-barcode-scanning-co-factor-table P03 | ~14m | 2 tasks | 15 files |
| Phase 03-barcode-scanning-co-factor-table P04 | ~7m | 2 tasks | 11 files |
| Phase 03-barcode-scanning-co-factor-table P05 | ~30min | 2 tasks | 9 files |
| Phase 04-meal-logging-core-10s-target P01 | 9min | 2 tasks | 16 files |
| Phase 04-meal-logging-core-10s-target P02 | ~30min | 2 tasks | 10 files |
| Phase 04-meal-logging-core-10s-target P03 | ~15min | 2 tasks | 11 files |
| Phase 04-meal-logging-core-10s-target P04 | ~20min | 2 tasks | 6 files |
| Phase 04-meal-logging-core-10s-target P05 | 24min | 2 tasks | 9 files |
| Phase 04-meal-logging-core-10s-target P06 | ~20min | 2 tasks | 8 files |
| Phase 04 P07 | ~35min | 2 tasks | 10 files |
| Phase 04-meal-logging-core-10s-target P08 | ~25min | 2 tasks | 7 files |
| Phase 04-meal-logging-core-10s-target P09 | ~21min | 2 tasks | 4 files |
| Phase 04-meal-logging-core-10s-target P10 | ~20min | 2 tasks | 6 files |
| Phase 04-meal-logging-core-10s-target P12 | ~10min | 2 tasks | 2 files |
| Phase 05 P01 | ~12min | 5 tasks | 25 files |
| Phase 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable P02 | ~10min | 2 tasks | 3 files |
| Phase 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable P03 | 10min | 2 tasks | 9 files |
| Phase 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable P04 | ~5min | 2 tasks | 5 files |
| Phase 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable P05 | ~10min | 3 tasks | 9 files |
| Phase 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable P06 | ~10min | 2 tasks | 9 files |
| Phase 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable P07 | ~10min | 2 tasks | 9 files |
| Phase 05 P08 | ~15min | 2 tasks | 9 files |
