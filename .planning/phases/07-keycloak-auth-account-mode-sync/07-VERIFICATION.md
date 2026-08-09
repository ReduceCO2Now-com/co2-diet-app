---
phase: 07-keycloak-auth-account-mode-sync
verified: 2026-08-09T16:39:42Z
status: human_needed
score: 5/5 roadmap success criteria verified at code level (40/40 plan-level must-haves verified); 5 items require human/external verification once Tomris's Keycloak realm + backend GDPR endpoint exist
overrides_applied: 0
human_verification:
  - test: "Apple Sign-in end-to-end via Keycloak IdP on a real iOS device"
    expected: "Tapping the Apple button on a real iPhone completes the Apple OAuth flow and returns the app to a logged-in state"
    why_human: "Requires a live, configured Keycloak realm + Apple IdP broker (does not exist yet, per 07-RESEARCH.md's backend repo scan) and a real Apple ID; cannot be mocked meaningfully. This is a named, documented dependency in ROADMAP.md's Phase 7 'Depends on' line, not an oversight."
  - test: "Google Sign-in end-to-end via Keycloak IdP on a real device"
    expected: "Tapping the Google button completes the OAuth flow and returns the app to a logged-in state on both Android and iOS"
    why_human: "Same reason as Apple — requires live Keycloak + Google IdP broker, neither of which exists yet."
  - test: "Full email/password signup -> verification email -> login round trip against the real Keycloak realm"
    expected: "Signing up with a real email delivers a verification link; login succeeds only after clicking it"
    why_human: "Requires a live realm with email delivery configured; local mocks (used by auth_provider_test.dart) cannot verify actual email deliverability or link validity."
  - test: "Account deletion against the real (not-yet-built) backend GDPR endpoint"
    expected: "Deleting a real test account removes the Keycloak user record; local data is untouched"
    why_human: "The backend DELETE /me/account endpoint doesn't exist yet — this phase's automated tests only cover the client-side flow against a mocked response. docs/backend-contracts/gdpr-account-deletion.md is a written [ASSUMED] proposal awaiting Tomris's confirmation, not a description of an already-built endpoint."
  - test: "App Store Guideline 4.8 compliance of the Keycloak-brokered (non-native-SDK) Apple Sign-in flow"
    expected: "A TestFlight submission using this web-broker Apple Sign-in flow passes App Store review"
    why_human: "No authoritative source confirms a web-broker Apple Sign-in (vs. native ASAuthorizationController) passes App Store review; this is a real-world review-outcome question flagged as 07-RESEARCH.md's highest-risk item, not something a test can assert."
---

# Phase 7: Keycloak Auth + Account Deletion — Verification Report

**Phase Goal:** Add Account Mode's authentication surface as a pure, self-contained enhancement — Keycloak OIDC login (email/password, Apple, Google), logout, password reset, GDPR account deletion, and a local-only CO₂ methodology-update announcement — with zero data movement, so Local Mode users are completely unaffected and nothing here depends on a backend sync/data-ownership model that doesn't exist yet.

**Verified:** 2026-08-09T16:39:42Z
**Status:** human_needed
**Re-verification:** No — initial verification

## Goal Achievement

