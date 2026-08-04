---
gsd_state_version: 1.0
milestone: v1.1
milestone_name: milestone
status: executing
last_updated: "2026-08-04T07:39:20.693Z"
progress:
  total_phases: 9
  completed_phases: 5
  total_plans: 51
  completed_plans: 51
---

# STATE: CO₂ Diet

**Last updated:** 2026-08-03
**Session:** Phase 5 fully verified on real hardware, both platforms — see `.planning/phases/05-.../05-UAT.md`. Ready to start Phase 6.

---

## Project Reference

See: `.planning/PROJECT.md` (updated 2026-07-16)

- **Core value:** A user must be able to log a meal in under 10 seconds — everything else is secondary to that speed and privacy guarantee.
- **What this is:** Privacy-first, offline-first Flutter mobile app (iOS + Android) tracking nutrition + estimated CO₂ footprint of food choices. Free forever, zero ads, zero behavioral data, on-device by default, optional self-hosted account sync.
- **Sole Flutter dev:** Ali. Backend (Spring Boot + PostgreSQL + Keycloak) is a parallel workstream owned by Tomris.
- **Package:** `com.reduceco2now.co2diet`
- **Launch market:** EU / Germany (English-only for v1)
- **Current focus:** Phase 5 complete and verified on real hardware (both platforms) → Phase 6 next

---

## Current Position

- **Milestone:** v1 launch
- **Phase:** 06-onboarding-legal-consent-legal-hub-ed-safety-nets-accessibility-pre-submission — **IN PROGRESS** (5/10 plans executed). CONTEXT/RESEARCH/VALIDATION complete; 10 plans across 6 waves drafted and committed (`7b87c2e`): 06-01 (wave 0 test stubs — COMPLETE) → 06-02/06-03 (wave 1: legal docs + loader + ED safety net checker — COMPLETE) → 06-04/05/06 (wave 2: consent domain + legal doc screen — 06-04/06-05 COMPLETE, privacy manifests still pending) → 06-07/06-08 (wave 3: Legal Consent screen, Legal Hub + Consent History) → 06-09 (wave 4: router/redirect/Settings integration) → 06-10 (wave 5: manual a11y/tone checkpoints). All 23 phase requirement IDs traced to a plan.
- **Plan:** 06-05 (Wave 2: onboarding gate + splash/welcome/carousel screens) — COMPLETE. Next up: 06-06 (privacy manifests, rest of Wave 2).
- **Status:** Executing Phase 6 — Wave 2 in progress (06-04/06-05 done, 06-06 next)
- **Progress:** [█████░░░░░] 50% (5/10 plans, Phase 6)
- **v1 requirements:** Phase 5's requirement set (CO2-05/06, DASH-01 through DASH-08, WT-01 through WT-05, NOTIF-01/02/03, INS-01 through INS-04, PRIV-01 through PRIV-04/08/09, and the NUTR-01/CO2-03 carry-overs from earlier phases) is now fully delivered and reachable end-to-end — confirmed via the real-device UAT pass, not just automated tests. Full requirement-by-requirement detail lives in `ROADMAP.md`'s Phase 5 section and the phase's `*-SUMMARY.md` files.

