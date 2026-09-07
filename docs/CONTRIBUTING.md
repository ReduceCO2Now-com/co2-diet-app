# Contributing

> Read [`../README.md`](../README.md) first for what the app is, and
> [`ARCHITECTURE.md`](ARCHITECTURE.md) for how it is put together.

---

## Setup

| | |
|---|---|
| Flutter | **3.44.6** — pinned; CI uses this exact version |
| Dart | ≥ 3.12.2 |
| Platform tooling | Xcode for iOS, Android SDK for Android |

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

**Code generation is mandatory.** A clean checkout does not compile without it. Generated
outputs — all committed — cover:

| Generator | Produces |
|---|---|
| `riverpod_generator` | `*.g.dart` next to every provider |
| `drift_dev` | `app_database.g.dart`, DAO parts |
| `freezed` | `*.freezed.dart` entities |
| `go_router_builder` | `app_router.g.dart` |

While working on generated code, run the watcher instead of rebuilding by hand:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

### First-run notes

**`off_reference.sqlite not available` in the console** is expected on a fresh clone. The bundled
food database is decompressed from `assets/off_reference.sqlite.gz` on first launch; when the
asset is absent, `main()` catches it and the app runs without the local catalog, falling back to
the Open Food Facts API. Not a failure — search is just slower and needs a network.

**iOS codesign failure** — `resource fork, Finder information, or similar detritus not allowed` —
is a macOS extended-attribute problem, not a project problem. Clear xattrs from the Flutter SDK,
the same workaround the iOS CI job applies:

```bash
xattr -cr "$(dirname "$(dirname "$(which flutter)")")"
```

On some macOS versions the OS re-applies `com.apple.provenance` to files under your home
directory and the failure persists locally even after this. Building elsewhere on disk, or
using the Android target, is the current workaround.

**Swift Package Manager.** Flutter 3.44 defaults `enable-swift-package-manager` to **on**, and it
can silently change how iOS plugins resolve — a project set up for CocoaPods may end up with
plugins skipped by one system and never supplied by the other, showing as an implausibly small
`pod install` count. If pods look wrong:

```bash
flutter config --no-enable-swift-package-manager
cd ios && rm -rf Pods Podfile.lock && pod install
```

---

## Before you open a PR

Run what CI runs:

```bash
dart run scripts/check_privacy_deps.dart pubspec.lock .privacy-blocklist.yaml
flutter analyze
flutter test
```

All three must pass. `flutter analyze` must be **clean** — `very_good_analysis` is strict on
purpose, including public-API documentation.

---

## Conventions

### Layering

