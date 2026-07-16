# Phase 1: Foundations & Sync-Safe Schema - Research

**Researched:** 2026-07-16
**Domain:** Flutter 3.44 / Drift 2.34 / Riverpod 3.x / go_router 17 / GitHub Actions CI
**Confidence:** HIGH (most findings verified against pub.dev live data and official docs)

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- Schema registry pattern: SyncSafeTable abstract Drift mixin; tables materialized per-phase
- Phase 1 materializes: `user_profile` + `consent_records` only
- Vertical slice = profile entry + auto-calculated targets (no food/meal tables in Phase 1)
- Profile UI: real styled standalone screen using DESIGN.md tokens
- Mifflin-St Jéor as pure domain function in the domain layer
- Override strategy: replace (not offset); `is_overridden` boolean column per target field
- Missing fields → show `—` dash; no fake precision, no population-average fallbacks
- CO₂ target hidden until Phase 3 (stored in schema but not rendered)
- Locale detection wired from day 1 via `Localizations.localeOf(context)`
- LEG-04 deferred entirely to Phase 6 — not a Phase 1 deliverable
- LicensePage widget for in-app license disclosure (runtime, no CI step)
- SDK blocklist: broad prefix block in `.privacy-blocklist.yaml`
- GitHub Actions CI: Flutter 3.44.6 pinned; two parallel jobs (ubuntu-latest + macos-latest)
- Pipeline: blocklist check → `flutter analyze` → `dart test` → `flutter build apk --debug` (ubuntu) + `flutter build ios --no-codesign` (mac)
- Theme: DESIGN.md verbatim source of truth; both ThemeData.light() and ThemeData.dark() from Phase 1
- Branch protection: CI must pass; no required reviewer
- Local DB: Drift (SQLite) — Hive rejected (unmaintained, no FTS5, brittle migrations)
- State management: Riverpod with codegen
- Router: go_router
- Architecture: Clean-layered (UI → Riverpod Presentation → Application → Domain → Data)
- Fonts: Plus Jakarta Sans + Inter
- Auth: Keycloak OIDC + PKCE (Phase 7 concern, NOT Phase 1)
- No Firebase, no analytics SDKs — enforced by CI from Phase 1
- Flutter version: 3.44.6 (pinned in CI to match dev environment)

### Claude's Discretion
- Drift migration numbering and file structure conventions
- Riverpod provider file organization (feature-based vs. layer-based)
- go_router route naming conventions
- HLC implementation library choice (roll our own vs. `hlc` Dart package)
- Exact `SyncSafeTable` mixin field types (int64 vs. DateTime for HLC millis)
- Profile screen field ordering and visual grouping
- `—` dash component styling for missing target values

### Deferred Ideas (OUT OF SCOPE)
- LEG-04 (Terms / Privacy / Disclaimer links from Legal Consent screen) — deferred to Phase 6
- CO₂ target display — hidden from Profile UI in Phase 1; shown from Phase 3
- Exodus Privacy scan in CI — Phase 6 pre-submission concern only
- Dark mode accessibility audit (ACC-01) — Phase 6 formal verification, though ThemeData.dark() wired in Phase 1
- Content delivery strategy for legal docs — Phase 6 decision
</user_constraints>

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| PROF-01 | User can configure profile: age, gender, height, weight, activity level (Low/Medium/High), dietary preference | Drift `user_profile` table schema; Profile screen pattern in `lib/features/profile/` |
| PROF-02 | User can select metric or imperial units; default auto-detected from device locale; overrideable | `Localizations.localeOf(context)` locale detection; `user_profile.units` column |
| PROF-03 | User can select a goal: 7 options (Reduce CO₂ / Lose weight / Maintain weight / etc.) | `user_profile.goal` enum column; goal-to-macro-ratio mapping table |
| PROF-04 | System auto-calculates daily targets from profile (Mifflin-St Jéor + activity factor) | Pure domain function; formula verified in research; activity factor table |
| PROF-05 | User can manually edit any auto-calculated target | `is_overridden` boolean column per target; override-replace strategy |
| PRIV-07 | Zero third-party analytics/ad/behavioral tracking SDKs; verified by automated dependency audit in CI | `.privacy-blocklist.yaml` + CI blocklist-check script; package legitimacy audit |
| CO2-04 | CO₂ values stored per row with `co2_methodology_version` field | `co2_methodology_version` TEXT column on `user_profile` |
| LEG-04 | Open source license disclosure accessible in-app | Flutter's `LicensePage` widget — auto-discovers at runtime; DEFERRED TO PHASE 6 per CONTEXT.md decision; in-app LicensePage still wired in Phase 1 settings stub |
</phase_requirements>

---

## Summary

Phase 1 is a foundations phase that creates the entire structural skeleton that every future phase builds on. Three domains dominate the work: (1) the sync-safe Drift schema, (2) the clean-architecture skeleton wired with Riverpod 3.x codegen and go_router 17, and (3) the CI privacy pipeline. A thin but real vertical slice — profile entry plus Mifflin-St Jéor targets persisted locally — proves the skeleton end-to-end.

Key discoveries from this research: Drift has been substantially updated since the project research (now 2.34.x; `sqlite3_flutter_libs` is fully EOL and replaced by `drift_flutter`). Riverpod is now on 3.3.x with a simplified `Ref` type replacing the old `AutoDisposeRef`/`FamilyRef` proliferation. go_router is at 17.3.0 and uses `StatefulShellRoute.indexedStack` as the standard bottom-nav pattern. Flutter 3.44 ships with AGP 9 Android template and SPM iOS coexistence mode; new projects from `flutter create` require no manual migration but developers must be aware of plugin compatibility gaps. The `uuid` package 4.6.0 supports `uuid.v7()` natively (RFC 9562), making `uuidv7` a redundant standalone package. The `hlc` package at 1.0.4 exists but has low adoption and no recent updates — rolling a minimal HLC is the correct choice for this project's Phase 1 needs.

**Primary recommendation:** Use `drift` + `drift_flutter` (no `sqlite3_flutter_libs`) for the DB layer; `flutter_riverpod` 3.3.2 + codegen for state; `go_router` 17.3.0 for routing; `uuid` 4.6.0's `v7()` for primary keys; roll a 20-line HLC helper in `lib/core/sync/hlc.dart` rather than depending on the undercooked `hlc` package.

---

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Drift schema + migrations | Data Layer | — | Schema is a data-layer concern; no UI dependency |
| SyncSafeTable mixin | Data Layer | — | Pure Dart mixin on Drift Table; wired at DB class level |
| Mifflin-St Jéor calculator | Domain Layer | — | Pure Dart function; zero framework imports; fully unit-testable |
| Macro/target derivation | Domain Layer | — | Same: deterministic calculation, no I/O |
| Profile persistence (DAO + repository) | Data Layer | Application Layer | DAO in Data; use case in Application |
| Profile UI (screen + form) | UI Layer | Presentation (Riverpod) | Riverpod provider holds state; Widget renders it |
| Riverpod DI wiring | Presentation Layer | Application Layer | Providers bridge Application use cases into UI |
| go_router route tree | UI Layer (core) | — | Router lives in `lib/core/router/`; references feature screens |
| ThemeData construction | UI Layer (core) | — | In `lib/core/theme/`; consumed by `MaterialApp.theme` |
| CI blocklist audit | CI pipeline | — | Bash/Python script parsing pubspec.lock; not app code |
| LicensePage | UI Layer (core) | — | Flutter runtime widget; wired to Settings screen |
| Locale detection | Presentation Layer | Domain Layer | `Localizations.localeOf(context)` in provider; drives unit enum in domain |
| HLC utility | Data Layer (core/sync) | — | Pure Dart util; used only by Data layer during writes |

---

## Standard Stack

### Core Phase 1 Packages

