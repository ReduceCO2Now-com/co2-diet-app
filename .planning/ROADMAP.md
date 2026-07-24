# Roadmap: CO₂ Diet

**Created:** 2026-07-16
**Granularity:** fine (target 8–12 phases)
**Total phases:** 9
**Coverage:** 75/75 v1 requirements mapped

**Core value:** A user must be able to log a meal in under 10 seconds — everything else is secondary to that speed and privacy guarantee.

**Delivery principle:** Local Mode is the product; Account Mode is an enhancement. Local Mode is shippable at the end of Phase 5. Legal/store-ready ships at Phase 6. Sync ships at Phase 7. Post-launch enrichment is Phase 8–9.

**Ordering rationale:** Highest architectural risk (sync-safe schema) is Phase 1 because it cannot be retrofitted. Highest technical risk (OFF ingest + FTS5 + barcode + CO₂ factor mapping) is Phase 2–3 to burn down uncertainty early. Auth is deliberately late (Phase 7) — Local Mode never blocks on it.

---

## Phases

- [x] **Phase 1: Foundations & Sync-Safe Schema** — Drift v1 with HLC/tombstones/dirty flags/consent/CO₂ methodology version, DI, router, theme, CI dependency-audit pipeline, thinnest E2E vertical slice (completed 2026-07-17)
- [x] **Phase 2: Food Catalog Ingest & Search** — OFF seed DB ingest, FTS5 index, bundled starter pack, search UI + API fallback, benchmarked <1s on low-end Android (completed 2026-07-20)
- [x] **Phase 3: Barcode Scanning & CO₂ Factor Table** — mobile_scanner integration, real-device barcode verification, product-to-CO₂ factor prototype, custom-food fallback (completed 2026-07-22)
- [ ] **Phase 4: Meal Logging Core** — Breakfast/Lunch/Dinner/Snack slots, portion units, Recent, Favorites, Custom foods, personal overrides, edit/delete/duplicate, offline-first, <10s meal-log verified
- [ ] **Phase 5: Nutrition, CO₂ Estimator, Dashboard, Insights, Weight, Notifications, Export/Backup** — full local app; CO₂ Estimator + Transparency + Improvement Opportunities; Insights (7d/30d); Weight tracking; local notifications; Export (CSV/Excel/JSON); Backup/Restore. **Local Mode shippable here.**
- [ ] **Phase 6: Onboarding, Legal Consent, Legal Hub, ED Safety Nets, Accessibility & Pre-Submission** — Splash → Welcome → Legal Consent → Mode Choice → Profile → Carousel; timestamped consent records; Legal Hub (Terms/Privacy/Disclaimer/Impressum); ED safety nets; PrivacyManifest/Data Safety; a11y audit; equal-weight Mode Choice audit; SAM test
- [ ] **Phase 7: Keycloak Auth + Account Mode + Sync** — flutter_appauth OIDC/PKCE, Apple + Google IdPs, email/password + reset, Local→Account upgrade, outbox drainer + delta pull LWW-by-HLC, GDPR endpoints (export/delete), sync status UI
- [ ] **Phase 8: Reference Data Delivery (Full OFF Pack)** — on-demand ~300–800MB OFF pack via CDN, delta refresh, methodology-version announcement flow
- [ ] **Phase 9: Post-Launch Enhancements (deferred)** — v1.1+ scope placeholder (water tracking, CO₂ profile modifiers UI polish, advanced insights, wearable/Health integration) — no v1 requirements land here; kept in roadmap for continuity

---

## Phase Details

### Phase 1: Foundations & Sync-Safe Schema
**Goal**: Establish the sync-safe local database, clean architecture skeleton, CI privacy guarantees, and a thinnest-possible end-to-end vertical slice so every subsequent phase builds on a correct foundation.
**Depends on**: Nothing (first phase)
**Requirements**: PROF-01, PROF-02, PROF-03, PROF-04, PROF-05, PRIV-07, CO2-04, LEG-04
**Success Criteria** (what must be TRUE):
  1. Drift schema v1 exists with UUID v7 primary keys, HLC columns, `dirty` flags, tombstone fields, `co2_methodology_version` column on all CO₂-bearing rows, and a `consent_records` table — even though sync and legal consent are not yet built.
  2. Clean-layered project (UI → Riverpod Presentation → Application → Domain → Data) compiles on iOS and Android with go_router, theme tokens, Riverpod codegen DI wired up, and Plus Jakarta Sans + Inter fonts bundled as assets.
  3. CI pipeline runs a hardcoded third-party-SDK blocklist audit and fails the build on any Firebase / Sentry / analytics / ad-SDK transitive dependency; open-source license disclosure is generated and viewable in-app.
  4. A user can enter a profile (age/gender/height/weight/activity/dietary/units/goal), see auto-calculated calorie + macro + CO₂ targets (Mifflin-St Jéor + activity factor), and manually override any target — persisted locally.
  5. Thinnest vertical slice works: a user can enter a complete profile → auto-calculated calorie/macro targets persist to the local Drift database → targets survive app restart and are visible on the Profile screen (food/meal tables and dashboard CO₂ are Phase 2–4 scope; this was reinterpreted in 01-CONTEXT.md before planning began).