### Observable Truths (Roadmap Success Criteria)

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | Email/password create-account (email verified before login completes), stay-logged-in-across-sessions, log out from any screen, reset password via secure Keycloak-hosted email link — all via OIDC+PKCE/system browser; refresh token in secure storage, access token in-memory only; zero Firebase/Supabase | ✓ VERIFIED (code-complete) | `lib/features/auth/providers/auth_provider.dart`: `signUp`/`signIn` use `AuthorizationTokenRequest` via `flutter_appauth` (PKCE, system browser); `_completeSignIn` gates on `/userinfo`'s `email_verified` claim before persisting anything; `AuthState.accessToken` never written to secure storage (only `kRefreshTokenKey`/`kCachedEmailKey` are); `logout()` clears state unconditionally; `_launchForgotPassword()` in `auth_screen.dart` opens Keycloak's hosted `reset-credentials` page via `url_launcher` — no in-app reset form exists. `dart scripts/check_privacy_deps.dart pubspec.lock .privacy-blocklist.yaml` → `OK: 196 packages checked, 0 violations`. Live cross-session persistence against a real realm is a Human Verification item (below). |
| 2 | Apple Sign-in (iOS-only, Keycloak IdP, no native Apple SDK) and Google Sign-in (Keycloak IdP) complete sign-up/sign-in end-to-end on real devices | ✓ VERIFIED (code-complete) / human item for real-device completion | `auth_screen.dart`: Apple button renders only `if (_showAppleButton)` (`Platform.isIOS`), positioned above Google, which always renders (`auth_screen_test.dart` "Apple button only renders on iOS" passes). `signInWithIdp('apple'|'google')` passes `kc_idp_hint` — no `apple_sign_in`/`sign_in_with_apple` native package in `pubspec.yaml`. Real-device end-to-end completion requires Tomris's live realm + IdP brokers — Human Verification item. |
| 3 | Creating/logging into an account moves zero local data; honesty note visible at signup/login; Dashboard mode indicator reflects "still stored locally" without implying backup exists | ✓ VERIFIED | `auth_screen.dart` renders the honesty note text unconditionally (outside any mode-specific `if`), confirmed by `auth_screen_test.dart`'s "honesty note text is always visible" test (2 passing widget builds, create-account + sign-in). `mode_indicator.dart`: `isLocalMode ? 'Stored on this device' : 'Account Mode: Data still stored locally (sync coming soon)'` — the old hardcoded `'Synced across devices'` string is gone (`grep -c "Synced across devices"` → not found in `mode_indicator.dart`). Wired to real state: `placeholder_dashboard_screen.dart:298` — `isLocalMode: ref.watch(authProvider) is! AuthAuthenticated`. |
| 4 | Permanent account deletion in-app; Keycloak user removed same operation (immediate hard delete, no grace period) within legal timeframe; local data untouched by default; deletion logged in local `consent_records` | ✓ VERIFIED (client-side) / human item for real backend | `auth_provider.dart`'s `deleteAccount()`: throws `AccountDeletionException` and leaves state/storage untouched on any non-2xx; on 2xx, clears storage, sets `AuthUnauthenticated`, then records one `consentsGiven: ['account_deletion']` row via `consentRepositoryProvider`. `account_section.dart`'s single confirmation dialog has no typed-word field, no re-auth, and a destructive-styled confirm button — matches locked copy. Backend `DELETE /me/account` doesn't exist yet; `docs/backend-contracts/gdpr-account-deletion.md` is an explicit `[ASSUMED]` proposal for Tomris — Human Verification item. |
| 5 | Local-only CO₂ methodology-update mechanism: stale entries trigger a non-intrusive, dismissible Dashboard banner; zero backend dependency; version constant not bumped this phase | ✓ VERIFIED | `methodology_version_checker.dart`: `currentCo2MethodologyVersion = '1.0'` (unchanged), pure `isStale`/`hasAnyStale` logic, zero Drift/DB imports (confirmed via file read — only takes plain strings). `methodology_banner_provider.dart` composes real DB reads (`userProfileDao`/`mealEntryDao`/`userFoodDao`) with the pure checker. `co2_methodology_banner.dart` renders `SizedBox.shrink()` unless `showMethodologyBannerProvider` resolves `true`; dismissal is per-version via `SharedPreferences` (`MethodologyBannerDismissalNotifier`). All 8 `methodology_version_checker_test.dart` + 2 `co2_methodology_banner_test.dart` cases pass. |