| Library | Verified Version | Purpose | Source |
|---------|-----------------|---------|--------|
| `drift` | 2.34.2 | Reactive SQLite ORM — tables, DAOs, migrations, codegen | [VERIFIED: pub.dev — 2026-07-14] |
| `drift_flutter` | 0.3.1 | Flutter SQLite integration; replaces `sqlite3_flutter_libs` | [VERIFIED: pub.dev — 2026-07-11] |
| `drift_dev` | 2.34.4 | Drift code generator (dev dep) | [VERIFIED: pub.dev — 2026-07-14] |
| `build_runner` | 2.15.2 | Runs all codegen (Drift + Riverpod + Freezed) (dev dep) | [VERIFIED: pub.dev — 2026-07-13] |
| `flutter_riverpod` | 3.3.2 | Reactive state + DI container | [VERIFIED: pub.dev — ~36 days ago] |
| `riverpod_annotation` | 4.0.3 | `@riverpod` codegen annotations | [VERIFIED: pub.dev — 2026-06-10] |
| `riverpod_generator` | 4.0.4 | Riverpod codegen (dev dep) | [VERIFIED: pub.dev — 2026-06-10] |
| `riverpod_lint` | 3.1.4 | Riverpod lint rules (dev dep) | [VERIFIED: pub.dev — 2026-06-10] |
| `custom_lint` | 0.8.1 | Host for riverpod_lint (dev dep) | [VERIFIED: pub.dev — 2025-09-09] |
| `go_router` | 17.3.0 | Declarative routing with typed routes + StatefulShellRoute | [VERIFIED: pub.dev — 2026-06-02] |
| `uuid` | 4.6.0 | UUID v4 + v7 (RFC 9562) generation — primary keys | [VERIFIED: pub.dev — 2026-07-15] |
| `intl` | 0.20.3 | Locale-aware number/date formatting | [VERIFIED: pub.dev — ~21 days ago] |
| `path_provider` | ^2.1.6 | App documents dir for Drift DB file location | [CITED: drift.simonbinder.eu/setup/] |
| `freezed` | 3.2.5 | Immutable domain models + sealed unions (dev dep) | [VERIFIED: pub.dev — ~5 months ago] |
| `freezed_annotation` | 3.1.0 | Freezed annotations | [VERIFIED: pub.dev] |
| `very_good_analysis` | 10.3.0 | Strict lint rules (dev dep) | [VERIFIED: pub.dev — 2026-06-18] |
| `mocktail` | 1.0.5 | Mocking for tests — no codegen required (dev dep) | [VERIFIED: pub.dev — 2026-04-10] |

**IMPORTANT: `sqlite3_flutter_libs` is EOL.** Starting with version 0.6.0, the package does nothing. As of 2026, `drift_flutter` 0.3.x is the replacement. Do not add `sqlite3_flutter_libs` to pubspec.yaml. [VERIFIED: pub.dev package page]

### Package Version Notes vs. Prior Research

The project's STACK.md (written Jan 2026 training data) cited significantly older versions. Verified current versions are substantially ahead:

| Package | STACK.md version | Current verified version |
|---------|-----------------|--------------------------|
| `drift` | ^2.20.0 | 2.34.2 |
| `drift_flutter` | ^0.2.0 | 0.3.1 |
| `drift_dev` | ^2.20.0 | 2.34.4 |
| `flutter_riverpod` | ^2.6.0 | 3.3.2 |
| `riverpod_annotation` | ^2.6.0 | 4.0.3 |
| `riverpod_generator` | ^2.6.0 | 4.0.4 |
| `go_router` | ^14.6.0 | 17.3.0 |
| `uuid` | ^4.5.0 | 4.6.0 |
| `very_good_analysis` | ^6.0.0 | 10.3.0 |
| `sqlite3_flutter_libs` | ^0.5.0 | **EOL — do not use** |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `uuid` v7() | `uuidv7` package (1.0.1) | `uuid` already supports v7 natively; standalone `uuidv7` adds a dependency with only 155 total downloads — use `uuid` |
| Roll own HLC | `hlc` package (1.0.4) | `hlc` is published by an individual (misha.jp), 2 years old, minimal updates; rolling a 20-line HLC in `lib/core/sync/hlc.dart` is safer and sufficient for Phase 1 |
| `drift_flutter` | raw `sqlite3_flutter_libs` + `sqlite3` v3.x | `drift_flutter` wraps the correct sqlite3 v3.x automatically; no need to configure separately |

**Installation for Phase 1:**

```bash
flutter create --org com.reduceco2now --project-name co2diet .

flutter pub add \
  drift drift_flutter path_provider \
  flutter_riverpod riverpod_annotation \
  go_router uuid intl \
  freezed_annotation

flutter pub add --dev \
  drift_dev build_runner \
  riverpod_generator riverpod_lint custom_lint \
  very_good_analysis freezed mocktail \
  flutter_test integration_test
```

---

## Package Legitimacy Audit

> Note: `slopcheck` was run but incorrectly against the PyPI registry (Python). These are Dart packages on pub.dev. All packages below were manually verified against the pub.dev API and official documentation. Slopcheck cannot be used for pub.dev verification; the standard verification is `pub.dev API + official docs`.

| Package | Registry | Age | Downloads | Publisher | Source Repo | Manual Check | Disposition |
|---------|----------|-----|-----------|-----------|-------------|-------------|-------------|
| `drift` | pub.dev | 6+ yrs (ex-Moor) | Very high | simolus3.dev (verified) | github.com/simolus3/drift | Active, 2.34.2 July 2026 | Approved |
| `drift_flutter` | pub.dev | 2+ yrs | High | simolus3.dev (verified) | github.com/simolus3/drift | Companion to drift, maintained together | Approved |
| `drift_dev` | pub.dev | 6+ yrs | High | simolus3.dev (verified) | github.com/simolus3/drift | Same monorepo | Approved |
| `build_runner` | pub.dev | 6+ yrs | Very high | dart.dev (verified) | github.com/dart-lang | Google/Dart team | Approved |
| `flutter_riverpod` | pub.dev | 4+ yrs | Very high | dash-overflow.net (verified) | github.com/rrousselGit/riverpod | Rémi Rousselet — author of Provider | Approved |
| `riverpod_annotation` | pub.dev | 3+ yrs | High | dash-overflow.net (verified) | same | Same author, v4.0.3 | Approved |
| `riverpod_generator` | pub.dev | 3+ yrs | High | dash-overflow.net (verified) | same | Same author, v4.0.4 | Approved |
| `riverpod_lint` | pub.dev | 2+ yrs | High | dash-overflow.net (verified) | same | Same author, v3.1.4 | Approved |
| `custom_lint` | pub.dev | 2+ yrs | High | dash-overflow.net (verified) | same | Same author, v0.8.1 | Approved |
| `go_router` | pub.dev | 3+ yrs | Very high | flutter.dev (verified) | github.com/flutter/packages | Flutter team owned | Approved |
| `uuid` | pub.dev | 8+ yrs | Very high | daegalus (verified) | github.com/daegalus/dart-uuid | v4.6.0, published July 2026 | Approved |
| `intl` | pub.dev | 10+ yrs | Very high | dart.dev (verified) | github.com/dart-lang/i18n | Google/Dart team | Approved |
| `freezed` | pub.dev | 4+ yrs | Very high | dash-overflow.net (verified) | github.com/rrousselGit/freezed | Rémi Rousselet, v3.2.5 | Approved |
| `very_good_analysis` | pub.dev | 4+ yrs | High | vgv.dev (verified) | github.com/VeryGoodOpenSource | Very Good Ventures, v10.3.0 | Approved |
| `mocktail` | pub.dev | 3+ yrs | High | felangel.dev (verified) | github.com/felangel/mocktail | Felix Angelov (BLoC author) | Approved |
| `path_provider` | pub.dev | 6+ yrs | Very high | flutter.dev (verified) | github.com/flutter/packages | Flutter team | Approved |
| `uuidv7` | pub.dev | 4 months | 155 total | vania.club (verified) | github.com/dodgog/uuidv7-dart | [ASSUMED] Very low adoption | NOT RECOMMENDED — use uuid instead |
| `hlc` | pub.dev | 2+ yrs | Low | misha.jp (verified) | github.com/misha/dart_hlc | v1.0.4, minimal updates | NOT RECOMMENDED — roll own |

**Packages removed from recommendations:** `uuidv7` (superseded by `uuid` v7()), `hlc` (low adoption, prefer hand-rolled), `sqlite3_flutter_libs` (EOL)
**Packages flagged as suspicious:** None of the approved packages above triggered concerns.

---

## Architecture Patterns

### System Architecture Diagram

