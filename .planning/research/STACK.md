# Technology Stack — CO₂ Diet (Flutter Mobile App)

**Project:** CO₂ Diet — offline-first, privacy-first nutrition + CO₂ tracker (iOS + Android)
**Researched:** 2026-07-16
**Researcher:** research-project agent (Claude)
**Overall confidence:** MEDIUM (see caveat below)

---

## ⚠ Research Environment Caveat

External research tools (WebSearch, WebFetch, Context7 MCP, ctx7 CLI) were **denied** in this session. Every recommendation below is drawn from **training-data knowledge (cutoff January 2026)** and cross-checked only against the assistant's internal knowledge of well-established Flutter ecosystem trends through Q4 2025.

**Consequence for downstream use:**
- Every version number below MUST be verified with `flutter pub outdated` or `pub.dev` before adoption.
- Every package marked HIGH confidence is drawn from strong, widely-corroborated ecosystem signals through late 2025 — but no live source was consulted this session.
- Every package marked MEDIUM or LOW confidence should be re-researched during the phase that introduces it.

Assume all version numbers are **"as of Q4 2025 / January 2026"** and treat them as lower bounds.

---

## Recommended Stack

### Core Framework

| Technology | Version (as of Jan 2026) | Purpose | Why | Confidence |
|------------|--------------------------|---------|-----|------------|
| Flutter SDK | `>=3.27.0 <4.0.0` (stable channel) | Cross-platform UI framework | Already decided in PROJECT.md. Flutter 3.27+ ships Impeller on both iOS/Android with mature 60/120 fps performance; single codebase for iOS + Android reduces sole-developer overhead. | HIGH |
| Dart | `>=3.6.0 <4.0.0` | Language | Ships with Flutter; sound null safety, pattern matching, records, and sealed classes are all needed for the state modelling below. | HIGH |

**Target minimum OS:**
- iOS: 13.0 (Flutter 3.27+ baseline; also required by `mobile_scanner`)
- Android: API 21 (Lollipop) — matches Flutter default; bump to API 23 if any biometric/passkey libraries require it.

---

### Local Database — **Drift (recommended)**

| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| `drift` | `^2.20.0` | Reactive SQLite ORM | Primary local store for meals, foods, weight entries, custom foods, sync queue. |
| `drift_flutter` | `^0.2.0` | Flutter integration + native SQLite bundling | Handles native lib setup on iOS/Android; recommended companion. |
| `drift_dev` | `^2.20.0` (dev) | Code generator for tables/DAOs | Compile-time SQL validation. |
| `sqlite3_flutter_libs` | `^0.5.0` | Bundled SQLite binaries | Ensures modern SQLite version on both platforms; avoids Android's stale system SQLite. |
| `build_runner` | `^2.4.0` (dev) | Runs codegen | Standard toolchain. |

**Confidence: HIGH.**

#### Why Drift over the alternatives

| Option | Verdict | Rationale |
|--------|---------|-----------|
| **Drift** ✅ | **Recommended** | Actively maintained (Simon Binder); built on SQLite (universally understood, 20+ year track record); reactive streams built in; strong typing via codegen; **full-text search (FTS5) is critical for the 4.5M-item Open Food Facts search catalog**; queryable JOINs across foods/meals/nutrition are natural in SQL; PostgreSQL parity with the Spring Boot backend simplifies mental model and schema migration reasoning. |
| **Isar** ❌ | **Reject** | Original v3 project has been effectively unmaintained since 2023; a community fork (`isar_community`) exists but adoption is fragmented, and v4 was still in unstable/beta state at the last widely-known signal. **High risk to bet a 5-year app on it.** |
| **ObjectBox** ⚠ | Alternative | Excellent performance, native sync product available. **However:** proprietary binary, licensing is BSL (not OSI-approved) for the sync piece, and the CO₂ Diet project explicitly requires MIT/Apache 2.0 open source. Also weaker at ad-hoc queries vs. SQL. |
| **Hive (v2)** ❌ | **Reject as primary store** | Original Hive v2 is effectively unmaintained; author moved to Isar which is itself now unmaintained. **PROJECT.md mentions Hive as a candidate — this is legacy thinking and should be revisited.** No relational queries; every JOIN is manual Dart code; poor fit for 4.5M-row food catalog. |
| **hive_ce** (Hive Community Edition) | ⚠ Acceptable for KV only | Community fork is actively maintained. Fine for tiny key-value use cases (settings, cache), **not** for the primary data store. |
| **sqflite** | ⚠ Downgrade | Works, but no codegen, no reactive queries, verbose boilerplate. Drift is strictly better. |