**Score:** 5/5 roadmap success criteria verified at the code level (all client-side implementation exists, is substantive, and is wired). 3 of these 5 (SC1's live persistence, SC2, SC4) additionally require human verification once Tomris's Keycloak realm and backend GDPR endpoint exist — see Human Verification Required below.

### Plan-Level Must-Haves (all 8 plans)

All 35 plan-frontmatter `must_haves.truths` entries across `07-01` through `07-08` were independently checked against the actual code (not SUMMARY.md claims) and are VERIFIED:

| Plan | Must-haves checked | Status |
|------|--------------------|--------|
| 07-01 | 5 Wave-0 stub files created; all `skip:` markers removed by the plans that implement them | ✓ VERIFIED — `grep -n "skip:"` across all 5 files returns zero matches |
| 07-02 | Packages installed + privacy blocklist green; native redirect scheme matches `KeycloakConfig.redirectUrl` byte-for-byte on both platforms; `AuthState` is exactly 2 variants; single shared config source | ✓ VERIFIED — `appAuthRedirectScheme`/`CFBundleURLSchemes` both `com.reduceco2now.co2diet.auth`; `KeycloakConfig`/`BackendConfig` are the sole source read by every later plan |
| 07-03 | Zero-network cold start when unauthenticated; optimistic silent restore; connectivity-failure ≠ logout; exactly-one consent row per signup/deletion; deleteAccount never mutates state on non-2xx; unverified email never reaches `AuthAuthenticated` | ✓ VERIFIED — read `auth_provider.dart` in full; logic matches every clause; all 16 `auth_provider_test.dart` cases pass |
| 07-04 | `isStale(null)` never stale; current-version never stale; zero Drift/DB imports | ✓ VERIFIED — 8/8 tests pass, file has zero DB imports |
| 07-05 | Defaults to create-account; Apple above Google, iOS-only; honesty note always visible; offline blocks browser pre-flight; no in-app reset form; Resend never double-writes consent | ✓ VERIFIED — 12/12 `auth_screen_test.dart` cases pass, code matches each clause |
| 07-06 | Account section absent (no skeleton) until realm-discovery resolves true; zero-tap logout; single confirmation dialog for delete, no typed word/re-auth; failed deletion leaves signed-in UI intact with inline error; successful deletion shows confirmation before reverting | ✓ VERIFIED — `settings_screen.dart`'s `if (accountReady) ...` renders nothing (not even a placeholder) when false; 9/9 `account_section_test.dart` cases pass |
| 07-07 | Banner dormant while no stale entries (constant never bumped); dismissal is per-version; Learn More reuses `/data-analysis` | ✓ VERIFIED — `showMethodologyBannerProvider` composes staleness + per-version dismissal; `co2_methodology_banner.dart`'s `onTap` pushes `/data-analysis` |
| 07-08 | `ModeIndicator` reflects real auth state, no false "Synced" copy; `/auth`/`/check-email` reachable without onboarding-gate bypass; Legal Hub cross-references Delete Account; `terms.md` version bumped + new Account Mode section; written GDPR contract spec exists; full suite green + AUTH-10 CI check passes | ✓ VERIFIED — all confirmed above; `flutter test` → 473 tests, all passed |

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `lib/domain/entities/auth_state.dart` | `AuthState` sealed class, 2 variants | ✓ VERIFIED | `AuthUnauthenticated{sessionExpired}` / `AuthAuthenticated{email,accessToken}`, exhaustive `switch` used at every call site |
| `lib/domain/services/keycloak_config.dart` | Single-source realm config | ✓ VERIFIED | issuer/clientId/redirectUrl/scopes/appleIdpAlias/googleIdpAlias, all `[ASSUMED]`-documented |
| `lib/domain/services/backend_config.dart` | Single-source backend base URL | ✓ VERIFIED | `baseUrl`, read only by `deleteAccount()` and the GDPR contract doc |
| `lib/core/di/auth_providers.dart` | `secureStorage`/`appAuth`/`authHttpClient` keepAlive DI wrappers | ✓ VERIFIED | thin wrappers, no app logic, matches `.g.dart` generated file present |
| `lib/features/auth/providers/auth_provider.dart` | `AuthNotifier` full lifecycle | ✓ VERIFIED | build/signIn/signUp/signInWithIdp/logout/deleteAccount/acknowledgeSessionExpired all present and substantive |
| `lib/features/auth/providers/realm_discovery_provider.dart` | `realmDiscoveryReadyProvider` | ✓ VERIFIED | keepAlive, 3s timeout, resolves `false` on any exception, never propagates an error |
| `lib/features/auth/screens/auth_screen.dart` | Combined sign-in/create-account screen | ✓ VERIFIED | social + email/password + honesty note + consent checkbox, all locked copy present |
| `lib/features/auth/screens/check_email_screen.dart` | Post-signup pre-verification screen | ✓ VERIFIED | Resend action reuses `signUp(recordConsent: false)` |
| `lib/features/auth/widgets/apple_sign_in_button.dart` / `google_sign_in_button.dart` | Hand-rolled social buttons | ✓ VERIFIED | HIG/brand-approximate styling; pixel-exact brand assets explicitly out of scope, documented in code comments |
| `lib/features/settings/widgets/account_section.dart` | Full signed-out/signed-in lifecycle + deletion | ✓ VERIFIED | all rows present, delete dialog matches locked copy exactly |
| `lib/domain/services/methodology_version_checker.dart` | Pure staleness comparison | ✓ VERIFIED | zero DB imports, `currentCo2MethodologyVersion = '1.0'` |
| `lib/features/dashboard/providers/methodology_banner_provider.dart` | Real DB reads + dismissal state | ✓ VERIFIED | composes `MethodologyVersionChecker` with `AppDatabase` DAOs |
| `lib/features/dashboard/widgets/co2_methodology_banner.dart` | Dismissible banner | ✓ VERIFIED | `SizedBox.shrink()` when dormant, `/data-analysis` Learn More link |
| `docs/backend-contracts/gdpr-account-deletion.md` | Written API-contract spec for Tomris | ✓ VERIFIED | every field marked `[ASSUMED — not yet confirmed with Tomris]`, open-questions list present |

### Key Link Verification

| From | To | Via | Status | Details |
|------|-----|-----|--------|---------|
| `android/app/build.gradle.kts` | `keycloak_config.dart` | `appAuthRedirectScheme` manifest placeholder | ✓ WIRED | both = `com.reduceco2now.co2diet.auth` |
| `ios/Runner/Info.plist` | `keycloak_config.dart` | `CFBundleURLSchemes` | ✓ WIRED | both = `com.reduceco2now.co2diet.auth` |
| `auth_provider.dart` | `auth_providers.dart` | `ref.read(secureStorageProvider/appAuthProvider/authHttpClientProvider)` | ✓ WIRED | confirmed by direct read of file |
| `auth_provider.dart` | `legal_providers.dart` | `consentRepositoryProvider.recordConsent(...)` for `account_mode_terms`/`account_deletion` | ✓ WIRED | confirmed in `_completeSignIn` and `deleteAccount` |
| `auth_provider.dart` | `backend_config.dart` | `http.delete('${BackendConfig.baseUrl}/me/account', ...)` | ✓ WIRED | confirmed |
| `auth_screen.dart` | `auth_provider.dart` | `ref.read(authProvider.notifier).signUp/signIn/signInWithIdp` | ✓ WIRED | confirmed |
| `auth_screen.dart` | `connectivity_plus` | pre-flight `Connectivity().checkConnectivity()` | ✓ WIRED | confirmed, blocks browser launch when offline |
| `settings_screen.dart` | `realm_discovery_provider.dart` | `ref.watch(realmDiscoveryReadyProvider)` gates `AccountSection` | ✓ WIRED | `if (accountReady) ...` — section entirely absent when false |
| `account_section.dart` | `auth_provider.dart` | `ref.watch(authProvider)` / `.logout()`/`.deleteAccount()` | ✓ WIRED | confirmed |
| `app_router.dart` | `auth_screen.dart`/`check_email_screen.dart` | `GoRoute(path: '/auth', ...)`/`'/check-email'` | ✓ WIRED | both registered, not in `onboardingOnlyRoutes` allowlist (reachable post-onboarding only) |
| `placeholder_dashboard_screen.dart` | `auth_provider.dart` | `ModeIndicator(isLocalMode: ref.watch(authProvider) is! AuthAuthenticated)` | ✓ WIRED | confirmed |
| `methodology_banner_provider.dart` | `methodology_version_checker.dart` | `MethodologyVersionChecker().hasAnyStale(...)` | ✓ WIRED | confirmed |
| `placeholder_dashboard_screen.dart` | `co2_methodology_banner.dart` | `Co2MethodologyBanner()` rendered above `ModeIndicator` | ✓ WIRED | confirmed |

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| All 5 Phase 7 test files are green, zero skips | `flutter test test/features/auth/ test/features/settings/widgets/account_section_test.dart test/domain/services/methodology_version_checker_test.dart test/features/dashboard/widgets/co2_methodology_banner_test.dart` | 52/52 passed | ✓ PASS |
| Full regression suite green | `flutter test` | 473/473 passed (9 unrelated skips in `notification_service_test.dart`, pre-existing) | ✓ PASS |
| AUTH-10 privacy blocklist check | `dart scripts/check_privacy_deps.dart pubspec.lock .privacy-blocklist.yaml` | `OK: 196 packages checked, 0 violations` | ✓ PASS |
| No debt markers (TBD/FIXME/XXX/TODO/HACK) in Phase 7 files | `grep -n -i -E "TBD\|FIXME\|XXX\|TODO\|HACK" <19 phase-7 files>` | zero real matches (one false-positive substring in unrelated chart code) | ✓ PASS |

### Requirements Coverage

| Requirement | Source Plan(s) | Description | Status | Evidence |
|-------------|-----------------|-------------|--------|----------|
| AUTH-01 | 07-01, 07-03, 07-05, 07-08 | Create account with email/password, verified before login | ✓ SATISFIED (client-side; live email-round-trip is human item) | `_completeSignIn`'s `email_verified` gate, `AuthScreen` create-account flow |
| AUTH-02 | 07-01, 07-03, 07-06, 07-08 | Log in, stay logged in across sessions | ✓ SATISFIED (client-side; live session-persistence is human item) | `_silentRefresh()`, `AccountSection`'s signed-in state |
| AUTH-03 | 07-01, 07-03, 07-06, 07-08 | Log out from any screen | ✓ SATISFIED | `AccountSection`'s single-tap `logout()`, reachable via Settings from any bottom-nav tab |
| AUTH-04 | 07-01, 07-05 | Reset password via secure email link | ✓ SATISFIED | `_launchForgotPassword()` opens Keycloak's hosted `reset-credentials` page externally |
| AUTH-05 | 07-01, 07-03, 07-05, 07-08 | Apple Sign-in via Keycloak IdP, iOS-only, no native SDK | ✓ SATISFIED (client-side; real-device end-to-end + App Store review outcome are human items) | `AppleSignInButton` iOS-gated, `signInWithIdp('apple')`, no native Apple SDK package |
| AUTH-06 | 07-01, 07-03, 07-05, 07-08 | Google Sign-in via Keycloak IdP | ✓ SATISFIED (client-side; real-device end-to-end is human item) | `GoogleSignInButton`, `signInWithIdp('google')` |
| AUTH-10 | 07-02, 07-03, 07-08 | Keycloak OIDC+PKCE only, no Firebase/Supabase | ✓ SATISFIED | privacy blocklist check passes on real `pubspec.lock`; `flutter_appauth`/`flutter_secure_storage` are the only new deps |
| PRIV-05 | 07-01, 07-03, 07-06, 07-08 | Permanent account deletion, Keycloak user removed same op, local data untouched, logged in `consent_records` | ✓ SATISFIED (client-side; real backend endpoint is human item) | `deleteAccount()`, `AccountSection`'s confirmation dialog, `docs/backend-contracts/gdpr-account-deletion.md` |

No orphaned requirements found: `.planning/REQUIREMENTS.md`'s traceability table maps exactly these 8 IDs to Phase 7, all "Complete." (`CO2-04` is also implemented this phase per ROADMAP.md's explanatory note, but is officially traced to Phase 1 in REQUIREMENTS.md's table and was not in this verification's assigned ID list — implementation confirmed anyway under "Observable Truths #5" for completeness, no discrepancy found.)

