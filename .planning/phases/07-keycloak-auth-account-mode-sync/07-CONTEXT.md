# Phase 7: Keycloak Auth + Account Mode + Sync - Context

**Gathered:** 2026-08-08
**Status:** Ready for planning

<domain>
## Phase Boundary

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

</domain>

<decisions>
## Implementation Decisions

### Auth Screens & Sign-up/Login Flow

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

### Settings Integration & Session Lifecycle

- **Placement:** A new "Account" section positioned after the core feature rows (Search foods, My Foods, CO2 Settings, Weight Tracking, Backup & Restore, Meal Reminders) but before Legal & Privacy / Open source licenses — discoverable without visually outranking the app's actual functionality (an earlier "top of Settings" proposal was explicitly rejected for overselling a feature that's honestly minimal today).
- **Logged-in display:** Account email + "Change password" row + "Log out" row, all in the Account section.
- **Token refresh:** Silent refresh on launch using the stored refresh token — no visible loading state.
- **Session death (genuine invalidation — revoked/expired refresh token, not a network blip):** Silent fallback to logged-out state, plus a one-time "You've been signed out" notice.
- **Network failure vs. real invalidation:** Explicitly distinguished. A refresh failing due to no connectivity does NOT trigger logout — the app stays optimistically logged-in (nothing this phase depends on a freshly-validated token anyway) until a genuine server rejection (`invalid_grant`, revoked token) occurs. Prevents falsely logging out offline users in an offline-first app.

### Account Deletion Flow (GDPR / PRIV-05)