**Plans**: 7 plans
Plans:
- [x] 01-01-PLAN.md — Flutter scaffold + pubspec + theme module
- [x] 01-02-PLAN.md — Sync-safe Drift schema (HLC + SyncSafeTable + DAOs + codegen)
- [x] 01-03-PLAN.md — Domain layer: UserProfile, CalcTargets, TargetCalculator, IProfileRepository
- [x] 01-04-PLAN.md — Repository layer + DI providers + ProfileNotifier AsyncNotifier
- [x] 01-05-PLAN.md — go_router + ProfileScreen (7 fields, unit-aware, auto-save, targets, override) + SettingsScreen
- [x] 01-06-PLAN.md — CI privacy pipeline (.privacy-blocklist.yaml + check_privacy_deps.dart + GitHub Actions)
- [x] 01-07-PLAN.md — Wave 0 test suite: 6 test files, 34 tests green

### Phase 2: Food Catalog Ingest & Search
**Goal**: Ship a fast, offline, high-coverage food search on a bundled OFF seed database with FTS5, benchmarked to meet the <1s search-response and >90% hit-rate targets.
**Depends on**: Phase 1
**Requirements**: LOG-01, LOG-02, NFR-06
**Success Criteria** (what must be TRUE):
  1. A bundled `off_reference.sqlite` seed database (~50MB starter pack) is attached at runtime via ATTACH DATABASE and read-only, decoupled from user-data schema lifecycle.
  2. Food name search returns results in <1s on a low-end Android reference device (Pixel 6a or Samsung A54 class), verified by a repeatable benchmark script committed to the repo.
  3. When online and local results fall below threshold, the search falls back to the Open Food Facts API via `openfoodfacts` Dart client, and returned results are cached locally into user-catalog tables for future offline use.
  4. NFR-06(a) verified: given a benchmark list of ~200 commonly logged EU/German foods, >90% return a usable result from the local DB without triggering the API fallback.
**Plans**: 7 plans
Plans:
- [x] 02-01-PLAN.md — Wave 0 test stubs + build.yaml FTS5 config
- [x] 02-02-PLAN.md — Python OFF JSONL ingest pipeline (tools/ingest_off.py + tools/README.md)
- [x] 02-03-PLAN.md — Dart data layer: pubspec deps, UserFoodCacheTable, AppDatabase ATTACH, FoodCatalogDao, FoodItem, IFoodCatalogRepository, FirstLaunchExtractor
- [x] 02-04-PLAN.md — OffApiClient + FoodCatalogRepository + DI providers + main.dart startup wiring
- [x] 02-05-PLAN.md — FoodSearchState sealed class + FoodSearchNotifier (debounce, offline, fallback)
- [x] 02-06-PLAN.md — Search screen UI + all state widgets + bottom sheet + /food-search route
- [x] 02-07-PLAN.md — Real unit/benchmark tests + human-verify physical device checkpoint
**UI hint**: yes