### Anti-Patterns Found

None. Scanned all 19 files created/modified across Plans 07-01–07-08 for `TBD`/`FIXME`/`XXX`/`TODO`/`HACK`/empty handlers (`onPressed: () {}`)/`console.log`-only implementations — zero real matches. No `skip:` markers remain in any of the 5 Wave-0 stub files.

### Human Verification Required

See frontmatter `human_verification` — 5 items, all pre-identified and documented by the phase's own `07-VALIDATION.md` "Manual-Only Verifications" table, all gated on infrastructure (live Keycloak realm, Apple/Google IdP brokers, backend GDPR endpoint) that Tomris has not yet deployed. This is consistent with ROADMAP.md's explicit Phase 7 "Depends on" line: *"requires a live Keycloak realm + Apple/Google IdP config from Tomris (the entire Account section in Settings is gated behind a live realm-discovery check and stays hidden until that's ready)."*

1. **Apple Sign-in end-to-end (real iOS device)** — requires Tomris's live Keycloak realm + Apple IdP broker.
2. **Google Sign-in end-to-end (real device)** — requires Tomris's live Keycloak realm + Google IdP broker.
3. **Email/password signup → verification email → login round trip** — requires a live realm with email delivery configured.
4. **Account deletion against the real backend GDPR endpoint** — the endpoint doesn't exist yet; only the client-side flow is testable today.
5. **App Store Guideline 4.8 review outcome for the web-broker Apple Sign-in flow** — no test can assert Apple's review decision; recommend an early TestFlight submission to probe this.

### Gaps Summary

No coding gaps found. Every artifact this phase's 8 plans committed to exists, is substantive (not a stub), is correctly wired, and is covered by a passing automated test (52 phase-specific + 421 pre-existing, 473 total, all green). The privacy blocklist (AUTH-10) passes against the real `pubspec.lock`. Native redirect-URI schemes match `KeycloakConfig.redirectUrl` byte-for-byte on both Android and iOS. No debt markers, no empty handlers, no hardcoded-empty data flows.

The 5 items requiring human verification are not implementation gaps — they are pre-identified, unavoidable consequences of this phase's own explicit scope decision (ROADMAP.md/07-CONTEXT.md: build the auth surface without depending on backend infrastructure that doesn't exist yet). They cannot be closed by more Flutter code; they require Tomris to deploy a live Keycloak realm, configure the Apple/Google IdP brokers, and implement the `DELETE /me/account` endpoint. `realmDiscoveryReadyProvider` correctly keeps the entire Account section hidden from real users until that infrastructure exists, so Local Mode users remain completely unaffected in the meantime — the phase goal's core "pure, self-contained enhancement" and "zero data movement" claims are independently verified true today.

---

_Verified: 2026-08-09T16:39:42Z_
_Verifier: Claude (gsd-verifier)_
