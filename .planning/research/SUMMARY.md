# Project Research Summary

**Project:** CO₂ Diet
**Domain:** Flutter offline-first, privacy-first nutrition + CO₂ footprint tracking mobile app (iOS + Android, EU/German launch market)
**Researched:** 2026-07-16
**Confidence:** MEDIUM

> **Research environment caveat:** External research tools (WebSearch, WebFetch) were denied during the four parallel research sessions. All findings draw from training-data knowledge through January 2026. Version numbers, competitor market data, and legal specifics (GDPR, Apple/Google policies) should be spot-verified with primary sources before locking scope. Confidence is marked per-area.

---

## Executive Summary

CO₂ Diet sits at the intersection of two categories: a **mature, crowded nutrition-tracker market** (dominated by MyFitnessPal, Yazio, Cronometer, Lifesum — all freemium, all tracker-heavy) and an **early, fragmented CO₂-tracker market** (Klimato B2B, Evocco defunct, My Emissions web-first — no dominant consumer player). The strategic wedge is unambiguous: **win on logging speed (<10s), methodology transparency, and genuinely trackerless privacy** — not on out-featuring MFP on breadth.

The recommended technical approach is **Flutter 3.27+ / Riverpod (codegen) / Drift (SQLite) / Dio**, with a **local-first architecture**, a **hand-rolled outbox + hybrid-logical-clock sync engine** for optional Account Mode, and **tiered Open Food Facts data delivery** (bundled ~50MB starter → on-demand ~300–800MB full pack → live API fallback).

**The single most important override of PROJECT.md's tentative decisions: Hive → Drift.** Hive v2 is effectively unmaintained, cannot support FTS5 search over the 4.5M-product OFF catalog, and has a brittle schema-migration story that will bite a multi-year app.

The three highest-risk failure modes:
1. **Silent data loss** from sync-as-afterthought — mitigate with UUIDs/tombstones/HLC in schema v1
2. **CO₂ false precision** undermining scientific credibility — mitigate with rounding, confidence bands, and peer-reviewed methodology as a launch blocker
3. **Privacy-claim collapse** from a transitive third-party dependency — mitigate with CI dependency auditing + Exodus scans from the first commit

Two highest-leverage external investments: **Fachanwalt IT-Recht** (€1–3k, GDPR/TMG/Impressum) and **external LCA methodology peer review** (€2–5k, CO₂ credibility).

---

## Recommended Stack

**Core:**
- Flutter 3.27+ / Dart 3.6+ — single codebase, Impeller-mature
- **Drift (SQLite) `^2.20.0`** — replaces Hive; FTS5, explicit migrations, asset-bundleable
- **Riverpod (codegen) `^2.6.0`** — compile-time DI, native `AsyncValue<T>` for offline states
- **Dio `^5.7.0`** + `dio_smart_retry` + `connectivity_plus` + `internet_connection_checker_plus`
- **`openfoodfacts` `^3.20.0`** (official Dart client) + **`mobile_scanner` `^5.2.0`** (MLKit/AVFoundation)
- **`flutter_appauth` `^7.0.0`** + `flutter_secure_storage` — Keycloak OIDC via system browser
- **`workmanager` `^0.5.2`** — background sync (foreground-on-resume is the reliable primary path)
- **`flutter_local_notifications` `^17.2.0`** — 100% local, zero FCM/APNs
- `fl_chart`, `go_router`, `freezed`, `uuid` (v7 for offline-safe PKs)

**Explicitly rejected:** Hive/Isar (maintenance), Firebase/FCM/Crashlytics/Sentry (privacy), `google_fonts` runtime download (bundle fonts as assets instead), `qr_code_scanner`/`flutter_barcode_scanner` (unmaintained), passkeys (Flutter ecosystem too nascent — defer to v1.1).

**Full detail:** `.planning/research/STACK.md`

---

## Expected Features

**Table stakes (must have or users leave):**
- Onboarding quiz → auto-calculated calorie/macro/CO₂ target (Mifflin-St Jeor + activity factor)
- Meal buckets + food search typeahead (<1s) + barcode scanning + portion units (g/ml/cups/pieces)
- Recent + Favorites + Custom foods (personal overrides never mutate originals)
- Daily dashboard: consumed vs target for calories, macros, and CO₂
- Weight logging + trend chart, meal reminders (local, opt-in)
- Offline access to full log history
- Data export (CSV/JSON) + within-app account deletion (App Store rule + GDPR)

