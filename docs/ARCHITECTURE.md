# Architecture

> Audience: developers joining the Flutter client, and anyone integrating against it.
> Companion documents: [`../README.md`](../README.md) for what the app is,
> [`CONTRIBUTING.md`](CONTRIBUTING.md) for how to work on it,
> `.planning/ROADMAP.md` for delivery history.

---

## 1. The constraints that decide everything

Four product constraints shape every technical choice below. They are not preferences.

**Privacy-first.** No analytics, no ad SDKs, no behavioural profiling. There is nothing to send,
so there is no send path to secure.

**Offline-first.** Every core flow must work with the radio off. The network is an enhancement
that fills gaps, never a dependency the daily loop waits on.

**Local Mode is the product.** Account Mode is an optional layer that adds sign-in and account
deletion. If the backend is down, unreachable, or never deployed, the app still works completely.

**Under 10 seconds to log a meal.** This is the single number the product is judged on, and it is
why search runs against a local FTS5 index rather than a network call.

The most important consequence: **the app owns its data.** It is not a thin client over a server.
The server, when it exists, is a reference-data source and an identity provider — never the home
of your meals.

---

## 2. Layers

Clean architecture, three layers, dependencies pointing inward only.

```
    features/  ──────────►  domain/  ◄──────────  data/
   (presentation)          (contracts)          (implementations)
```

`domain/` is the centre and depends on nothing — no Drift, no HTTP, no Flutter widgets. Both
outer layers depend on it; neither depends on the other.

| Layer | Holds | May import |
|---|---|---|
| `domain/` | Entities (Freezed), repository interfaces, pure services | Nothing app-specific |
| `data/` | Drift DB, DAOs, tables, API clients, repository implementations | `domain/` |
| `features/` | Screens, widgets, Riverpod notifiers | `domain/`, `core/` |
| `core/` | DI, router, theme, HLC, cross-feature widgets | `domain/`, `data/` |

**The rule that keeps it honest:** the presentation layer names the *interface*, never the
implementation. Providers are typed to `IWeightRepository`, not `WeightRepository`, so a screen
cannot reach a DAO even by accident.

```dart
@Riverpod(keepAlive: true)
IWeightRepository weightRepository(Ref ref) =>
    WeightRepository(ref.watch(weightDaoProvider));
```

**Where mapping lives.** Row ↔ entity conversion belongs in the repository, not the DAO. DAOs
speak Drift rows and raw queries; repositories speak domain entities. Likewise, DAOs know nothing
about named concepts — `getEntriesInRange(WeightRange.last30d)` is resolved to a concrete
`[from, to]` window by the repository before the DAO sees a date at all.

---

## 3. Directory map

```
lib/
├── main.dart              bootstrap, before runApp
├── app.dart               root widget, app-lifecycle hooks
├── core/
│   ├── di/                Riverpod providers, one file per feature area
│   ├── router/            go_router config + redirect guard
│   ├── theme/             color / spacing / text tokens
│   ├── sync/              hybrid logical clock
│   ├── assets/            first-launch reference DB extraction
│   └── widgets/           cross-feature widgets
├── data/
│   ├── local/
│   │   ├── app_database.dart      Drift database
│   │   ├── tables/                table definitions
│   │   ├── daos/                  queries, incl. an FTS5 .drift file
│   │   ├── migrations/            versioned schema migrations
│   │   ├── mixins/                sync_safe_table
│   │   └── reference_pack/        download, checksum, disk, extract, delta
│   ├── remote/            OFF + reference-pack API clients
│   └── repositories/      implementations of the domain interfaces
├── domain/
│   ├── entities/          Freezed value types
│   ├── repositories/      i_*.dart abstract interfaces
│   └── services/          pure logic + centralized config classes
└── features/<feature>/
    ├── screens/
    ├── widgets/
    └── providers/
```

`core/di/` is split per feature area (`weight_providers.dart`, `meal_logging_providers.dart`, …)
rather than one file, so `providers.dart` stays focused on core infrastructure — the database and
profile — and feature work touches one small file.

---

## 4. Data flow

One direction, every time:

```
Screen ──watch──► Notifier ──► IRepository ──► Repository ──► DAO ──► Drift/SQLite
  ▲                                                                        │
  └──────────────────── reactive rebuild ◄─────────────────────────────────┘
```

A read: the screen watches a Riverpod notifier; the notifier calls the repository *interface*;
the concrete repository asks its DAO and maps rows to entities.

A write: the same path inbound, then invalidation flows back out and every watcher rebuilds. No
screen talks to another screen, and no screen holds a reference to another screen's state.

