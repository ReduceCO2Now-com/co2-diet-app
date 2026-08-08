# Phase 7: Keycloak Auth + Account Deletion - Research

**Researched:** 2026-08-08
**Domain:** OIDC/PKCE mobile authentication (Keycloak) + GDPR account deletion + local-only version-comparison banner
**Confidence:** MEDIUM — Flutter-side package/pattern research is HIGH confidence (verified against pub.dev registry + official READMEs); Keycloak-realm-specific and backend-contract claims are LOW-MEDIUM because no live realm or GDPR endpoint exists yet (confirmed via direct scan of the sibling backend reference repo).

## Summary

This phase adds a self-contained authentication surface (Keycloak OIDC + PKCE via `flutter_appauth`) and GDPR account deletion to an app that is otherwise fully local-first. The Flutter-side implementation pattern is well-established and verifiable today: `flutter_appauth` (MaikuB/dexterx.dev, v12.0.2) handles the authorization-code+PKCE dance and token exchange against any OIDC-compliant discovery document, `flutter_secure_storage` (v11.0.0) is the standard place for the refresh token, and Keycloak's own hosted pages (login, password reset, account-management) are opened via `flutter_appauth`'s system-browser flow or `url_launcher`'s external-browser mode — never a custom in-app form for password-related actions, which matches the locked CONTEXT.md decisions.

The riskier unknowns are all on the Keycloak-server and backend-API side, not the Flutter side: no realm, no Apple/Google identity-provider broker config, and no GDPR delete/export endpoints exist in the backend reference repo scanned for this research (`~/Documents/ReduceCO2-Now/CO2Diet_Backend-reference`, confirmed via direct file read of `SecurityConfig.java` and `application.yml`). The backend is configured only as an OAuth2 **resource server** validating JWTs against `issuer-uri: http://localhost:8081/realms/co2diet` — nothing else Keycloak-related exists in the repo. This means every Keycloak-realm-specific value used below (realm name, client ID, IdP aliases, redirect URI scheme) is a **placeholder convention**, not a confirmed contract, and is flagged `[ASSUMED]` throughout. The planner should treat realm/IdP configuration as a coordination checkpoint with Tomris, not a solved input.

**Primary recommendation:** Build the entire Flutter-side auth surface (`AuthNotifier` + PKCE flow + secure token storage + realm-discovery gate + account-deletion call) against the standard OIDC/Keycloak conventions documented here, using a configurable realm URL/client ID (not hardcoded), so the code is correct and testable in isolation today and only needs real values plugged in once Tomris's realm exists.

## User Constraints (from CONTEXT.md)

### Locked Decisions

**Roadmap deviation (flag for planner and for a future ROADMAP.md update):** ROADMAP.md's Phase 7 goal bundles Keycloak auth, Local→Account upgrade, and a bidirectional outbox+HLC+LWW sync engine into one phase, requiring AUTH-01 through AUTH-10, PRIV-05 (CO2-07 does not exist — REQUIREMENTS.md itself flags this as a stale roadmap reference). A backend repo scan (`CO2Diet_Backend`, cloned as reference material) found this doesn't match reality: the backend is early scaffolding (~15 Java files, 4 endpoints, no Keycloak realm/IdP config, no GDPR endpoints, no account/user data model), and its own architecture doc explicitly avoids the backend ever owning bidirectional user data — sync there is designed one-directional (server→device, catalog-only), with personal-data backup an undecided open item.