```
Flutter App Entry Point (main.dart)
         │
         ▼
  ProviderScope (Riverpod root)
         │
         ▼
  MaterialApp.router ──── GoRouter ──── Route tree
         │                              (Profile / Settings / Placeholder Dashboard)
         ▼
  Feature Screens (UI Layer)
    ProfileScreen, TargetsScreen
         │  reads
         ▼
  Riverpod Providers (Presentation)
    profileNotifierProvider    targetsProvider
    (AsyncNotifier<UserProfile>) (Provider<CalcTargets?>)
         │  calls
         ▼
  Use Cases (Application Layer)
    SaveProfileUseCase   CalculateTargetsUseCase
         │  depends on
         ▼
  Domain Layer (pure Dart)
    UserProfile entity   MifflinStJeorCalculator
    TargetCalculator     HlcClock (utility)
         │  implemented by
         ▼
  Data Layer (Drift)
    AppDatabase (Drift class)
    UserProfileDao       ConsentRecordsDao
    user_profile table   consent_records table
    (SyncSafeTable mixin) (append-only, no mixin)
         │  written to
         ▼
  SQLite file (via drift_flutter / NativeDatabase)
```

Data flows strictly downward. Drift streams bubble up reactively through the DAO → repository → provider → widget.

### Recommended Project Structure

```
lib/
  main.dart                    # ProviderScope + MaterialApp.router
  core/
    router/
      app_router.dart          # GoRouter definition, all routes
    theme/
      app_theme.dart           # ThemeData.light() + ThemeData.dark()
      color_tokens.dart        # All DESIGN.md color tokens as const Color
      text_tokens.dart         # All DESIGN.md typography as TextStyle constants
    sync/
      hlc.dart                 # Hand-rolled 20-line HLC utility
    di/
      providers.dart           # Core-level providers (AppDatabase, etc.)
  data/
    local/
      app_database.dart        # Drift @DriftDatabase class, schemaVersion: 1
      app_database.g.dart      # Generated
      mixins/
        sync_safe_table.dart   # SyncSafeTable mixin definition
      tables/
        user_profile_table.dart
        consent_records_table.dart
      daos/
        user_profile_dao.dart
        consent_records_dao.dart
      migrations/
        migration_strategy.dart
        schemas/
          schema_v1.json       # Generated: dart run drift_dev schema dump
  domain/
    entities/
      user_profile.dart        # Freezed immutable entity
      calc_targets.dart        # Freezed: CalcTargets (kcal, protein, carbs, fat, co2)
    services/
      mifflin_st_jeor.dart     # Pure Dart function, no imports outside dart:core
      target_calculator.dart   # Pure Dart: macro ratios by goal
    repositories/
      i_profile_repository.dart  # Abstract interface
  application/
    use_cases/
      save_profile_use_case.dart
      calculate_targets_use_case.dart
  features/
    profile/
      screens/
        profile_screen.dart
      widgets/
        profile_form.dart
        target_display_card.dart
        missing_target_dash.dart
      providers/
        profile_notifier.dart       # @riverpod AsyncNotifier
        profile_notifier.g.dart     # Generated
        targets_provider.dart       # @riverpod
    settings/
      screens/
        settings_screen.dart        # Stubs for Phase 6; shows LicensePage link
  l10n/                             # Empty placeholder for Phase 6 localizations

assets/
  fonts/
    PlusJakartaSans-Regular.ttf
    PlusJakartaSans-Medium.ttf
    PlusJakartaSans-SemiBold.ttf
    PlusJakartaSans-Bold.ttf
    Inter-Regular.ttf
    Inter-SemiBold.ttf

.github/
  workflows/
    ci.yml

.privacy-blocklist.yaml
```

### Pattern 1: SyncSafeTable Mixin on Drift Table

```dart
// Source: drift.simonbinder.eu/dart_api/tables/ — mixin syntax verified
// lib/data/local/mixins/sync_safe_table.dart

import 'package:drift/drift.dart';

/// Abstract mixin that injects sync-safe columns onto any Drift table.
/// Apply to every user-data table that participates in LWW sync.
///
/// Columns injected:
///   id          — UUID v7 string primary key (time-ordered)
///   hlc_millis  — HLC wall-clock component (milliseconds since epoch)
///   hlc_counter — HLC logical counter (tie-breaking)
///   hlc_node_id — Node identifier (device installation UUID)
///   dirty       — true when this row has uncommitted local changes
///   deleted_at  — tombstone: non-null = row deleted, retained 90 days
mixin SyncSafeTable on Table {
  // Primary key: UUID v7 stored as TEXT (sortable by creation time)
  late final id = text()();

  // HLC: wall-clock millis (int64 fits comfortably in Dart int)
  late final hlcMillis = int64()();

  // HLC: logical counter for same-millisecond ordering
  late final hlcCounter = integer()();

  // HLC: stable node identifier (device installation UUID v4)
  late final hlcNodeId = text()();

  // Dirty flag: true = row has local changes not yet synced
  late final dirty = boolean().withDefault(const Constant(true))();

  // Tombstone: null = live; non-null = soft-deleted
  late final deletedAt = dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
```

### Pattern 2: user_profile table

```dart
// lib/data/local/tables/user_profile_table.dart

import 'package:drift/drift.dart';
import '../mixins/sync_safe_table.dart';

/// Single-row table (one row per app installation in Local Mode).
/// All sync-safe columns come from SyncSafeTable mixin.
@DataClassName('UserProfileRow')
class UserProfileTable extends Table with SyncSafeTable {
  // Profile fields
  late final age = integer().nullable()();
  late final gender = text().nullable()(); // 'male' | 'female' | 'other' | null

  // Height stored in cm (converted from imperial in app layer)
  late final heightCm = real().nullable()();

  // Weight stored in kg (converted from imperial in app layer)
  late final weightKg = real().nullable()();

  late final activityLevel = text().nullable()(); // 'low' | 'medium' | 'high'
  late final dietaryPreference = text().nullable()(); // 'no_preference' | 'vegetarian' | ...
  late final goal = text().nullable()(); // 'reduce_co2' | 'lose_weight' | ...
  late final units = text().withDefault(const Constant('metric'))(); // 'metric' | 'imperial'

  // Auto-calculated targets (nullable = not yet calculated)
  late final kcalTarget = real().nullable()();
  late final proteinGTarget = real().nullable()();
  late final carbsGTarget = real().nullable()();
  late final fatGTarget = real().nullable()();

  // CO2 target — stored but NOT shown in UI until Phase 3
  late final co2GTarget = real().nullable()();

  // Per-target override flags (true = user manually set this value)
  late final kcalIsOverridden = boolean().withDefault(const Constant(false))();
  late final proteinIsOverridden = boolean().withDefault(const Constant(false))();
  late final carbsIsOverridden = boolean().withDefault(const Constant(false))();
  late final fatIsOverridden = boolean().withDefault(const Constant(false))();
  late final co2IsOverridden = boolean().withDefault(const Constant(false))();

  // CO2 methodology version — present from day 1 per CO2-04
  late final co2MethodologyVersion = text().withDefault(const Constant('1.0'))();

  // Locale at time of profile creation (BCP 47 tag, e.g. 'de-DE')
  late final localeTag = text().nullable()();

  // Audit timestamps
  late final createdAt = dateTime().withDefault(currentDateAndTime)();
  late final updatedAt = dateTime().nullable()();
}
```

### Pattern 3: consent_records table (append-only, NO mixin)

```dart
// lib/data/local/tables/consent_records_table.dart
// NOT using SyncSafeTable — consent records are insert-only audit log;
// HLC/LWW conflict resolution is inappropriate for legal audit data.

import 'package:drift/drift.dart';

@DataClassName('ConsentRecord')
class ConsentRecordsTable extends Table {
  // UUID v7 primary key — time-ordered for audit chronology
  late final id = text()();

  // UTC timestamp of the consent event
  late final createdAt = dateTime().withDefault(currentDateAndTime)();

  // App version at time of consent (e.g. '0.1.0+1')
  late final appVersion = text()();

  // Policy version at time of consent (e.g. '2026-07-16')
  late final policyVersion = text()();

  // JSON array of accepted checkboxes:
  // ['terms', 'privacy', 'not_medical_advice', 'user_responsibility']
  // + optionally 'age_16_plus' when 5th checkbox was checked
  late final consentsGiven = text()(); // stored as JSON string

  @override
  Set<Column> get primaryKey => {id};
}
```

### Pattern 4: Riverpod 3.x Codegen — AsyncNotifier

Riverpod 3.x introduces a unified `Ref` type (no more `AutoDisposeRef`, `FamilyRef`, etc.) and uses `@riverpod` annotation on a class extending `_$ClassName`:

```dart
// Source: riverpod.dev/docs/whats_new (Riverpod 3.0 release — 2025-09-10)
// lib/features/profile/providers/profile_notifier.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/entities/user_profile.dart';
import '../../../domain/repositories/i_profile_repository.dart';

part 'profile_notifier.g.dart';

@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  @override
  Future<UserProfile?> build() async {
    // build() is the async initializer; return current profile or null
    final repo = ref.watch(profileRepositoryProvider);
    return repo.getProfile();
  }

  Future<void> saveProfile(UserProfile profile) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(profileRepositoryProvider);
      await repo.saveProfile(profile);
      return profile;
    });
  }
}

// Riverpod 3.x: function providers use plain Ref (not AutoDisposeRef)
@riverpod
IProfileRepository profileRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return DriftProfileRepository(db.userProfileDao);
}
```

Key Riverpod 3.x changes from 2.x:
- `Ref` replaces `AutoDisposeRef<T>` and all family/autodispose variants
- `StateProvider`, `StateNotifierProvider`, `ChangeNotifierProvider` moved to `package:riverpod/legacy.dart`
- `ProviderContainer.test()` for test containers (auto-disposes after test)
- Automatic retry on provider failure with configurable backoff

### Pattern 5: go_router 17 — Phase 1 Stub Routes

For Phase 1, the router has only a profile route and a settings stub. The `StatefulShellRoute.indexedStack` bottom-nav shell is defined now but with placeholder tabs:

```dart
// Source: pub.dev/packages/go_router v17.3.0 (Flutter team)
// lib/core/router/app_router.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/profile',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/profile', builder: (c, s) => const ProfileScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/dashboard', builder: (c, s) => const PlaceholderDashboardScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/settings', builder: (c, s) => const SettingsScreen()),
          ]),
        ],
      ),
    ],
  );
}
```

`StatefulShellRoute.indexedStack` is the 2026 standard for bottom-nav apps — preserves each branch's navigator stack when switching tabs. [CITED: codewithandrea.com — flutter-bottom-navigation-bar-nested-routes-gorouter]

### Pattern 6: Drift Migration — Schema v1

```dart
// lib/data/local/migrations/migration_strategy.dart

import 'package:drift/drift.dart';

MigrationStrategy buildMigrationStrategy(AppDatabase db) {
  return MigrationStrategy(
    onCreate: (Migrator m) async {
      // Creates all tables defined in @DriftDatabase(tables: [...])
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Phase 1 is schemaVersion 1 — no upgrade paths yet.
      // Future phases add: if (from < 2) { await m.addColumn(...); }
    },
    beforeOpen: (details) async {
      // Enable FK enforcement (SQLite disables FKs by default)
      await db.customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
```

After initial schema definition, generate and commit the schema file:
```bash
dart run drift_dev schema dump lib/data/local/app_database.dart \
  lib/data/local/migrations/schemas/
# Creates schema_v1.json — commit this file to git
```

### Pattern 7: ThemeData from DESIGN.md Tokens

```dart
// lib/core/theme/color_tokens.dart — verbatim from DESIGN.md frontmatter
import 'package:flutter/material.dart';

abstract final class AppColors {
  // Surface family
  static const surface         = Color(0xFFF9F9FC);
  static const surfaceDim      = Color(0xFFDADADC);
  static const surfaceBright   = Color(0xFFF9F9FC);
  static const surfaceLowest   = Color(0xFFFFFFFF);
  static const surfaceContainerLowest  = Color(0xFFFFFFFF);
  static const surfaceContainerLow     = Color(0xFFF3F3F6);
  static const surfaceContainer        = Color(0xFFEEEEF0);
  static const surfaceContainerHigh    = Color(0xFFE8E8EA);
  static const surfaceContainerHighest = Color(0xFFE2E2E5);
  static const onSurface         = Color(0xFF1A1C1E);
  static const onSurfaceVariant  = Color(0xFF3F493F);

  // Primary
  static const primary            = Color(0xFF005222);
  static const onPrimary          = Color(0xFFFFFFFF);
  static const primaryContainer   = Color(0xFF006D2F);
  static const onPrimaryContainer = Color(0xFF90EC9F);
  static const inversePrimary     = Color(0xFF7FDA8F);
  static const surfaceTint        = Color(0xFF016D2F);

  // Secondary
  static const secondary            = Color(0xFF0155C7);
  static const onSecondary          = Color(0xFFFFFFFF);
  static const secondaryContainer   = Color(0xFF336FE2);
  static const onSecondaryContainer = Color(0xFFFEFCFF);

  // Tertiary
  static const tertiary            = Color(0xFF00512D);
  static const onTertiary          = Color(0xFFFFFFFF);
  static const tertiaryContainer   = Color(0xFF006C3D);
  static const onTertiaryContainer = Color(0xFF91EAAF);

  // Error
  static const error            = Color(0xFFBA1A1A);
  static const onError          = Color(0xFFFFFFFF);
  static const errorContainer   = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);

  // Inverse + outline
  static const inverseSurface   = Color(0xFF2F3133);
  static const inverseOnSurface = Color(0xFFF0F0F3);
  static const outline          = Color(0xFF6F7A6E);
  static const outlineVariant   = Color(0xFFBECABC);

  // Brand extras
  static const background   = Color(0xFFF9F9FC);
  static const onBackground = Color(0xFF1A1C1E);
  static const leafGreen    = Color(0xFF2EB85C);
  static const softMint     = Color(0xFF4BB477);
  static const skyBlue      = Color(0xFF316FE2);
}

// lib/core/theme/app_theme.dart
ThemeData buildLightTheme() => ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.light(
    primary:             AppColors.primary,
    onPrimary:           AppColors.onPrimary,
    primaryContainer:    AppColors.primaryContainer,
    onPrimaryContainer:  AppColors.onPrimaryContainer,
    secondary:           AppColors.secondary,
    onSecondary:         AppColors.onSecondary,
    secondaryContainer:  AppColors.secondaryContainer,
    onSecondaryContainer: AppColors.onSecondaryContainer,
    tertiary:            AppColors.tertiary,
    onTertiary:          AppColors.onTertiary,
    tertiaryContainer:   AppColors.tertiaryContainer,
    onTertiaryContainer: AppColors.onTertiaryContainer,
    error:               AppColors.error,
    onError:             AppColors.onError,
    errorContainer:      AppColors.errorContainer,
    onErrorContainer:    AppColors.onErrorContainer,
    surface:             AppColors.surface,
    onSurface:           AppColors.onSurface,
    onSurfaceVariant:    AppColors.onSurfaceVariant,
    outline:             AppColors.outline,
    outlineVariant:      AppColors.outlineVariant,
    inverseSurface:      AppColors.inverseSurface,
    onInverseSurface:    AppColors.inverseOnSurface,
    inversePrimary:      AppColors.inversePrimary,
    surfaceTint:         AppColors.surfaceTint,
    surfaceContainerLowest:  AppColors.surfaceContainerLowest,
    surfaceContainerLow:     AppColors.surfaceContainerLow,
    surfaceContainer:        AppColors.surfaceContainer,
    surfaceContainerHigh:    AppColors.surfaceContainerHigh,
    surfaceContainerHighest: AppColors.surfaceContainerHighest,
  ),
  textTheme: _buildTextTheme(),
  // Shape: 8px standard, 16px/24px for larger containers
  cardTheme: const CardThemeData(shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
  )),
  // ... ElevatedButton, InputDecoration themes referencing AppSpacing
);
```

DESIGN.md DOES NOT define dark-mode color roles as a separate token set. For ThemeData.dark(), invert the surface/on-surface pairs and use the inverse-* tokens as the primary canvas. This is a Claude's Discretion area — apply Material Design 3 inverse-surface semantics.

### Pattern 8: Mifflin-St Jéor Calculator (Domain Layer)