**Rejection of PROJECT.md's "Hive" tentative decision:** The current Flutter ecosystem consensus (through late 2025) is that Hive v2 is a maintenance hazard for a multi-year app. Recommend an explicit re-decision in favour of Drift. If a small KV cache is needed on top, use `shared_preferences` or `hive_ce` — not the abandoned `hive`.

---

### Secondary Storage & Secrets

| Library | Version | Purpose | Why |
|---------|---------|---------|-----|
| `flutter_secure_storage` | `^9.2.0` | Encrypted key-value (Keychain / EncryptedSharedPreferences) | Store auth tokens, Keycloak refresh tokens, passkey credential IDs. **Do NOT store tokens in Drift or SharedPreferences.** |
| `shared_preferences` | `^2.3.0` | Simple settings (theme, units, locale) | Ships-with-Flutter feel; non-sensitive only. |
| `path_provider` | `^2.1.0` | Locate app documents dir | Required by Drift, backup/restore, and export flows. |

**Confidence: HIGH.**

---

### State Management — **Riverpod (recommended)**

| Technology | Version | Purpose |
|------------|---------|---------|
| `flutter_riverpod` | `^2.6.0` | Reactive state + DI container |
| `riverpod_annotation` | `^2.6.0` | Codegen annotations (`@riverpod`) |
| `riverpod_generator` | `^2.6.0` (dev) | Codegen |
| `riverpod_lint` | `^2.6.0` (dev) | Riverpod-specific lint rules — catches provider misuse at compile time |
| `custom_lint` | `^0.7.0` (dev) | Required host for `riverpod_lint` |

**Confidence: HIGH.**

#### Why Riverpod over BLoC / Provider

| Option | Verdict | Rationale |
|--------|---------|-----------|
| **Riverpod (v2, codegen)** ✅ | **Recommended** | Compile-time safety (no runtime `ProviderNotFoundException`), testable without a `BuildContext`, first-class async (`AsyncValue<T>`) which maps perfectly onto offline-first "loading / data / error / stale-cached" states, granular auto-dispose which matters for a memory-conscious mobile app, and `Notifier` / `AsyncNotifier` classes give a natural home for the sync queue orchestrator. Lower boilerplate than BLoC — important for a **sole developer**. |
| **BLoC** ⚠ | Alternative | Excellent for large teams needing rigid event/state contracts. For a single developer, the event/state ceremony (event class → mapEventToState → state class per screen) roughly doubles the code volume vs. Riverpod. Recommend against unless Ali has strong personal preference. |
| **Provider** ❌ | **Reject** | Provider is on soft-maintenance mode (its author, Remi Rousselet, wrote Riverpod as the successor and recommends new projects use Riverpod). Riverpod is a superset of what Provider offers. |
| **GetX** ❌ | **Reject** | Popularity is inversely correlated with community-code-review reputation. Encourages tight coupling of routing + state + DI; hard to test in isolation; frequent breaking changes without deprecation cycles. Not appropriate for a 5-year privacy-critical app. |
| **setState only** ❌ | **Reject** | Fine for prototypes; will not scale to 16 screens with cross-screen state (daily totals, sync status, auth). |

#### Riverpod usage pattern for this app

- **`@riverpod` code-gen syntax** (not the legacy `Provider.autoDispose` manual syntax) — this is the mainline path going forward.
- One `AsyncNotifier` per bounded context: `foodLogNotifier`, `weightNotifier`, `syncQueueNotifier`, `authNotifier`.
- Repository layer sits between Notifiers and Drift/HTTP — never call Drift from a widget.

---

### HTTP & Networking

