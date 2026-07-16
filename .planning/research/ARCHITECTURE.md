# Architecture Research: CO₂ Diet
**Domain:** Flutter offline-first nutrition + CO₂ tracking mobile app
**Confidence note:** WebSearch/WebFetch unavailable during this session; verify size estimates and package versions against current docs before committing.

---

## High-Level Architecture

```
┌──────────────────────────────────────────────────────────────────────────┐
│                            PRESENTATION LAYER                            │
│  (Flutter widgets, Riverpod providers, GoRouter, screen-scoped state)    │
└──────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌──────────────────────────────────────────────────────────────────────────┐
│                            APPLICATION LAYER                             │
│  Use cases: LogMealUseCase, SearchFoodUseCase, CalculateCO2UseCase,      │
│  SyncNowUseCase, EnrollAccountUseCase                                    │
└──────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌──────────────────────────────────────────────────────────────────────────┐
│                             DOMAIN LAYER                                 │
│  Pure Dart entities (Food, Meal, DailyLog, UserProfile, CO2Factor)       │
│  Domain services: CO2Estimator, MacroCalculator, TargetsCalculator       │
│  Repository INTERFACES only — no I/O                                     │
└──────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌──────────────────────────────────────────────────────────────────────────┐
│                              DATA LAYER                                  │
│                                                                          │
│  ┌──────────────────────┐  ┌────────────────────┐  ┌──────────────────┐  │
│  │  User Data           │  │  OFF Reference DB  │  │  Sync Engine     │  │
│  │  (Drift/SQLite)      │  │  (read-only asset  │  │  (Outbox + HLC)  │  │
│  │  logs, meals,        │  │  SQLite, ~50MB     │  │                  │  │
│  │  favorites, custom,  │  │  bundled starter + │  │                  │  │
│  │  outbox, sync_state  │  │  on-demand full)   │  │                  │  │
│  └──────────────────────┘  └────────────────────┘  └──────────────────┘  │
│           │                          │                       │            │
│           └──────────┬───────────────┴──────────┬────────────┘            │
│                      ▼                          ▼                        │
│             ┌──────────────────┐      ┌───────────────────────┐          │
│             │ OFF API Client   │      │ Backend API Client    │          │
│             │ (cache-miss      │      │ (Spring Boot REST +   │          │
│             │  fallback)       │      │  Keycloak OIDC)       │          │
│             └──────────────────┘      └───────────────────────┘          │
└──────────────────────────────────────────────────────────────────────────┘
```

Data flows strictly one-directional: UI → Application → Domain → Data. The Data layer never depends upward. Sync is a background service; UI never blocks on network.

---

## Component Boundaries

| Component | Responsibility | Communicates With |
|-----------|----------------|-------------------|
| UI (Flutter widgets) | Render, gesture, navigation | Presentation providers only |
| Presentation (Riverpod) | Screen state, view-models | Use cases (Application) |
| Application (Use Cases) | Orchestrate user intent, transactions | Domain services + Repository interfaces |
| Domain (Entities/Services) | Business rules (macros, CO₂ estimation, targets) | Nothing — pure Dart |
| User Data Repository | CRUD user logs/meals/favorites/custom foods | Local DB (Drift) + Sync Outbox |
| Food Catalog Repository | Search/lookup food products | OFF bundled DB → OFF API fallback → custom foods |
| CO₂ Repository | Lookup CO₂ factors, apply regional adjustments | Local DB co2_factors table |
| Sync Engine | Push outbox, pull deltas, resolve conflicts | Local DB + Backend API |
| Auth Service | OIDC flow, token storage/refresh, local-mode fallback | Keycloak (flutter_appauth) + FlutterSecureStorage |
| Barcode Scanner | Camera → EAN/UPC string | Food Catalog Repository |
| Backup/Export | Serialize local DB to CSV/JSON, restore | Local DB + File I/O |

**Golden rule:** UI must never import `drift`, `dio`, `flutter_appauth`, or any I/O package directly.

---

## Local Database: Drift (SQLite), Not Hive

PROJECT.md lists Hive as tentative. **Recommendation: switch to Drift.**