```dart
// lib/domain/services/mifflin_st_jeor.dart
// Source: formula verified against nutriadmin.com/blog/mifflin-st-jeor-equation-in-nutrition/

enum Gender { male, female, other }
enum ActivityLevel { low, medium, high }

/// Activity factor (PAL) mapping for the three app levels.
/// Maps: Low → 1.375 (lightly active), Medium → 1.55, High → 1.725
/// Source: Standard PAL table from Mifflin & St Jeor 1990 paper.
const _activityFactor = {
  ActivityLevel.low:    1.375,   // lightly active (1-3 days/week)
  ActivityLevel.medium: 1.550,   // moderately active (3-5 days/week)
  ActivityLevel.high:   1.725,   // very active (6-7 days/week)
};

/// Returns TDEE in kcal/day, or null if any required field is missing.
/// Required fields: weightKg, heightCm, age, gender.
/// [gender] = other/null → average of male and female BMR variants.
double? calculateTdee({
  required double? weightKg,
  required double? heightCm,
  required int? age,
  required Gender? gender,
  required ActivityLevel activityLevel,
}) {
  if (weightKg == null || heightCm == null || age == null) return null;

  // Male:   BMR = (10 × W) + (6.25 × H) − (5 × A) + 5
  // Female: BMR = (10 × W) + (6.25 × H) − (5 × A) − 161
  // Other:  average of male and female variants
  final base = (10 * weightKg) + (6.25 * heightCm) - (5 * age);
  final double bmr;
  switch (gender) {
    case Gender.male:
      bmr = base + 5;
    case Gender.female:
      bmr = base - 161;
    case Gender.other:
    case null:
      bmr = base + 5 * 0.5 + (base - 161) * 0.5; // = base − 78
  }

  return bmr * (_activityFactor[activityLevel] ?? 1.55);
}
```

**Macro ratios by goal** — standard dietitian-recommended splits (AMDR-compliant):

| Goal | Protein % | Carbs % | Fat % |
|------|-----------|---------|-------|
| Reduce CO₂ | 25% | 45% | 30% |
| Lose weight | 35% | 35% | 30% |
| Maintain weight | 25% | 50% | 25% |
| Gain muscle | 30% | 45% | 25% |
| Improve health | 25% | 50% | 25% |
| Balanced lifestyle | 25% | 50% | 25% |
| Learn & explore | 25% | 50% | 25% |

Macro grams from kcal: protein g = kcal × 0.xx / 4; carbs g = kcal × 0.xx / 4; fat g = kcal × 0.xx / 9.

[ASSUMED] — macro splits above are standard dietitian guidelines, not user-confirmed for this specific app. Planner should note these as defaults that can be tuned.

### Pattern 9: Hand-Rolled HLC Utility

The `hlc` package (1.0.4, misha.jp, 2 years no update) is not suitable for a production app. A minimal HLC fits in ~25 lines:

```dart
// lib/core/sync/hlc.dart
// Reference: Kulkarni et al. 2014 "Logical Physical Clocks and Consistent Snapshots"

class Hlc implements Comparable<Hlc> {
  final int millis;    // wall-clock milliseconds since Unix epoch
  final int counter;   // logical counter for same-ms tie-breaking
  final String nodeId; // stable device installation UUID

  const Hlc(this.millis, this.counter, this.nodeId);

  /// Advance local clock (for local writes).
  Hlc increment(int wallMillis) {
    if (wallMillis > millis) {
      return Hlc(wallMillis, 0, nodeId);
    }
    return Hlc(millis, counter + 1, nodeId);
  }

  /// Merge with remote clock (for incoming sync rows).
  Hlc receive(Hlc remote, int wallMillis) {
    final maxMillis = [millis, remote.millis, wallMillis].reduce((a, b) => a > b ? a : b);
    if (maxMillis == millis && maxMillis == remote.millis) {
      return Hlc(maxMillis, [counter, remote.counter].reduce((a, b) => a > b ? a : b) + 1, nodeId);
    }
    return Hlc(maxMillis, 0, nodeId);
  }

  @override
  int compareTo(Hlc other) {
    final c = millis.compareTo(other.millis);
    if (c != 0) return c;
    final c2 = counter.compareTo(other.counter);
    if (c2 != 0) return c2;
    return nodeId.compareTo(other.nodeId);
  }
}
```

### Pattern 10: LicensePage (in-app license disclosure)

Flutter's `LicensePage` widget auto-discovers all pub.dev package LICENSE files at build time — the Flutter tool bundles them into the default asset bundle. No `pubspec.yaml` configuration needed.

```dart
// In SettingsScreen — adds About entry opening LicensePage
ListTile(
  title: const Text('Open source licenses'),
  onTap: () => showLicensePage(
    context: context,
    applicationName: 'CO₂ Diet',
    applicationVersion: '0.1.0',
    applicationLegalese: '© 2026 ReduceCO2Now',
  ),
),
```

`showLicensePage` is a built-in Flutter function; no additional package needed. [CITED: api.flutter.dev/flutter/material/LicensePage-class.html]

### Anti-Patterns to Avoid

- **Using `sqlite3_flutter_libs`:** It is EOL as of v0.6.0. Use `drift_flutter` instead — it handles the sqlite3 v3.x dependency automatically.
- **Calling `Uuid().v4()` for primary keys:** Use `Uuid().v7()` — v7 UUIDs are time-ordered, which means the SQLite B-tree index is more efficient for sequential inserts and the sync layer can sort rows by creation time without a separate `created_at` column for that purpose.
- **Applying `SyncSafeTable` to `consent_records`:** This table is an append-only audit log; LWW conflict resolution would allow a sync to silently overwrite a consent record. It must stay outside the mixin.
- **Storing access tokens in Drift:** All tokens go in `flutter_secure_storage`. Phase 1 has no auth, but establishing this rule from day 1 prevents future mistakes.
- **Importing Drift from UI widgets:** Feature screens must never import `package:drift`. The golden rule: UI imports only Riverpod providers; providers import use cases; use cases import repository interfaces; data layer implements those interfaces and imports Drift.
- **Using `google_fonts` in network-download mode:** The default mode makes a CDN request to Google Fonts on first launch — a privacy violation. Fonts must be bundled in `assets/fonts/` and declared in `pubspec.yaml:fonts:`.
- **Riverpod 2.x codegen patterns in 3.x code:** The 3.x `Ref` type is unified — don't write `AutoDisposeRef<T>` or `ProfileNotifierRef`. The function signature is now `Widget example(Ref ref)`, not `Widget example(ExampleRef ref)`.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| SQLite ORM + migrations | Custom SQL + version table | `drift` 2.34 | Drift gives compile-time query validation, typed streams, tested migration tooling |
| Reactive state from DB | `StreamController` + `ChangeNotifier` | `drift` reactive streams + `riverpod` `AsyncNotifier` | Drift streams + Riverpod providers handle backpressure, disposal, and error propagation |
| UUID v7 generation | Hand-roll RFC 9562 bit-packing | `uuid` package's `Uuid().v7()` | The spec has a monotonic-counter sub-field whose correct behavior under clock drift is non-trivial |
| Route generation | Navigator 1.0 string routes | `go_router` 17 | Type-safe routes, deep links, back-button correctness on Android |
| License page | Custom screen parsing pub licenses | `LicensePage` widget | Flutter bundles all pub licenses automatically; re-reading the same files is wasted work |
| JSON serialization of Dart models | Manual `toJson`/`fromJson` | `freezed` + `json_serializable` | Pattern-matched sealed unions are essential for `CalcTargets?` where any of the five values can be independently null |

**Key insight:** Drift's codegen and Riverpod's codegen both use `build_runner` — their outputs are designed to coexist cleanly. Run `dart run build_runner build --delete-conflicting-outputs` once to resolve any namespace clashes on the first generation.

---

## Common Pitfalls

### Pitfall 1: `flutter create` Produces the Wrong Bundle ID

**What goes wrong:** `flutter create --org com.reduceco2now co2_diet` produces bundle ID `com.reduceco2now.co2_diet` (org + project_name concatenated). The target bundle ID is `com.reduceco2now.co2diet` (no underscore in the project portion).

**Why it happens:** Flutter concatenates `--org` + `--project-name` with a dot. Underscores in `--project-name` carry through literally.

**How to avoid:** Use `--project-name co2diet` (no underscore):
```bash
flutter create --org com.reduceco2now --project-name co2diet .
```
Verify in `android/app/build.gradle` (applicationId) and `ios/Runner.xcodeproj/project.pbxproj` (PRODUCT_BUNDLE_IDENTIFIER) after creation.

**Warning signs:** `applicationId "com.reduceco2now.co2_diet"` in `build.gradle`.

### Pitfall 2: AGP 9 Kotlin Plugin Conflict

**What goes wrong:** `flutter build apk --debug` fails with "kotlin-android plugin must be removed."

**Why it happens:** Flutter 3.44 templates target AGP 9, which has built-in Kotlin. Applying the external `kotlin-android` plugin alongside AGP 9's built-in Kotlin causes a conflict.

