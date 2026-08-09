---
phase: 07-keycloak-auth-account-mode-sync
plan: 02
subsystem: auth
tags: [flutter_appauth, flutter_secure_storage, oidc, pkce, keycloak, riverpod, dependency-injection]

# Dependency graph
requires:
  - phase: 07-01
    provides: Wave 0 test stubs for AUTH-01–06/PRIV-05/CO2 methodology announcement (skipped, awaiting implementation)
provides:
  - flutter_appauth 12.0.2 and flutter_secure_storage 11.0.0 installed and human-approved
  - Native Android/iOS redirect-URI scheme wiring (com.reduceco2now.co2diet.auth)
  - AuthState sealed class (AuthUnauthenticated{sessionExpired}, AuthAuthenticated{email,accessToken})
  - KeycloakConfig (issuer, clientId, redirectUrl, scopes, appleIdpAlias, googleIdpAlias) — all [ASSUMED]
  - BackendConfig (baseUrl) — [ASSUMED]
  - auth_providers.dart (secureStorageProvider, appAuthProvider, authHttpClientProvider)
affects: [07-03-auth-notifier, 07-05-auth-screen, 07-06-account-section, 07-08-routing]

# Tech tracking
tech-stack:
  added: [flutter_appauth 12.0.2, flutter_secure_storage 11.0.0, http 1.6.0 (promoted to direct dep)]
  patterns:
    - "Plain sealed-class state (not Freezed) with static ergonomic factories — mirrors FoodSearchState (Phase 02-06)"
    - "Config-only static-const classes ([ASSUMED] doc-commented) as the single source of truth for external-service values"
    - "keepAlive DI wrapper providers for thin third-party client instances, read via bare ref.read from mutation methods"

key-files:
  created:
    - lib/domain/entities/auth_state.dart
    - lib/domain/services/keycloak_config.dart
    - lib/domain/services/backend_config.dart
    - lib/core/di/auth_providers.dart
  modified:
    - pubspec.yaml
    - android/app/build.gradle.kts
    - ios/Runner/Info.plist

key-decisions:
  - "Package legitimacy checkpoint approved by user after independent pub.dev signal review (160/160 scores, verified publishers, active maintenance) — pub.dev/Dart isn't a slopcheck-supported ecosystem"
  - "http promoted from transitive to direct dependency per very_good_analysis depend_on_referenced_packages rule, since BackendConfig-consuming code will import it directly"
  - "KeycloakConfig/BackendConfig use private unnamed constructors (const ClassName._()) as static-only config holders — no instances are ever created"

patterns-established:
  - "Pattern: [ASSUMED] values get an inline doc comment citing the exact 07-RESEARCH.md Assumptions Log entry (A1-A5) they correspond to, plus a class-level warning they are not a production contract"

requirements-completed: [AUTH-10]

# Metrics
duration: 7min
completed: 2026-08-09
---

# Phase 07 Plan 02: Keycloak Auth Foundations Summary

**Installed flutter_appauth 12.0.2 + flutter_secure_storage 11.0.0 (human-approved), wired native OIDC redirect-URI schemes on Android/iOS, and created the shared AuthState/KeycloakConfig/BackendConfig/auth_providers.dart contracts every later Phase 7 auth plan builds against.**

## Performance

- **Duration:** ~7 min (resumed after checkpoint approval)
- **Started:** 2026-08-09T14:52:03Z
- **Completed:** 2026-08-09T14:58:07Z
- **Tasks:** 2 (plus 1 checkpoint approved by prior session)
- **Files modified:** 11 (4 created, 7 modified — including 2 incidental generated-code files)