**Differentiators (where CO₂ Diet wins):**
- Combined per-meal + daily CO₂e footprint alongside calories (**unoccupied market position**)
- Transparent CO₂ methodology screen with sources, ranges not false precision (**trust wedge**)
- Zero third-party SDKs (verifiable via Exodus — publish result in-app)
- Local Mode fully functional, zero account (equal visual weight — reject live-build bias toward "Recommended" badge)
- Non-judgmental "Improvement Opportunities" with quantified CO₂ delta
- Open source (auditable privacy claims; F-Droid eligibility)

**Defer to v1.1+:** sync/Account Mode, water tracking, CO₂ profile modifiers UI, passkeys, 30-day/annual insights, recipes, meal planning, wearables, AI photo recognition.

**Never ship:** third-party SDKs, streak-shame, dark-pattern account nudging, false-precision CO₂, GitHub sign-in (wrong audience), behavioral push notifications.

**Full detail:** `.planning/research/FEATURES.md`

---

## Architecture Approach

Clean-layered: **UI → Riverpod Presentation → Application (Use Cases) → Domain (pure Dart) → Data (Drift + Dio)**. One-directional dependency — UI never imports Drift, Dio, or I/O packages.

Key structural decisions:
- **Drift schema v1 must include HLC columns, dirty flags, tombstones, `co2_methodology_version`, and consent fields from day one** — even for Local Mode. Cannot be retrofitted without data loss.
- **Separate `off_reference.sqlite` asset** (attached via `ATTACH DATABASE`) for read-only OFF catalog — decouples user data lifecycle from reference data updates.
- **CO₂ Estimator is pure-Dart on-device** — deterministic, offline, auditable. Stores both `co2_g_estimated` and `co2_g_authoritative` with methodology version per row.
- **Sync: outbox + Hybrid Logical Clock**, LWW per record. No CRDTs needed for personal-tracking data.
- **Auth: `flutter_appauth` OIDC + PKCE** via system browser; refresh token in secure storage, access token in memory only; Apple mandatory on iOS (App Store Guideline 4.8).

**Feature module rule:** `features/*` never import each other; cross-feature via domain events or core router.

**Build order:**
```
Phase 1: Foundations (sync-safe schema, DI, router, theme, HLC, CI audit)
Phase 2: Food Catalog & Search (highest risk — OFF FTS5, barcode, CO₂ factor table)
Phase 3: Full Local App (meal logging, insights, weight, export/backup)
Phase 4: Legal, Onboarding Polish, Pre-Submission
Phase 5: Keycloak Auth + Sync (Account Mode)
Phase 6: Reference Data Delivery & Post-Launch
```

Auth+Sync is deliberately late — Local Mode is the product; Account Mode is the enhancement.

**Full detail:** `.planning/research/ARCHITECTURE.md`

---

## Critical Pitfalls

| # | Pitfall | Impact | Prevention | Phase |
|---|---------|--------|------------|-------|
| C1 | Sync-as-afterthought → silent data loss | Rewrite | UUID v7 PKs, HLC columns, tombstones in schema v1 | P1 |
| C2 | Hive schema migration → data loss on cold start | Forced reinstall | Choose Drift, first-class migrations | P1 |
| C3 | CO₂ false precision → credibility collapse / EU Directive exposure | Viral PR, legal | Round to 1-2 sig figs, confidence bands, methodology versioning, LCA peer review (€2-5k) | P2–P4 |
| C4 | Transitive dependency breaks privacy claim | Trust collapse | CI blocklist audit + Exodus scan on every release from commit 1 | P1 |
| C5 | GDPR consent invalid (pre-checked boxes, bundled consents, no version records) | BfDI fine up to €20M/4% | Separate checkboxes, `consent_records` with timestamp + app + policy version, Fachanwalt review (€1-3k) | P1, P4 |
| C6 | App Store rejection on health/ED grounds | Launch block | ED safety nets (calorie floor 1200, BMI floor 17.5 + helpline), avoid "diagnose/treat/cure/medical" | P4 |
| C7 | Backend deletion cascade not designed in | GDPR non-compliance | `user_id` FK on all user tables, `DELETE /me/account` endpoint from v1, Keycloak user deletion in same flow | P1, P5 |