| Criterion | Drift (SQLite) | Hive | Isar |
|-----------|----------------|------|------|
| FTS5 for 1M+ OFF products | ✓ Built-in | ✗ No — manual scan | ✓ But format churn |
| Complex aggregates (daily totals, joins) | SQL | Manual, painful | Query DSL |
| Bundle prebuilt .sqlite as asset | ✓ Trivial | ✗ Awkward | ✗ Awkward |
| Reactive streams | ✓ | Partial (box listeners) | ✓ |
| Versioned migrations | ✓ Explicit | Ad-hoc | Ad-hoc |
| Maturity 2025+ | Very active | hive_ce fork, original unmaintained | v3 stalled, v4 unclear |

**Decision: Drift.** Confidence: HIGH on capabilities; FTS on 1M+ makes Hive impractical.

### User Data Schema (mutable, synced)

```sql
users(id, keycloak_sub, mode, created_at)
user_profiles(user_id PK, age, gender, height, weight, activity, dietary_pref, units, updated_hlc)
user_goals(user_id PK, goal_type, kcal_target, protein_g, fat_g, carb_g, co2_target_g, updated_hlc)
co2_settings(user_id PK, region_code, sourcing_pref, transport_pref, cooking_pref,
             storage_pref, household_size, waste_level, updated_hlc)
meal_entries(id PK, user_id, meal_slot, logged_at, food_ref, portion_qty, portion_unit,
             kcal, protein_g, fat_g, carb_g, sugar_g, fiber_g, sodium_mg,
             co2_g_estimated, co2_g_authoritative, co2_methodology_version,
             created_hlc, updated_hlc, deleted_hlc, dirty INTEGER)
custom_foods(id PK, user_id, name, brand, per_100g_kcal, [macros...],
             co2_g_per_kg, source, updated_hlc)
favorites(user_id, food_ref, added_at)
weight_entries(id PK, user_id, weight_g, unit, logged_at, note, updated_hlc)
sync_outbox(id PK, entity_type, entity_id, op, payload_json, created_hlc, attempts, last_error)
sync_state(entity_type PK, last_pulled_hlc, last_pushed_hlc)
consent_records(id, user_id, doc_type, doc_version, accepted_at, app_version)
```

### Reference Data Schema (bundled + updatable, read-mostly)

```sql
off_products(barcode PK, name, brand, categories, per_100g_kcal, [macros...], image_url, off_updated_at)
off_products_fts -- FTS5 virtual table on name, brand
products_cache(barcode PK, [same as off_products], cached_at)
co2_factors(id PK, category_or_barcode, region_code, co2e_g_per_kg, source, methodology_version, valid_from)
```

Reference data ships as a separate `off_reference.sqlite` asset, attached via `ATTACH DATABASE`. Separates user data lifecycle from reference data updates.

---

## Open Food Facts Data Strategy

This is the highest-risk architectural decision. Raw OFF JSONL dump is very large (tens of GB uncompressed). After stripping to needed fields and filtering by language/completeness, bundled SQLite is estimated at 300 MB–1.2 GB for full coverage — **too large to bundle in the app binary.**

**VERIFY current dump sizes before committing** at: https://wiki.openfoodfacts.org/Data

### Recommended: Tiered Hybrid

1. **Tier 1 — Bundled starter (~50 MB):** Top-N globally scanned products + user's region. Ships with app. Covers ~90% of common scans + reasonable offline name search.
2. **Tier 2 — On-demand full pack (~300–800 MB):** Downloaded on first launch over Wi-Fi with progress bar; user can defer. Play Asset Delivery (Android) / on-demand resources or CDN (iOS).
3. **Tier 3 — API fallback:** OFF API for cache misses when online. Results written to `products_cache`.
4. **Delta updates:** Weekly/monthly `off_reference.sqlite` refresh via CDN; server computes diff from OFF exports.

### Impact on UX design
First-launch experience needs a "Downloading food database (Wi-Fi recommended)" step — not in current onboarding spec. Flag this for design team.

---

## CO₂ Calculation Engine

**Where it lives: on-device, deterministic.** Confidence: HIGH.

Reasons:
- Offline-first constraint: dashboard shows CO₂ per meal without network
- Local Mode and Account Mode must be identical in features — backend CO₂ would break Local Mode
- Auditability: open-source pure-Dart module matches "methodology publicly documented" requirement

### Engine structure