### Phase 3: Barcode Scanning & CO₂ Factor Table
**Goal**: Deliver P0 barcode scanning verified on real devices and the product→CO₂ factor mapping that gives every scanned/searched food a defensible CO₂ estimate with a confidence band.
**Depends on**: Phase 2
**Requirements**: LOG-03, LOG-04, CO2-01, LEG-05
**Success Criteria** (what must be TRUE):
  1. A user can open the barcode scanner, scan a product barcode, and the resulting food is autofilled with name, nutritional values, and CO₂e estimate — verified end-to-end on at least one real Android device (Galaxy Tab S7 FE) before this phase closes (P0 acceptance criterion; simulator alone is insufficient). iOS real-device gate deferred to Phase 4 (no physical iPhone available).
  2. When a barcode scan finds no match (online or offline), the user is offered an explicit "Add as custom food" fallback — no dead-end UX.
  3. Every food item surfaces a CO₂e value paired with a High or Medium confidence band and rounded to 1–2 significant figures — never as a single false-precision number. No Low tier (no data source to back it).
  4. A documented product→CO₂ factor table (per-category and per-product where available) is loaded from the reference DB, and the methodology + data sources are publicly documented (docs/CO2_METHODOLOGY.md) and linked from within the app (MethodologyScreen + ConfidenceChip explanation sheet).
  5. NFR-06(b) verified: >90% of products in the bundled seed DB have at least a category-average CO₂e estimate, verified by the integration benchmark on a connected Android device.
**Plans**: 5 plans
Plans:
- [x] 03-01-PLAN.md — Wave 0 test stubs for all Phase 3 test files
- [x] 03-02-PLAN.md — FoodItem CO₂ fields + FoodCatalogDao barcode lookup + AGRIBALYSE ingest + off_to_agribalyse_map.csv
- [x] 03-03-PLAN.md — Scanner UI: mobile_scanner deps, BarcodeScanNotifier, BarcodeScanScreen, router wiring, barcode icon in FoodSearchScreen
- [x] 03-04-PLAN.md — CO₂ display: warningAmber token, ConfidenceChip, FoodDetailBottomSheet CO₂ row, MethodologyScreen, docs/CO2_METHODOLOGY.md, NFR-06(b) benchmark
- [x] 03-05-PLAN.md — Real-device human-verify checkpoint: Galaxy Tab S7 FE end-to-end scan + NFR-06(b) benchmark
**UI hint**: yes

### Phase 4: Meal Logging Core (<10s target)
**Goal**: Deliver the heart of the app — end-to-end meal logging under 10 seconds, fully offline, with Recent, Favorites, and Custom foods, so the core value proposition is verifiable in user testing.
**Depends on**: Phase 3
**Requirements**: LOG-05, LOG-06, LOG-07, LOG-08, LOG-09, LOG-10, LOG-11, LOG-12, LOG-13
**Success Criteria** (what must be TRUE):
  1. A user can add a food to Breakfast, Lunch, Dinner, or Snack slots; enter portion in g / ml / cups / pieces / portions (cup/slice/portion sizes are user-configurable in My Foods; metric default, imperial from locale).
  2. Recent shows individually logged food items (never combo/meal entries) with one-tap reuse and previously-used quantity pre-filled; Favorites are one-tap re-loggable; meal entries can be edited, deleted, and duplicated.
  3. A user can create custom foods (My Foods) with name/brand/category, reference amount, full nutrition (calories/protein/carbs/sugar/fat/fiber/salt), CO₂ values (manual or category-estimated), and quick serving sizes; personal overrides of existing DB entries never mutate the original — override and original are stored as an independent, revertible pair.
  4. End-to-end meal logging (from "Add Breakfast" tap → food saved → visible on placeholder dashboard) completes in under 10 seconds on a mid-range device, verified in user testing on real hardware before this phase closes.
  5. All core meal-logging flows function with airplane mode enabled — zero network dependency.
**Plans**: 13 plans
Plans:
- [x] 04-01-PLAN.md — Wave 0 test stubs (16 files covering LOG-05 through LOG-13)
- [x] 04-02-PLAN.md — Drift schema: MealEntryTable, FavoriteTable, UserFoodTable (schemaVersion 2→3)
- [x] 04-03-PLAN.md — Domain entities & interfaces: MealSlot/PortionUnit, MealEntry, Favorite, ServingSize, UserFood, IMealEntryRepository, IUserFoodRepository
- [x] 04-04-PLAN.md — DAOs: MealEntryDao (entries + favorites), UserFoodDao
- [x] 04-05-PLAN.md — Repositories + DI: MealEntryRepository, UserFoodRepository, meal_logging_providers.dart
- [x] 04-06-PLAN.md — Search & barcode override integration (FoodItem.source, FoodCatalogDao override precedence)
- [x] 04-07-PLAN.md — Notifiers: MealEntryNotifier, FavoriteNotifier, UserFoodNotifier
- [x] 04-08-PLAN.md — My Foods: Custom Food Form screen + My Foods list screen
- [ ] 04-09-PLAN.md — Sheet reconciliation + PortionSlotForm (core <10s logging UI)
- [ ] 04-10-PLAN.md — Food search Recent/Favorites empty-state UI + "Add as custom food" link
- [ ] 04-11-PLAN.md — Dashboard managing entries: flutter_slidable checkpoint + swipe actions
- [ ] 04-12-PLAN.md — LOG-13 benchmark + LOG-12 offline logging test fill-ins
- [ ] 04-13-PLAN.md — Real-device human-verify checkpoint (Android + iOS, <10s + airplane mode)
**UI hint**: yes