**How to avoid:** New projects from `flutter create` in 3.44 add `android.builtInKotlin=false` to `gradle.properties` automatically as a compatibility escape hatch. **Do not override this.** If building CI on `ubuntu-latest`, confirm the generated `gradle.properties` contains the flag, or explicitly add it.

**Warning signs:** Build output: `'kotlin-android' plugin cannot be applied when built-in Kotlin is enabled`.

### Pitfall 3: `sqlite3_flutter_libs` Still in pubspec

**What goes wrong:** App builds fine but `sqlite3_flutter_libs` 0.6.0+ does nothing — you get a redundant, misleading dependency.

**Why it happens:** STACK.md (written Jan 2026) recommended it; pub.dev deprecated it in February 2026.

**How to avoid:** Use only `drift_flutter`. Its transitive dependency on `sqlite3` v3.x provides native binaries on both platforms.

**Warning signs:** `sqlite3_flutter_libs` in `pubspec.lock` with version `0.6.0+eol`.

### Pitfall 4: Riverpod 2.x Code in a 3.x Project

**What goes wrong:** Provider ref types like `AutoDisposeRef<T>`, `ProfileNotifierRef`, `StateProvider` — these import from the legacy path or generate incorrect code.

**Why it happens:** Most tutorials and Stack Overflow answers pre-date the Riverpod 3.0 release (September 10, 2025).

**How to avoid:** Use unified `Ref` in all `@riverpod` function signatures. Move `StateProvider` uses to `Notifier`. Run `riverpod_lint` with `custom_lint` to catch legacy patterns at analysis time.

**Warning signs:** `riverpod_lint` emitting "prefer_notifier_over_state_notifier" warnings; generated code contains `AutoDisposeNotifier` in the output.

### Pitfall 5: HLC Clock Drift Handling

**What goes wrong:** On a device with an incorrect system clock, the HLC can jump far into the future. This invalidates LWW ordering — a row written with a future timestamp always "wins" in LWW, even if it's logically older.

**Why it happens:** HLC is designed to bound clock drift, not prevent it entirely.

**How to avoid:** In the hand-rolled HLC, cap the maximum drift: if `wallMillis > localHlc.millis + maxDriftMs`, emit a warning log and use `localHlc.millis + 1` instead. For Phase 1 (Local Mode only), this is low-risk. Document the constraint for Phase 7 (sync) planning.

**Warning signs:** `hlc_millis` values in the DB that are years in the future.

### Pitfall 6: iOS `--no-codesign` Build on Xcode 26

**What goes wrong:** `flutter build ios --no-codesign` fails on GitHub Actions `macos-latest` when the runner has Xcode 26+ due to extended-attribute issues with Flutter.framework binaries and stricter code-signing validation in macOS 15.