**Network sits behind the same interface.** Food search hits the local FTS5 index first and only
falls back to the Open Food Facts API on a miss. The screen never learns which one answered — the
repository decides, and the UI shows a loading banner only for the API path.

---

## 5. The schema is sync-safe from v1

Even though the app currently syncs nothing, every table created in Phase 1 carries the columns a
sync engine would need:

| Column | Purpose |
|---|---|
| `id` | UUID v7 — time-ordered, collision-free across devices |
| `hlcMillis`, `hlcCounter`, `hlcNodeId` | Hybrid logical clock, for ordering writes across devices |
| `dirty` | Marks locally-modified rows not yet pushed |
| tombstone fields | Deletes as records, so a delete can propagate |
| `co2MethodologyVersion` | Stamps the methodology that produced a CO₂ value |

**Why before it is needed.** This cannot be retrofitted. Rows users create today would have no
clock, no origin, and no basis for conflict resolution — a sync engine bolted on later would have
to guess about existing data. Adding the columns up front costs almost nothing; adding them after
launch means a migration over data you cannot reconstruct.

Through Phases 1–5 the HLC fields hold deliberate placeholders (`hlcNodeId: 'local'`,
`hlcCounter: 0`) — the columns are real, the clock is not yet driving anything.

`core/sync/hlc.dart` implements the clock (Kulkarni et al., 2014), intentionally minimal. It
carries one known gap, recorded in the code: a `maxDriftMs` cap is needed before sync ships, or a
row written with a far-future timestamp would always win last-write-wins — a clock-manipulation
opening.

---

## 6. Navigation

`go_router` 17 with `StatefulShellRoute.indexedStack`. Three branches — Profile, Dashboard,
Settings — each keeping its own navigation stack across tab switches.

**One enforcement point.** A single top-level `redirect` in `app_router.dart` decides whether any
navigation is allowed. It runs on every attempt, including the initial location, which is what
makes "consent is never skippable" true against a crafted deep link into `/dashboard` rather than
merely true for users who walk the flow.

The guard maintains two lists: routes that belong to onboarding, and routes reachable *before*
onboarding completes. The second is larger than the first — `/profile` is both an onboarding step
and a permanent tab, and `/legal-hub` must be reachable from the consent screen's "View Terms"
links. Both of those were real bugs found in manual verification, not hypotheticals.

**The bottom nav bar is hidden until onboarding completes.** Otherwise a user on Profile Setup
could tap "Dashboard" directly, bypassing the only call site that marks onboarding complete — the
guard would then correctly bounce them back to `/splash`, which reads to a user as an
unexplained loop rather than a guard working. Removing the shortcut beats explaining it away.

**Every deep-link parameter has a safe fallback.** `?slot=`, `?metric=`, `?doc=` all resolve
through `firstWhereOrNull` or an explicit switch with a default. A malformed deep link lands
somewhere sensible; it never crashes.

A `rootNavigatorKey` is captured at app start so non-widget code — notably the notification tap
handler, which has no `BuildContext` and no Riverpod `ref` — can still navigate.

---

## 7. Lifecycle work, and why there is no scheduler

The app has **no background scheduler**. Two pieces of periodic work run on
`AppLifecycleState.resumed` instead:

**Weigh-in reminder re-arming.** `flutter_local_notifications` has no long-interval recurrence
primitive, so biweekly and monthly reminders can only ever be scheduled one occurrence ahead,
computed from `DateTime.now()`. Something must refresh that occurrence. App-foreground is the one
trigger every user hits regardless of where they navigate.

**Reference-pack delta checks.** When the user has opted into weekly or monthly automatic
refresh, and the interval has actually elapsed, the app checks the CDN manifest. The check
timestamp is recorded whichever way it resolves, so "no update available" still counts as a
completed check and the throttle holds.

The two are **sibling calls, not nested**. If the reference-pack check were nested inside the
reminder block, any early return there — settings still loading, no reminder configured — would
silently skip it. Neither block reads or mutates the other's state.

---

## 8. Reference-pack delivery

The app ships a small bundled catalog and can fetch the full Open Food Facts pack (~300–800 MB)
on demand. At that size, on a phone, on real networks, every failure mode is a normal Tuesday —
so the pipeline is built defensively:

1. **Disk preflight** — check free space before starting, not after filling it.
2. **Native background download** — iOS URLSession / Android WorkManager, so the transfer
   survives backgrounding and app termination.
3. **Range-header resume** — continue from the last recorded byte, not from zero.
4. **SHA-256 verification** — chunked, before the pack is trusted or applied. Checksum before
   trust.