### Phase 5: Nutrition, CO₂ Estimator, Dashboard, Insights, Weight, Notifications & Export — Local Mode Shippable
**Goal**: Complete the full local-mode app: nutrition + CO₂ tracking, dashboard, insights, weight tracking, local notifications, and export/backup — so Local Mode is a shippable product independent of any backend.
**Depends on**: Phase 4
**Requirements**: NUTR-01, NUTR-02, NUTR-03, NUTR-04, CO2-02, CO2-03, CO2-05, CO2-06, DASH-01, DASH-02, DASH-03, DASH-04, DASH-05, DASH-06, DASH-07, DASH-08, INS-01, INS-02, INS-03, INS-04, WT-01, WT-02, WT-03, WT-04, WT-05, NOTIF-01, NOTIF-02, NOTIF-03, PRIV-01, PRIV-02, PRIV-03, PRIV-04, PRIV-08, PRIV-09, AUTH-07, NFR-05
**Success Criteria** (what must be TRUE):
  1. Dashboard is the default post-onboarding screen and shows today's CO₂, calories, and protein each with target comparison; quick-log buttons for B/L/D/S plus Quick Add; today's meal list with swipe-to-edit and duplicate; 7-day trend chart; contextual quick insight; Local Mode indicator; empty state; and every metric tap opens the Data Analysis screen for that metric.
  2. CO₂ Estimator runs entirely on-device (deterministic, offline) and calculates per-meal / daily / weekly totals; CO₂ Calculation Settings screen lets the user optionally configure location, purchasing source, transport, cooking method, storage, household size, and waste level (regional averages as fallback); Estimate Transparency screen shows value + confidence + factors + source + methodology link; Improvement Opportunities suggests non-judgmental alternatives with quantified CO₂ delta.
  3. Data Analysis screen shows today's breakdown by meal, largest contributors, goal comparison with dynamic message, switchable 7-day / 30-day rolling trend, Improvement Opportunities, expandable per-serving + per-100g detail, Estimate Transparency, and an Insights Timeline — all working fully offline.
  4. Weight tracking: user can log weight (value/unit/date/note), view an interactive trend chart (7d/30d/90d/1yr/all), set an optional weight goal with progress on the chart, and configure weigh-in reminder frequency + day; Weight is primarily under Profile/Settings with the Insights-tab placement resolved as a documented design decision.
  5. Local notifications work via `flutter_local_notifications` only (zero FCM/APNs); user can export all data as CSV/Excel/JSON zip with manifest, create manual backups (device/cloud/share), configure automatic backups, restore from backup with preview + explicit confirmation, and delete all local data via a typed-confirmation Danger Zone. In Local Mode, no data is ever transmitted to any server without explicit user action.
**Plans**: TBD
**UI hint**: yes