## Accomplishments
- flutter_appauth and flutter_secure_storage installed after blocking package-legitimacy checkpoint approval; privacy blocklist (AUTH-10) verified 0 violations across 196 packages
- Android manifestPlaceholders + iOS CFBundleURLTypes both register `com.reduceco2now.co2diet.auth` as the OIDC redirect scheme, matching `KeycloakConfig.redirectUrl` byte-for-byte
- AuthState sealed class gives every later plan one shared, exhaustive session-state shape (never logged in / logged in)
- KeycloakConfig/BackendConfig centralize every Keycloak/backend value behind `[ASSUMED]` doc comments citing the exact Assumptions Log entry, so the real-realm handoff from Tomris is a one-file change
- auth_providers.dart's three keepAlive wrapper providers (secureStorage, appAuth, authHttpClient) are ready for Plan 07-03's AuthNotifier to consume

## Task Commits

Each task was committed atomically:

1. **Task 1: Install packages + native redirect-scheme wiring** - `5db2b3e` (feat)
2. **Task 2: AuthState, KeycloakConfig, BackendConfig, auth_providers.dart** - `d609b1e` (feat)

**Plan metadata:** (pending — final docs commit below)

## Files Created/Modified
- `pubspec.yaml` - flutter_appauth ^12.0.2, flutter_secure_storage ^11.0.0 added; http promoted to direct dependency, each with a version-comment block matching the project's existing convention
- `pubspec.lock` - dependency lockfile updated
- `android/app/build.gradle.kts` - `appAuthRedirectScheme` manifestPlaceholder added to `defaultConfig`
- `ios/Runner/Info.plist` - `CFBundleURLTypes`/`CFBundleURLSchemes` entry added
- `lib/domain/entities/auth_state.dart` - `AuthState` sealed class (`AuthUnauthenticated`, `AuthAuthenticated`)
- `lib/domain/services/keycloak_config.dart` - `KeycloakConfig` static-const class, all six fields `[ASSUMED]`
- `lib/domain/services/backend_config.dart` - `BackendConfig.baseUrl`, `[ASSUMED]`
- `lib/core/di/auth_providers.dart` - `secureStorageProvider`, `appAuthProvider`, `authHttpClientProvider` (all keepAlive)
- `lib/core/di/auth_providers.g.dart` - riverpod_generator output
- `ios/Runner.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved` - new SPM lockfile (flutter_appauth's iOS AppAuth-iOS dependency), first plugin in this project to use Swift Package Manager
- `linux/flutter/generated_plugin_registrant.cc`, `linux/flutter/generated_plugins.cmake`, `macos/Flutter/GeneratedPluginRegistrant.swift`, `windows/flutter/generated_plugin_registrant.cc`, `windows/flutter/generated_plugins.cmake` - regenerated by `flutter pub get` to register the two new plugins' desktop implementations (present even though this app targets iOS/Android only, per Flutter's default multi-platform scaffold)
- `lib/features/onboarding/providers/onboarding_gate_provider.g.dart` - incidentally regenerated by `dart run build_runner build` (doc-comment bracket-reference escaping only, no logic change)

## Decisions Made
- Package legitimacy checkpoint (flutter_appauth 12.0.2, flutter_secure_storage 11.0.0) was approved by the user in a prior session after independent pub.dev signal review — no re-verification performed per resume instructions
- `http` promoted from transitive to direct pubspec dependency, matching the project's established `depend_on_referenced_packages` precedent (path, collection)
- `KeycloakConfig`/`BackendConfig` use a private unnamed constructor (`const ClassName._()`) to make them non-instantiable static-only config holders — kept `flutter analyze` fully clean rather than accepting the default `avoid_classes_with_only_static_members` risk

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Corrected privacy-blocklist script invocation**
- **Found during:** Task 1 verification
- **Issue:** Plan's automated verify command referenced `tool/check_privacy_deps.dart`, but the script actually lives at `scripts/check_privacy_deps.dart` and requires two positional args (`pubspec.lock` and `.privacy-blocklist.yaml`) — the plan's bare `dart run tool/check_privacy_deps.dart` would fail immediately with "file not found"
- **Fix:** Ran `dart run scripts/check_privacy_deps.dart pubspec.lock .privacy-blocklist.yaml` instead — this is the script's actual documented CLI usage (confirmed via its own usage message)
- **Files modified:** None (verification-only correction, no source change)
- **Verification:** `OK: 196 packages checked, 0 violations`, exit 0
- **Committed in:** N/A (verification step only)

