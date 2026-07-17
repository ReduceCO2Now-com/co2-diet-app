---
gsd_state_version: 1.0
milestone: v1.1
milestone_name: milestone
status: completed
last_updated: "2026-07-17T08:50:07.548Z"
progress:
  total_phases: 1
  completed_phases: 0
  total_plans: 0
  completed_plans: 0
  percent: 0
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
- **Phase:** 01-foundations-sync-safe-schema (in progress)
- **Plan:** 01-02 complete (Sync-safe Drift schema + HLC + DAOs)
- **Status:** Phase 1 execution in progress; 2 of 7 plans complete
- **Progress:** [░░░░░░░░░░] 0%
- **v1 requirements:** 5 / 75 delivered (CO2-04, PROF-01 through PROF-05)

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

---

## Performance Metrics

- Requirements defined: 75 v1 (+ 15 deferred to v2)
- Requirements mapped to phases: 75 / 75 (100% coverage)
- Phases planned: 9 (target: fine granularity 8–12) ✓
- Plans executed: 2 (01-01 + 01-02 complete)
- Verifications passed: 2
- Total sessions: 3

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

**Last session:** 2026-07-17T09:15:00Z
**Stopped at:** Completed 01-02-PLAN.md (Sync-safe Drift schema + HLC + DAOs)
**Next action:** Execute Plan 01-03 (Mifflin-St Jéor domain layer + target calculator).
**Suggested next command:** `/gsd-execute-phase 1 --plan 03`

**Phase 1 scope reminder:** Sync-safe Drift schema (HLC, tombstones, dirty flags, `consent_records`, `co2_methodology_version`) + DI/router/theme + CI dependency-audit pipeline + thinnest E2E vertical slice (manual food add → meal entry → placeholder dashboard shows CO₂). Requirements: PROF-01–05, PRIV-07, CO2-04, LEG-04.

**Do not skip Phase 1 sync-safe schema work.** The HLC / tombstone / dirty / consent columns cannot be retrofitted later without data loss. This is the single highest-priority architectural constraint in the project.

---

*State updated: 2026-07-17 after Plan 01-02 execution*