**Decision: split the phase.** This round of Phase 7 delivers only what doesn't require a backend sync/data-ownership model:
- Keycloak OIDC/PKCE auth: email/password signup, login, logout, password reset (AUTH-01, AUTH-02, AUTH-03, AUTH-04, AUTH-10)
- Apple Sign-in (iOS-only) and Google Sign-in via Keycloak IdPs (AUTH-05, AUTH-06)
- GDPR account deletion (PRIV-05)
- A local-only CO2 methodology-update announcement (roadmap success criterion #5's non-sync half)

**What this phase does NOT include (deferred to a new future phase, pending a data-ownership conversation with Tomris):**
- The outbox/HLC/LWW bidirectional sync engine (AUTH-09)
- Local→Account upgrade with zero data loss (AUTH-08) — account creation this phase does NOT move any local data
- The onboarding Mode Choice screen (two equal-weight cards) and its ONBD-03 equal-weight audit — Account Mode has no tangible benefit to weigh against Local Mode until sync exists
- Onboarding Carousel's optional 4th slide (account-mode messaging)

Local Mode remains fully unaffected and unchanged throughout (AUTH-07, already complete).

#### Auth Screens & Sign-up/Login Flow

- **Layout:** Social buttons first (Apple above Google, iOS-only for Apple; Android shows Google + email only), then an "or" divider, then email/password fields below.
- **Brand compliance:** Apple and Google sign-in buttons follow their official brand/HIG guidelines exactly (required for App Store review; Apple explicitly rejects non-compliant buttons) — not restyled to match the app's design system.
- **Entry point:** One combined "Sign in / Create account" row in Settings → single screen with both methods, distinguished by a toggle/link ("Already have an account? Sign in"), not two separate rows/screens.
- **Password reset:** Hands off to the system browser via Keycloak's own hosted reset page — no custom in-app reset UI, consistent with the OIDC/PKCE pattern already used for login itself.
- **Change password (post-login):** A "Change password" row in Settings' Account section, also opening Keycloak's hosted account-management page via the system browser.
- **Errors:** Inline red helper text below the relevant field, matching the app's existing form-validation pattern (Profile Setup, Custom Food form). Keycloak's brute-force-lockout error is passed through and shown the same way — no dedicated lockout UI.
- **Email verification:** Required before first login completes (Keycloak realm's "Verify email" required action) — a logged-in account is always verified.
- **Post-signup, pre-verification:** A dedicated "Check your email" screen ("We sent a verification link to {email}. Verify, then come back and sign in.") with a "Resend email" action, rather than dumping the user back on the login form.
- **Post-login/signup landing:** Back to Settings, now showing the logged-in Account state — no navigation surprise, since the entry point was Settings.
- **Honesty note:** A one-line note ("Your existing local data stays on this device — cross-device sync is coming soon") shown on BOTH the signup and login paths — nothing syncs down on login either. No additional persuasive/value-prop copy beyond this fact; account creation is offered, not pitched (matches the app's non-manipulative principle).
- **Signup fields:** Email + password only — no display name field. Confirmed via a full-text search of the original PRD (`docs/Diet-Mobile-app ReduceCO2Now.pdf`, all 40 pages): zero mention of a profile icon, avatar, or display name anywhere in navigation/header context. Not a PRD-driven requirement.
- **Password field:** Single field with a show/hide toggle — no confirm-password field.
- **Password validation:** Client-side pre-check (min 8 chars) for fast feedback; Keycloak's realm policy is the actual source of truth, surfaced via the same inline-error pattern on rejection.
- **Autofill:** Flutter `AutofillGroup`/`autofillHints` (username, password, newPassword) wired on the fields — directly honors the original PRD's explicit password-manager intent ("use existing password managers if possible").
- **PKCE handoff:** An in-app loading state is shown before/behind the system browser opens (standard `flutter_appauth` pattern).
- **Cancelled auth:** Backing out of the system browser returns silently to the auth screen — no error message for an intentional cancellation.
- **Session persistence:** Always persistent (refresh token in secure storage, access token in memory only) — no "stay signed in" toggle; matches AUTH-02 literally.
- **Signup consent:** A separate, lightweight "I agree to the Terms for Account Mode" checkbox at signup — distinct from the Local Mode legal consent already captured at onboarding, since the backend has zero consent-tracking of its own. Recorded as a new `consent_records` entry (new consent type). Links to a new "Account Mode & Data" section added to the existing `docs/legal/terms.md` (version-bumped), not a new 5th legal document.
- **Connectivity pre-check:** Uses the existing `connectivity_plus` dependency before opening the system browser; shows an inline "Sign-in requires an internet connection" message if offline rather than letting the browser fail.
- **Backend-readiness gate:** The entire Account section in Settings is hidden until Keycloak's realm OIDC discovery endpoint (`/realms/co2diet/.well-known/openid-configuration`) responds successfully — a first-party endpoint, not a third-party remote-config service (keeps the privacy "no third-party SDKs" constraint intact). Checked once per app session, cached until restart (not re-pinged every Settings visit). No skeleton/loading placeholder — the Account section just doesn't render until resolved, then appears.
- **Mode indicator:** Dashboard's `mode_indicator` widget (`lib/features/dashboard/widgets/mode_indicator.dart`, currently hardcoded `isLocalMode=true`) updates to "Account Mode: Data still stored locally (sync coming soon)" once logged in, and reverts immediately to "Local Mode: Stored on this device" on logout or session death.
- **Logout:** Immediate, no confirmation dialog (low-stakes, nothing to lose since nothing was synced). Reachable only via Settings — satisfies AUTH-03's "log out from any screen" through the ≤2-taps-via-bottom-nav reasoning already used for Legal Hub, not a persistent header/overflow button.

#### Settings Integration & Session Lifecycle

- **Placement:** A new "Account" section positioned after the core feature rows (Search foods, My Foods, CO2 Settings, Weight Tracking, Backup & Restore, Meal Reminders) but before Legal & Privacy / Open source licenses — discoverable without visually outranking the app's actual functionality (an earlier "top of Settings" proposal was explicitly rejected for overselling a feature that's honestly minimal today).
- **Logged-in display:** Account email + "Change password" row + "Log out" row, all in the Account section.
- **Token refresh:** Silent refresh on launch using the stored refresh token — no visible loading state.
- **Session death (genuine invalidation — revoked/expired refresh token, not a network blip):** Silent fallback to logged-out state, plus a one-time "You've been signed out" notice.
- **Network failure vs. real invalidation:** Explicitly distinguished. A refresh failing due to no connectivity does NOT trigger logout — the app stays optimistically logged-in (nothing this phase depends on a freshly-validated token anyway) until a genuine server rejection (`invalid_grant`, revoked token) occurs. Prevents falsely logging out offline users in an offline-first app.

#### Account Deletion Flow (GDPR / PRIV-05)

- **Location:** "Delete account" lives in the new Account section — deliberately separate from the existing Danger Zone (Phase 5's local-data wipe, PRIV-09), since they're different actions with different consequences.
- **Local data:** Untouched by default when the backend account is deleted (nothing was ever synced away, so there's nothing to lose) — user reverts to Local Mode with all local data intact. Danger Zone's "Delete all local data" remains a separate, deliberate action if the user also wants to wipe the device.
- **Confirmation:** A single dialog stating consequences explicitly ("Your account will be permanently deleted. Your local data on this device will NOT be affected.") with a destructive-styled confirm button — same friction level as the existing Danger Zone wipe, no re-authentication/typed-phrase requirement.
- **Deletion timing:** Immediate hard delete, no grace/recovery period — defines the backend contract Tomris needs to build as a single DELETE endpoint (no scheduled-purge job needed).
- **Failure handling:** Inline error on failure; no local state changes until the backend confirms success — user retries manually. Avoids a mismatched "app thinks deleted, backend disagrees" state.
- **Post-deletion:** Confirmation message, then the Account section reverts to signed-out state — user stays on Settings, rest of the app unaffected.
- **Audit trail:** Deletion writes a new `consent_records` entry (new consent type, e.g. `account_deletion`), reusing Phase 1's append-only schema — visible in the existing "View my consent history" screen (Phase 6), no new schema.
- **Legal Hub cross-reference:** Phase 6's "Your Rights" section (Legal Hub) gets updated to also reference the new in-app Delete Account flow for Account Mode users, alongside its existing Danger Zone/uninstall references.

#### CO2 Methodology Announcement

- **Ships in this phase**, despite being conceptually separate from auth — confirmed genuinely local-only via codebase scan: the CO2 catalog (`off_reference.sqlite`) is fully bundled and decompressed on first launch (`first_launch_extractor.dart`), `co2MethodologyVersion` is a hardcoded domain-layer default (`'1.0'`, `user_profile.dart`), and there is no live "check server for current version" call anywhere in the codebase. Zero backend dependency.
- **Mechanism:** On app launch, compare each `UserProfile`/`UserFood`/`MealEntry` row's stored `co2MethodologyVersion`/`co2MethodologyVersionSnapshot` against a current app-binary constant. Rows with a **null** snapshot are excluded from the check (never had a CO2 estimate applied — per the existing Phase 4 rule that null means CO2-absent or `co2Source == 'manual'` — so they can't be "outdated").
- **This phase builds the mechanism only.** It does NOT bump the actual version constant (stays `'1.0'`) or change any CO2 factor data — the banner stays dormant for real users until some future release (e.g., a factor-table update, or Phase 8's fuller OFF pack) actually increments the constant. (Note: ROADMAP.md's Phase 8 description separately mentions a live/CDN-fetched "methodology-version announcement flow" — that's a future live-fetch variant, distinct from and not blocking this phase's simpler local-only comparison.)
- **UI:** Non-intrusive, dismissible Dashboard banner/card ("CO2 estimates updated with methodology v{X} — your past entries keep their original estimates"), with a "Learn more" link to the existing Estimate Transparency screen (Phase 5) rather than new explanatory copy. Dismissal is remembered per-version via a locally-stored flag, so it doesn't reappear until the next real bump.

### Claude's Discretion

- Exact copy/wording throughout (error messages, banner text, confirmation dialog phrasing) beyond the tone/content direction given above
- Realm-discovery endpoint check implementation details (timeout duration, exact caching mechanism/storage)
- Structural placement of the new "Account Mode & Data" section within `terms.md`
- go_router route naming, provider file organization for new auth-related code (`@riverpod class` codegen conventions already established)
- `flutter_appauth` configuration details (redirect URI scheme, exact PKCE parameters)
- Secure storage key naming for the refresh token
- `consent_records` consent-type string naming for the new `account_deletion` and account-mode-terms entries

### Deferred Ideas (OUT OF SCOPE)

- **Outbox/HLC/LWW bidirectional sync engine (AUTH-09)** — deferred to a new future phase, pending an explicit backend data-ownership conversation with Tomris. The backend's own architecture doc currently avoids owning user data entirely (one-directional catalog-only sync design; backup story undecided between encrypted blob and user-cloud export).
- **Local→Account upgrade with zero data loss (AUTH-08)** — deferred to that same future sync phase; this phase's account creation does not move any local data.
- **Mode Choice screen (two equal-weight cards) + ONBD-03 equal-weight audit** — deferred to the same future sync phase, since Account Mode has no tangible benefit to weigh against Local Mode until sync exists. No onboarding-flow scaffolding built this phase.
- **Onboarding Carousel's optional 4th slide** (account-mode data/control messaging) — still available whenever Mode Choice ships.
- **Live/remote-fetched methodology version check** — ROADMAP.md's Phase 8 description mentions this for the future CDN-delivered OFF pack; not needed for this phase's local-only, app-binary-constant comparison.
- **Account linking behavior across identity providers** (e.g., same email registering via Google then later via password) — a Keycloak realm-configuration concern, not a Flutter-side decision. Flagged as a coordination point with Tomris, not resolved here.
- **ROADMAP.md structural update** — Phase 7's entry should eventually be split/edited to reflect this narrower scope and a new phase inserted for the deferred sync work. Not done as part of this discussion; flagged for a follow-up `/gsd:insert-phase` or manual roadmap edit before/after planning.

## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| AUTH-01 | Create account email/password, email verified before login completes | `flutter_appauth` PKCE signup flow + Keycloak "Verify email" required action (Code Examples, Common Pitfalls: Email Verification Gate) |
| AUTH-02 | Log in, stay logged in across sessions | Refresh token in `flutter_secure_storage`, silent refresh on launch pattern (Architecture Patterns: AuthNotifier) |
| AUTH-03 | Log out from any screen | Settings-based logout row, `endSession`/local token clear pattern (Code Examples: Logout) |
| AUTH-04 | Reset password via secure email link | Keycloak hosted `login-actions/reset-credentials` page, opened externally, no in-app form (Code Examples: Password Reset) |
| AUTH-05 | Apple Sign-in via Keycloak IdP, no native SDK | `kc_idp_hint` broker pattern + App Store 4.8 analysis (Common Pitfalls: Apple Sign-in Compliance) |
| AUTH-06 | Google Sign-in via Keycloak IdP | Same `kc_idp_hint` broker pattern, `google` alias |
| AUTH-10 | All auth via Keycloak OIDC + PKCE, no Firebase/Supabase | Standard Stack: `flutter_appauth` is the only auth package added; zero Firebase/Supabase packages in Standard Stack |
| PRIV-05 | Permanent account deletion, Keycloak user deleted, GDPR Art. 17 timeframe | Assumed `DELETE /me/account` contract (Open Questions #1, Assumptions Log A2), `consent_records` audit entry pattern (existing DAO, no schema change) |

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Email/password signup & login (PKCE) | Browser / Client (system browser via `flutter_appauth`) | API/Backend (Keycloak validates credentials) | AppAuth SDK hands the entire credential-entry UI to Keycloak's own hosted login page rendered in the system browser — the Flutter app never sees the password |
| Apple/Google social login | Browser / Client (system browser, Keycloak IdP broker) | — | Keycloak brokers the OAuth handshake with Apple/Google entirely server-side; Flutter only launches the authorization URL with `kc_idp_hint` and receives the final code |
| Token storage & refresh | Browser / Client (on-device) | — | Refresh token in OS Keychain/Keystore via `flutter_secure_storage`; access token in memory only (Riverpod state) — no backend session state exists for the mobile client to synchronize with |
| Password reset / change password | Browser / Client (system browser, Keycloak hosted pages) | — | No custom UI; entirely Keycloak's own web pages, matching AUTH-04's "secure email link" requirement without the app touching credentials |
| Realm-discovery readiness gate | Browser / Client (on-device check) | API/Backend (Keycloak's own `.well-known` endpoint) | A first-party HTTP GET, not a remote-config SDK — keeps the "no third-party SDKs" privacy invariant intact |
| GDPR account deletion | API / Backend (new endpoint to be built by Tomris) | Browser / Client (triggers the call, writes local audit record) | Deleting the actual Keycloak user record must happen server-side; the Flutter app is a thin trigger + local audit-log writer |
| Consent audit trail (`account_mode_terms`, `account_deletion`) | Database / Storage (local Drift, `consent_records` table) | — | Existing Phase 1 append-only table, per-device by design (see table's own doc comment) — never synced to backend |
| CO2 methodology-version banner | Browser / Client (on-device comparison + dismissible UI) | Database / Storage (reads `co2MethodologyVersion(Snapshot)` columns) | Zero backend dependency this phase; pure local comparison against an app-binary constant |
| Mode indicator (Dashboard) | Browser / Client (reads local auth state) | — | Reflects in-memory `AuthNotifier` state, not a server round-trip |

## Standard Stack

### Core

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| `flutter_appauth` | 12.0.2 (published 2026-06-26) `[VERIFIED: pub.dev registry — direct API fetch confirmed version + publish date]` | OIDC Authorization Code + PKCE flow via native AppAuth (Android)/AppAuth-iOS SDKs; system browser (Custom Tabs/`ASWebAuthenticationSession`) | Only actively-maintained Flutter plugin providing spec-compliant native AppAuth bridging; the project's own locked decision (STATE.md: "Auth: Keycloak OIDC + PKCE via `flutter_appauth`") already names it; verified publisher `dexterx.dev` on pub.dev, 160/160 pub points |
| `flutter_secure_storage` | 11.0.0 (published ~38h before research date) `[VERIFIED: pub.dev registry — direct API fetch]` | Refresh-token persistence in iOS Keychain / Android platform-specific secure cipher (not plain SharedPreferences) | Industry-standard choice for Flutter secure token storage; verified publisher `steenbakker.dev`, 160/160 pub points, 3.47M 30-day downloads, actively maintained (community continuation of the original `mogol` package) |

### Supporting

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `connectivity_plus` | 7.3.0 (already a pubspec dependency) `[VERIFIED: existing pubspec.yaml]` | Pre-flight "are we online" check before opening the system browser for auth, matching the locked "Sign-in requires an internet connection" inline-message decision | Already used identically for the OFF API fallback (Phase 2) — reuse verbatim, no new dependency |
| `url_launcher` | ^6.3.1 (already a pubspec dependency) `[VERIFIED: existing pubspec.yaml]` | Opening Keycloak's hosted password-reset (`login-actions/reset-credentials`) and account-management (`/account/account-security/signing-in`) pages, which are NOT part of the OIDC code-exchange flow and therefore don't need `flutter_appauth`'s `authorize()` | Any Keycloak-hosted page that isn't itself a token-issuing redirect target |
| `package_info_plus` | ^10.2.1 (already a pubspec dependency) `[VERIFIED: existing pubspec.yaml]` | Populates `consent_records.appVersion` for the two new consent-type entries this phase adds, mirroring Phase 6's exact usage | Reuse verbatim — same pattern as `LegalConsentScreen`'s existing consent-recording call |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Hand-rolled Apple/Google branded buttons (Icon + Text widgets styled to spec) | `sign_in_button` package (v5.0.0, publisher `steenbakker.dev`, 160/160 pub points, MIT, `[VERIFIED: pub.dev]`) | The package ships `apple`/`appleDark`/`google`/`googleDark` button variants, but its pub.dev listing does not explicitly document ongoing compliance with Apple's and Google's brand-guideline revisions — a stale asset risks App Store rejection on a requirement CONTEXT.md calls out as non-negotiable ("Apple explicitly rejects non-compliant buttons"). This codebase has zero precedent of depending on a UI-kit package for branded elements (every existing screen hand-rolls its widgets against the app's own design tokens) — building the two buttons directly from Apple's published Sign in with Apple button assets (developer.apple.com) and Google's Identity brand guidelines (developers.google.com/identity/branding-guidelines) is the safer, more auditable choice and consistent with project convention. Recommend hand-rolling; do not add this dependency unless a future compliance review finds the hand-rolled version insufficient. |
| System-browser-only reset/change-password (locked decision) | Native in-app `UPDATE_PASSWORD` `kc_action` re-auth flow | Locked decision already rejects this — noted only as the technical alternative that exists in Keycloak (Application-Initiated Actions), for awareness if a future phase revisits in-app account management |

**Installation:**
```bash
flutter pub add flutter_appauth flutter_secure_storage
```

**Version verification:** Confirmed directly against the pub.dev registry API (`https://pub.dev/api/packages/<name>`) on 2026-08-08 — `flutter_appauth` latest is `12.0.2` (published 2026-06-26T09:53:41Z), `flutter_secure_storage` latest is `11.0.0` (published within the prior 48 hours of this research). Both are current as of research date; re-verify at plan-execution time if more than 30 days have elapsed, per this project's own established convention of pinning exact versions with dated pub.dev verification comments in `pubspec.yaml`.

## Package Legitimacy Audit

> slopcheck (installed and run at research time) does **not** support the pub.dev/Dart ecosystem — its `install`/`scan` commands only recognize `pypi, npm, crates.io, go, rubygems, maven, packagist`. This is a documented ecosystem gap, not a tool failure. Per the graceful-degradation protocol this would normally mean tagging every package `[ASSUMED]`; however, this project has an established, already-human-approved precedent (every dependency in the current `pubspec.yaml`, from Phase 1 through Phase 6, was vetted this exact way) of substituting **direct pub.dev registry verification** — publisher identity, pub score, download count, license, last-publish date — as the equivalent-strength signal for this ecosystem. Both new packages were verified this way below. The planner should still gate both installs behind a `checkpoint:human-verify` task, consistent with every prior phase's package-legitimacy checkpoint pattern in this codebase (e.g., Plans 04-11, 05-08, 05-09, 05-16, 06-02).

| Package | Registry | Age | Downloads | Source Repo | slopcheck | Disposition |
|---------|----------|-----|-----------|-------------|-----------|-------------|
| `flutter_appauth` | pub.dev | First published 2019, latest release 2026-06-26 (7 years, actively maintained) | Not directly surfaced by pub.dev API; verified publisher `dexterx.dev`, 160/160 pub points | github.com/MaikuB/flutter_appauth | N/A (ecosystem unsupported) | Approved — direct registry verification substituted |
| `flutter_secure_storage` | pub.dev | Long-running (original author `mogol`, now `steenbakker.dev`), latest release ~38h before research | 3.47M / 30-day downloads, 4.47k likes, 160/160 pub points | github.com/juliansteenbakker/flutter_secure_storage | N/A (ecosystem unsupported) | Approved — direct registry verification substituted |
| `sign_in_button` (alternative, NOT recommended — see Alternatives Considered) | pub.dev | Latest release 2026-05-18, publisher `steenbakker.dev` | 22.4k total downloads (30-day not shown), 174 likes, 160/160 pub points | github.com (steenbakker.dev org) | N/A (ecosystem unsupported) | Not adopted — hand-roll recommended instead for brand-compliance auditability |

**Packages removed due to slopcheck [SLOP] verdict:** none (tool inapplicable to this ecosystem).
**Packages flagged as suspicious [SUS]:** none — both core packages have long publish histories, verified publishers, and high pub scores/download counts, which is the standard signal set this project has used for every prior dependency addition.

## Architecture Patterns

### System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Flutter App (Client)                         │
│                                                                       │
│  Settings Screen ──tap "Sign in / Create account"──▶ Auth Screen     │
│                                                          │            │
│                                          [connectivity_plus check]   │
│                                                          │            │
│                                                          ▼            │
│                                          AuthNotifier.signIn()        │
│                                                          │            │
│                                    flutter_appauth.authorizeAndExchangeCode(
│                                      AuthorizationTokenRequest(       │
│                                        clientId, redirectUrl,        │
│                                        discoveryUrl / issuer,        │
│                                        scopes: [openid, profile,     │
│                                          email, offline_access],     │
│                                        additionalParameters:         │
│                                          {kc_idp_hint: 'apple'/'google'} (social only)
│                                      ))                               │
│                                                          │            │
└──────────────────────────────────────────────────────────┼──────────┘
                                                             │ opens
                                                             ▼
                              ┌───────────────────────────────────────────┐
                              │ System Browser (Custom Tabs / ASWebAuth-   │
                              │ enticationSession) — NOT an embedded WebView│
                              │                                             │
                              │  Keycloak-hosted login page                │
                              │   ├─ email/password form, OR               │
                              │   ├─ "Forgot password?" → reset-credentials│
                              │   └─ Apple/Google IdP broker redirect      │
                              │        (kc_idp_hint skips this page)       │
                              └──────────────────┬──────────────────────────┘
                                                  │ redirect_uri callback
                                                  │ (authorization code)
┌─────────────────────────────────────────────────┼──────────────────────┐
│                         Flutter App (Client)     ▼                      │
│                                                                          │
│  flutter_appauth exchanges code for tokens (PKCE code_verifier          │
│  auto-generated/validated internally — never touches app code)         │
│                                                          │              │
│                          AuthorizationTokenResponse                    │
│                   { accessToken, refreshToken, idToken,                │
│                     accessTokenExpirationDateTime }                    │
│                                                          │              │
│              ┌───────────────────────────────────────────┴──────┐      │
│              ▼                                                  ▼      │
│  flutter_secure_storage.write(refreshToken)      AuthNotifier state =  │
│  (Keychain / platform secure cipher)             AsyncData(AuthState.  │
│                                                      authenticated(     │
│                                                        accessToken,     │  ← in-memory ONLY
│                                                        email, expiry))  │
│                                                          │              │
│                                          ref.watch by:                 │
│                                          ├─ ModeIndicator (Dashboard)  │
│                                          ├─ SettingsScreen Account row │
│                                          └─ go_router (no redirect gate│
│                                             this phase — Account       │
│                                             section conditionally      │
│                                             renders, doesn't redirect) │
└──────────────────────────────────────────────────────────────────────┘

Cold start / app relaunch:
  AuthNotifier.build() ──▶ read refresh token from secure storage
        │
        ├─ none found ──▶ AuthState.unauthenticated
        │
        └─ found ──▶ appAuth.token(TokenRequest(..., refreshToken: stored))
                        │
                        ├─ success ──▶ AuthState.authenticated (silent, no spinner)
                        ├─ network/offline error ──▶ stay AuthState.authenticated
                        │    (optimistic — do NOT log out on connectivity failure)
                        └─ invalid_grant / revoked ──▶ AuthState.unauthenticated
                             + one-time "You've been signed out" notice

Account deletion:
  Settings → Delete account → confirm dialog → AuthNotifier.deleteAccount()
        │
        ▼
  HTTP DELETE {backend}/me/account  (Authorization: Bearer <access_token>)
   [ASSUMED contract — endpoint does not exist yet, see Open Questions #1]
        │
        ├─ 2xx ──▶ clear secure storage + in-memory state
        │            + write consent_records('account_deletion') via
        │              existing ConsentRecordsDao (local data untouched)
        │
        └─ error ──▶ inline error, no local state change, user retries
```

### Recommended Project Structure

```
lib/features/auth/
├── screens/
│   ├── auth_screen.dart              # combined sign-in/create-account, social+email
│   └── check_email_screen.dart       # post-signup, pre-verification
├── widgets/
│   ├── apple_sign_in_button.dart     # hand-rolled, HIG-compliant
│   ├── google_sign_in_button.dart    # hand-rolled, brand-guideline-compliant
│   └── signed_out_notice_snackbar.dart (or reuse a core/ helper)
├── providers/
│   ├── auth_provider.dart            # @Riverpod(keepAlive: true) class AuthNotifier
│   └── realm_discovery_provider.dart # session-cached readiness gate
lib/domain/
├── entities/
│   └── auth_state.dart               # sealed/freezed AuthState (authenticated/unauthenticated/loading)
├── services/
│   └── keycloak_config.dart          # realm URL, client ID, redirect URI — single source of truth
lib/features/settings/widgets/
└── account_section.dart              # new Account section in SettingsScreen
lib/features/dashboard/widgets/
└── co2_methodology_banner.dart       # dismissible banner, per-version dismissal flag
lib/domain/services/
└── methodology_version_checker.dart  # compares stored snapshot vs. app-binary constant
```

This mirrors the project's existing `features/<domain>/{screens,widgets,providers}` + `domain/{entities,services}` split used identically by every prior phase (e.g., `features/legal/`, `features/co2_settings/`).

### Pattern 1: AuthNotifier as the single source of truth

**What:** A `@Riverpod(keepAlive: true) class AuthNotifier extends _$AuthNotifier` holding an `AsyncValue<AuthState>` (or a plain synchronous `AuthState` if silent refresh is modeled as an internal async method rather than `build()` itself being async — either is consistent with this project's existing `Notifier` vs `AsyncNotifier` split, see `OnboardingGateNotifier` for the synchronous precedent).

**When to use:** Any screen needing to know "is the user logged in" (ModeIndicator, SettingsScreen Account section) watches this single provider — never duplicate auth-state logic elsewhere.

**Why keepAlive:** Exactly the same rationale already documented in this codebase for `OnboardingGateNotifier` and `appDatabaseProvider` — this is app-lifetime state read via bare `ref.read`/`ref.watch` from widgets that may not always have an active watcher during a mutation's `await` chain (e.g., a route guard or a `deleteAccount()` call), and this project has already been bitten once (06-10) by an `UnmountedRefException` from a plain `@riverpod` autoDispose provider under exactly this shape of usage.

**Example (based on flutter_appauth's documented API, adapted to this project's provider conventions):**
```dart
// Source: flutter_appauth README (github.com/MaikuB/flutter_appauth) +
// this project's existing OnboardingGateNotifier keepAlive precedent
@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  final _appAuth = const FlutterAppAuth();

  @override
  Future<AuthState> build() async {
    final refreshToken = await ref
        .watch(secureStorageProvider)
        .read(key: 'kc_refresh_token');
    if (refreshToken == null) return const AuthState.unauthenticated();

    try {
      final result = await _appAuth.token(
        TokenRequest(
          KeycloakConfig.clientId,
          KeycloakConfig.redirectUrl,
          issuer: KeycloakConfig.issuer,
          refreshToken: refreshToken,
          scopes: KeycloakConfig.scopes,
        ),
      );
      return AuthState.authenticated(
        accessToken: result.accessToken!,
        // ... email parsed from idToken claims or a follow-up /userinfo call
      );
    } on FlutterAppAuthPlatformException catch (e) {
      // Distinguish network failure from genuine invalidation — see
      // Common Pitfalls: "Network Failure vs. Real Invalidation".
      if (_looksLikeNetworkFailure(e)) {
        // Stay optimistically authenticated per locked CONTEXT.md decision —
        // requires caching the last-known access token/email alongside the
        // refresh token, or accepting a brief "authenticated but no fresh
        // access token" state until connectivity returns.
        rethrow; // planner must design the exact optimistic-state shape
      }
      await ref.read(secureStorageProvider).delete(key: 'kc_refresh_token');
      return const AuthState.unauthenticated();
    }
  }
}
```

### Pattern 2: `kc_idp_hint` for direct social login

**What:** Keycloak-specific `additionalParameters` value that skips Keycloak's own login page and redirects the system browser straight to the named identity provider's login screen.

**When to use:** Apple/Google buttons — matches the locked "Social buttons first... then email/password below" UX, where tapping Apple/Google should not show an intermediate Keycloak-branded login form.

**Example:**
```dart
// Source: Keycloak identity-broker docs pattern (kc_idp_hint), applied to
// flutter_appauth's additionalParameters map
// [CITED: Keycloak docs — Client Suggested Identity Provider]
final result = await appAuth.authorizeAndExchangeCode(
  AuthorizationTokenRequest(
    KeycloakConfig.clientId,
    KeycloakConfig.redirectUrl,
    issuer: KeycloakConfig.issuer,
    scopes: const ['openid', 'profile', 'email', 'offline_access'],
    additionalParameters: {'kc_idp_hint': 'apple'}, // or 'google'
    // [ASSUMED] alias values 'apple'/'google' — must match whatever
    // Tomris names the IdP aliases in the actual realm config.
  ),
);
```

### Pattern 3: Realm-discovery readiness gate (session-cached)

**What:** A one-time-per-session HTTP GET to `{issuer}/.well-known/openid-configuration`, gating whether the Account section renders at all.

**Example:**
```dart
// [ASSUMED] issuer URL shape — matches the ONLY Keycloak config found in
// the backend reference repo (application.yml: issuer-uri).
@riverpod
Future<bool> realmDiscoveryReady(Ref ref) async {
  try {
    final response = await http
        .get(Uri.parse('${KeycloakConfig.issuer}/.well-known/openid-configuration'))
        .timeout(const Duration(seconds: 3)); // exact timeout: Claude's discretion
    return response.statusCode == 200;
  } on Exception {
    return false;
  }
}
// keepAlive: true with a manual "already checked this session" flag,
// OR rely on Riverpod's default caching + an app-lifetime provider scope —
// exact caching mechanism is Claude's discretion per CONTEXT.md.
```

### Pattern 4: Distinguishing network failure from real session invalidation

**What:** `flutter_appauth`'s token-refresh call surfaces both "no internet" and "refresh token revoked/expired" as thrown exceptions. The locked decision requires treating these differently (stay logged in vs. force logout).

**How:** `flutter_appauth` typically surfaces OAuth-spec errors (`invalid_grant`, `invalid_token`) via `FlutterAppAuthPlatformException.details.code`/`errorDescription` for genuine server-side rejections, versus platform-level connectivity exceptions (`SocketException`, or a network-layer `FlutterAppAuthPlatformException` with a different underlying code) for connectivity issues. **This exact error-shape distinction has not been verified against a live Keycloak instance in this research session** (no realm exists to test against) — flagged as an Open Question / Wave 0 risk. The safer implementation is to explicitly pre-check `connectivity_plus` before attempting the silent refresh at all, and only treat an actual OAuth-error-coded exception as invalidation — anything else (timeout, no connection, DNS failure) is treated as "stay logged in."

### Anti-Patterns to Avoid

- **Storing the access token in `flutter_secure_storage` or any persistent storage:** CONTEXT.md and AUTH-02's spirit both require access-token-in-memory-only — persisting it defeats the short-lived-token security model and re-introduces exactly the kind of long-lived-credential-on-disk risk PKCE was designed to avoid.
- **Using an embedded `WebView` for the login flow instead of the system browser:** `flutter_appauth` already defaults to the system browser (Custom Tabs/`ASWebAuthenticationSession`) — this is also an OAuth 2.0 for Native Apps (RFC 8252) best-practice requirement, and embedding a WebView instead is both a security anti-pattern (no phishing-resistant browser chrome, no shared cookie jar with the real browser) and would likely fail Google/Apple's own login-flow review guidance for third-party auth.
- **Hardcoding the realm URL/client ID as string literals scattered across files:** centralize in one `KeycloakConfig` (or equivalent) source, since every value in it is currently an `[ASSUMED]` placeholder that WILL change once Tomris's real realm exists — scattering the values makes that future find-and-replace error-prone.
- **Adding `app_links`/`uni_links` for redirect handling:** a common misconception — `flutter_appauth` handles the native redirect-URI interception itself (via `RedirectUriReceiverActivity` on Android and the URL-scheme `CFBundleURLTypes` entry on iOS); a separate deep-link package is unnecessary and could even conflict by double-handling the same URI scheme.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| PKCE code-verifier/challenge generation | Custom SHA-256 + base64url PKCE implementation | `flutter_appauth`'s built-in PKCE (automatic in `authorizeAndExchangeCode`) | Getting PKCE's crypto exactly right (correct challenge method, correct verifier entropy/length per RFC 7636) is a well-known source of subtle security bugs; the plugin wraps Google/AOSP's own AppAuth SDKs which already implement this correctly |
| Secure refresh-token storage | Custom encrypted `SharedPreferences` wrapper | `flutter_secure_storage` (Keychain/platform secure cipher) | OS-level secure storage APIs have hardware-backed protections a hand-rolled encryption layer cannot replicate cheaply, and this project already treats "no home-grown crypto" as a norm (no evidence of any hand-rolled encryption anywhere in the current codebase) |
| Password-reset / change-password UI | Custom Flutter forms calling a hypothetical Keycloak Admin REST endpoint from the client | Keycloak's own hosted pages (`login-actions/reset-credentials`, `/account/account-security/signing-in`), opened externally | Already the locked CONTEXT.md decision — also correct from a security standpoint: the mobile client should never handle raw password-reset tokens or an admin-level API credential |
| OIDC discovery-document parsing | Manual JSON parsing of `.well-known/openid-configuration` for endpoint URLs | `flutter_appauth`'s `discoveryUrl`/`issuer` parameter (auto-fetches and parses the discovery doc internally) | The readiness-gate check (Pattern 3) still needs a raw HTTP GET for existence/reachability, but the actual endpoint-URL extraction for the real auth flow should go through `flutter_appauth`'s own discovery handling, not a second hand-rolled parser |
| JWT expiry/claims parsing | Custom JWT decoder | `AuthorizationTokenResponse.accessTokenExpirationDateTime` (already parsed by the plugin) for expiry; a `/userinfo` call (if email display is needed and not already in the ID token) rather than manually decoding the ID token's payload | The plugin already surfaces the expiry as a typed `DateTime` — decoding the JWT payload yourself for information the plugin already extracts is unnecessary and error-prone (base64url padding edge cases) |

**Key insight:** Every hand-rolling risk in this domain is a security or compliance risk (crypto correctness, credential storage, App Store review), not a UX risk — which is exactly the category of problem mature, widely-audited libraries (backed by Google/AOSP's own AppAuth reference implementation) exist to solve. The one area where this project should deliberately NOT reach for a package (branded sign-in buttons) is a compliance-auditability call, not a hand-rolling-is-hard call — see Alternatives Considered.

## Common Pitfalls

### Pitfall 1: Apple Sign-in "no native SDK" ≠ "no compliance obligations"
**What goes wrong:** Assuming that because Keycloak brokers Apple as a web-based IdP (no native `ASAuthorizationController`), App Store Guideline 4.8 compliance is automatically satisfied.
**Why it happens:** Guideline 4.8 requires apps using third-party/social login (e.g., Google) to also offer Sign in with Apple as an "equivalent option" — the requirement is about UX/data-minimization equivalence, not implementation mechanism, but reviewers have been inconsistent in practice about whether a web-broker-based Apple flow (vs. native SDK) passes review.
**How to avoid:** The button itself must still follow Apple's Human Interface Guidelines exactly (black/white "Sign in with Apple" button using Apple's official glyph and copy), and the resulting account flow must collect no more data than the Google flow does. This is achievable via a Keycloak Apple broker (e.g., the widely-used `klausbetz/apple-identity-provider-keycloak` extension pattern) `[CITED: GitHub — klausbetz/apple-identity-provider-keycloak]`, but real App Store review outcome for this specific web-broker approach has not been verified in this research session (no submitted build exists yet).
**Warning signs:** App Store rejection citing 4.8 despite Apple sign-in being present — budget time in a later phase for a possible pivot to native `sign_in_with_apple` + token exchange if the web-broker approach is rejected.

### Pitfall 2: Redirect URI scheme case-sensitivity and cross-platform mismatch
**What goes wrong:** Android's `appAuthRedirectScheme` manifest placeholder silently fails (or causes multidex-related build errors) if the scheme isn't strictly lowercase, or if `+=` isn't used for the placeholder assignment when other plugins also contribute manifest placeholders.
**Why it happens:** `[CITED: flutter_appauth README]` — explicitly documented gotcha in the package's own setup instructions.
**How to avoid:** Use a single lowercase custom scheme (e.g., `com.reduceco2now.co2diet.auth`, matching the existing `com.reduceco2now.co2diet` package convention from STATE.md) consistently in `build.gradle`'s `manifestPlaceholders` (via `+=`, not `=`) and iOS `Info.plist`'s `CFBundleURLSchemes`. Verify the Android `RedirectUriReceiverActivity` does NOT have `android:taskAffinity=""` set if redirects intermittently fail to return to the app.
**Warning signs:** Auth flow opens the browser but never returns to the app after login; works on one platform but not the other.

### Pitfall 3: Email verification gate interacting with the "check your email" screen
**What goes wrong:** If Keycloak's realm has "Verify email" as a required action, a user who signs up gets tokens issued anyway (Keycloak may still complete the OIDC flow with a "not yet verified" claim) or gets blocked entirely depending on realm config — the exact behavior differs by Keycloak version/config and needs confirmation against the real realm once it exists.
**Why it happens:** "Email verified before login completes" (AUTH-01's literal wording) is a realm-side policy, not something the Flutter client can enforce independently — the client can only react to whatever Keycloak actually returns.
**How to avoid:** Treat this as a Wave 0/coordination item with Tomris: confirm whether the realm blocks token issuance entirely until verified (cleanest — the login attempt simply fails with an actionable error, which the "Check your email" screen can catch and route to) versus issuing tokens with an `email_verified: false` claim that the client must itself gate on. Flagged in Open Questions.
**Warning signs:** A user completes signup, is never routed to "Check your email," and lands as apparently-logged-in before verifying.

### Pitfall 4: Confusing Danger Zone's typed-confirmation pattern with account deletion's simpler dialog
**What goes wrong:** Reusing `DangerZoneSection`'s exact typed-`DELETE`-word confirmation widget for account deletion, when CONTEXT.md explicitly specifies "no re-authentication/typed-phrase requirement" — a simple destructive-styled `AlertDialog` instead.
**Why it happens:** `DangerZoneSection` (`lib/features/backup/widgets/danger_zone_section.dart`, Phase 5) is the only existing "high-stakes deletion" precedent in the codebase, making it tempting to copy verbatim.
**How to avoid:** Build a distinct, simpler confirmation dialog (this codebase already has a `core/widgets/` precedent for shared `AlertDialog`-style confirmations — see `lib/core/widgets/ed_safety_net_dialog.dart`, Phase 6 — follow that pattern instead of `DangerZoneSection`'s typed-word pattern).
**Warning signs:** Account deletion requiring the user to type a confirmation word, which directly contradicts the locked CONTEXT.md decision.

### Pitfall 5: GDPR delete endpoint doesn't exist yet — building against an assumed contract
**What goes wrong:** Writing `AuthNotifier.deleteAccount()` against a specific assumed request/response shape (`DELETE /me/account`, bearer-token auth, synchronous 2xx = hard-deleted) that the actual backend endpoint (once built by Tomris) doesn't match.
**Why it happens:** Confirmed via direct scan of the backend reference repo — zero GDPR endpoints exist anywhere in the codebase (`~/Documents/ReduceCO2-Now/CO2Diet_Backend-reference`), only the 4 endpoints already documented in this phase's `additional_context` (3 public food-lookup, 1 JWT-echo).
**How to avoid:** Implement the client-side call behind a single, isolated service method with the assumed contract clearly marked `[ASSUMED]` in a code comment, so swapping in the real contract later (once Tomris builds it) is a one-file change. Do not scatter the endpoint URL/verb assumption across multiple call sites.
**Warning signs:** None until real backend integration — this is a coordination risk, not a code-quality risk, but the isolation matters for how cheaply it's fixed later.

### Pitfall 6: `preferEphemeralSession` on iOS causing unexpected re-login prompts
**What goes wrong:** Setting `preferEphemeralSession: true` (available on iOS/macOS 13+, `[CITED: flutter_appauth README]`) prevents Safari's shared cookie jar from persisting the Keycloak session across separate sign-in attempts, meaning even the "Change password" system-browser hop won't be silently authenticated even though the user is logged into the app.
**Why it happens:** Ephemeral sessions are the "don't leave any browsing trace" option — useful for privacy but directly at odds with any assumption that the system browser shares an authenticated cookie session with the app's stored refresh token.
**How to avoid:** Decide deliberately whether ephemeral sessions are used for login (privacy benefit — no lingering Safari history of the Keycloak login page) versus for the "Change password" hop (where NOT using ephemeral mode might let Safari's cookie jar auto-authenticate the account-console page, avoiding a second login prompt). This tradeoff has not been resolved in CONTEXT.md and should be a planner decision point, not an accidental default.
**Warning signs:** User taps "Change password," expects to land straight in the account console, but is asked to log in again — confusing but not incorrect; worth a deliberate UX call either way.

## Code Examples

### Realm-configurable auth constants (single source of truth)

```dart
// [ASSUMED] every value below is a placeholder pending Tomris's actual
// realm export — this is deliberately centralized so it's a one-file
// change once real values exist.
class KeycloakConfig {
  static const issuer = 'http://localhost:8081/realms/co2diet'; // matches
      // the ONLY Keycloak value found in the backend reference repo's
      // application.yml (dev-local port 8081) — production value unknown
  static const clientId = 'co2diet-mobile'; // [ASSUMED] no client
      // registration visible in the backend repo
  static const redirectUrl = 'com.reduceco2now.co2diet.auth://callback';
  static const scopes = ['openid', 'profile', 'email', 'offline_access'];
      // offline_access is REQUIRED for Keycloak to issue a refresh token
      // at all — [ASSUMED] the client's "Offline Access" scope is enabled
      // in the realm; without it, silent refresh (AUTH-02) is impossible
}
```

### Logout

```dart
// Source: flutter_appauth README endSession pattern
Future<void> logout(WidgetRef ref) async {
  final idToken = /* cached from last token response, if kept */;
  await const FlutterAppAuth().endSession(
    EndSessionRequest(
      idTokenHint: idToken,
      postLogoutRedirectUrl: KeycloakConfig.redirectUrl,
      issuer: KeycloakConfig.issuer,
    ),
  );
  await ref.read(secureStorageProvider).delete(key: 'kc_refresh_token');
  ref.read(authProvider.notifier).state = const AsyncData(AuthState.unauthenticated());
}
```
Note: `endSession` opens the system browser briefly to invalidate the Keycloak-side session (revokes the refresh token server-side). If instantaneous UI feedback matters more than server-side revocation completing first, consider clearing local state immediately and firing `endSession` without awaiting the browser round-trip — exact sequencing is a planner/implementation decision not resolved by CONTEXT.md.

### Password reset (system browser, no code exchange)

```dart
// [ASSUMED] URL shape per Keycloak's documented login-actions endpoint
// [CITED: Keycloak forum/GitHub discussions — login-actions/reset-credentials
// is described as a stable, safe-for-client-use endpoint]
Future<void> openPasswordReset() async {
  final uri = Uri.parse(
    '${KeycloakConfig.issuer}/login-actions/reset-credentials'
    '?client_id=${KeycloakConfig.clientId}',
  );
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
```

### Change password (Keycloak Account Console)

```dart
// [CITED: Keycloak Account Console docs — Account Security > Signing In]
Future<void> openChangePassword() async {
  final uri = Uri.parse(
    '${KeycloakConfig.issuer}/account/account-security/signing-in',
  );
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
```

### Account deletion (assumed contract)

```dart
// [ASSUMED CONTRACT] — no such endpoint exists in the backend reference
// repo scanned for this research; this is a specification the planner
// should hand to Tomris, not a confirmed API.
Future<void> deleteAccount(String accessToken) async {
  final response = await http.delete(
    Uri.parse('${BackendConfig.baseUrl}/me/account'),
    headers: {'Authorization': 'Bearer $accessToken'},
  );
  if (response.statusCode >= 200 && response.statusCode < 300) {
    await ref.read(secureStorageProvider).delete(key: 'kc_refresh_token');
    await ref.read(consentRecordsDaoProvider).insertConsent(
      ConsentRecordsTableCompanion.insert(
        id: const Uuid().v7(),
        appVersion: (await PackageInfo.fromPlatform()).version,
        policyVersion: /* terms.md frontmatter version */,
        consentsGiven: '["account_deletion"]', // consent-type naming: Claude's discretion
      ),
    );
    // local data untouched by default, per locked decision
  } else {
    throw AccountDeletionException(response.statusCode);
  }
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|---------------|--------|
| Embedded `WebView` for OAuth login | System browser (Custom Tabs on Android, `ASWebAuthenticationSession`/`SFSafariViewController` on iOS) via AppAuth | RFC 8252 (OAuth 2.0 for Native Apps, 2017) formalized this as best practice; `flutter_appauth` has defaulted to it for years | Better phishing resistance, shared browser cookie state, no way for the app to intercept credentials |
| Implicit grant flow | Authorization Code + PKCE | OAuth 2.0 Security Best Current Practice (deprecated implicit grant) | This project's AUTH-10 already locks in PKCE — no implicit-grant code paths should ever appear |
| `flutter_secure_storage` EncryptedSharedPreferences (Android) | Custom cipher / DataStore-backed storage (v10+) | v10.0.0 introduced this; DataStore migration path exists since then `[MEDIUM confidence — WebSearch summary of package changelog, not independently re-verified against the changelog file itself]` | Version 11.0.0 (this research's recommended pin) should already include this; no action needed beyond staying current |

**Deprecated/outdated:**
- Native Apple `ASAuthorizationController` SDK integration on the Flutter client: explicitly rejected by this phase's locked decision in favor of Keycloak-brokered Apple sign-in — not deprecated technology per se, but deliberately out of scope here.

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | Keycloak realm name is `co2diet`, issuer base is `http://localhost:8081/realms/co2diet` (dev) | Standard Stack, Code Examples | Low for research purposes (this is the ONLY value actually found in the backend repo, so it's the best available signal) but the production issuer URL is completely unknown — planner must not hardcode this as a production value |
| A2 | GDPR account-deletion endpoint contract: `DELETE {baseUrl}/me/account`, `Authorization: Bearer <access_token>`, synchronous 2xx = hard-deleted | Code Examples, Architecture Patterns | High — if Tomris builds a different contract (e.g., POST with a request body, async job with polling, different path), the client implementation needs rework; isolated to one service method by design to minimize blast radius |
| A3 | Keycloak IdP aliases are literally `apple` and `google` for use with `kc_idp_hint` | Pattern 2, Code Examples | Medium — if Tomris configures different alias strings, `kc_idp_hint` values are a one-line config change, not a structural rework |
| A4 | Client ID is `co2diet-mobile`, redirect URI scheme is `com.reduceco2now.co2diet.auth://callback` | Code Examples | Low — entirely a Flutter-side + Keycloak-client-registration coordination value, easy to change before real testing begins |
| A5 | `offline_access` scope is enabled by default for the mobile client in the realm (required for refresh tokens / "stay logged in across sessions," AUTH-02) | Code Examples (KeycloakConfig) | High if false — AUTH-02 would silently fail (access token only, no persistent session) with no client-side code change able to fix it; already flagged as a named backend-coordination item in STATE.md ("`offline_access` scope defaults") |
| A6 | Email-verification enforcement happens at Keycloak's token-issuance layer (blocks login) rather than the client needing to check an `email_verified` claim itself | Pitfall 3 | Medium — determines whether "Check your email" screen routing is driven by a login failure or a claim check; affects one code path, not the overall architecture |
| A7 | A Keycloak-brokered (non-native-SDK) Apple Sign-in passes App Store Guideline 4.8 review as long as button branding and data-minimization match Apple's HIG | Pitfall 1 | High if wrong — could require a late pivot to the native `sign_in_with_apple` package + Keycloak token-exchange, a real architecture change; this is the single highest-uncertainty compliance risk in the phase and should be flagged for early real-device App Store review testing, not left until final QA |

**All claims above need user/Tomris confirmation before being treated as locked implementation decisions** — this is expected and by-design for a phase explicitly scoped around a not-yet-existent backend realm.

## Open Questions (DEFERRED — backend coordination pending)

All 4 items below are blocked on Tomris's not-yet-existent Keycloak realm/backend, not on planning gaps in this phase -- each has a recommendation the planner has already acted on (see Assumptions Log and Plan 07-08's `docs/backend-contracts/gdpr-account-deletion.md`), pending real-realm confirmation.

1. **What is the exact GDPR account-deletion API contract?**
   - What we know: No such endpoint exists anywhere in the backend reference repo; PRIV-05 requires "Keycloak user record is deleted in the same operation," implying a single synchronous server-side call that both removes the Keycloak user and any backend-side account record.
   - What's unclear: HTTP verb, path, request/response body shape, auth header requirements, and whether it's synchronous or requires client-side polling.
   - Recommendation: The planner should generate this as an explicit written API-contract spec to hand to Tomris (method, path, headers, expected status codes) as part of this phase's deliverables, and build the Flutter-side call against that spec with a `checkpoint:human-verify` before relying on it working against a real backend.

2. **Does Keycloak block token issuance entirely for unverified emails, or issue tokens with `email_verified: false`?**
   - What we know: The realm's "Verify email" required action is the locked mechanism (AUTH-01).
   - What's unclear: The exact client-visible behavior at the OIDC-flow level — this varies by how the required action interacts with the specific client/flow binding configured in the realm.
   - Recommendation: Confirm with Tomris once a realm exists; build the "Check your email" screen routing logic to handle both possible behaviors defensively (catch a login-flow error AND check an `email_verified` claim if tokens are issued anyway).

3. **What are the actual Apple/Google Keycloak IdP alias names, client IDs, and redirect allowlist entries?**
   - What we know: `kc_idp_hint` is the standard Keycloak mechanism (verified via multiple independent sources).
   - What's unclear: The literal alias strings Tomris will configure.
   - Recommendation: Centralize in `KeycloakConfig` (already recommended architecturally) so this is a config-only change once known.

4. **Does a Keycloak-brokered (web-based) Apple Sign-in actually pass App Store review under Guideline 4.8, or does Apple's review process specifically require the native SDK regardless of backend brokering?**
   - What we know: Multiple third-party Keycloak Apple-broker extensions exist and are used in production by other teams; Guideline 4.8's text is about UX/data equivalence, not implementation mechanism.
   - What's unclear: No definitive, current (2026) Apple documentation or review-outcome case study was found confirming this specific web-broker pattern passes review consistently.
   - Recommendation: Treat this as the single highest-risk open item in the phase. Recommend an early TestFlight submission specifically probing this once a real Apple IdP broker exists, rather than discovering a rejection at final launch review.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Flutter SDK | Entire phase | ✓ | 3.44.6 (stable channel) — matches pubspec's `>=3.44.6` requirement | — |
| Dart SDK | Entire phase | ✓ | 3.12.2 | — |
| Live Keycloak realm (`co2diet`) | Real end-to-end testing of AUTH-01–06, AUTH-10 | ✗ | — | Flutter-side code can be built and unit/widget-tested against a local mock OIDC discovery response; true integration testing against a live realm depends on Tomris's infra work, outside this phase's control (explicitly acknowledged in the phase's own `additional_context`) |
| Apple/Google Keycloak IdP broker config | AUTH-05, AUTH-06 | ✗ | — | Same as above — build against the `kc_idp_hint` pattern generically; cannot verify against real Apple/Google credentials without realm config |
| GDPR delete endpoint | PRIV-05 | ✗ | — | Build against the assumed contract (Assumption A2), isolated to one service method |
| Docker (for a local dev Keycloak instance) | Optional local testing convenience | ✗ (not installed on this dev machine) | — | No local Docker-based Keycloak spin-up is possible on this machine today; if local end-to-end testing is desired before Tomris's realm is ready, Docker installation is a prerequisite outside this phase's code scope |

**Missing dependencies with no fallback:**
- A live, reachable Keycloak realm with Apple/Google IdP brokers configured and a GDPR delete endpoint — none of these can be substituted by this phase's own work; they are the explicit dependency named in the phase description ("requires a live Keycloak realm + Apple/Google IdP config from Tomris").

**Missing dependencies with fallback:**
- Local Docker-based Keycloak for dev-loop testing — not required if Tomris provides a shared dev/staging realm instead; either path unblocks real end-to-end testing, but neither exists today.

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | `flutter_test` (unit/widget) + `integration_test` (device-level) + `mocktail` (mocking) — no dedicated config file beyond `pubspec.yaml`'s `dev_dependencies`, consistent with every prior phase |
| Config file | none — see Wave 0 |
| Quick run command | `flutter test test/features/auth/` (once created) |
| Full suite command | `flutter test` |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| AUTH-01 | Signup flow reaches "Check your email" screen; email-verification-required error surfaces correctly | widget | `flutter test test/features/auth/auth_screen_test.dart -x` | ❌ Wave 0 |
| AUTH-02 | Silent refresh on launch restores authenticated state from a mocked secure-storage refresh token | unit | `flutter test test/features/auth/providers/auth_provider_test.dart -x` | ❌ Wave 0 |
| AUTH-03 | Logout row clears state and reverts ModeIndicator | widget | `flutter test test/features/settings/widgets/account_section_test.dart -x` | ❌ Wave 0 |
| AUTH-04 | "Forgot password?" launches the correct external URL (mocked `url_launcher`) | unit | `flutter test test/features/auth/auth_screen_test.dart -x` | ❌ Wave 0 |
| AUTH-05 / AUTH-06 | Apple/Google buttons pass `kc_idp_hint` with the correct alias value | unit | `flutter test test/features/auth/providers/auth_provider_test.dart -x` | ❌ Wave 0 |
| AUTH-10 | No Firebase/Supabase packages present; CI privacy blocklist audit (existing PRIV-07 pipeline) stays green | ci | `dart run tool/check_privacy_deps.dart` (existing script, Phase 1) | ✅ existing |
| PRIV-05 | Delete-account flow writes the `account_deletion` consent record and clears local auth state, given a mocked successful backend response; failure path leaves state untouched | unit + widget | `flutter test test/features/auth/providers/auth_provider_test.dart -x` and `test/features/settings/widgets/account_section_test.dart -x` | ❌ Wave 0 |
| (CO2 methodology banner, non-REQ-ID success criterion #5) | Rows with a stale non-null `co2MethodologyVersion(Snapshot)` trigger the banner; null-snapshot rows are excluded; per-version dismissal persists | unit | `flutter test test/domain/services/methodology_version_checker_test.dart -x` | ❌ Wave 0 |

### Sampling Rate
- **Per task commit:** `flutter test test/features/auth/` (and the methodology-checker test file)
- **Per wave merge:** `flutter test` (full suite)
- **Phase gate:** Full suite green before `/gsd-verify-work`

### Wave 0 Gaps

- [ ] `test/features/auth/auth_screen_test.dart` — covers AUTH-01, AUTH-04 (widget-level, mocked `AuthNotifier`/`url_launcher`)
- [ ] `test/features/auth/providers/auth_provider_test.dart` — covers AUTH-02, AUTH-05, AUTH-06, PRIV-05 (unit-level, mocked `flutter_appauth`/`flutter_secure_storage`/HTTP client)
- [ ] `test/features/settings/widgets/account_section_test.dart` — covers AUTH-03, PRIV-05 (widget-level)
- [ ] `test/domain/services/methodology_version_checker_test.dart` — covers the CO2 methodology-announcement mechanism
- [ ] `test/features/dashboard/widgets/co2_methodology_banner_test.dart` — widget-level dismissal-persistence test
- [ ] Group-level skip-pattern Wave 0 stubs for all of the above, following this project's established convention (verbatim, per every prior phase's Plan 01/precedent) — group-level `skip:` argument, not individual per-test skips
- [ ] No new test framework/dependency install needed — `mocktail`, `flutter_test`, `integration_test` are already `dev_dependencies`

## Security Domain

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-------------------|
| V2 Authentication | yes | Delegated entirely to Keycloak via OIDC — the app never handles raw credentials; `flutter_appauth` (AppAuth SDKs) is the standard control, not a hand-rolled auth flow |
| V3 Session Management | yes | Access token in memory only (short-lived, never persisted); refresh token in `flutter_secure_storage` (OS Keychain/secure cipher); explicit distinction between network failure and genuine session invalidation (locked CONTEXT.md decision) prevents both false-logout and stale-session risks |
| V4 Access Control | partial | Not a major concern this phase — no role-based access control surface exists in the Flutter client; the backend's own resource-server JWT validation (already configured) is the enforcement point, out of this phase's scope |
| V5 Input Validation | yes | Client-side password min-length pre-check (8 chars) is a UX nicety only — Keycloak's realm password policy is the actual source of truth (already the locked decision) |
| V6 Cryptography | yes | Never hand-roll — PKCE crypto is entirely inside `flutter_appauth`'s native AppAuth SDK dependency; secure storage encryption is entirely inside `flutter_secure_storage`'s platform-specific cipher implementation |

### Known Threat Patterns for OIDC/PKCE Mobile Auth

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|----------------------|
| Authorization code interception (malicious app registers the same redirect URI scheme) | Spoofing / Tampering | PKCE (code_verifier/challenge binding) — automatic via `flutter_appauth`; the intercepting app cannot complete the token exchange without the original verifier |
| Refresh token theft from insecure storage | Information Disclosure | `flutter_secure_storage` (Keychain/hardware-backed cipher), never `SharedPreferences`/plain files — matches this phase's locked "refresh token in secure storage" decision |
| Access token leaking via logs/crash reports | Information Disclosure | Access-token-in-memory-only (never persisted) plus this project's existing zero-analytics/zero-crash-reporting-SDK invariant (PRIV-07) already eliminates the most common leak vector (third-party crash SDKs scraping app state) |
| CSRF/state-parameter stripping during the redirect | Tampering | `flutter_appauth` generates and validates the `state` parameter internally as part of `authorizeAndExchangeCode` — no manual handling needed or should be added |
| Session fixation via a stale cached "logged in" UI state after a genuine server-side revocation | Tampering / Repudiation | The locked "silent fallback to logged-out + one-time notice on genuine invalidation" behavior directly addresses this — the app must actively distinguish and react to `invalid_grant`, not just cache the last successful state indefinitely |

## Sources

### Primary (HIGH confidence)
- pub.dev registry API (`https://pub.dev/api/packages/flutter_appauth`, `https://pub.dev/api/packages/flutter_secure_storage`, `https://pub.dev/api/packages/sign_in_button`) — direct JSON fetch, version/publish-date ground truth
- `flutter_appauth` official README (github.com/MaikuB/flutter_appauth) — installation, Android/iOS setup, `authorizeAndExchangeCode`/`token`/`endSession` API examples, PKCE/ephemeral-session notes
- Direct file reads of this project's own codebase: `pubspec.yaml`, `lib/features/dashboard/widgets/mode_indicator.dart`, `lib/features/settings/screens/settings_screen.dart`, `lib/core/router/app_router.dart`, `lib/core/di/providers.dart`, `lib/data/local/tables/consent_records_table.dart`, `lib/data/local/daos/consent_records_dao.dart`, `lib/features/onboarding/providers/onboarding_gate_provider.dart`, `lib/features/backup/widgets/danger_zone_section.dart`, `lib/domain/entities/user_profile.dart`
- Direct file reads of the sibling backend reference repo (`~/Documents/ReduceCO2-Now/CO2Diet_Backend-reference`): `SecurityConfig.java`, `application.yml` — the ONLY Keycloak-related configuration confirmed to exist anywhere in this project's ecosystem today

### Secondary (MEDIUM confidence)
- Keycloak documentation on `kc_idp_hint` / Client Suggested Identity Provider (wjw465150.gitbooks.io mirror of Keycloak server admin guide; skycloak.io blog cross-references) — pattern confirmed by multiple independent sources
- Keycloak Account Console URL structure (`/account/account-security/signing-in`) — confirmed via Red Hat's Keycloak-based product documentation, a downstream distribution of upstream Keycloak
- `login-actions/reset-credentials` endpoint stability — confirmed via Keycloak's own GitHub Discussions (maintainer-adjacent forum, not the formal docs site, but consistent across multiple threads)
- `apple-identity-provider-keycloak` broker extension pattern (github.com/klausbetz) — a well-known, widely-referenced community extension, cross-referenced by multiple independent Medium/GitHub sources, but not an official Keycloak-maintained component

### Tertiary (LOW confidence)
- App Store Guideline 4.8's applicability to a web-broker (non-native-SDK) Apple Sign-in implementation specifically — no authoritative, dated 2026 source confirming this passes review consistently; flagged as Open Question #4 / Assumption A7, the single highest-risk unresolved item in this research
- `flutter_secure_storage` v10→v11 changelog specifics (DataStore migration, cipher changes) — summarized from WebSearch results, not independently verified against the package's actual `CHANGELOG.md` file

## Metadata

**Confidence breakdown:**
- Standard stack (flutter_appauth, flutter_secure_storage): HIGH — verified directly against pub.dev registry API and official README, both packages have long publish histories and verified publishers
- Architecture (AuthNotifier pattern, kc_idp_hint, realm-discovery gate): MEDIUM — Flutter-side conventions are HIGH confidence (match this project's own established Riverpod patterns exactly), but Keycloak-specific runtime behavior (email-verification gating, refresh-error-shape distinction) is unverified against any live realm
- Pitfalls: MEDIUM-HIGH for Flutter/AppAuth-side pitfalls (documented in the package's own README or well-corroborated by multiple sources); LOW for the Apple App Store Guideline 4.8 web-broker compliance question specifically (flagged explicitly)
- Backend contract (GDPR delete endpoint): LOW — confirmed via direct repo scan that literally nothing exists yet; this is an honest "does not exist" finding, not a research gap

**Research date:** 2026-08-08
**Valid until:** 14 days for the Flutter-package-specific findings (fast-moving pub.dev ecosystem, re-verify versions if planning is delayed); indefinite/no-expiry for the "backend has no GDPR/Keycloak-IdP config yet" finding until Tomris's infra work changes that fact (re-scan the backend reference repo immediately before planning if more than a few days have passed, since it could change at any time as a parallel workstream).