| Library | Version | Purpose | Why |
|---------|---------|---------|-----|
| `dio` | `^5.7.0` | HTTP client for Open Food Facts + Spring Boot backend | Interceptors (auth token refresh, retry, offline queueing), FormData, cancellation tokens, better ergonomics than `http` for a real app. |
| `dio_smart_retry` | `^7.0.0` | Automatic retry with backoff | Critical for flaky mobile networks + sync flows. |
| `pretty_dio_logger` | `^1.4.0` (dev-only) | Readable request/response logs | Debug builds only; strip from release. |
| `connectivity_plus` | `^6.0.0` | Detect online/offline transitions | Triggers sync queue drain when network returns; drives "You are offline" UI banner. |
| `internet_connection_checker_plus` | `^2.5.0` | Actual reachability check (not just "wifi radio on") | Wi-Fi captive portals, airplane mode with saved Wi-Fi, etc. — `connectivity_plus` alone reports false positives. |

**Confidence: HIGH.**

**Do NOT use** the bare `http` package for this app — no interceptors means you'll reinvent auth-refresh and retry logic. **Do NOT use** `chopper` — Dio has won the mindshare battle and has a wider plugin ecosystem.

---

### Offline Sync — **Custom outbox + Drift + Dio (recommended architecture)**

There is **no de-facto "just add a package" sync framework** for arbitrary Flutter ↔ Spring Boot setups. The mainstream, well-understood approach is a hand-rolled outbox pattern layered on the primitives you already have.

**Architectural pattern: Local-first with outbox + last-write-wins-per-field.**

| Component | Package | Notes |
|-----------|---------|-------|
| Local mutations table (outbox) | Drift table `sync_queue` | Every user-initiated write (add meal, edit weight, delete food) inserts a row: `{id, entity_type, entity_id, op, payload_json, created_at, attempts, last_error}`. |
| Background drainer | `workmanager` + `connectivity_plus` | Drainer wakes when the network returns or on periodic schedule. |
| Conflict resolution | Backend authoritative on catalog (foods, CO₂ data); per-field LWW with server-side `updated_at` on user data (meals, weight). | Encode `client_updated_at` and `client_id` on every mutation for observability. |
| Idempotency | UUID v7 client-generated IDs | Client generates the primary key so retries are safe. `uuid: ^4.5.0` |
| Sync cursor | `sync_cursor` KV row per entity type | Backend exposes `GET /meals?since=<cursor>` — client persists the cursor per user. |
| Delta encoding | JSON patches for updates | Reduces bandwidth on slow connections; not strictly required for v1. |

**Explicitly rejected sync approaches:**

| Approach | Why not |
|----------|---------|
| **PowerSync / Turso Sync / ElectricSQL** | All excellent CRDT/logical-replication products, but they require a Postgres logical-replication publisher or their own cloud plane; adds infra Tomris (backend dev) hasn't scoped. Reconsider for v2 if scaling demands it. |
| **Firebase / Firestore sync** | Explicitly rejected in PROJECT.md. |
| **CouchDB / PouchDB-style CRDT** | Overkill; no need for multi-device offline collaboration on the same account. |
| **Naïve "just POST on save"** | Fails as soon as the user is offline — which is the entire point of this app. |

**Confidence: HIGH (pattern), MEDIUM (specific package versions).**

---

### Open Food Facts Integration

| Library | Version | Purpose | Why |
|---------|---------|---------|-----|
| `openfoodfacts` | `^3.20.0` | Official OFF Dart client, maintained by the Open Food Facts foundation | First-party, actively maintained; covers product search, barcode lookup, taxonomies, and image upload. Do not roll your own OFF client — the API has many undocumented quirks the package already handles. |

**Confidence: HIGH.**