**Full detail (plus 10 moderate + 10 minor pitfalls with detection signals):** `.planning/research/PITFALLS.md`

---

## Roadmap Implications

**Suggested phases: 6**

1. **Foundations & Local Vertical Slice** — sync-safe Drift schema, consent recording, CO₂ methodology versioning, CI dependency-audit pipeline, DI/router/theme, thinnest E2E vertical (add food → dashboard shows CO₂).
2. **Food Catalog, Search & Barcode** *(highest technical risk)* — OFF ingest + FTS5 benchmarked on low-end Android, bundled starter seed, OFF API fallback, mobile_scanner barcode flow, product-to-CO₂ mapping prototype.
3. **Full Local App** — complete meal logging (Recent/Favorites/Custom), CO₂ Estimator + Transparency screen, Insights + Improvement Opportunities, Weight tracking, notifications, Export/Backup. **Local Mode is shippable here.**
4. **Legal, Onboarding Polish & Pre-Submission** — Legal Consent flow (timestamped records), Legal Hub, ED safety nets, PrivacyManifest, Data Safety form, Fachanwalt review, LCA peer review, accessibility audit, equal-weight Mode Choice card audit.
5. **Keycloak Auth + Sync** — `flutter_appauth` OIDC, Apple/Google IdPs, outbox drainer + delta pull + LWW-by-HLC, Local→Account upgrade, GDPR endpoints, sync status UI.
6. **Reference Data Delivery & Post-Launch** — on-demand full OFF pack via CDN, delta refresh, water tracking, CO₂ profile modifiers, advanced insights, wearable/Health integration, recipes.

**Principle:** Local Mode ships at Phase 3. Account Mode (Phase 5) is a pure enhancement — never a prerequisite.

---

## Research Flags by Phase

| Phase | Needs Verification |
|-------|--------------------|
| P2 | OFF export current size (wiki.openfoodfacts.org/Data), FTS5 benchmark on Pixel 6a / Samsung A54, `mobile_scanner` iOS 17+/Android 14+ behavior, Play Asset Delivery 2025 limits |
| P3 | Poore & Nemecek 2018 vs newer LCA meta-analyses, Agribalyse 3.1 current version |
| P4 | GDPR Art. 8 age of consent in Germany, App Store Guidelines 1.4.1/5.1.1/4.8 current text, `PrivacyInfo.xcprivacy` requirements, Fachanwalt + LCA reviewer sourcing |
| P5 | Keycloak `offline_access` defaults (coordinate with Tomris), `flutter_appauth` current maintenance, `workmanager` iOS 18/Android 15 behavior, Apple Sign in with Apple mandate |
| P6 | Play Asset Delivery vs CDN trade-offs, PowerSync spike for v2 |

**Standard patterns (lighter research burden):** P1 (Drift + Riverpod scaffolding), P3 subset (`fl_chart`, `flutter_local_notifications`, `csv`/`archive`/`share_plus`).

---

## Open Decisions (from PROJECT.md — still unresolved)

| Decision | Research Recommendation |
|----------|------------------------|
| Hive vs. local DB | **Drift** — Hive v2 unmaintained, no FTS5 |
| GitHub sign-in | **Drop for v1** — wrong audience, conflicts with privacy positioning |
| Passkeys | **Defer to v1.1+** — Flutter ecosystem not mature as of Jan 2026 |
| 16+ age gate mechanism | **Self-declaration checkbox** — lightest touch, lowest onboarding friction |
| Mode Choice card visual weighting | **Equal weight** is correct (design intent); audit live-build bias in Phase 4 |
| Weight tracking placement | Resolve in Phase 3 — suggestion: Insights tab shortcut + Settings native |

---

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | MEDIUM | Package selection HIGH; versions MEDIUM — verify with `flutter pub outdated` |
| Features | MEDIUM | Table stakes/anti-features HIGH; current competitor market state MEDIUM |
| Architecture | HIGH | Clean-layered Drift + Riverpod + outbox+HLC is textbook; OFF data delivery sizing needs empirical verification |
| Pitfalls | MEDIUM | Legal/store specifics need lawyer + current docs; development pitfalls HIGH |

---

*Research completed: 2026-07-16*
*Ready for requirements definition: yes*