**2. [Rule 1 - Bug] Fixed `flutter analyze` info-level lints in new files**
- **Found during:** Task 2 verification
- **Issue:** Initial drafts of `auth_state.dart`, `keycloak_config.dart`, `backend_config.dart`, and `auth_providers.dart` triggered 12 `info`-level lints (`lines_longer_than_80_chars`, `comment_references` from unescaped `[ASSUMED]`/`[BackendConfig...]` doc-comment brackets resolving to non-existent symbols) — the project's existing DI files (`providers.dart`, `legal_providers.dart`) analyze with zero issues, so this fell short of that established bar
- **Fix:** Wrapped `[ASSUMED]` in backticks instead of square brackets (avoids dartdoc treating it as an unresolvable symbol reference), reflowed two over-80-character lines, and changed one comment reference to backtick-quoted plain text
- **Files modified:** `lib/domain/entities/auth_state.dart`, `lib/domain/services/keycloak_config.dart`, `lib/domain/services/backend_config.dart`, `lib/core/di/auth_providers.dart`
- **Verification:** `flutter analyze` on all four files reports "No issues found!"
- **Committed in:** `d609b1e` (Task 2 commit)

---

**Total deviations:** 2 auto-fixed (2 Rule 1 bug fixes, both verification/correctness — no scope creep, no architectural changes)
**Impact on plan:** Both fixes were necessary to actually run the plan's own verification commands and to meet the plan's stated "zero lint errors" done-criterion at the same quality bar as sibling DI files.

## Issues Encountered
- `dart run build_runner build` incidentally regenerated `lib/features/onboarding/providers/onboarding_gate_provider.g.dart` (doc-comment bracket-to-backtick escaping churn from riverpod_generator processing the whole codebase in one pass) — no logic change, included in the Task 2 commit rather than left as untracked drift.
- Five desktop-platform files (`linux/flutter/*`, `macos/Flutter/GeneratedPluginRegistrant.swift`, `windows/flutter/*`) were regenerated by `flutter pub get` to register the new plugins' Linux/macOS/Windows implementations, even though this project only ships iOS/Android — this is Flutter's default multi-platform plugin registration behavior for every `pub get`, not something introduced by this plan; included in the Task 1 commit for a consistent lockstep state with `pubspec.lock`.

## User Setup Required

None - no external service configuration required. (Real Keycloak realm coordination with Tomris remains a pre-Phase-7-completion backend dependency, tracked in STATE.md's "Backend Coordination" section — not a Plan 07-02 blocker.)

## Next Phase Readiness

Plan 07-03 (AuthNotifier) can now:
- Call `flutter_appauth`/`flutter_secure_storage` APIs immediately (installed, human-approved, privacy-blocklist-green)
- Read `AuthState`/`KeycloakConfig`/`BackendConfig` as pure, dependency-free contracts
- Read `secureStorageProvider`/`appAuthProvider`/`authHttpClientProvider` via `ref.read` from mutation methods without UnmountedRefException risk

No blockers. Native redirect-URI wiring has not yet been verified via a real system-browser round trip on-device (that verification belongs to whichever later plan first exercises the login flow end-to-end, e.g. 07-03 or 07-05's checkpoint).

## Known Stubs

None — all four created files are pure contracts (constants, sealed-class variants, thin DI wrapper providers) with no data source to stub. No hardcoded empty UI-facing values, no placeholder text, no unwired components.

## Threat Flags

None beyond what the plan's own `<threat_model>` already covers (T-07-02-SC package installs, T-07-02-01 redirect-scheme spoofing acceptance) — no new network endpoints, auth paths, file access patterns, or schema changes were introduced outside those two entries.

---
*Phase: 07-keycloak-auth-account-mode-sync*
*Completed: 2026-08-09*

## Self-Check: PASSED

All 5 file claims verified present on disk (4 created source files + this SUMMARY.md). Both task commit hashes (`5db2b3e`, `d609b1e`) verified present in `git log --oneline --all`.