**Integration pattern:**
1. **Barcode scan or search** → check local Drift `foods` table first (offline-first) → miss → call `openfoodfacts` → **cache the result into Drift** so next scan is instant/offline.
2. **Set User-Agent properly.** OFF requires a descriptive `User-Agent: CO2Diet/1.0 (contact@reduceco2now.com)` — they will rate-limit or block generic agents. Configure this once in the `OpenFoodAPIConfiguration`.
3. **Product images**: cache-on-write to local file system via `path_provider`; use `cached_network_image` for the online fallback.
4. **CO₂ enrichment layer**: OFF has `ecoscore`/`green-score` data but coverage is patchy. Plan for a **CO₂ Diet-owned enrichment table** (shipped with app + updated via backend) that overlays OFF products with your curated `co2_per_kg` values keyed by `barcode` or `off_id`.
5. **Rate limiting**: OFF search API is throttled; batch/debounce user typing (300–500 ms) before firing search.
6. **License compliance**: OFF data is ODbL 1.0 — attribution required in-app on any screen displaying OFF data (typically the Insights/About screen). This is a **legal requirement**, not a courtesy.

**Do NOT use** unofficial forks (`openfoodfacts_dart` etc.) — the first-party `openfoodfacts` package is the correct choice.

---

### Barcode Scanning — **mobile_scanner (recommended)**

| Library | Version | Purpose |
|---------|---------|---------|
| `mobile_scanner` | `^5.2.0` | Camera-based barcode scanner using MLKit (Android) / AVFoundation (iOS) |

**Confidence: HIGH.**

#### Why mobile_scanner over alternatives

| Option | Verdict | Rationale |
|--------|---------|-----------|
| **mobile_scanner** ✅ | **Recommended** | Actively maintained by the Julian Finkler / community fork of the original; uses Google MLKit (Android) and native AVFoundation (iOS); supports EAN-13 / EAN-8 / UPC-A which is 99% of packaged food; **no native lib version conflicts** with modern Gradle/Xcode. Ships an easy `MobileScanner(onDetect: ...)` widget. |
| **flutter_barcode_scanner** ❌ | **Reject** | Effectively unmaintained (author archived); does not build on modern Android Gradle Plugin without patches; iOS 17+ camera permission changes are not handled. |
| **qr_code_scanner** ❌ | **Reject** | Same maintenance issue; deprecated in favour of mobile_scanner by its own community. |
| **flutter_zebra_scanner / bluetooth scanners** | N/A | Only relevant for retail hardware; irrelevant here. |

**Gotchas to plan for:**
- iOS: `Info.plist` must declare `NSCameraUsageDescription` with a **user-facing** reason ("CO₂ Diet uses your camera to scan food barcodes.") or App Store review will reject.
- Android: Manifest requires `<uses-permission android:name="android.permission.CAMERA" />` and `<uses-feature android:name="android.hardware.camera" android:required="false"/>` (mark not required so tablets without a camera can still install).
- Handle "permission denied permanently" — deep-link to Settings using `permission_handler`.
- Torch/flashlight control: `mobile_scanner` exposes it; expose in UI for low-light supermarket scanning.

**Supporting package:**

| Library | Version | Purpose |
|---------|---------|---------|
| `permission_handler` | `^11.3.0` | Runtime permission requests (camera, notifications) |

---

### Background Sync — **workmanager (recommended)**

| Library | Version | Purpose |
|---------|---------|---------|
| `workmanager` | `^0.5.2` (or the maintained fork `flutter_workmanager` if the original stalls) | Schedule background tasks on Android (WorkManager) + iOS (BGTaskScheduler) |

**Confidence: MEDIUM.** The Flutter background-execution ecosystem has been historically fragile; verify current maintenance status before committing.

#### Why workmanager

| Option | Verdict | Rationale |
|--------|---------|-----------|
| **workmanager** ✅ | **Recommended** | Only mainstream package that unifies Android `WorkManager` and iOS `BGTaskScheduler` under one Dart API. Handles constraints (charging, unmetered network) and periodic tasks. |
| **flutter_background_service** | ⚠ Alternative | Better for long-running foreground services (music, tracking) — overkill for a periodic sync drain. Uses a persistent notification on Android which is user-hostile for a nutrition app. |
| **android_alarm_manager_plus + Timer** | ❌ Reject | Alarm manager is not the right primitive for network-conditional periodic work; also more battery drain. |
| **iOS-only silent push wake** | Complementary | For account users, backend can send a silent APNs push to wake the app for sync. **Nice-to-have, not required for v1.** |

