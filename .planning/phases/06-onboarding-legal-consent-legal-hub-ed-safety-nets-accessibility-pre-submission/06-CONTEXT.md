# Phase 6: Onboarding, Legal Consent, Legal Hub, ED Safety Nets, Accessibility & Pre-Submission - Context

**Gathered:** 2026-08-03
**Status:** Ready for planning

<domain>
## Phase Boundary

Wrap Local Mode in a store-submission-ready shell: onboarding flow, GDPR-valid consent capture, Legal Hub, ED safety nets, accessibility compliance, and store pre-submission artifacts — so the app can be submitted to the App Store and Play Store as a Local-Mode-only v1. Requirements: ONBD-01–05, LEGAL-01–04, LEG-01–03, ACC-01–05, NFR-01–04/07, PRIV-06.

**Roadmap deviation (flag for planner):** ROADMAP.md's Phase 6 flow description and success criterion #1 list a "Mode Choice" screen with two equal-weight cards. This phase does **not** build that screen — see the Mode Choice decision below. ONBD-03 (equal-weight card audit) is explicitly deferred to Phase 7, when Account Mode actually exists to compare against. Everything else in Phase 6's success criteria stands.

**What this phase does NOT include:**
- Account Mode, Keycloak auth, Mode Choice screen, "Sign in" — all Phase 7 (Account Mode doesn't exist yet; nothing to choose between)
- Actual App Store Connect / Play Console submission — this phase produces drafted answer-sets and required manifest files, not the live submission itself
- Real legal review of Terms/Privacy/Disclaimer text (flagged as a pre-launch blocker, tracked outside this phase)
- Final Impressum entity/address (blocked on a decision from Dr. Thomas / ReduceCO2Now's actual leadership — see below)

</domain>

<decisions>
## Implementation Decisions

### Onboarding Flow (ONBD-01–05)

- **Final flow for this phase:** Splash (2–3s auto-advance) → Welcome (single "Continue" button) → Legal Consent → Profile Setup → Onboarding Carousel (3 slides) → Dashboard. **No Mode Choice screen in Phase 6.**
- **Both entry paths hit Legal Consent.** There is no separate "skip consent" path anymore — resolves the flagged inconsistency where Local Mode users were bound by Terms/Disclaimer without ever seeing them. Since there's only one path (Local Mode) live this phase, this is moot in practice today but the routing principle (consent is never skippable) is locked in for when Phase 7 adds Account Mode back.
- **Welcome screen:** collapses from two CTAs ("Get Started" / "Use Without Account") to one button, labeled **"Continue"** (not "Get Started" — more neutral now that it doesn't imply account creation). Keeps the tagline and the "Private. Offline-first. No ads." supporting line unchanged.
- **Splash tagline:** revert to the original spec wording ("Track calories...") rather than the live-build's "Lose Weight. Improve Health. Reduce CO2." — confirm exact copy during planning/execution.
- **Mode Choice screen is skipped entirely, not shown as a single-card placeholder.** No route/screen scaffolding for it exists in this phase; Phase 7 builds it fresh with both cards and runs the real equal-weight audit then.
- **Onboarding Carousel is 3 slides**, not 4 — the optional 4th slide ("data/control: local vs account mode") is cut since Account Mode doesn't exist yet in this build; Phase 7 can reintroduce a 4th slide.
- **Profile Setup footer always shows the Local Mode text** ("stored only on this device") — no mode-conditional branching in this phase, since only one mode exists. Phase 7 makes it conditional again.
- **Mode indicator on Dashboard** (DASH-06, already built in Phase 5) continues to read "Local Mode: Stored on this device" — app's internal mode state defaults to local for all users until Phase 7 introduces the picker (implementation detail, Claude's discretion).

### Legal Consent Screen (LEGAL-01–04)

- 4 mandatory separate checkboxes (Terms, Privacy, not-medical-advice, user-responsibility) + 1 optional 16+ self-declaration checkbox, per existing spec — no changes from REQUIREMENTS.md wording.
- **"View Terms" / "View Privacy Policy" / "View Disclaimer" links open the same full-document screens the Legal Hub uses** (reuse, not separate lighter dialogs) — one markdown-rendered screen per document, reachable from both Legal Consent and Legal Hub.
- Consent recording uses the already-built `ConsentRecordsDao`/`ConsentRecordsTable` (Phase 1) as-is — no schema changes needed.

### Legal Document Content Strategy

- **Claude drafts realistic, complete Terms of Service / Privacy Policy / Health Disclaimer text now** — not stub/lorem placeholders — so the app is fully navigable and store-submittable in its current state. Every document is internally flagged "pending legal review" via **code comments and a tracked TODO only — never a user-visible banner** (a visible "DRAFT" marker on a legal document would itself look unfinished to a store reviewer).
- **Health Disclaimer copy is drafted directly by Claude** from PITFALLS.md's existing guidance (no "diagnose/treat/cure/medical" language; "helps you track" not "helps you lose weight"; BMR/TDEE framed as estimates) — no separate bullet-outline sign-off round needed first.
- **Legal document source of truth: markdown files in `docs/legal/`** (e.g. `terms.md`, `privacy.md`, `health_disclaimer.md`, `impressum.md`), rendered in-app via a markdown viewer widget — not hardcoded Dart strings. Easier for non-Flutter-dev review/edit later (Dr. Thomas or a lawyer).
- **Each markdown file carries a frontmatter `version` field** (same pattern as `docs/design/DESIGN.md`, e.g. `version: 2026-08-03`) — the Legal Consent screen reads this to populate `LEGAL-03`'s required `policyVersion` string on every `consent_records` write. Single source of truth; bumping the date signals a possible re-consent need.
- **Impressum is the one exception to "draft and move on."** Its entity name, address, and responsible-person fields are **blocked on a decision from Dr. Thomas** (named Product Owner) or whoever formally owns ReduceCO2Now — do not default to any individual developer's personal name/address. In the meantime: **render the Impressum screen with honest, visible placeholder text** ("Legal Entity Name", "Address TBD", placeholder contact) rather than hiding the screen — since there's no way to fabricate real identity data, and TMG §5 compliance is blocked on this regardless of appearance. Explicitly flag this in STATE.md / a tracked TODO as a concrete pre-launch blocker requiring org-leadership sign-off, distinct from the general "needs lawyer review" flag on the other three documents.
- **ED helpline resource: Germany-specific (BZgA / ANAD e.V.) plus one generic international fallback line** for non-German users.

### ED Safety Nets (NFR-07)

- **Two independent trigger points, one shared check/warning component:**
  1. Calorie target override < 1200 kcal (Profile Setup, both at onboarding and later edits from Settings) — this is a *new*, tighter threshold than `TargetCalculator`'s existing 500–10000 kcal physiological clamp (`target_calculator.dart:32-33`); it does not replace that clamp, it adds a stricter UI-level warning underneath it.
  2. Weight goal target weight implying BMI < 17.5 (Weight Tracking's goal field, `weight_screen.dart`).
- **Both triggers show the same pattern: a blocking modal dialog** (not an inline banner, not a hard block) — explains the concern, links the helpline resource, and requires an explicit "I understand, continue" or "Go back and revise" tap before the value saves. Confirming lets the value save (respects legitimate medically-supervised edge cases; matches NFR-07's literal "warning + resource" wording rather than an absolute refusal).
- **Copy tone: non-judgmental but clear** — factual framing (e.g. "This target is below what's generally considered safe for most adults...") consistent with the app's overall calm tone (NFR-03), not alarmist/clinical language, even though this is a safety-critical moment.
- **Re-warn logic: only on a new/changed value that's still under threshold.** Once confirmed for a specific value, revisiting or re-saving that same value doesn't re-trigger the modal. A different low value re-triggers it.
- **BMI check requires height** (optional Profile field). **If height is missing, the BMI check is silently skipped** — no prompt to add height (would violate Profile Setup's "no blocking validation" principle). The calorie-target check still applies regardless of profile completeness, so the safety net isn't entirely absent even when height is unknown.
- **A standalone, always-visible "Concerned about eating or your relationship with food?" entry lives in Settings/Legal Hub**, independent of whether the reactive warning has ever triggered — same BZgA/ANAD e.V. + international-fallback resource, reachable proactively.
- No logging/analytics of when the warning triggers — consistent with the app's zero-behavioral-tracking principle.

### Legal Hub (LEG-01–03) & GDPR Rights (PRIV-06)

- **Entry point: a new "Legal & Privacy" row in the existing General Settings screen** (`lib/features/settings/screens/settings_screen.dart`), alongside the existing "Open source licenses" row — Settings is already ≤2 taps from anywhere via bottom nav, satisfying LEG-01 without new nav chrome.
- **Legal Hub contains:** About (what the app is + open-source note), Legal Documents (Terms/Privacy/Health Disclaimer/Impressum, each the same markdown-rendered full-document screen used from Legal Consent), a **"Your Rights"** section, a **"View my consent history"** entry, and a real contact email. **FAQ and Discord/community links are cut** for v1 — no FAQ content or Discord server confirmed to exist, same reasoning Phase 5 used to cut Weight Tracking's "Learn More" section.
- **GDPR rights (PRIV-06) are explanatory, not new screens.** "Your Rights" section maps each right directly to an existing feature: Access & Portability → Export Data (Phase 5, already built); Rectify → edit any entry directly anywhere in the app (already possible); Consent withdrawal → Danger Zone's "Delete all local data" (Phase 5, already built) or uninstalling the app. No new "Exercise Your Rights" action screen — this is a redirect/explanation layer over existing capability.
- **"View my consent history" is a new, simple read-only screen** built on top of the already-existing-but-unused `ConsentRecordsDao.getAllConsents()`/`watchConsents()` (built Phase 1, never surfaced in UI) — plain-language rendering of each consent event (timestamp, app version, policy version, what was accepted). Makes "demonstrable consent" (GDPR Art. 7) visible to the user, not just stored invisibly.

### Pre-Submission Checklist

- **In scope for this phase**, since "Pre-Submission" is literally in the phase name and ROADMAP.md's own success criteria already list "PrivacyInfo.xcprivacy present, Play Data Safety form drafted."
- **`PrivacyInfo.xcprivacy` is a real code artifact** to build in this phase (Apple checks it at build time).
- **Play Data Safety form + age-rating questionnaire answers are drafted as a markdown doc in `docs/`** (not filled into the actual console — that requires App Store Connect / Play Console access at real submission time, outside this phase's reach). Whoever submits copies these answers in.
- **Age rating target: 16+**, with "Frequent Medical/Treatment Information" as the relevant content descriptor — matches MyFitnessPal's actual App Store rating (verified: 16+, not 4+) rather than assuming a generic "health app = Everyone" precedent. Chosen over 12+ specifically to keep one coherent "this content is for 16+" story consistent with the GDPR self-declaration checkbox already in place, even though the two mechanisms (content rating vs. data-consent age) are formally separate.
- **Explicitly declare the app is NOT "Made for Kids" / directed at children** in both stores' respective questionnaires — consistent with the 16+ positioning, avoids triggering COPPA/child-directed-app compliance regimes entirely.
- **Play Data Safety form discloses Open Food Facts API queries (search terms, barcodes) as third-party data sharing** — even in Local Mode, since these are real network calls to a third party. Matches the Privacy Policy's own planned disclosure and PITFALLS.md's C4 guidance ("This app makes network requests to (1) Open Food Facts API... It makes NO requests to any other service").

### Claude's Discretion

- Exact markdown-rendering widget/package choice for Legal Hub documents
- Legal Hub screen composition/navigation structure (single hub screen with sub-routes vs. nested list)
- Internal app "mode" state default/plumbing now that Mode Choice doesn't exist this phase
- Exact wording of the ED safety-net modal copy (tone direction given; final phrasing is Claude's to draft)
- Consent-history screen's exact visual layout
- PrivacyInfo.xcprivacy's exact required-reason-API declarations (technical accuracy call)

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets

- `ConsentRecordsTable` / `ConsentRecordsDao` (`lib/data/local/tables/consent_records_table.dart`, `lib/data/local/daos/consent_records_dao.dart`) — schema and DAO already built in Phase 1 (append-only, not synced, never overwritten). `insertConsent`, `getAllConsents`, `watchConsents` all exist and are unused — Legal Consent screen writes to it, new consent-history screen reads from it. No schema changes needed.
- `TargetCalculator` (`lib/domain/services/target_calculator.dart`) — already has a `_kcalMin`/`_kcalMax` (500/10000) physiological safety clamp with a `print()` warning and code comments explicitly noting "Phase 6 will surface a visible warning to the user (NFR-07)." The new 1200kcal ED-safety-net check is a separate, tighter, UI-level check layered on top of this — does not replace the existing clamp.
- `WeightSettings.targetWeightKg` (`lib/domain/entities/weight_settings.dart`) and `weight_screen.dart`'s override dialog (~line 167) — existing entry point for the BMI<17.5 check.
- `ProfileScreen`'s override dialog (`lib/features/profile/screens/profile_screen.dart`, `onOverrideTap`/`kcalTarget` case ~lines 120-204) — existing entry point for the calorie-target check.
- `SettingsScreen` (`lib/features/settings/screens/settings_screen.dart`) — already has ListTiles for Search foods, My Foods, CO2 Settings, Weight Tracking, Backup & Restore, Meal Reminders, Open source licenses. Add "Legal & Privacy" row here.
- `docs/design/DESIGN.md` — existing frontmatter-based versioning pattern (`name:`, token blocks) to mirror for legal markdown files' `version:` frontmatter field.
- `docs/CO2_Diet_Full_Reference.md` — full screen-by-screen spec source (§3 Legal Consent, Legal & Privacy Hub, Welcome, Onboarding Carousel) and Known Open Decisions table (§6) — most items there are now resolved by this phase's decisions.
- `docs/research/PITFALLS.md` — direct source for GDPR consent mechanics (C5), ED safety net specifics (C6), and privacy-audit language; used verbatim as drafting guidance for Health Disclaimer and Data Safety form answers.
- App theme tokens (`lib/core/theme/color_tokens.dart`, `text_tokens.dart`, `spacing_tokens.dart`) — reuse directly for all new onboarding/legal screens, no new tokens needed.

### Established Patterns

- go_router named routes, `@riverpod class` codegen notifiers — same conventions as Phases 1–5, apply to new onboarding/legal/consent-history routes and providers.
- `SyncSafeTable` mixin is deliberately NOT used for `ConsentRecordsTable` (per-device, non-syncable, audit-integrity reasons documented in the table file) — new tables this phase (if any) should follow the same non-sync pattern only if they share that rationale; otherwise default to `SyncSafeTable` as established elsewhere.
- No shimmer/loading indicators for fast local operations; honest, non-judgmental, no-false-precision copy everywhere (established since Phase 1) — apply to all new onboarding/legal/ED-safety copy.

### Integration Points

- `main.dart` / `app_router.dart`'s `initialLocation: '/profile'` needs to become onboarding-gated (Splash first-launch check) — currently no onboarding gate exists at all; this phase adds it.
- `SettingsScreen` gains a "Legal & Privacy" entry point into the new Legal Hub.
- `ProfileScreen` and `WeightScreen`'s existing override dialogs gain the ED safety-net modal check, without changing their existing save/override mechanics.

</code_context>

<specifics>
## Specific Ideas

- Welcome screen's single button reads **"Continue"**, not "Get Started" — deliberately neutral now that there's only one path.
- Splash tagline reverts to original spec's "Track calories..." framing rather than the live-build's "Lose Weight. Improve Health. Reduce CO2." (exact copy TBD during execution).
- ED safety-net modal copy example direction: "This target is below what's generally considered safe for most adults. If you're working with a healthcare provider on a specific plan, that's fine — otherwise, here's a resource that can help." — factual, not alarming.
- Impressum placeholder fields render as literal visible text ("Legal Entity Name", "Address TBD") — deliberately not hidden, since the gap is a real compliance blocker, not a copy-polish issue.
- Age rating precedent was verified via live App Store lookup: MyFitnessPal = 16+ ("Frequent Medical Treatment information" descriptor), Cronometer = 13+. Confirms 16+ is the right target, not an assumed "health app = Everyone" default.

</specifics>

<deferred>
## Deferred Ideas

- **Mode Choice screen (two equal-weight cards) — deferred to Phase 7.** Only built once Account Mode actually exists to compare against; ONBD-03's equal-weight audit happens then, not now.
- **"Sign in" link / Create Account flow** — Phase 7, no scaffolding built in Phase 6.
- **Onboarding Carousel's 4th slide** (account-mode data/control messaging) — cut for this phase; Phase 7 may reintroduce it once there's a second mode to explain.
- **FAQ content and Discord community links in Legal Hub** — out of v1 scope per PROJECT.md, same reasoning as Phase 5's Weight Tracking "Learn More" cut. Revisit only if FAQ content and a real Discord server exist.
- **Actual live legal review** (Fachanwalt IT-Recht per PITFALLS.md) of Terms/Privacy/Disclaimer — tracked as a pre-launch blocker outside this phase's scope; this phase produces the draft text, not the reviewed-final text.
- **Real Impressum entity/address** — blocked on a decision from Dr. Thomas / ReduceCO2Now's actual leadership on who the TMG §5 "responsible natural person" is. Tracked as a concrete pre-launch blocker, not resolved in this phase.
- **Actual App Store Connect / Play Console submission** — this phase produces drafted answers and required manifest files only; the live submission itself is a separate, later action requiring store-account access.

</deferred>

---

*Phase: 06-onboarding-legal-consent-legal-hub-ed-safety-nets-accessibility-pre-submission*
*Context gathered: 2026-08-03*
