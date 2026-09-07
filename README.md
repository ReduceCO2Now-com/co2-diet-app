# CO₂ Diet

A privacy-first, offline-first Flutter app (iOS + Android) for tracking what you eat **and**
what it costs the planet — calories, protein, macros, and the estimated CO₂e footprint of your
food, in one place.

Free, no ads, no analytics, no behavioural profiling. Your meals, weight, and profile stay on
your device by default; an account is optional and adds nothing the app needs to function.

**Core promise:** log a meal in under 10 seconds, with no network.

---

## Contents

- [The two modes](#the-two-modes)
- [What the app does](#what-the-app-does)
- [Getting started](#getting-started)
- [Architecture](#architecture)
- [Where the food data comes from](#where-the-food-data-comes-from)
- [How CO₂ is estimated](#how-co-is-estimated)
- [Privacy, enforced in CI](#privacy-enforced-in-ci)
- [Testing](#testing)
- [Project status](#project-status)
- [Further documentation](#further-documentation)

---

## The two modes

This distinction drives most of the architecture, so it comes first.

**Local Mode** is the product. No account, no server, no network required. Every core flow —
dashboard, search, logging, insights, weight, export — works fully offline against an on-device
SQLite database. Nothing is attributed to a person because there is no person record.

**Account Mode** is an enhancement. It exists for sign-in and GDPR account deletion, and it
never becomes a prerequisite for using the app. Auth is Keycloak OIDC + PKCE through the system
browser (`flutter_appauth`); the refresh token lives in the platform Keychain/Keystore.

> Firebase and Supabase are explicitly rejected — self-hosted stack only. This is a product
> constraint, not a preference, and CI enforces the SDK half of it (see
> [Privacy, enforced in CI](#privacy-enforced-in-ci)).

---

## What the app does

**Food logging** — the heart of it. Search the local catalog (SQLite FTS5, sub-second) with an
Open Food Facts API fallback when the local pack misses. Scan a barcode with the camera. Add to
Breakfast / Lunch / Dinner / Snack with portions in g, ml, cups, pieces, or servings. Reuse from
Recent and Favourites. Create your own foods, and override existing ones without ever mutating
the original record.

**Nutrition and CO₂** — per meal and per day: calories, protein, carbs, fat, sugar, fibre,
sodium, and CO₂e. The dashboard shows consumed against target, macro split, footprint, and a
7-day trend; every metric is tappable through to a Data Analysis screen for that metric.

**Insights** — today's breakdown by meal, ranked contributors, goal comparison, 7/30-day trends,
and Improvement Opportunities that suggest lower-CO₂ alternatives with the delta quantified.
Wording is deliberately non-judgemental, and an ED safety-net checker sits in front of the
weight and target flows.

**Weight** — entries in kg or lb, history, and an interactive chart across 7d / 30d / 90d / 1yr /
all, with an optional target weight and date.

**Your data is yours** — export to CSV, Excel, or JSON by category; backup and restore through
the OS share sheet and document picker; permanent account deletion; a Legal Hub with Terms,
Privacy Policy, Health Disclaimer and Impressum, each reachable within two taps, and a consent
history recording what you accepted, when, and against which policy and app version.

**Reminders** — optional local notifications for meal slots and weigh-ins. Nothing is pushed
from a server.

---

## Getting started

**Prerequisites**

| | |
|---|---|
| Flutter | 3.44.6 (pinned — CI uses this exact version) |
| Dart | ≥ 3.12.2 |
| Xcode | for iOS; Android Studio / SDK for Android |

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

The code generation step is not optional. Riverpod providers (`*.g.dart`), Drift DAOs and the
database class, Freezed entities, and the go_router config are all generated — the project will
not compile from a clean checkout without it.

**Running the checks CI runs**

```bash
dart run scripts/check_privacy_deps.dart pubspec.lock .privacy-blocklist.yaml
flutter analyze
flutter test
```

**If an iOS build fails at codesign** with `resource fork, Finder information, or similar
detritus not allowed`, clear macOS extended attributes from the SDK — the same workaround the
iOS CI job applies:

```bash
xattr -cr "$(dirname "$(dirname "$(which flutter)")")"
```

**A note on the food database.** The bundled `assets/off_reference.sqlite.gz` is decompressed to
the app documents directory on first launch. Its absence is handled, not fatal — `main()` catches
the failure and the app runs without the local catalog, falling back to the OFF API. If you see
`off_reference.sqlite not available` in the debug console on a fresh clone, that is why.

---

## Architecture

Clean architecture in three layers, with dependencies pointing inward only. `domain/` knows
nothing about Drift, HTTP, or Flutter widgets.

```
lib/
├── main.dart          bootstrap: OFF user-agent, first-launch DB extraction,
│                      notifications, SharedPreferences preload, ProviderScope
├── app.dart           root widget; app-lifecycle hooks for reminder re-arming
│                      and throttled reference-pack update checks
├── core/
│   ├── di/            Riverpod providers, grouped by feature area
│   ├── router/        go_router config + the onboarding redirect guard
│   ├── theme/         colour, spacing and text tokens
│   ├── sync/          hybrid logical clock
│   └── widgets/       cross-feature widgets (ED safety-net dialog)
├── data/
│   ├── local/         Drift database, DAOs, tables, migrations, reference pack
│   ├── remote/        Open Food Facts and reference-pack API clients
│   └── repositories/  repository implementations
├── domain/
│   ├── entities/      Freezed value types
│   ├── repositories/  abstract interfaces (the i_*.dart files)
│   └── services/      pure business logic — CO₂, targets, calculators, config
└── features/          one folder per feature: screens/, widgets/, providers/
```

| Concern | Choice |
|---|---|
| State management | Riverpod 3 with `riverpod_generator` |
| Local database | Drift over SQLite, with FTS5 for food search |
| Navigation | go_router 17, `StatefulShellRoute.indexedStack` |
| Value types | Freezed |
| Lints | `very_good_analysis` |

**The schema is sync-safe from v1.** UUID v7 primary keys, hybrid-logical-clock columns, `dirty`
flags, tombstones for deletes, and a `co2_methodology_version` stamped on every CO₂-bearing row —
all present before any sync engine exists. That was deliberate: it cannot be retrofitted onto
rows users have already created.

**Navigation has one enforcement point.** A single top-level `redirect` in `app_router.dart` runs
on every navigation attempt, including the initial location, so legal consent cannot be skipped
by a crafted deep link. Every deep link that takes a query parameter falls back to a safe default
rather than crashing on a malformed one. Three bottom-nav branches — Profile, Dashboard,
Settings — with the bar hidden until onboarding completes.

**There is no background scheduler.** Long-interval weigh-in reminders and reference-pack update
checks are re-armed on `AppLifecycleState.resumed`. `flutter_local_notifications` has no
long-interval recurrence primitive, so the app schedules only the next occurrence and refreshes
it whenever the app comes to the foreground. The two checks are deliberate siblings, not nested,
so neither can short-circuit the other.

---

## Where the food data comes from

**Open Food Facts** is the primary source, with **USDA FoodData Central** secondary. Bulk data is
ingested from OFF's exports rather than crawled — the live API is reserved for the
barcode-miss path and carries a custom User-Agent, configured once in `main()` before any search.

The ingestion pipeline lives in `tools/` (`ingest_off.py`,
`build_reference_pack_release.py`) and produces the bundled starter pack.

**Reference packs.** The app ships a small core catalog and can pull the full OFF pack
(~300–800 MB) on demand over CDN, with delta refresh afterwards. That path is built for hostile
conditions: SHA-256 verification before the download is ever trusted, a free-disk-space
preflight, Range-header resume through native background download (iOS URLSession / Android
WorkManager), and a deliberate distinction between *cancel* (delete the partial file) and
*interrupted* (keep it for resume).

> The CDN URL in `ReferencePackConfig` is a placeholder. CDN hosting has no owner yet — see
> `docs/data-contracts/reference-pack-manifest.md`.

---

## How CO₂ is estimated

It is an **estimate**, and the app says so everywhere it shows a number.

Every figure carries a confidence level and the methodology version that produced it, and the
Estimate Transparency panel explains how it was derived. Estimates are stamped with their
methodology version at write time, so a later methodology change never silently rewrites history —
it announces itself.

Two things are kept apart on purpose:

- **Product-level** — the food itself: category factor × mass, adjusted for origin, production,
  transport and processing.
- **Context-level** — your circumstances: cooking method, storage, household size, retail
  channel, location. These are applied **once** at daily aggregation, never per item, because
  applying them per food would double-count them.

Context factors live in CO₂ Calculation Settings rather than Profile Setup — they are optional
and advanced, and onboarding stays light.

Full method: `docs/CO2_METHODOLOGY.md`.

---

## Privacy, enforced in CI

The privacy claim is not a promise in a README — it fails the build.

`.privacy-blocklist.yaml` lists banned package-name prefixes. `scripts/check_privacy_deps.dart`
audits `pubspec.lock` on every push and pull request, and any match — direct or transitive —
fails CI:

```
firebase_    crashlytics   amplitude_   mixpanel_   sentry_
segment_     datadog_      onesignal_   appsflyer_  adjust_
braze_       clevertap     leanplum     moengage
```

Changing that list requires a pull request, so the change is auditable in git history.

Alongside it: no meal, weight, or profile data leaves the device in Local Mode; consent is
recorded with timestamp, app version and policy version; and export, deletion and portability are
built in for GDPR.

---

## Testing

97 test files, ~19,800 lines, plus an `integration_test/` suite. CI runs analyze, the privacy
audit, the full test suite, and a debug APK build on Android, with a no-codesign iOS build in
parallel.

```bash
flutter test                                    # unit + widget
flutter test integration_test                   # on a device or simulator
```

---

## Project status

Pre-release. Local Mode is feature-complete and shippable; Account Mode ships login and account
deletion only.

| Phase | Status |
|---|---|
| 1. Foundations & sync-safe schema | Complete |
| 2. Food catalog ingest & search | Complete |
| 3. Barcode scanning & CO₂ factor table | Complete |
| 4. Meal logging core | In progress |
| 5. Full local app — **Local Mode shippable** | Complete |
| 6. Onboarding, legal & pre-submission | In progress |
| 7. Keycloak auth + account deletion | Complete |
| 8. Encrypted account backup | Contingent — blocked on a backend decision |
| 9. Reference data delivery (full OFF pack) | Complete |
| 10. Post-launch enhancements | Deferred to v1.1+ |

**Known open items.** Every value in `KeycloakConfig`, `BackendConfig` and `ReferencePackConfig`
is a placeholder pending the real Keycloak realm export and a deployed backend URL — each is
isolated to a single file so the handoff is a one-file change. The backend contract in
`docs/backend-contracts/gdpr-account-deletion.md` is a written proposal awaiting confirmation,
not an agreed API. Phase 8 has no actionable content until the backend's
encrypted-blob-versus-user-cloud-export question is resolved.

---

## Further documentation

| Document | What it covers |
|---|---|
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | Layer rules, data flow, key patterns |
| [`docs/CONTRIBUTING.md`](docs/CONTRIBUTING.md) | Setup, codegen, conventions, PR expectations |
| [`docs/CO2_METHODOLOGY.md`](docs/CO2_METHODOLOGY.md) | How the footprint is calculated |
| [`docs/design/DESIGN.md`](docs/design/DESIGN.md) | Design system and tokens |
| [`docs/backend-contracts/`](docs/backend-contracts/) | Proposed backend API contracts |
| [`docs/data-contracts/`](docs/data-contracts/) | Reference-pack manifest format |
| [`docs/legal/`](docs/legal/) | Terms, Privacy, Health Disclaimer, Impressum |
| `.planning/` | Requirements, roadmap and phase-by-phase delivery history |

**Team.** Flutter — Ali. Backend (Spring Boot / PostgreSQL / Keycloak) — Tomris, a separate
workstream. Design — Lydia, Ilke, Neetha, Dilosi.

Package name `com.reduceco2now.co2diet`.