- **Location:** "Delete account" lives in the new Account section — deliberately separate from the existing Danger Zone (Phase 5's local-data wipe, PRIV-09), since they're different actions with different consequences.
- **Local data:** Untouched by default when the backend account is deleted (nothing was ever synced away, so there's nothing to lose) — user reverts to Local Mode with all local data intact. Danger Zone's "Delete all local data" remains a separate, deliberate action if the user also wants to wipe the device.
- **Confirmation:** A single dialog stating consequences explicitly ("Your account will be permanently deleted. Your local data on this device will NOT be affected.") with a destructive-styled confirm button — same friction level as the existing Danger Zone wipe, no re-authentication/typed-phrase requirement.
- **Deletion timing:** Immediate hard delete, no grace/recovery period — defines the backend contract Tomris needs to build as a single DELETE endpoint (no scheduled-purge job needed).
- **Failure handling:** Inline error on failure; no local state changes until the backend confirms success — user retries manually. Avoids a mismatched "app thinks deleted, backend disagrees" state.
- **Post-deletion:** Confirmation message, then the Account section reverts to signed-out state — user stays on Settings, rest of the app unaffected.
- **Audit trail:** Deletion writes a new `consent_records` entry (new consent type, e.g. `account_deletion`), reusing Phase 1's append-only schema — visible in the existing "View my consent history" screen (Phase 6), no new schema.
- **Legal Hub cross-reference:** Phase 6's "Your Rights" section (Legal Hub) gets updated to also reference the new in-app Delete Account flow for Account Mode users, alongside its existing Danger Zone/uninstall references.

### CO2 Methodology Announcement

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

</decisions>

<specifics>
## Specific Ideas

- Honesty-note copy direction: "Your existing local data stays on this device — cross-device sync is coming soon."
- Account deletion confirmation dialog direction: "Your account will be permanently deleted. Your local data on this device will NOT be affected."
- PRD (`docs/Diet-Mobile-app ReduceCO2Now.pdf`) explicitly states: "Use existing password managers if possible - like passkey on apple" — directly drove the autofill-hints decision.
- PRD's account-related requirements (FR-001, US-001) specify only email/password signup, login/logout, password reset — no display name or avatar field anywhere in the 40-page document.

</specifics>

<code_context>
## Existing Code Insights

### Reusable Assets
- `ConsentRecordsDao`/`ConsentRecordsTable` (`lib/data/local/tables/consent_records_table.dart`, Phase 1) — reused for both the new signup "Account Mode & Data" consent and the account-deletion audit entry via new consent-type values; no schema changes needed.
- Danger Zone / `BackupExportService` (`lib/domain/services/backup_export_service.dart`, Phase 5) — local-data wipe pattern; account deletion is a deliberately separate, adjacent action, not merged into it.
- `mode_indicator.dart` (`lib/features/dashboard/widgets/mode_indicator.dart`) — already has an `isLocalMode` bool defaulting to `true`, with doc comments explicitly built awaiting Phase 7; this phase wires it to real auth state.
- Every repository's `hlcNodeId='local'`/`hlcCounter=0` HLC placeholders (drift_profile_repository.dart, user_food_repository.dart, food_catalog_repository.dart, weight_repository.dart, co2_settings_repository.dart, notification_prefs_repository.dart, backup_metadata_repository.dart, meal_entry_repository.dart) — deliberately **UNCHANGED this phase**; they're only relevant once the deferred sync engine ships in the future phase.
- `SettingsScreen` (`lib/features/settings/screens/settings_screen.dart`) — existing ListTile rows extended with the new Account section.
- Estimate Transparency screen (Phase 5) — linked from the CO2 methodology banner's "Learn more."
- Legal Hub's "Your Rights" section (Phase 6) — updated to reference account deletion.
- `connectivity_plus` (already a pubspec dependency) — reused for the pre-flight connectivity check before opening the auth browser flow.
- `docs/legal/terms.md` (Phase 6) — gets a new "Account Mode & Data" section + version-frontmatter bump, reused rather than creating a new legal document (which would re-trigger the "pending legal review" flag on a new file).

### Established Patterns
- go_router named routes, `@riverpod class` codegen notifiers (strips "Notifier" suffix from generated provider name, per Phase 06-05/06-07/06-09 precedent) — apply to new auth-related routes/providers.
- Danger Zone's confirmation-dialog friction level — matched for account deletion.
- "≤2 taps from anywhere via bottom nav" reasoning (Legal Hub precedent, Phase 6) — applied to satisfy AUTH-03's "log out from any screen."
- No analytics/tracking of dismissal, trigger, or auth events — consistent with the app's zero-behavioral-tracking cross-cutting invariant.

### Integration Points
- `SettingsScreen` gains a new "Account" section (positioned after feature rows, before Legal & Privacy).
- Dashboard's `mode_indicator` wired to real auth state instead of the hardcoded `isLocalMode=true` default.
- Dashboard gains a new dismissible CO2-methodology-announcement banner/card.
- Legal Hub's "Your Rights" section gets one updated mapping entry referencing account deletion.
- `docs/legal/terms.md` gains a new section and a version-frontmatter bump (re-flags "pending legal review," consistent with Phase 6's existing legal-review pre-launch blocker).

</code_context>

<deferred>
## Deferred Ideas

- **Outbox/HLC/LWW bidirectional sync engine (AUTH-09)** — deferred to a new future phase, pending an explicit backend data-ownership conversation with Tomris. The backend's own architecture doc currently avoids owning user data entirely (one-directional catalog-only sync design; backup story undecided between encrypted blob and user-cloud export).
- **Local→Account upgrade with zero data loss (AUTH-08)** — deferred to that same future sync phase; this phase's account creation does not move any local data.
- **Mode Choice screen (two equal-weight cards) + ONBD-03 equal-weight audit** — deferred to the same future sync phase, since Account Mode has no tangible benefit to weigh against Local Mode until sync exists. No onboarding-flow scaffolding built this phase.
- **Onboarding Carousel's optional 4th slide** (account-mode data/control messaging) — still available whenever Mode Choice ships.
- **Live/remote-fetched methodology version check** — ROADMAP.md's Phase 8 description mentions this for the future CDN-delivered OFF pack; not needed for this phase's local-only, app-binary-constant comparison.
- **Account linking behavior across identity providers** (e.g., same email registering via Google then later via password) — a Keycloak realm-configuration concern, not a Flutter-side decision. Flagged as a coordination point with Tomris, not resolved here.
- **ROADMAP.md structural update** — Phase 7's entry should eventually be split/edited to reflect this narrower scope and a new phase inserted for the deferred sync work. Not done as part of this discussion; flagged for a follow-up `/gsd:insert-phase` or manual roadmap edit before/after planning.

</deferred>

---

*Phase: 07-keycloak-auth-account-mode-sync*
*Context gathered: 2026-08-08*