```
CO2Estimator (pure Dart, Domain layer)
  input:  Food, Portion, CO2Settings (region, sourcing, transport, cooking, storage, waste)
  steps:
    1. baseFactor = CO2FactorRepository.lookup(food, region) // from bundled table
    2. adjustments = regional + sourcing + transport + cooking + storage + waste multipliers
    3. per_portion = baseFactor × portionKg × Π(adjustments)
    4. returns CO2Estimate { grams, confidence, methodologyVersion, contributingFactors[] }
  fallback: category-average factor when no specific factor found, confidence = LOW
```

Store both `co2_g_estimated` (client-computed) and `co2_g_authoritative` (server-override when methodology v2 lands). Show `confidence` in UI to support "Estimate Transparency" requirement.

Baseline methodology reference: Poore & Nemecek 2018 (Science) — standard in the literature.

---

## Delta Sync Strategy

**Model: Server-authoritative, client-outbox, per-record HLC (Hybrid Logical Clock)**

CRDTs are overkill for personal-tracking data. Almost all writes are single-user, single-record — conflicts are rare edge cases. LWW-by-HLC is sufficient. Confidence: HIGH.

### Push (client → server)
1. Drain `sync_outbox` in HLC order
2. `POST /sync/push` with batch: `[{entity_type, entity_id, op, payload, client_hlc}]`
3. Server applies LWW-by-HLC, returns per-record `server_hlc` and conflict list
4. Client clears successful outbox rows; backoff on failures

### Pull (server → client)
1. `GET /sync/pull?since=<last_pulled_hlc>&entity_types=…`
2. Server returns records changed after `last_pulled_hlc`, ordered by server HLC
3. Client applies LWW-by-HLC; skips records where local HLC is newer (outbox still pending)
4. Client updates `sync_state.last_pulled_hlc`

### Conflict resolution
- **meal_entries, weight_entries, favorites:** Last-Write-Wins by HLC
- **profile/goals/co2_settings:** LWW at field group level (each field group has its own `updated_hlc`)
- **custom_foods:** LWW row-level; deletes are tombstones retained ≥90 days
- **off_products, co2_factors:** One-way pull only, never conflict

### Critical rule
Sync fields (HLC columns, dirty flag, deleted_hlc, outbox) must exist in schema **from day one** — even in Local Mode. Adding them after Local Mode ships means existing local data can never sync. This is a rewrite trigger if missed. Confidence: HIGH.

### Sync triggers
- App resume + online → immediate sync
- After each write in Account Mode (debounced 2s)
- Background: every 4–6h (WorkManager Android / BGTaskScheduler iOS)
- Manual "Sync now" in Settings

---

## Local → Account Upgrade Flow

1. User in Local Mode taps "Create Account"
2. Keycloak OIDC flow → `sub` obtained
3. Client sets `users.keycloak_sub`, marks all existing rows dirty, seeds outbox with everything
4. Sync runs — server receives full initial payload as bulk push
5. Server assigns HLCs, returns them; client updates `sync_state`
6. Mode flag flips to `account`

All local data is preserved. This must work correctly before Account Mode is considered shipped.

---

## Keycloak Integration from Flutter

### Package stack
- **`flutter_appauth`** — OIDC with PKCE, Custom Tab / SFSafariViewController (no in-app webview)
- **`flutter_secure_storage`** — refresh token (Keychain/Keystore-backed)
- **In-memory only** for access token — never persisted

### OIDC flow
1. Login → `flutter_appauth.authorizeAndExchangeCode(...)` → Custom Tab → user authenticates → redirect via deep link (`com.reduceco2now.co2diet://oauth/callback`)
2. Store refresh token in secure storage; keep access token in memory
3. Dio interceptor attaches `Authorization: Bearer <access_token>`
4. On 401: interceptor refreshes token silently; on refresh failure: prompt re-login (never wipe local data)

### Social sign-in
Configure as Keycloak Identity Providers (Apple, Google, optionally GitHub) — NOT native SDKs on the Flutter client. Single OIDC flow stays clean; account linking is server-side.
**Note:** Apple requires Sign in with Apple be offered if any social sign-in is present on iOS (App Store Guideline 4.8). Including Apple IdP in Keycloak satisfies this.

### AuthState enum
```dart
enum AuthState { unauthenticated, localMode, authenticated }
```
All repositories accept `AuthState`. In `localMode`, `user_id` = stable local sentinel (`local:<installation-uuid>`). Sync engine is no-op when not `authenticated`. Zero code paths require a token to render any core screen.

---

## Feature Module Structure