5. **Atomic apply** — a failed or reverted application must not corrupt the working database.

**Cancel and interrupt are deliberately different.** An explicit user cancel deletes the partial
file immediately. An interruption — connection lost, process killed, OS eviction — preserves it
for resume. "I changed my mind" and "something happened to me" are different intentions and get
different behaviour.

The CDN URL in `ReferencePackConfig` is a placeholder; hosting has no owner yet.

---

## 9. Identity and the backend

Two paths, kept strictly separate.

**Local Mode** touches no identity system at all. There is no user record to attach anything to.

**Account Mode** uses Keycloak OIDC + PKCE via `flutter_appauth`, through the **system browser** —
not an embedded webview, which would be able to observe credentials. The refresh token is stored
in the platform Keychain/Keystore via `flutter_secure_storage`. Apple and Google sign-in are
Keycloak identity providers reached with `kc_idp_hint`, so the client carries no vendor SDK.

`AuthNotifier` is the single source of truth for "is the user signed in". Every auth-aware
screen watches that one provider; no screen re-derives auth state.

**Account Mode moves no personal data.** It ships sign-in, sign-out, password reset, and GDPR
account deletion. Sync is Phase 8 and is contingent on an unresolved backend decision.

**Every backend-facing value is a single-file placeholder.** `KeycloakConfig`, `BackendConfig`
and `ReferencePackConfig` each centralize their values with an explicit `[ASSUMED]` marker, so
the eventual handoff — real realm export, deployed URL, real CDN — is a one-file change rather
than a hunt through the codebase. Treat none of them as a production contract.

The account-deletion API in `docs/backend-contracts/gdpr-account-deletion.md` is a written
proposal for the backend owner to confirm or reject — deliberately concrete so there is something
to react to, rather than the client guessing silently at runtime.

---

## 10. CO₂ estimation

An estimate, presented as one. Every value carries a confidence level and the methodology version
that produced it.

**Versioned at write time.** Rows store the methodology version that generated their number, so
changing the methodology never silently rewrites history — it announces itself and the user is
told.

**Two scopes, never mixed:**

- *Product-level*, per food: category factor × mass, adjusted for origin, production, transport,
  processing. Deterministic and cacheable.
- *Context-level*, per user: cooking method, storage, household size, retail channel, location.
  Applied **once at daily aggregation**. Applying these per item would multiply one lifestyle
  factor across every food logged that day — the same adjustment counted five times over.

Thresholds for high/medium/low confidence are owned centrally, not invented per screen, so the
same number never reads differently in two places.

Method detail: [`CO2_METHODOLOGY.md`](CO2_METHODOLOGY.md).

---

## 11. Privacy enforcement

`.privacy-blocklist.yaml` names banned package prefixes; `scripts/check_privacy_deps.dart`
audits `pubspec.lock` on every push and PR. A match anywhere in the tree — including a
transitive dependency pulled in by something innocent — fails the build.

This is the point: a tracking SDK usually arrives as somebody else's dependency, not as a
deliberate choice. Editing the blocklist requires a PR, so any loosening is visible in git
history rather than quietly landing in a lockfile.

Consent records store timestamp, app version and policy version, so it is always answerable which
document a user actually agreed to.

---

## 12. Testing

97 test files, ~19,800 lines, plus `integration_test/`.

CI runs two jobs: Android (analyze → privacy audit → full test suite → debug APK) and iOS
(no-codesign build). The iOS job clears macOS extended attributes from the Flutter SDK before
building — an Xcode 26 codesign workaround.

Tests are written against domain interfaces and fed fakes or `mocktail` mocks, which is the
practical payoff of the layering: business logic is testable without a database, a device, or a
network.

---

## 13. Known gaps

Recorded here so nobody rediscovers them.

| Gap | Where |
|---|---|
| HLC needs a `maxDriftMs` cap before sync ships | `core/sync/hlc.dart` — TODO in code |
| Keycloak realm, client ID, redirect URI all `[ASSUMED]` | `domain/services/keycloak_config.dart` |
| Backend base URL `[ASSUMED]`, no deployment yet | `domain/services/backend_config.dart` |
| Reference-pack CDN URL is a placeholder, hosting unowned | `domain/services/reference_pack_config.dart` |
| Account-deletion contract unconfirmed by the backend owner | `docs/backend-contracts/gdpr-account-deletion.md` |
| Phase 8 blocked on encrypted-blob vs user-cloud-export decision | `.planning/ROADMAP.md` |
| `PROJECT.md` still names Hive for local storage; the app uses Drift | `.planning/PROJECT.md` |