**Critical gotchas:**
- **iOS BGTaskScheduler is best-effort.** iOS decides when your task actually runs — could be minutes, could be hours. Design the sync to also drain aggressively when the app foregrounds.
- **iOS Info.plist** must declare `BGTaskSchedulerPermittedIdentifiers` with your task IDs.
- Sync must be **idempotent** because the same task may be scheduled twice.
- Battery: cap sync attempts; exponential backoff on repeated failures.

**Alternative primary strategy:** Foreground sync on app-resume + `connectivity_plus` listener is 80% of the value; treat `workmanager` as the enhancement for "app has been closed for 6 hours, user opened it once for a week." Do NOT overinvest in true background sync in v1.

---

### Notifications

| Library | Version | Purpose |
|---------|---------|---------|
| `flutter_local_notifications` | `^17.2.0` | Meal reminders, weigh-in reminders — 100% local, no push server |
| `timezone` | `^0.9.0` | Scheduling reminders across DST changes correctly |

**Confidence: HIGH.**

**Deliberately excluding** Firebase Cloud Messaging / OneSignal / any push service — PROJECT.md's privacy constraint forbids them. All notifications are locally scheduled.

---

### Authentication (Account Mode)

| Library | Version | Purpose |
|---------|---------|---------|
| `openid_client` | `^0.4.9` | Keycloak OIDC flows (auth code + PKCE) |
| `flutter_appauth` | `^7.0.0` | Alternative: system-browser OAuth via ASWebAuthenticationSession / Chrome Custom Tabs |
| `sign_in_with_apple` | `^6.1.0` | Apple Sign-In (mandatory on iOS if you offer Google sign-in) |
| `google_sign_in` | `^6.2.0` | Google Sign-In |
| **Passkeys** | See caveat | See below |

**Confidence: MEDIUM.**

#### Recommendation: `flutter_appauth` over raw `openid_client`

`flutter_appauth` uses the OS-provided secure browser (ASWebAuthenticationSession / Custom Tabs) which is what Apple/Google now require and what Keycloak documentation recommends. Store the resulting tokens in `flutter_secure_storage`.

#### Passkeys caveat

Passkey support in Flutter is nascent as of Jan 2026. The realistic options:
1. Wrap the platform APIs via Pigeon / method channels yourself (WebAuthn on iOS/Android via `ASAuthorizationController` / `CredentialManager`).
2. Use a package such as `passkeys` or similar — **verify current maintenance and completeness before committing**.

PROJECT.md marks passkey-first vs. password-first as an open decision. **Recommend: launch v1 with password + Apple/Google social, add passkey in v1.1 once the Flutter ecosystem is more mature.** Do not block the launch on passkey plumbing.

---

### Data Export / Backup / Restore

| Library | Version | Purpose |
|---------|---------|---------|
| `csv` | `^6.0.0` | CSV generation |
| `excel` | `^4.0.0` | XLSX generation |
| `archive` | `^3.6.0` | Zip up JSON + CSV + images into one backup file |
| `share_plus` | `^10.0.0` | Share sheet on iOS + Android |
| `file_picker` | `^8.1.0` | Pick backup file to restore |

**Confidence: HIGH.**

**Format recommendation:** primary export = a single `.zip` containing a `manifest.json` (schema version, export date, app version), one `.csv` per entity, and a `data.json` machine-readable dump. This satisfies GDPR portability + the "human-usable" export UX.

---

### Charts (Insights + Weight tracking)

| Library | Version | Purpose |
|---------|---------|---------|
| `fl_chart` | `^0.69.0` | Weight trend line, macro pie, CO₂ trend bar |

**Confidence: HIGH.** `fl_chart` is the mainstream mature choice. `syncfusion_flutter_charts` is more powerful but the free tier is community-edition-license and adds significant APK size — reject on size grounds for a lean app.

---

### Design System / UI

| Library | Version | Purpose |
|---------|---------|---------|
| `google_fonts` | `^6.2.0` | Plus Jakarta Sans + Inter | **Bundle the fonts locally** in `pubspec.yaml` `fonts:` instead of runtime download — PROJECT.md's privacy constraint forbids uncontrolled network calls. |
| `flutter_svg` | `^2.0.0` | SVG icons from the Stitch export |
| `go_router` | `^14.6.0` | Declarative routing, deep links (barcode → product → log flow), typed routes |
| `intl` | `^0.19.0` | Locale-aware number/date formatting (kg vs lb, kcal vs kJ, DD.MM vs MM/DD) |