```
lib/
  core/          # DI, theme, router, error, result, HLC, connectivity
  data/
    local/drift/ # DB schema, DAOs, migrations
    remote/      # backend API client, OFF API client
    reference/   # bundled asset loaders
  domain/        # entities, services (CO2Estimator, MacroCalculator), repository interfaces
  features/
    onboarding/  # Welcome, Legal Consent, Mode Choice, Profile Setup, Carousel
    auth/        # Keycloak flow, tokens, local-mode
    dashboard/
    food_logging/
      search/    # FTS + OFF API fallback
      barcode/   # mobile_scanner
      log/       # Meal editor, portion picker
      my_foods/  # Custom foods CRUD
    insights/    # Data Analysis, Improvement Opportunities
    co2/         # CO₂ settings, transparency
    weight/
    profile/
    privacy/     # Export, backup, delete
    settings/    # App settings, legal hub
    sync/        # Sync engine, status UI
```

**Dependency rule:** `features/*` must never import each other. Cross-feature communication goes through `domain` events or `core` router.

---

## Suggested Build Order

```
Phase 0: Foundations
  └─ Drift schema v1 (WITH sync fields from day one), DI, router, theme, HLC, Result type

Phase 1: Local Vertical Slice
  └─ Local Mode onboarding → Profile → Manual food add → Meal Entry → Dashboard CO₂
     └─ Verify <10s logging target before scale complications

Phase 2: Food Catalog & Search (highest technical risk)
  └─ OFF ingest script → bundled starter DB → FTS5 search → OFF API fallback
     └─ Barcode scanner (mobile_scanner) → lookup → My Foods CRUD

Phase 3: Full Local App
  └─ Recent, Favorites → Insights screens → Weight tracking → Notifications → Export/Backup

Phase 4: Legal & Onboarding Polish
  └─ Legal Consent (consent_records) → Legal Hub → Mode Choice → Carousel → Age gate

Phase 5: Keycloak Auth + Sync
  └─ flutter_appauth → token mgmt → backend API client → push/pull → upgrade flow → multi-device testing

Phase 6: Reference Data Delivery
  └─ On-demand full OFF pack → CDN delta refresh → background scheduling

Phase 7: Privacy & GDPR Compliance
  └─ GDPR endpoints → deletion propagation → consent withdrawal
```

**Hard dependency graph:**
```
Foundations → Local Slice → Food Catalog → Full Local → Legal/Onboarding → Auth+Sync → Reference Delivery → Privacy
                                  ↓
                       CO₂ engine builds in parallel once factor table exists
```

Auth+Sync is deliberately late — everything before must work in Local Mode. Confidence: HIGH.

---

## Key Architectural Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| OFF full dump too large to bundle | Can't meet offline-first search target | Tier the reference data; verify dump size early in Phase 2 |
| FTS5 search >1s on 1M+ rows on low-end Android | Fails <1s constraint | Prebuild FTS index at ingest; benchmark on Pixel 6a before committing |
| Hive chosen, then FTS needed → rewrite | 4–6 week rework | Commit to Drift in Phase 0 |
| Sync fields added after Local Mode ships | Existing data can never sync | Include HLC/tombstones in schema v1 |
| CO₂ methodology change silently changes numbers | User trust | Store `co2_methodology_version` per row; show recalculation banner |
| Keycloak realm changes uncoordinated with backend | Auth breaks | Version-lock realm config; contract-test with Keycloak Testcontainer |
| Apple review rejects missing Sign in with Apple | Launch block | Include Apple IdP in Keycloak from day one |
| Barcode scan → API miss offline → dead end | User frustration | Always offer "save as custom food" fallback |
| iOS BG scheduler unreliable → stale sync | Users think app broken | Sync on every app resume; show last-sync timestamp |
| Regional CO₂ factors sparse | Estimates questioned | Show confidence (High/Medium/Low) + methodology link in UI |

---

## Items to Verify (Requires Network Access)

- OFF current export sizes and field schema: https://wiki.openfoodfacts.org/Data
- Drift current version + FTS5 recipe: https://drift.simonbinder.eu
- flutter_appauth + Keycloak integration guide
- Play Asset Delivery 2025 size limits
- iOS on-demand resources current guidance
- App Store Review Guideline 4.8 (social sign-in / Sign in with Apple)
- mobile_scanner package current status: pub.dev
- HLC reference: Kulkarni et al. 2014
