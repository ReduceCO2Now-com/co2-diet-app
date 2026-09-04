# Milestone Summary: v1.1 — CO₂ Diet

**Generated:** 2026-09-04
**Status:** Mid-milestone (no archived `.planning/milestones/` snapshot yet — sourced live from `.planning/ROADMAP.md`, `.planning/REQUIREMENTS.md`, `.planning/STATE.md`, `.planning/PROJECT.md`)

---

## 1. Project Overview

CO₂ Diet is a privacy-first, offline-first Flutter mobile app (iOS + Android) that tracks both nutrition (calories, protein, macros) and the estimated CO₂ footprint of a user's food choices in one place. It is free forever, contains no ads, collects no behavioral data, and stores all personal data locally on-device by default. An optional account (Keycloak OIDC login) adds authentication as a pure, zero-data-movement enhancement — no sync exists yet, and encrypted account backup (Phase 8) is parked pending a backend architecture decision owned by a separate developer (Tomris, Spring Boot + PostgreSQL + Keycloak, a parallel workstream). The app is targeted at the EU/Germany market, English-only for v1.

**Core value:** A user must be able to log a meal in under 10 seconds — everything else is secondary to that speed and privacy guarantee.

**Package:** `com.reduceco2now.co2diet`
**Stack:** Flutter (Dart SDK `>=3.12.2 <4.0.0`, Flutter `>=3.44.6`), Drift/SQLite (sync-safe schema with HLC + tombstones from day one), Riverpod (codegen), go_router.

As of this report, 9 of 10 roadmap phases are complete (Phase 8 parked, Phase 10 an unscoped placeholder). Phase 9 (Reference Data Delivery — Full OFF Pack) closed tonight, 2026-09-04, after an extensive real-device debugging session.

---

## 2. Architecture & Technical Decisions