```
[█████░░░░] 55% (5/9 phases)
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

- **Weight Tracking placement** — Settings-only vs. also Insights tab. To be resolved during Phase 5 planning.

### Resolved Decisions (carried forward for record)

- **Mode Choice visual weighting** — RESOLVED in `06-CONTEXT.md`: no Mode Choice screen exists in Phase 6 at all (Account Mode doesn't exist yet, nothing to compare). Skipped entirely, not a placeholder. Phase 7 builds the real two-card screen and runs the equal-weight audit (ONBD-03) then, once there's something to weigh equally.

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

### Pre-Launch Blockers (not Phase 6 completion blockers)

- **External legal review:** Fachanwalt IT-Recht (€1–3k) sign-off on Terms/Privacy/Health Disclaimer, and LCA methodology peer reviewer (€2–5k) — per `06-CONTEXT.md`, Phase 6 ships complete drafted text flagged "pending legal review" via code comment/tracked TODO only (no user-visible banner). The live review is a pre-*launch* gate, explicitly out of Phase 6's scope — it does not block Phase 6 from closing.
- **Impressum real identity data:** entity name/address/responsible-person are placeholder text ("Legal Entity Name", "Address TBD") pending a decision from Dr. Thomas (Product Owner) or whoever formally owns ReduceCO2Now. TMG §5 compliance blocked on this regardless of Phase 6 completion — org-leadership sign-off required before launch.

---

## Session Continuity

**Last session:** 2026-08-04T07:36:55Z
**Stopped at:** Plan 06-05 (Wave 2: onboarding gate + splash/welcome/carousel screens) executed and committed
**Next action:** Execute Plan 06-06 (privacy manifests, last plan in Wave 2)
**Suggested next command:** `/gsd:execute-phase 6`

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
- [Phase 05-09]: archive downgraded 4.0.9 -> 3.6.1 project-wide -- excel 4.0.6 hard-depends on archive ^3.6.1 and calls APIs (ZipDecoder.decodeBuffer, InputStream) removed in archive 4.0.0; every archive API this codebase uses (GZipDecoder.decodeBytes, ZipFileEncoder, ZipDecoder.decodeBytes, ArchiveFile.string) verified unchanged between the two versions
- [Phase 05-09]: csv 8.0.0's actual public API is CsvEncoder, not ListToCsvConverter (removed in a prior major version) -- BackupExportService uses const CsvEncoder().convert(rows)
- [Phase 05-09]: Every Drift row round-trips through a custom _BackupValueSerializer (BigInt->String, DateTime->ISO8601) for JSON export/restore -- drift's default ValueSerializer passes BigInt through unconverted, which jsonEncode cannot serialize, and every sync-safe row's hlcMillis column is a BigInt
- [Phase 05-09]: MealEntryDao.getAllEntries/restoreEntries/restoreFavorites, UserFoodDao.restoreCustomFoods, WeightDao.restoreEntries added -- no existing DAO exposed an all-rows read or a verbatim bulk restore-write; export/restore cannot function without them
- [Phase 05-10]: DailyTotalsCalculator filters to entry.unit.isWeightBased before scaling -- piece/cup/portion entries excluded from every numeric total, matching Phase 04-10's MealEntryRow/RecentRow precedent
- [Phase 05-10]: PersonalCo2MultiplierCalculator's 4 active factors use additive percentage deltas clamped to [0.7, 1.3]; foodStorage/householdSize/location intentionally produce no numeric effect in v1, documented via a permanent code comment per 05-CONTEXT.md's locked Planning Addendum decision (not a TODO)
- [Phase 05-11]: Co2ProfilePromptCard's exact copy uses the subscript CO2 character ('Complete your CO2 profile for better estimates'), matching CONTEXT.md's literal source string, not the plain-2 rendering that appeared in PLAN.md prose
- [Phase 05-11]: TrendSparkline built as a StatelessWidget controlled component (selectedMetric/onMetricChanged owned by parent screen), not local StatefulWidget state, since the parent screen needs the selected metric for DASH-08's tap-to-navigate-to-Data-Analysis behavior
- [Phase 05-12]: DataQualityIndicator built as a distinct sibling widget to ConfidenceChip (not shared) -- settings-completeness vs per-food CO2 confidence are different concepts per 05-CONTEXT.md
- [Phase 05-12]: Co2SettingsScreen not wired into app_router.dart or Settings yet -- CO2-03 intentionally left Pending in REQUIREMENTS.md until Plan 05-18 makes the screen reachable
- [Phase 05-12]: Widget tests set a tall test viewport (1080x4000) -- default 800x600 test surface plus Flutter's sliver-list cache-extent hides ListView items past the viewport from find.text
- [Phase 05-13]: WeighInReminderSection's Custom-only weekday+time picker -- non-Custom frequencies use a fixed default reminder time ('09:00') with no time-picker UI; only Custom exposes user-configurable day+time
- [Phase 05-13]: WeightChart converts every plotted entry to kg (lb * 0.453592) before plotting, since targetWeightKg is always kg and entries may be logged in either unit
- [Phase 05-13]: WT-01 through WT-05 and NOTIF-02 left Pending in REQUIREMENTS.md -- WeightScreen is standalone/unreachable until Plan 05-18 wires it into app_router.dart and Settings
- [Phase 05-14]: NotificationPrefsNotifier.setSlotEnabled merges only the touched slot's fields into the full 4-slot NotificationPrefs row (via a generic switch-based _withSlot helper) before calling savePrefs, since the repository always writes the complete row -- a partial call would silently reset the other three slots
- [Phase 05-14]: MealReminderSettingsSection stays a stateless ConsumerWidget; each of the 4 meal-slot rows is a private _MealSlotRow ConsumerStatefulWidget holding its own local pending-time + permission-denied-message state, mirroring WeighInReminderSection's (05-13) local-state pattern scaled to 4 independent rows
- [Phase 05-14]: AppTextTheme has no bodyMd token -- bodyLg is the correct token for row-label body text (bodySm is reserved for secondary/caption text)
- [Phase 05-14]: NOTIF-01 left Pending in REQUIREMENTS.md -- MealReminderSettingsSection is standalone/unreachable until Plan 05-18 embeds it into General Settings
- [Phase 05-15]: AnalysisMetric is a screen-local enum, never importing/extending Dashboard's DashboardMetric (same-wave Plan 05-11, no depends_on edge)
- [Phase 05-15]: IMealEntryRepository.getEntriesInRange(from, to) added -- no existing repository/DAO method could pool entries across multiple days; getEntriesForToday/getRecent are single-day/recency-scoped only
- [Phase 05-15]: Weight metric mode reuses the existing WeightChart widget verbatim rather than teaching TrendSection to plot weight -- a genuinely distinct chart satisfies the must-have more directly than branching one widget's internals
- [Phase 05-15]: GoalComparisonBar's CO2 target always renders 'no target set' -- CalcTargets.co2GTarget is never populated by TargetCalculator anywhere in the codebase, confirmed via grep, not a bug introduced here
- [Phase 05-16]: BackupNotifier.pendingRestoreFile getter bridges pickAndPreviewRestoreFile()'s RestorePreview?-only return and applyRestore(File zip)'s explicit-file signature for the choose/confirm restore UI flow
- [Phase 05-16]: BackupExportService.clearAllLocalData() deliberately excludes UserFoodCacheTable (shared OFF cache, not personal data) and ConsentRecordsTable (legal consent audit trail) from the Danger Zone wipe
- [Phase 05-16]: SharePlatform.instance mocked once process-wide via MockPlatformInterfaceMixin + reset() between tests -- SharePlus.instance is static final and permanently binds to whichever SharePlatform.instance was set at its first access
- [Phase 05-17]: MealEntry has no persisted category-tag snapshot field -- ImprovementOpportunityFinder infers a co2_factors category via documented keyword substring matching on productNameSnapshot rather than a schema change
- [Phase 05-17]: Substitution clusters tiered en:beef/en:lamb-and-goat/en:pork -> [en:poultry, en:fishes, en:legumes]; en:poultry -> [en:fishes, en:legumes]; en:fishes -> [en:legumes]; legumes has no key (already lowest tier)
- [Phase 05-17]: InsightsTimelineRuleEngine.evaluate takes an optional proteinTargetG param -- protein rule never fires without a set target, avoiding a fabricated threshold
- [Phase 05-17]: CO2-06/INS-03 left Pending in REQUIREMENTS.md -- DataAnalysisScreen still unreachable from app_router.dart/Dashboard until Plan 05-18
- [Phase 05-18]: QuickInsightLine's 'most notable metric' selection uses largest single-meal-slot-share fraction across CO2/calories/protein (not per-metric target deviation) -- CO2 has no numeric target anywhere in this codebase (co2GTarget never populated), so this uniformly covers all three metrics per CONTEXT.md and matches the literal 'Lunch contributed most CO2 today' example
- [Phase 05-18]: Co2DietApp's WidgetsBindingObserver reads WeightState.settings via .value (not .valueOrNull, which doesn't exist in this project's pinned Riverpod 3.3.2 per the existing [Phase 01-04] decision) -- re-arms the weigh-in reminder on every AppLifecycleState.resumed in addition to Plan 05-13's screen-open re-arm
- [Phase 05-18]: PlaceholderDashboardScreen and Co2DietApp both converted from ConsumerWidget to ConsumerStatefulWidget to hold session-only local UI state (sparkline metric selection, CO2-prompt dismissal, lifecycle observer) rather than introducing new Riverpod providers -- mirrors WeighInReminderSection/MealReminderSettingsSection's established local-widget-state convention
- [Phase 05-18]: Every slot's quick-log button (Breakfast/Lunch/Dinner/Snack) always renders regardless of that slot's entry count; only the slot section header above the meal list is conditionally hidden when empty -- existing Phase 4 tests asserting slot-name absence for empty slots needed updating to findsOneWidget (button-only) vs findsNWidgets(2) (button+header)
- [Phase 05-19]: formatCo2Approx extracted from formatCo2Display so callers composing their own unit text reuse the ~-prefixed rounding convention without inheriting the per-kg-of-product 'kg CO2e/kg' suffix
- [Phase 05-19]: offline_phase5_test.dart proves AUTH-07/PRIV-08/INS-04 by direct-constructing every new Phase 5 service/repository with zero offApiClientProvider/connectivity_plus mocks -- an accidental network call would surface as MissingPluginException rather than being silently swallowed
- [Phase 06-01]: Reused Phase 2-5 Wave 0 group-level skip convention verbatim for all 6 Phase 6 stub files, including testWidgets bodies wrapped inside a skipped group() -- no production imports until the implementing plan (06-02/03/04/07/08/09) turns each stub green
- [Phase ?]: [Phase 06-02]: Health Disclaimer uses diagnose/treat only inside the required Google Play Jan-2026 negation sentence -- zero claims-making instances elsewhere
- [Phase ?]: [Phase 06-02]: legalDocumentLoaderProvider is not keepAlive -- LegalDocumentLoader is stateless/const, cheap to reconstruct, holds no DB/stream resources
- [Phase 06-03]: showEdSafetyNetDialog always returns non-null bool -- declining/dismissing both resolve to false
- [Phase 06-03]: WeightScreen target-weight field needs a submit-in-flight guard -- Flutter's EditableText fires both onEditingComplete and onFieldSubmitted for one Done action, which would double-invoke the async ED safety-net check
- [Phase 06-04]: ConsentEvent named distinct from Drift's generated ConsentRecord class -- mirrors MealEntry.fromRow precedent, imports row type from app_database.dart
- [Phase 06-04]: policyVersion for every consent event is always terms.md's frontmatter version -- all 4 legal docs are drafted/versioned together as one dated bundle
- [Phase 06-05]: Generated provider variable is onboardingGateProvider, not onboardingGateNotifierProvider -- @riverpod strips the 'Notifier' suffix from the class name (consistent with the existing [Phase 02-06] convention)
- [Phase 06-05]: OnboardingCarouselScreen's 'Go to Dashboard' button is conditionally built (absent from the widget tree on slides 1-2), not hidden via Visibility/Offstage -- keeps widget-tree text searches accurate to "appears on slide 3 only"

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
| Phase 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable P09 | ~35min | 2 tasks | 10 files |
| Phase 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable P10 | 8min | 2 tasks | 4 files |
| Phase 05 P11 | ~10min | 2 tasks | 8 files |
| Phase 05 P12 | ~12min | 2 tasks | 3 files |
| Phase 05 P13 | ~15min | 2 tasks | 4 files |
| Phase 05 P14 | 16min | 2 tasks | 4 files |
| Phase 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable P15 | ~25min | 2 tasks | 10 files |
| Phase 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable P16 | ~22min | 2 tasks | 7 files |
| Phase 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable P17 | ~20min | 2 tasks | 9 files |
| Phase 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable P18 | ~50min | 4 tasks | 11 files |
| Phase 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable P19 | ~20min | 2 tasks | 6 files |
| Phase 06-onboarding-legal-consent-legal-hub-ed-safety-nets-accessibility-pre-submission P01 | ~5min | 2 tasks | 6 files |
| Phase 06-onboarding-legal-consent-legal-hub-ed-safety-nets-accessibility-pre-submission P02 | ~15min | 2 tasks | 11 files |
| Phase 06-onboarding-legal-consent-legal-hub-ed-safety-nets-accessibility-pre-submission P03 | ~15min | 3 tasks | 5 files |
| Phase 06-onboarding-legal-consent-legal-hub-ed-safety-nets-accessibility-pre-submission P04 | ~5min | 2 tasks | 8 files |
| Phase 06-onboarding-legal-consent-legal-hub-ed-safety-nets-accessibility-pre-submission P05 | ~15min | 3 tasks | 6 files |