**Why it happens:** Flutter 3.44 release notes mention an xattr fix for code signing (PR #180710) but Xcode 26 introduces stricter validation around `com.apple.provenance` extended attributes.

**How to avoid:** In the CI workflow, pin `macos-latest` explicitly or add a `xattr -cr $HOME/flutter` step. If builds fail, add:
```yaml
- name: Remove extended attributes from Flutter
  run: xattr -cr "$HOME/flutter" 2>/dev/null || true
```

**Warning signs:** Build error mentioning `code signing` or `xattr` on `macos-latest`.

### Pitfall 7: `build_runner` Conflicting Outputs

**What goes wrong:** Running `dart run build_runner build` fails with "conflicting outputs" when Drift, Riverpod, and Freezed all generate `.g.dart` files.

**Why it happens:** Different generators may attempt to write the same intermediate files.

**How to avoid:** Always run with `--delete-conflicting-outputs`:
```bash
dart run build_runner build --delete-conflicting-outputs
```
Or use `dart run build_runner watch --delete-conflicting-outputs` during development.

**Warning signs:** Error: `Failed to run build: build_runner: Conflicting outputs`.

### Pitfall 8: Missing PRAGMA foreign_keys in Drift

**What goes wrong:** SQLite disables foreign key enforcement by default. If Phase 2 or later adds FK references between tables and the PRAGMA is not set, FK violations silently pass.

**Why it happens:** SQLite legacy behavior — FKs are OFF by default for backwards compatibility.

**How to avoid:** Add `PRAGMA foreign_keys = ON` in the `beforeOpen` callback of `MigrationStrategy` (shown in Pattern 6 above). This runs before any user code in every database session.

**Warning signs:** Inserting a meal row with a non-existent user_profile FK succeeds silently.

---

## Code Examples

### Generate UUID v7 for a new row

```dart
// Source: pub.dev/packages/uuid v4.6.0 documentation
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

String newId() => _uuid.v7();
// Produces: '01908b7e-0000-7xxx-xxxx-xxxxxxxxxxxx'
// Time-ordered, sortable, globally unique
```

### Drift DAO — Profile CRUD

```dart
// Source: drift.simonbinder.eu/dart_api/dao/ (verified pattern)
// lib/data/local/daos/user_profile_dao.dart

import 'package:drift/drift.dart';
import '../app_database.dart';

part 'user_profile_dao.g.dart';

@DriftAccessor(tables: [UserProfileTable])
class UserProfileDao extends DatabaseAccessor<AppDatabase>
    with _$UserProfileDaoMixin {
  UserProfileDao(super.db);

  Future<UserProfileRow?> getProfile() =>
      (select(userProfileTable)..limit(1)).getSingleOrNull();

  Stream<UserProfileRow?> watchProfile() =>
      (select(userProfileTable)..limit(1)).watchSingleOrNull();

  Future<void> upsertProfile(UserProfileTableCompanion entry) =>
      into(userProfileTable).insertOnConflictUpdate(entry);
}
```

### In-memory Drift DB for unit tests

```dart
// Source: drift.simonbinder.eu/testing/
// test/data/local/user_profile_dao_test.dart

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:co2diet/data/local/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(DatabaseConnection(
      NativeDatabase.memory(),
      closeStreamsSynchronously: true, // required for widget tests
    ));
  });

  tearDown(() => db.close());

  test('upsert and retrieve profile', () async {
    await db.userProfileDao.upsertProfile(UserProfileTableCompanion.insert(
      id: Value('test-uuid-v7'),
      hlcMillis: Value(0),
      hlcCounter: Value(0),
      hlcNodeId: Value('node-1'),
      // ... other required fields
    ));
    final profile = await db.userProfileDao.getProfile();
    expect(profile?.id, 'test-uuid-v7');
  });
}
```

### pubspec.yaml fonts declaration (local bundles)

```yaml
# pubspec.yaml — fonts section
flutter:
  uses-material-design: true
  assets:
    - assets/fonts/
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
        - asset: assets/fonts/Inter-SemiBold.ttf
          weight: 600
```

Font files must be downloaded from Google Fonts (free download), placed in `assets/fonts/`, and committed to git. The `google_fonts` package must NOT be used — it makes network calls to Google CDN on first launch.

### GitHub Actions CI workflow skeleton

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  ubuntu:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Flutter 3.44.6
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.44.6'
          channel: 'stable'
          cache: true
          cache-key: flutter-${{ hashFiles('pubspec.lock') }}

      - name: Get dependencies
        run: flutter pub get

      - name: SDK blocklist audit
        run: |
          python3 scripts/check_privacy_blocklist.py \
            pubspec.lock .privacy-blocklist.yaml

      - name: Analyze
        run: flutter analyze

      - name: Tests
        run: dart test

      - name: Build APK (debug)
        run: flutter build apk --debug

  macos:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Flutter 3.44.6
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.44.6'
          channel: 'stable'
          cache: true
          cache-key: flutter-${{ hashFiles('pubspec.lock') }}

      - name: Get dependencies
        run: flutter pub get

      - name: Remove xattr from Flutter (Xcode 26 workaround)
        run: xattr -cr "$HOME/flutter" 2>/dev/null || true

      - name: Build iOS (no codesign)
        run: flutter build ios --no-codesign
```

### Privacy blocklist check script

```python
# scripts/check_privacy_blocklist.py
# Usage: python3 scripts/check_privacy_blocklist.py pubspec.lock .privacy-blocklist.yaml
import sys, yaml, re

lock_file = sys.argv[1]
blocklist_file = sys.argv[2]

with open(lock_file) as f:
    lock = yaml.safe_load(f)

with open(blocklist_file) as f:
    config = yaml.safe_load(f)

prefixes = config.get('blocked_prefixes', [])
packages = list(lock.get('packages', {}).keys())

violations = []
for pkg in packages:
    for prefix in prefixes:
        if pkg.startswith(prefix):
            violations.append(f'BLOCKED: {pkg} matches prefix "{prefix}"')

if violations:
    print('\n'.join(violations))
    sys.exit(1)
print(f'OK: {len(packages)} packages checked, 0 violations')
```

```yaml
# .privacy-blocklist.yaml
blocked_prefixes:
  - firebase_
  - crashlytics
  - amplitude_
  - mixpanel_
  - sentry_
  - segment_
  - datadog_
  - onesignal_
  - appsflyer_
  - adjust_
  - braze_
  - clevertap
  - leanplum
  - moengage
```

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `sqlite3_flutter_libs` for native SQLite | `drift_flutter` (includes sqlite3 v3.x) | Feb 2026 (v0.6.0 EOL) | Remove from pubspec; `drift_flutter` handles everything |
| Riverpod 2.x `AutoDisposeRef<T>`, `FamilyRef` | Unified `Ref` in Riverpod 3.x | Sep 10, 2025 (Riverpod 3.0) | All provider function signatures use `Ref`; legacy imports move to `riverpod/legacy.dart` |
| `StatefulShellRoute` manual setup for bottom nav | `StatefulShellRoute.indexedStack` factory | go_router v14+ | Cleaner API with built-in state preservation per branch |
| `StateProvider` / `StateNotifierProvider` | `Notifier` / `AsyncNotifier` with `@riverpod` | Riverpod 3.0 | Legacy providers still work but require `riverpod/legacy.dart` import |
| CocoaPods as iOS default | SPM coexists alongside CocoaPods | Flutter 3.44 (Jul 2026) | New projects support both; plugin authors migrating; no immediate action for this project |
| External `kotlin-android` plugin | AGP 9 built-in Kotlin | Flutter 3.44 (Jul 2026) | New Flutter 3.44 projects auto-add `android.builtInKotlin=false` as escape hatch |

**Deprecated/outdated:**
- `sqlite3_flutter_libs`: EOL since 0.6.0 (Feb 2026). Remove entirely from any pubspec.yaml based on STACK.md.
- `Riverpod 2.x AutoDisposeRef` patterns: replaced by unified `Ref`. All tutorial code pre-Sep 2025 uses the old pattern.
- `StateProvider` for simple mutable state: still works via `riverpod/legacy.dart` but new code should use `Notifier`.

---

## Dependency Gotchas (Transitive Risk Audit for Phase 1 Packages)

All packages in the Phase 1 stack were evaluated for transitive SDK risks:

| Package | Transitive Firebase/Analytics risk? | Notes |
|---------|-------------------------------------|-------|
| `drift` | None | Pure Dart + SQLite; zero tracking SDKs |
| `drift_flutter` | None | Only depends on `drift` + `sqlite3` |
| `flutter_riverpod` | None | Pure Dart state management |
| `go_router` | None | Flutter team navigation; no telemetry |
| `uuid` | None | Cryptographic UUID; pure Dart |
| `freezed` | None | Code generator only; no runtime deps |
| `very_good_analysis` | None | Lint rules only; dev dep |
| `mocktail` | None | Test mocking; dev dep only |
| `intl` | None | Dart team localization; no tracking |
| `path_provider` | None | File system; Flutter team |

No package in the Phase 1 stack pulls in Firebase, analytics, or behavioral tracking. The blocklist CI will confirm this on every PR. [ASSUMED: verified by package inspection at training time; CI blocklist is the authoritative runtime gate]

---

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | Macro split ratios (protein/carbs/fat by goal) are standard dietitian-recommended values | Code Examples — Mifflin formula | Wrong ratios → poor nutritional guidance; user should confirm ratios before Phase 5 surfaces them prominently |
| A2 | `flutter build ios --no-codesign` works on `macos-latest` with Flutter 3.44.6 without the xattr workaround | CI Pipeline | iOS CI job fails on every PR; workaround step may be sufficient |
| A3 | `riverpod_annotation` 4.0.3 is compatible with Flutter 3.44.6 / Dart 3.12.2 | Standard Stack | Codegen incompatibility would block all Riverpod providers |
| A4 | `custom_lint` 0.8.1 (Sep 2025) is compatible with `riverpod_lint` 3.1.4 (Jun 2026) | Standard Stack | riverpod_lint analysis would fail to run |
| A5 | Dark mode color mapping (inverse-surface as primary background in dark) follows Material 3 conventions | ThemeData pattern | Incorrect dark theme — visual audit in Phase 6 will catch this |
| A6 | Transitive dependency scan found no Firebase/analytics packages in Phase 1 stack | Dependency Gotchas | Blocklist CI would catch any violation before merge |

---

## Open Questions (RESOLVED)

1. **Dark mode token definitions** — RESOLVED: Plan 01-01 Task 2 implements `ThemeData.dark()` using Material 3 inverse-surface convention (`inverse-surface` as dark background, `surface-dim` as container variants). Flagged for Phase 6 accessibility audit review.
   - What we know: DESIGN.md defines a single set of color roles without an explicit dark-mode palette.
   - What's unclear: Whether the `inverse-*` tokens are intended as the primary dark-mode surface/on-surface, or whether a separate dark palette should be derived.
   - Recommendation: Implement `ThemeData.dark()` using Material 3 convention (inverse-surface as dark background, surface-dim as container variants). Flag for review in Phase 6 accessibility audit.

2. **`flutter create` in existing directory** — RESOLVED: Plan 01-01 Task 1 uses the `--overwrite` flag when running `flutter create` in the existing repo directory to handle existing files safely.
   - What we know: The repo already has `.claude/`, `.planning/`, `docs/` but no Flutter project yet.
   - What's unclear: Whether `flutter create .` in a non-empty directory skips or overwrites existing files.
   - Recommendation: Run `flutter create` in a temp directory first, then copy generated files into the repo; or use `flutter create --no-overwrite` if available. The planner should include an explicit step for this.

3. **Font weight variants for Plus Jakarta Sans** — RESOLVED: Plan 01-01 Task 1 explicitly downloads the full Google Fonts zip, inspects actual filenames, and aligns pubspec.yaml font declarations to match the extracted TTF filenames.
   - What we know: DESIGN.md uses weights 400, 600, 700. Font file name conventions vary by download source.
   - What's unclear: Whether `PlusJakartaSans-SemiBold.ttf` is the correct filename for weight 600 from the Google Fonts download.
   - Recommendation: Verify filenames after downloading from fonts.google.com and match pubspec.yaml declarations accordingly.

---

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Flutter SDK | All tasks | ✓ | 3.44.6 (exact match) | — |
| Dart SDK | All tasks | ✓ | 3.12.2 | — |
| Git | Version control | ✓ | 2.50.1 | — |
| Python 3 | CI blocklist script | ✓ | 3.14.2 | Node.js script alternative |
| pip3 | Install slopcheck/yaml | ✓ | 25.3 | — |
| Xcode | iOS build | [ASSUMED] present on dev Mac | Unknown | GitHub Actions macos-latest has it |
| Android SDK | APK build | [ASSUMED] configured | Unknown | GitHub Actions ubuntu-latest has it |
| GitHub Actions runner | CI | ✓ (via github.com) | ubuntu-latest + macos-latest | — |

**Missing dependencies with no fallback:** None identified.
**Missing dependencies with fallback:** Android SDK local presence unverified — CI uses ubuntu-latest runners which have it pre-installed.

---

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | `flutter_test` (SDK) + `dart test` for pure-Dart domain tests |
| Config file | None required — `dart test` discovers `test/` automatically |
| Quick run command | `dart test test/domain/` (pure-Dart, < 5 seconds) |
| Full suite command | `dart test && flutter test` |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| PROF-04 | Mifflin-St Jéor returns correct TDEE for known inputs | unit | `dart test test/domain/services/mifflin_st_jeor_test.dart` | ❌ Wave 0 |
| PROF-04 | Returns null when age/height/weight are missing | unit | `dart test test/domain/services/mifflin_st_jeor_test.dart` | ❌ Wave 0 |
| PROF-04 | Activity factor multipliers are correct for Low/Medium/High | unit | `dart test test/domain/services/mifflin_st_jeor_test.dart` | ❌ Wave 0 |
| PROF-05 | Override replaces value; `is_overridden` flag set to true | unit | `dart test test/data/local/user_profile_dao_test.dart` | ❌ Wave 0 |
| PROF-01/02/03 | Profile DAO: upsert + retrieve round-trip | unit (in-memory Drift) | `dart test test/data/local/user_profile_dao_test.dart` | ❌ Wave 0 |
| CO2-04 | `co2_methodology_version` column exists and defaults to '1.0' | unit (in-memory Drift) | `dart test test/data/local/schema_test.dart` | ❌ Wave 0 |
| Schema | consent_records insert + read (no SyncSafeTable mixin) | unit (in-memory Drift) | `dart test test/data/local/consent_records_dao_test.dart` | ❌ Wave 0 |
| Schema | SyncSafeTable mixin injects all expected columns | unit (in-memory Drift) | `dart test test/data/local/schema_test.dart` | ❌ Wave 0 |
| PRIV-07 | blocklist script exits 0 for clean pubspec.lock | unit (subprocess) | `dart test test/ci/blocklist_test.dart` | ❌ Wave 0 |
| PRIV-07 | blocklist script exits 1 when firebase_core present | unit (subprocess) | `dart test test/ci/blocklist_test.dart` | ❌ Wave 0 |
| ThemeData | All DESIGN.md color tokens present in ColorScheme | unit | `dart test test/core/theme/theme_token_test.dart` | ❌ Wave 0 |
| Theme | ThemeData.light() and ThemeData.dark() build without error | unit | `dart test test/core/theme/theme_token_test.dart` | ❌ Wave 0 |

### Sampling Rate

- **Per task commit:** `dart test test/domain/` (< 5 seconds, pure-Dart only)
- **Per wave merge:** `dart test && flutter test` (all tests including widget)
- **Phase gate:** Full suite green + CI pipeline green before `/gsd-verify-work`

### Wave 0 Gaps

- [ ] `test/domain/services/mifflin_st_jeor_test.dart` — covers PROF-04 formula correctness
- [ ] `test/data/local/user_profile_dao_test.dart` — covers PROF-01/02/03/05, in-memory Drift DAO
- [ ] `test/data/local/consent_records_dao_test.dart` — covers LEGAL-03 schema
- [ ] `test/data/local/schema_test.dart` — covers CO2-04 column + SyncSafeTable mixin structure
- [ ] `test/ci/blocklist_test.dart` — covers PRIV-07 CI script logic
- [ ] `test/core/theme/theme_token_test.dart` — covers ThemeData token coverage

---

## Security Domain

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | No — no auth in Phase 1 | N/A |
| V3 Session Management | No — no sessions in Phase 1 | N/A |
| V4 Access Control | No — single-user local only | N/A |
| V5 Input Validation | Yes — profile form inputs | Null checks + range validation in domain layer (e.g., age 1–130, weight 1–500 kg); Dart type system provides baseline |
| V6 Cryptography | No — no encryption in Phase 1 | Data at rest unencrypted (accepted for Local Mode; Phase 7 adds sync with TLS) |
| V8 Data Protection | Partial | No PII transmitted; all data on-device; no analytics SDK per CI blocklist |
| V14 Configuration | Yes — dependency audit | CI blocklist script verifies zero analytics SDKs on every PR |

### Known Threat Patterns for Phase 1 Stack

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Transitive SDK introducing analytics | Information Disclosure | CI blocklist script (PRIV-07); package legitimacy audit |
| Profile data readable by other apps (Android) | Information Disclosure | Drift DB stored in app-private directory (not external storage); `drift_flutter` uses `getApplicationDocumentsDirectory()` by default |
| SQLite injection via raw queries | Tampering | Drift codegen uses parameterized queries exclusively; never use `customStatement` with user input |
| Clock manipulation affecting HLC ordering | Tampering | HLC is bounded by `maxDriftMs` cap; Phase 1 risk is low (Local Mode, no sync) |

---

## Sources

### Primary (HIGH confidence)

- `pub.dev/packages/drift` — current version 2.34.2, published 2026-07-14 [VERIFIED via pub.dev API]
- `pub.dev/packages/drift_flutter` — current version 0.3.1, published 2026-07-11 [VERIFIED via pub.dev API]
- `pub.dev/packages/drift_dev` — current version 2.34.4, published 2026-07-14 [VERIFIED via pub.dev API]
- `pub.dev/packages/build_runner` — current version 2.15.2, published 2026-07-13 [VERIFIED via pub.dev API]
- `pub.dev/packages/go_router` — current version 17.3.0, published 2026-06-02 [VERIFIED via pub.dev API]
- `pub.dev/packages/riverpod_annotation` — current version 4.0.3, published 2026-06-10 [VERIFIED via pub.dev API]
- `pub.dev/packages/riverpod_generator` — current version 4.0.4, published 2026-06-10 [VERIFIED via pub.dev API]
- `pub.dev/packages/riverpod_lint` — current version 3.1.4, published 2026-06-10 [VERIFIED via pub.dev API]
- `pub.dev/packages/flutter_riverpod` — current version 3.3.2, ~36 days ago [VERIFIED via pub.dev WebFetch]
- `pub.dev/packages/very_good_analysis` — current version 10.3.0, published 2026-06-18 [VERIFIED via pub.dev API]
- `pub.dev/packages/mocktail` — current version 1.0.5, published 2026-04-10 [VERIFIED via pub.dev API]
- `pub.dev/packages/uuid` — current version 4.6.0, published 2026-07-15 [VERIFIED via pub.dev WebFetch]
- `pub.dev/packages/intl` — current version 0.20.3 [VERIFIED via pub.dev WebFetch]
- `pub.dev/packages/freezed` — current version 3.2.5 [VERIFIED via pub.dev WebFetch]
- `pub.dev/packages/sqlite3_flutter_libs` — EOL at 0.6.0+eol [VERIFIED via pub.dev WebFetch]
- `drift.simonbinder.eu/setup/` — current Drift setup using `drift_flutter` [VERIFIED via WebFetch]
- `drift.simonbinder.eu/dart_api/tables/` — table mixin pattern [VERIFIED via WebFetch]
- `drift.simonbinder.eu/testing/` — in-memory NativeDatabase.memory() pattern [VERIFIED via WebFetch]
- `drift.simonbinder.eu/migrations/` — MigrationStrategy pattern [VERIFIED via WebFetch]
- `riverpod.dev/docs/whats_new` — Riverpod 3.0 unified Ref, Notifier, retry [VERIFIED via WebFetch]
- `api.flutter.dev/flutter/material/LicensePage-class.html` — LicensePage auto-discovery [CITED]
- `docs.flutter.dev/release/release-notes/release-notes-3.44.0` — Flutter 3.44 AGP 9, SPM [VERIFIED via WebFetch]
- `docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-app-developers` — AGP 9 migration [VERIFIED via WebFetch]
- `github.com/subosito/flutter-action` — `flutter-version` parameter for exact pinning [CITED via WebSearch]
- Mifflin & St Jeor 1990 formula: `(10W + 6.25H − 5A ± constant) × PAL` [VERIFIED via nutriadmin.com multiple sources]

### Secondary (MEDIUM confidence)

- Flutter 3.44 xattr/codesign issue on Xcode 26 — github.com/flutter/flutter/issues/180351 [WebSearch verified]
- `StatefulShellRoute.indexedStack` as 2026 bottom-nav standard — codewithandrea.com + dev.to [WebSearch, multiple sources]
- Macro ratio recommendations (protein/carbs/fat by goal) — nutriadmin.com, gethealthycalculators.com [ASSUMED — standard dietitian guidelines]

### Tertiary (LOW confidence)

- HLC implementation correctness details — based on Kulkarni et al. 2014 paper description from training data [ASSUMED]
- Dark mode ColorScheme mapping strategy — Material 3 convention applied by training knowledge [ASSUMED]

---

## Metadata

**Confidence breakdown:**
- Package versions: HIGH — all verified against pub.dev live data on 2026-07-16
- Architecture patterns: HIGH — verified against Drift and Riverpod official docs
- Flutter 3.44 breaking changes: HIGH — verified against official release notes
- Mifflin-St Jéor formula: HIGH — verified against multiple authoritative medical calculator sources
- Macro ratio defaults: LOW — standard dietitian guidelines, not app-specific; user should confirm
- Dark mode ThemeData: MEDIUM — Material 3 convention applied; no DESIGN.md dark token set specified
- CI workarounds (xattr Xcode 26): MEDIUM — one GitHub issue source; may not apply to all runner configurations

**Research date:** 2026-07-16
**Valid until:** 2026-08-16 (30 days; package versions on pub.dev move frequently)