**Confidence: HIGH.**

**On google_fonts**: The default runtime-download mode makes a network call to Google Fonts CDN on first launch — this violates the "no telemetry" constraint. **Add the .ttf files to `assets/fonts/` and register them in `pubspec.yaml`.** The `google_fonts` package will detect and use the local copy without any network call.

---

### Utilities & Domain Helpers

| Library | Version | Purpose |
|---------|---------|---------|
| `uuid` | `^4.5.0` | UUID v4/v7 for client-generated primary keys (offline write safety) |
| `freezed` | `^2.5.0` (dev) | Immutable data classes + sealed unions for `AsyncValue`-adjacent models |
| `freezed_annotation` | `^2.4.0` | Freezed annotations |
| `json_serializable` | `^6.8.0` (dev) | JSON codegen (Open Food Facts models, backend DTOs) |
| `json_annotation` | `^4.9.0` | JSON annotations |
| `equatable` | `^2.0.0` | If not using Freezed for a specific class, fallback for value equality |
| `logger` | `^2.4.0` | Structured logging (dev builds); wrap so release builds are no-ops |
| `sentry_flutter` | **REJECT for v1** | Consider carefully — Sentry ships crash reports to a third-party server. If used, self-host Sentry to remain compliant with the privacy constraint. **Default: no crash reporting service in v1.** Rely on Play Console / App Store Connect crash reports (aggregated, no PII). |

**Confidence: HIGH.**

---

### Testing

| Library | Version | Purpose |
|---------|---------|---------|
| `flutter_test` | (SDK) | Widget tests |
| `mocktail` | `^1.0.0` | Mocking (Riverpod-friendly; no codegen unlike `mockito`) |
| `integration_test` | (SDK) | End-to-end on real device/emulator |
| `patrol` | `^3.11.0` | Better integration test framework — can grant permissions, tap system dialogs, simulate offline |
| `drift` (in-memory) | (same as above) | `NativeDatabase.memory()` for fast repository tests without touching disk |
| `alchemist` or `golden_toolkit` | `^0.11.0` | Golden image tests for the 16 designed screens (Stitch parity) |
| `very_good_analysis` | `^6.0.0` (dev) | Strict lint rules |

**Confidence: HIGH.**

See TESTING notes in the Feature/Architecture docs (or below in Installation) for the offline-first test strategy.

---

## Alternatives Considered (summary matrix)

| Category | Recommended | Alternative(s) | Why Not the Alternative |
|----------|-------------|----------------|-------------------------|
| Local DB | Drift | Hive, Isar, ObjectBox, sqflite | Hive/Isar maintenance risk; ObjectBox license; sqflite no codegen |
| State mgmt | Riverpod (codegen) | BLoC, Provider, GetX | BLoC boilerplate too high for solo dev; Provider superseded; GetX quality concerns |
| HTTP | Dio | http, chopper | http lacks interceptors; chopper losing mindshare |
| Barcode | mobile_scanner | flutter_barcode_scanner, qr_code_scanner | Both unmaintained |
| OFF client | openfoodfacts | roll-your-own, forks | Official + maintained is strictly better |
| Background sync | workmanager | flutter_background_service, alarm_manager | Wrong primitives for periodic conditional sync |
| Notifications | flutter_local_notifications | FCM, OneSignal | Privacy constraint |
| Auth | flutter_appauth + Keycloak | Firebase Auth, Auth0, Supabase Auth | Privacy / self-host constraint |
| Charts | fl_chart | syncfusion, charts_flutter | Size + licensing |
| Routing | go_router | auto_route, Navigator 1.0 | go_router is the Flutter-team-recommended path |
| Modelling | freezed | manual + equatable | Sealed unions + copyWith too valuable |
| Testing mocks | mocktail | mockito | No codegen step, cleaner API |
| Integration tests | patrol + integration_test | integration_test alone | Cannot handle permission dialogs alone |
| Crash reporting | none (v1) | Sentry, Crashlytics | Privacy — reconsider self-hosted Sentry later |