### Phase 6: Onboarding, Legal Consent, Legal Hub, ED Safety Nets, Accessibility & Pre-Submission
**Goal**: Wrap Local Mode in a store-submission-ready shell: full onboarding flow, GDPR-valid consent capture, Legal Hub, ED safety nets, accessibility compliance, and the equal-weight Mode Choice audit — so the app can be submitted to the App Store and Play Store as a Local-Mode-only v1.
**Depends on**: Phase 5
**Requirements**: ONBD-01, ONBD-02, ONBD-03, ONBD-04, ONBD-05, LEGAL-01, LEGAL-02, LEGAL-03, LEGAL-04, LEG-01, LEG-02, LEG-03, ACC-01, ACC-02, ACC-03, ACC-04, ACC-05, NFR-01, NFR-02, NFR-03, NFR-04, NFR-07, PRIV-06
**Success Criteria** (what must be TRUE):
  1. Onboarding flow works end-to-end: Splash (2–3s auto-advance) → Welcome (equal-weight "Get Started" / "Use Without Account" CTAs) → Legal Consent → Mode Choice (two equal-weight cards, no "Recommended" badge, audited against live-build bias) → Profile Setup (all fields optional, auto-saves, no blocking validation, mode-adaptive footer) → 3–4 slide Carousel (swipeable, "Skip intro", sticky "Go to Dashboard") → Dashboard.
  2. Legal Consent screen presents 4 mandatory separate checkboxes (Terms / Privacy / not-medical-advice / user-responsibility) with a 5th optional "I confirm I am 16 or older" checkbox; "Accept and Continue" stays disabled until all 4 mandatory are checked; no pre-checked boxes; View Terms / Privacy / Disclaimer accessible from the screen; each consent event is written to `consent_records` with UTC timestamp + app version + policy version and is never deletable except on full account deletion.
  3. Legal Hub is reachable within 2 taps from any screen and contains full-document screens for Terms, Privacy Policy, Health Disclaimer, and Impressum (with legal entity, address, contact email, responsible person, and TMG §5 / MStV §18 disclosures); Health Disclaimer is also linked from the Legal Consent screen; user can exercise GDPR rights (access, rectify, portability, consent withdrawal) from the hub.
  4. ED safety nets: the app refuses daily calorie targets below 1,200 kcal or goals implying BMI below 17.5 without surfacing a warning and a professional resource / helpline link; app uses no "diagnose / treat / cure / medical" language anywhere.
  5. Accessibility audit passes: system dark mode supported on iOS and Android; text scales with Dynamic Type / font size without layout breakage; all interactive elements have VoiceOver / TalkBack labels with key flows verified by a screen-reader pass; all charts and indicators are color-blind friendly (never red/green alone); all tap targets are ≥ 44×44 pt; tone/copy validated non-judgmental and non-preachy; SAM (Self-Assessment Manikin) test conducted and app confirmed to feel calm, supportive, and non-stressful; PrivacyInfo.xcprivacy present, Play Data Safety form drafted.
**Plans**: TBD
**UI hint**: yes

### Phase 7: Keycloak Auth + Account Mode + Sync
**Goal**: Add Account Mode as a pure enhancement — Keycloak OIDC auth (email/password, Apple, Google), Local→Account upgrade without data loss, and hand-rolled outbox + HLC sync — so users who opt in get transparent cross-device sync while Local Mode users are unaffected.
**Depends on**: Phase 6; requires backend readiness from Tomris (Spring Boot + PostgreSQL + Keycloak realm + GDPR endpoints)
**Requirements**: AUTH-01, AUTH-02, AUTH-03, AUTH-04, AUTH-05, AUTH-06, AUTH-08, AUTH-09, AUTH-10, CO2-07, PRIV-05
**Success Criteria** (what must be TRUE):
  1. A user can create an account with email/password (email verified before sync enables), log in and stay logged in across sessions, log out from any screen, and reset password via a secure email link — all via Keycloak OIDC + PKCE using `flutter_appauth` and the system browser; refresh token in secure storage, access token in memory only; zero Firebase/Supabase auth.
  2. Apple Sign-in (via Keycloak Identity Provider, mandatory on iOS per App Store Guideline 4.8) and Google Sign-in (via Keycloak IdP) both complete the sign-up/sign-in flow end-to-end on real devices; no native Apple Sign-in SDK on the Flutter client.
  3. A Local Mode user can upgrade to Account Mode at any time without losing any local data — all existing local rows are marked dirty and drained to the backend via the outbox, and dashboard/history reflect zero data loss after the upgrade completes.
  4. Sync engine: background/foreground-on-resume outbox drainer pushes dirty local rows, delta pull applies remote changes, conflicts resolve LWW-by-HLC; sync status is visible to the user (idle / syncing / error) via a non-intrusive indicator; sync is fully transparent on happy path.
  5. A user can permanently delete their account and all associated data from within the app; the deletion request removes the Keycloak user in the same operation and completes within the legally required timeframe (App Store rule + GDPR Art. 17); a CO₂ methodology update surfaces a non-intrusive "CO₂ estimates updated with methodology v2" announcement to users on next launch.
**Plans**: TBD
**UI hint**: yes