- **Local database:** Drift (SQLite), chosen over Hive — Hive was rejected for being unmaintained, lacking FTS5, and having brittle migrations. Every user-data table was built sync-safe from Phase 1: UUID v7 primary keys, HLC (hybrid logical clock) columns, `dirty` flags, tombstone fields, and a `co2_methodology_version` column on every CO₂-bearing row — even though sync itself doesn't ship until (if) Phase 8 does.
- **Reference data delivery:** The app ships a bundled ~50MB OFF (Open Food Facts) seed database at install time (Phase 2, ATTACH DATABASE, read-only, decoupled from the user-data schema's own migration lifecycle), with FTS5 full-text search. Phase 9 added an optional, on-demand full OFF pack (~300–800MB) via CDN with resumable/pausable downloads, incremental delta refresh, and atomic swap-in (DETACH → replace file → re-ATTACH) — all while the app can still be actively querying the catalog.
- **Auth:** Keycloak OIDC + PKCE via `flutter_appauth` (system browser, not embedded webview) — refresh token in `flutter_secure_storage`, access token held in memory only. No Firebase, no Supabase, no Google/Apple native SDKs on the client (Apple/Google sign-in route through Keycloak as Identity Providers).
- **CO₂ estimation:** Fully on-device and deterministic — a documented product/category → CO₂e factor table (AGRIBALYSE-sourced) paired with a High/Medium confidence band (never a false-precision single number, never Low — there's no data source to back a Low tier).
- **Privacy enforcement:** A CI pipeline (`.privacy-blocklist.yaml` + `check_privacy_deps.dart`) fails the build on any Firebase/Sentry/analytics/ad-SDK transitive dependency, checked on every commit via GitHub Actions.
- **Notifications:** `flutter_local_notifications` only — zero FCM/APNs push infrastructure.
- **Barcode scanning:** `mobile_scanner` (CameraX/MLKit on Android, AVFoundation on iOS) — treated as a P0 launch requirement, verified on real hardware before Phase 3 closed.
- **Key packages:** `drift` 2.34.2, `go_router` 17.3.0, `openfoodfacts` 3.30.2, `riverpod_annotation`/`riverpod_generator` 4.x, `fl_chart` ^1.2.0, `flutter_appauth` ^12.0.2, `flutter_secure_storage` ^11.0.0, `background_downloader` ^9.5.8, `mobile_scanner` 7.4.0.
- **Phase 7/8 split (2026-08-08):** The originally-planned single "Keycloak Auth + Account Mode + Sync" phase was split after a scan of the backend's reference repo found its actual architecture avoids owning bidirectional user data (one-way catalog sync only, no realm/IdP config, no GDPR endpoints at the time). Phase 7 now ships only what has zero backend-sync dependency (login, logout, password reset, GDPR account deletion); the sync/backup engine was deferred to a renamed, narrowed Phase 8 ("Encrypted Account Backup" — a simple opaque push/pull, not a bidirectional sync engine), which the backend's own architecture doc currently leans against building at all.

---

## 3. Phases Delivered

| Phase | Goal | Status | Plans | Completed |
|---|---|---|---|---|
| 1. Foundations & Sync-Safe Schema | Sync-safe Drift schema, clean architecture skeleton, CI privacy pipeline, thinnest E2E vertical slice | Complete | 7/7 | 2026-07-17 |
| 2. Food Catalog Ingest & Search | Bundled OFF seed DB, FTS5 search <1s, OFF API fallback, >90% local hit-rate | Complete | 7/7 | 2026-07-20 |
| 3. Barcode Scanning & CO₂ Factor Table | Real-device-verified barcode scan → autofill, product→CO₂ factor table, confidence bands | Complete | 5/5 | 2026-07-22 |
| 4. Meal Logging Core (<10s target) | Breakfast/Lunch/Dinner/Snack logging, Recent/Favorites/Custom foods, verified <10s end-to-end | Complete | 13/13 | 2026-07-27 |
| 5. Nutrition, CO₂, Dashboard, Insights, Weight, Notifications, Export — Local Mode Shippable | Full local-only app: dashboard, CO₂ estimator + transparency, insights, weight tracking, local notifications, export/backup | Complete | 19/19 | 2026-07-28 |
| 6. Onboarding, Legal Consent, Legal Hub, ED Safety Nets, Accessibility & Pre-Submission | Store-submission-ready shell: onboarding flow, GDPR consent capture, Legal Hub, ED safety nets, accessibility audit | Complete | 10/10 | close date not recorded in ROADMAP (06-10 real-device checkpoints approved per STATE.md) |
| 7. Keycloak Auth + Account Deletion | OIDC/PKCE login (email/password, Apple, Google), logout, password reset, GDPR account deletion, zero data movement | Complete | 8/8 | 2026-08-09 |
| 8. Encrypted Account Backup (contingent) | Opaque client-encrypted backup blob push/pull to backend | **Parked** — 0/0 planned | TBD | Not started; blocked on Tomris's backend "encrypted blob vs. user-cloud export" decision (currently leaning against it) |
| 9. Reference Data Delivery (Full OFF Pack) | On-demand ~300–800MB full OFF catalog via CDN, delta refresh, atomic swap, revert-to-seed | Complete | 8/8 | 2026-09-04 |
| 10. Post-Launch Enhancements (v1.1+ placeholder) | Unscoped slot for post-launch priorities (water tracking, CO₂ modifier UI polish, wearables, recipes, passkeys) | **Not started** — placeholder | TBD | Not scoped |

Note: STATE.md's own YAML progress counter (`completed_phases: 8`) is a documented pre-existing counting quirk — 9 phases (1–7, 9) are functionally complete; only Phase 8 (parked) and Phase 10 (unscoped) remain.

---

## 4. Requirements Coverage

Of 93 total requirements tracked in `.planning/REQUIREMENTS.md` (v1 + v2 combined), **89 are marked complete**. The 4 open items:

| Requirement | Status | Why it's open |
|---|---|---|
| AUTH-09 | Open | Narrowed to the encrypted-backup case only (2026-08-12); contingent on Tomris resolving the backend's still-open "encrypted blob vs. user-cloud export" decision — tracked under parked Phase 8. |
| PROF-06 | Open | CO₂ profile factors (location, sourcing, transport, cooking method, storage, household size, waste level) live in CO₂ Calculation Settings, not Profile Setup — functionally delivered in Phase 5 per ROADMAP.md, but the checkbox in REQUIREMENTS.md was not updated; worth a verification pass. |
| LEG-04 | Open | Open-source license disclosure (all third-party licenses/copyright notices viewable in-app) — CI generates the disclosure per Phase 1's success criteria, but the requirement's own checkbox is unmarked; worth a verification pass. |
| NFR-03 | Open (Pre-Launch Blocker, not a phase-completion blocker) | App tone/SAM (Self-Assessment Manikin) test requires an independent, naive tester by its own methodology — Ali's self-review reads positively but doesn't satisfy the test's design intent. Tracked in STATE.md, does not block Phase 6's closure. |

All v1 requirements are mapped to exactly one roadmap phase (100% coverage), per REQUIREMENTS.md's Traceability table.

---

## 5. Key Decisions Log

- **Drift over Hive** for local storage — Hive lacked FTS5 and had brittle migrations; sync-safety had to be baked in from Phase 1 because it can't be retrofitted later.
- **freezed 3.2.6-dev.1** (not stable 3.2.5) — 3.2.5's analyzer constraint conflicted with `riverpod_lint` 3.1.4; `custom_lint` was dropped entirely for the same reason [Phase 1].
- **Phase 7/8 split (2026-08-08)** — Auth (Phase 7, zero data movement) separated from sync/backup (Phase 8, contingent), after a backend repo scan showed the backend doesn't own bidirectional user data.
- **Phase 8 renamed and narrowed (2026-08-12)** from "User Data Sync Engine" to "Encrypted Account Backup" — the backend's Sync module is permanently scoped to catalog/reference data only and will never do bidirectional user-data sync (settled architecture, not an open question); only the encrypted-blob-backup question remains open, and the backend's own docs currently lean against building it.
- **AUTH-08/AUTH-09/ONBD-03 resolution (2026-08-12):** AUTH-08 satisfied by Phase 7's zero-data-movement design (no further work). AUTH-09 narrowed to the encrypted-backup case only. ONBD-03 (an account-vs-local choice screen) moved to v2 requirements — its premise doesn't exist without a real backup feature to choose into.
- **Recent = individual food items, not combo entries** — confirmed via live build, overriding an earlier spec draft.
- **CO₂ profile factors live in CO₂ Calculation Settings, not Profile Setup** — keeps onboarding lightweight; factors are optional/advanced.
- **Real CDN explicitly out of scope for Phase 9** — both real-device checkpoints were verified against a local throwaway Range-capable dev server (`tool/dev/range_test_server.dart`), not a production endpoint; logged as a Pre-Launch Blocker.
- **compileSdk floor raised for third-party library subprojects, not just the app module** [Phase 9-08] — a stale `storage_space` plugin compileSdk (33) broke the Android build against newer transitive deps; the fix had to be project-wide, not app-level only.
- **gzip decompression moved off the main isolate via `compute()`** [Phase 9-08] — synchronous decompression of a real ~123MB payload froze the UI thread long enough to trigger an Android ANR; no existing automated test exercised a payload large enough to catch it.
- **`revertToSeed()` now stages before deleting** [Phase 9-08] — the bundled seed path and the installed-pack path resolve to the exact same on-disk file (`off_reference.sqlite`) in production; the prior delete-then-ATTACH sequence silently destroyed the seed's only copy before ever reading it, corrupting the installed database to an empty file on every real revert. No unit fixture caught this because test fixtures use two distinct files.
- **`DownloadManager.resume()` falls back to re-enqueuing from scratch** [Phase 9-08] when no native resume data exists after a connection-level failure — previously a silent no-op.
- **`fetchManifest()` given a 15s timeout** [Phase 9-08] — previously hung indefinitely against a dead/unreachable `manifestUrl`, with zero error surfaced.

---

## 6. Tech Debt & Deferred Items

- **Real CDN integration (Pre-Launch Blocker, Phase 9):** `ReferencePackConfig.manifestUrl` still points at a `cdn.example.com` placeholder. Client-side mechanics (resumable download, atomic swap, revert) are proven on real hardware against a local dev server; real-world CDN behaviors (stable ETags, real network conditions, real payload sizes at scale) remain unverified.
- **Phase 7 real-device/real-backend auth verification (5 items, not completion blockers):** Apple Sign-in and Google Sign-in end-to-end on real devices, full email/password signup→verification→login round trip, account deletion against a real backend endpoint (not yet built by Tomris), and the App Store Guideline 4.8 review outcome for the non-native-SDK Apple Sign-in flow — all blocked on a live Keycloak realm + IdP configuration that doesn't exist yet.
- **SAM (Self-Assessment Manikin) test with an independent tester (NFR-03):** self-review reads positively but doesn't satisfy the test's own naive-tester design intent; must be run before launch.
- **External legal review:** Fachanwalt IT-Recht sign-off on Terms/Privacy/Health Disclaimer (€1–3k) and an LCA methodology peer reviewer (€2–5k) — drafted text is flagged "pending legal review" via tracked TODO, not a user-visible banner.
- **Impressum real identity data:** entity name/address/responsible-person are placeholder text pending a decision from the product owner — TMG §5 compliance is blocked on this regardless of any phase's completion status.
- **Phase 8 (Encrypted Account Backup):** entirely parked, zero actionable content, pending Tomris's backend architecture decision (currently leaning against building it).
- **Phase 10 (Post-Launch Enhancements):** unscoped placeholder — water tracking, CO₂ profile modifier UI polish, advanced insights, wearable/Apple Health/Google Fit integration, recipes, passkey re-evaluation, and ONBD-03's Mode Choice screen all wait here for real post-launch signal.
- **PROF-06 / LEG-04 checkbox discrepancy:** both appear functionally delivered per ROADMAP.md phase success criteria but are unmarked in REQUIREMENTS.md — worth a verification pass before the next milestone close.

---

## 7. Getting Started

```bash
git clone <repo-url>
cd Co2-diet-app
flutter pub get
flutter test          # full suite (553 tests passing as of Phase 9 close)
flutter run           # launches on connected device/emulator
```

Requires Dart SDK `>=3.12.2 <4.0.0` and Flutter `>=3.44.6`. The privacy dependency-blocklist check (`check_privacy_deps.dart`) runs in CI on every commit via GitHub Actions and fails the build on any disallowed analytics/ad/Firebase SDK.

For architecture and methodology detail, see `docs/CO2_METHODOLOGY.md` (CO₂ calculation sourcing) and `.planning/phases/07-keycloak-auth-account-mode-sync/07-CONTEXT.md` (Phase 7/8 split rationale). <!-- VERIFY: exact remote repo URL -->

---

## Stats

- **Commits since Phase 1 kickoff (`5e2d2a5`, 2026-07-16) through HEAD (`1607453`, 2026-09-04):** 409
- **Files changed:** 680 files (+111,668 / −260 lines)
- **Timeline:** 2026-07-16 → 2026-09-04 (~50 days)
- **Contributors:** 1 (Ali — sole Flutter developer; backend is a separate parallel workstream owned by Tomris, not reflected in this repo's git history)
- **Phases complete:** 9 of 10 (Phase 8 parked, Phase 10 unscoped)
- **Plans executed:** 77 of 77 planned across the 9 active phases (7, 7, 5, 13, 19, 10, 8, 8 across Phases 1–7 and 9 respectively)
- **Requirements delivered:** 89 of 93 tracked (4 open — see Requirements Coverage)
- **Test suite:** 553 tests passing as of Phase 9 close (2026-09-03/04)
- **Real-device verification sessions:** Phase 3 (barcode, Galaxy Tab S7 FE), Phase 4 (<10s + airplane mode, Android + iOS), Phase 6 (accessibility/SAM, both platforms), Phase 9 (resumable download + atomic swap, Galaxy Tab S7 FE — found and fixed 5 real defects in a single ~10-hour session)

---
*Report generated by the GSD milestone-summary workflow. Source data: `.planning/STATE.md`, `.planning/ROADMAP.md`, `.planning/REQUIREMENTS.md`, `.planning/PROJECT.md`, `.planning/phases/*/`, git history.*