---

## Installation (starter `pubspec.yaml` fragment)

```yaml
name: co2_diet
description: Privacy-first nutrition + CO2 tracking
publish_to: none
version: 0.1.0+1

environment:
  sdk: '>=3.6.0 <4.0.0'
  flutter: '>=3.27.0'

dependencies:
  flutter:
    sdk: flutter

  # Local storage
  drift: ^2.20.0
  drift_flutter: ^0.2.0
  sqlite3_flutter_libs: ^0.5.0
  path_provider: ^2.1.0
  flutter_secure_storage: ^9.2.0
  shared_preferences: ^2.3.0

  # State
  flutter_riverpod: ^2.6.0
  riverpod_annotation: ^2.6.0

  # Networking
  dio: ^5.7.0
  dio_smart_retry: ^7.0.0
  connectivity_plus: ^6.0.0
  internet_connection_checker_plus: ^2.5.0

  # Domain / integrations
  openfoodfacts: ^3.20.0
  mobile_scanner: ^5.2.0
  permission_handler: ^11.3.0
  workmanager: ^0.5.2

  # Auth
  flutter_appauth: ^7.0.0
  sign_in_with_apple: ^6.1.0
  google_sign_in: ^6.2.0

  # Notifications
  flutter_local_notifications: ^17.2.0
  timezone: ^0.9.0

  # Export / share
  csv: ^6.0.0
  excel: ^4.0.0
  archive: ^3.6.0
  share_plus: ^10.0.0
  file_picker: ^8.1.0

  # UI
  go_router: ^14.6.0
  fl_chart: ^0.69.0
  google_fonts: ^6.2.0
  flutter_svg: ^2.0.0
  intl: ^0.19.0
  cached_network_image: ^3.4.0

  # Utilities
  uuid: ^4.5.0
  freezed_annotation: ^2.4.0
  json_annotation: ^4.9.0
  equatable: ^2.0.0
  logger: ^2.4.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter

  # Codegen
  build_runner: ^2.4.0
  drift_dev: ^2.20.0
  riverpod_generator: ^2.6.0
  freezed: ^2.5.0
  json_serializable: ^6.8.0

  # Lints
  very_good_analysis: ^6.0.0
  riverpod_lint: ^2.6.0
  custom_lint: ^0.7.0

  # Test tooling
  mocktail: ^1.0.0
  patrol: ^3.11.0
  alchemist: ^0.11.0

  # Debug-only
  pretty_dio_logger: ^1.4.0

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/
  fonts:
    - family: Plus Jakarta Sans
      fonts:
        - asset: assets/fonts/PlusJakartaSans-Regular.ttf
        - asset: assets/fonts/PlusJakartaSans-Medium.ttf
          weight: 500
        - asset: assets/fonts/PlusJakartaSans-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/PlusJakartaSans-Bold.ttf
          weight: 700
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Regular.ttf
        - asset: assets/fonts/Inter-Medium.ttf
          weight: 500
```

Bootstrap commands:

```bash
flutter create --org com.reduceco2now --project-name co2_diet .
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

---

## Known Gotchas for the Chosen Stack

1. **Drift + iOS release build**: `sqlite3_flutter_libs` bumps iOS deployment target — set `platform :ios, '13.0'` (or newer) in `ios/Podfile`, then `cd ios && pod install`.
2. **Drift migrations**: Every schema change requires a version bump and a migration; get comfortable with `drift_dev schema dump` from day 1. Store `schema/v1.json` in git.
3. **build_runner clashes**: Riverpod, Drift, Freezed, and json_serializable all use `build_runner`. Run with `--delete-conflicting-outputs` to avoid tears.
4. **`connectivity_plus` false-positive**: reports "connected" when device is on Wi-Fi with no actual internet (captive portal, hotel Wi-Fi). Layer `internet_connection_checker_plus` on top for the sync trigger, not for the UI status bar.
5. **`mobile_scanner` on iOS Simulator**: no camera hardware — always test barcode flow on a real device.
6. **`workmanager` iOS BGTaskScheduler**: Do NOT rely on precise timing. Sync must also happen on app foreground. Set `BGTaskSchedulerPermittedIdentifiers` in `Info.plist`.
7. **`openfoodfacts` User-Agent**: OFF actively rate-limits generic user agents. Configure the app-specific UA in `OpenFoodAPIConfiguration.userAgent` at app startup before any API call.
8. **`google_fonts` runtime download**: makes a Google CDN request by default. **Bundle fonts as assets** — configuration above does this.
9. **App size on Android**: Enable R8 shrinking (`android/app/build.gradle`) — this stack + Flutter engine easily crosses 50 MB APK without shrinking. Target <30 MB for the split-per-ABI release APK.
10. **`sign_in_with_apple`** requires an Apple Developer account with a Services ID + private key configured in Keycloak — nontrivial one-time backend setup, coordinate early with Tomris.
11. **Keycloak PKCE + `flutter_appauth`**: Keycloak's default token endpoint requires client-secret for confidential clients; the mobile client must be configured as **public** with PKCE required — coordinate with Tomris.
12. **Riverpod `@riverpod` codegen**: file must import both `flutter_riverpod` and the `.g.dart` part file, and the class must extend the generated `_$Foo` mixin — first-time friction; document in `docs/architecture/state.md`.
13. **Passkeys are not stable in Flutter yet** — do not scope for v1.
14. **CI Xcode 15/16 + Flutter**: pin Xcode version in GitHub Actions / Codemagic; iOS build regressions on Xcode point releases are common.

---

## Confidence Assessment

| Recommendation | Confidence | Justification |
|----------------|------------|---------------|
| Drift over Hive/Isar/ObjectBox | HIGH | Multiple corroborating ecosystem signals through late 2025 |
| Riverpod (codegen) over BLoC/Provider | HIGH | Same, plus author-of-Provider recommendation |
| Dio over http | HIGH | Community standard for 3+ years |
| mobile_scanner | HIGH | Only actively maintained mainstream option |
| openfoodfacts (official) | HIGH | Foundation-owned, well-known |
| workmanager | MEDIUM | Package ecosystem historically fragile — re-verify at implementation phase |
| Sync outbox pattern (hand-rolled) | HIGH (pattern) / MEDIUM (details) | Pattern is textbook; implementation details need spike |
| Passkey deferral to v1.1 | HIGH | Flutter passkey ecosystem is genuinely nascent as of Jan 2026 |
| All specific version numbers | MEDIUM | Training data cutoff Jan 2026 — verify with `pub outdated` |
| Overall stack coherence | HIGH | These packages are known to interoperate cleanly |

**Any recommendation marked MEDIUM should be re-researched by the phase that consumes it.**

---

## Sources

**No live sources were consulted this session** — external research tools (WebFetch, WebSearch, Context7 MCP, ctx7 CLI) were denied by the sandbox permissions. All content above is drawn from the assistant's training-data knowledge of the Flutter ecosystem through **January 2026** and cross-referenced against:

- Flutter team recommendations (`go_router`, `flutter_local_notifications`) — well-known through 2025.
- Riverpod / Provider author's own public recommendation to prefer Riverpod for new projects.
- Open Food Facts foundation's Dart package (`openfoodfacts` on pub.dev, first-party).
- Community consensus signals through 2025 on Hive/Isar maintenance status.

**Before adoption, the following live verifications are required:**
- `flutter pub outdated` on the pubspec above to obtain current versions.
- pub.dev score / like count / last-published-date for each `MEDIUM` confidence package.
- Direct check of Isar / Hive repository health if either is being reconsidered.
- Direct check of `workmanager` maintenance status (author responsiveness on GitHub issues).
- Direct check of any passkey package if that decision is revisited.

**Recommended follow-up research (during the phase that consumes it):**
- Phase introducing sync: spike PowerSync / Turso Sync for potential v2 upgrade path.
- Phase introducing auth: verify Keycloak + `flutter_appauth` + Apple/Google configs against latest Keycloak version Tomris deploys.
- Phase introducing background sync: verify current `workmanager` maintenance and iOS 18 / Android 15 behaviour.
