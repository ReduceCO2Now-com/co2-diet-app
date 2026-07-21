---
gsd_state_version: 1.0
milestone: v1.1
milestone_name: milestone
status: completed
last_updated: "2026-07-20T20:14:42.117Z"
progress:
  total_phases: 9
  completed_phases: 1
  total_plans: 7
  completed_plans: 7
  percent: 11
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
- **Phase:** 02-food-catalog-ingest-search — COMPLETE (7 of 7 plans done)
- **Plan:** 02-06 complete — FoodSearchScreen, all state widgets, /food-search route, Settings entry point
- **Status:** Phase 2 complete; ready for Phase 3
- **Progress:** [░░░░░░░░░░] 0%
- **v1 requirements:** 15 / 75 delivered (CO2-04, PROF-01 through PROF-05, PRIV-07, LOG-01, LOG-02, NFR-06)

```
[░░░░░░░░░░░░░░░░░░░░] 1%
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

**Last session:** 2026-07-21
**Stopped at:** Phase 2 checkpoint approved — SM T733 physical device, all benchmarks pass, UI smoke test pass, reinstall/decompression pass. Phase 2 officially closed.
**Next action:** Plan Phase 3 (Barcode Scanning & CO₂ Factor Table)
**Suggested next command:** `/gsd:plan-phase 3`

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

## Performance Metrics

| Phase | Plan | Duration | Notes |
|-------|------|----------|-------|
| Phase 02 P01 | 6 | 3 tasks | 5 files |
| Phase 02-food-catalog-ingest-search P02 | 3 | 2 tasks | 2 files |
| Phase 02-food-catalog-ingest-search P03 | 11m 54s | 2 tasks | 12 files |
| Phase 02-food-catalog-ingest-search P04 | ~15m | 2 tasks | 8 files |
| Phase 02-food-catalog-ingest-search P06 | ~20m | 2 tasks | 8 files |
| Phase 02-food-catalog-ingest-search P07 | ~25m | 2 tasks | 3 files |