Reread [`ARCHITECTURE.md` §2](ARCHITECTURE.md#2-layers) before adding a file. In short:

- `domain/` imports nothing app-specific. No Drift, no HTTP, no widgets.
- Presentation depends on the **interface** (`IWeightRepository`), never the implementation.
- Row ↔ entity mapping lives in the repository. DAOs return rows.
- DAOs take concrete values. Named concepts like `WeightRange.last30d` are resolved by the
  repository first.

A new feature usually means: entity in `domain/entities/`, interface in `domain/repositories/`,
table + DAO in `data/local/`, implementation in `data/repositories/`, providers in `core/di/`, and
screens/widgets/notifiers in `features/<feature>/`.

### Providers

One DI file per feature area (`weight_providers.dart`, `meal_logging_providers.dart`, …).
`providers.dart` stays reserved for core infrastructure — database and profile.

Use `@Riverpod(keepAlive: true)` for app-lifetime state, and say why in the doc comment. It
matters: a provider read via a bare `ref.read` from a widget that may unmount before the call
completes will throw `UnmountedRefException` if it is not kept alive.

### Adding a dependency

This project takes dependencies seriously, and the git history shows it — every entry in
`pubspec.yaml` carries a comment explaining what it is for and why that package.

1. **Check the blocklist.** `.privacy-blocklist.yaml` bans analytics, crash-reporting and
   attribution SDK prefixes. CI fails on any match, transitive included.
2. **Verify the package** — publisher, pub score, last release, repository, whether it is
   discontinued. Prefer `flutter.dev` and `dart.dev` packages, then verified publishers.
3. **Check it pulls in no network or analytics dependency** of its own.
4. **Comment the entry** in `pubspec.yaml`: what uses it, why this package over the alternatives,
   and any version pin with its reason.
5. **Pin exactly when a constraint forces it**, and record the conflict in the comment. Several
   existing pins exist only because of analyzer-version conflicts between codegen packages — undo
   one and the build breaks in a way that is not obvious from the error.

### Schema changes

Every table carries the sync-safe columns described in
[`ARCHITECTURE.md` §5](ARCHITECTURE.md#5-the-schema-is-sync-safe-from-v1): UUID v7 id, HLC
columns, `dirty`, tombstone fields, and `co2MethodologyVersion` on CO₂-bearing rows. New tables
include them too, even though nothing syncs yet — retrofitting them onto live user data is not
practical.

Schema changes need a versioned migration in `data/local/migrations/` and a regression test
covering **both** the broken and the already-correct prior state. A past migration gap left
columns permanently missing from any database created inside a specific commit window; the
crash surfaced much later, and the tests that now guard it are the reason it stays fixed.

Use `tool/generate_schema_v1.dart` for schema dumps — the `dart run drift_dev schema dump` CLI is
broken against the pinned drift version.

### Deep links

Every route parameter must have a safe fallback — `firstWhereOrNull`, or a switch with a
`default`. A malformed deep link lands somewhere sensible; it never crashes. See the `?slot=`,
`?metric=` and `?doc=` handlers in `app_router.dart` for the established pattern.

Anything reachable before onboarding completes must be added to the pre-onboarding allowlist in
the router's `redirect`, or it will bounce to `/splash`.

### Writing user-facing text

The product is non-judgemental about food and weight, and the copy carries that. No guilt
framing, no "bad" foods, no streak-shaming. CO₂ numbers are always presented as **estimates**
with their confidence, never as measurements.

ED safety nets sit in front of weight and target flows. If you touch those screens, do not route
around the checker.

### Commits

Conventional commits, scoped to the plan they belong to:

```
feat(06.1-01): Profile Setup becomes the terminal onboarding-completion trigger
test(06.1-01): extend onboarding_gate_test with Profile Setup trigger coverage
fix(09-08): retry from scratch when a failed download has no resume data
docs(06.1-01): update flow-order comments in router and gate provider
```

Tests generally land before or with the implementation — several plans in the history commit a
failing test first, then the change that makes it pass.

---

## Planning workflow

Delivery is organised into phases under `.planning/`:

| File | Contents |
|---|---|
| `PROJECT.md` | What the product is, constraints, key decisions |
| `REQUIREMENTS.md` | Numbered requirements (`AUTH-10`, `PRIV-05`, …) referenced from code |
| `ROADMAP.md` | Phases, dependencies, success criteria, status |
| `STATE.md` | Running log of decisions and sessions |
| `phases/` | Per-phase context, research, plans and summaries |

Requirement IDs appear in code comments and doc comments. When you change behaviour tied to one,
update the requirement — a code comment citing a requirement that has since changed is worse than
no comment.

**Assumptions get marked.** The codebase uses an explicit `[ASSUMED]` convention for values not
yet confirmed by their owner — see `KeycloakConfig`, `BackendConfig`, `ReferencePackConfig`, and
the `status: ASSUMED` frontmatter on the backend contract docs. If you add a value that depends on
somebody else confirming it, mark it the same way and centralize it in one file so the eventual
handoff is a one-file change.

---

## Documenting a non-obvious fix

Much of this codebase's value sits in comments explaining *why*, not *what*. When you resolve
something that cost real time — a build failure with a misleading error, a version pin forced by a
conflict, a bug that only appears on device — write down the symptom, how you found the cause,
and the fix. The next person hits the same wall with a search term that reaches your note.

Two worked examples already in the tree: the `archive` version pin comment in `pubspec.yaml`, and
the bottom-nav-bar gate explanation in `app_router.dart`.