### Phase 8: Reference Data Delivery (Full OFF Pack)
**Goal**: Enable users on Wi-Fi to opt into the full Open Food Facts catalog (~300–800MB) via CDN with incremental delta refresh — closing the last gap between "starter seed" and "full catalog" without inflating install size for everyone.
**Depends on**: Phase 7 (post-launch enrichment; not blocking store submission)
**Requirements**: (none — v1 launch is served by the Phase 2 bundled seed; this phase is v1.0.x enrichment kept in-roadmap for continuity)
**Success Criteria** (what must be TRUE):
  1. User can opt into "Download full food database" from settings; the client downloads the current OFF pack from a CDN with pause/resume and Wi-Fi-only default.
  2. Incremental delta refresh runs on user request or on a configurable schedule (never silent background transfer in Local Mode), and applied deltas do not require app reinstall.
  3. Download progress and disk-usage impact are transparently shown before and during the transfer; user can revert to the bundled seed at any time.
**Plans**: TBD

### Phase 9: Post-Launch Enhancements (v1.1+ Placeholder)
**Goal**: Track deferred v1.1+ scope (water tracking, CO₂ profile modifier UI polish, advanced insights, wearable / Apple Health / Google Fit integration, recipes, passkeys) as a durable slot in the roadmap — no v1 requirements land here.
**Depends on**: Phase 7 shipped and live-user feedback collected
**Requirements**: (none in v1; placeholder for v1.1 promotions from `## v2 Requirements` in REQUIREMENTS.md)
**Success Criteria** (what must be TRUE):
  1. A prioritized v1.1 shortlist exists in `.planning/` derived from post-launch user feedback and store review signal.
  2. Passkey feasibility (AUTH-V2-01) is re-evaluated against the current Flutter ecosystem before implementation is scheduled.
**Plans**: TBD

---

## Progress

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Foundations & Sync-Safe Schema | 7/7 | Complete   | 2026-07-17 |
| 2. Food Catalog Ingest & Search | 7/7 | Complete   | 2026-07-20 |
| 3. Barcode Scanning & CO₂ Factor Table | 5/5 | Complete   | 2026-07-22 |
| 4. Meal Logging Core | 8/13 | In Progress|  |
| 5. Full Local App (Local Mode Shippable) | 0/0 | Not started | - |
| 6. Onboarding, Legal & Pre-Submission | 0/0 | Not started | - |
| 7. Keycloak Auth + Account Mode + Sync | 0/0 | Not started | - |
| 8. Reference Data Delivery (Full OFF Pack) | 0/0 | Not started | - |
| 9. Post-Launch Enhancements (v1.1+) | 0/0 | Not started | - |

---

## Coverage Notes

**All 75 v1 requirements are mapped to exactly one phase.** Traceability in `.planning/REQUIREMENTS.md`.

**NFR-01, NFR-02, NFR-03, NFR-04, NFR-05, NFR-07 handling:** These UX-tone and safety-net non-functional requirements are validated in Phase 6 (SAM test, ED safety nets, non-judgmental copy audit). They are also considered *cross-cutting quality gates* — every phase's UI work must respect them, but Phase 6 owns the pre-launch verification. To satisfy the "exactly one phase" rule they are formally assigned to Phase 6, with NFR-05 (confidence bands / no false precision) additionally reinforced in Phase 5 where the CO₂ display components are built.

**NFR-06 (food DB reliability):** Split across phases. NFR-06(a) (search hit-rate ≥90%) is assigned to Phase 2 where the seed DB, FTS5 search, and benchmark script are built. NFR-06(b) (CO₂ coverage ≥90%) is assigned to Phase 3 where the CO₂ factor table is built — it cannot be measured until that table exists.

**AUTH-07 (Local Mode never contacts backend without explicit action):** Assigned to Phase 5 (Local Mode complete). The invariant is enforced from Phase 1 by not integrating any auth/backend code until Phase 7.

**CO2-04 (`co2_methodology_version` field):** Column added in Phase 1 schema; user-facing update-announcement flow ships with the sync/auth surface in Phase 7 (first realistic point at which a methodology update would be pushed).

**PRIV-05 (permanent account deletion):** Assigned to Phase 7 (requires backend + Keycloak). PRIV-09 (local Danger Zone delete) is Phase 5 (local-only).

**PRIV-06 (GDPR rights UI hub):** Assigned to Phase 6 (Legal Hub is the delivery vehicle). The backing sync/backend endpoints ship in Phase 7.

**LEG-05 (CO₂ methodology publicly documented):** Assigned to Phase 3 where the CO₂ factor table + confidence bands + transparency link land together.

---

*Roadmap created: 2026-07-16*
*Phase 2 planned: 2026-07-17 — 7 plans, 4 waves*
*Phase 3 planned: 2026-07-21 — 5 plans, 4 waves*
