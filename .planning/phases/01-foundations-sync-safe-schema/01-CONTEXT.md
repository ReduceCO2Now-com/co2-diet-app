# Phase 1: Foundations & Sync-Safe Schema - Context

**Gathered:** 2026-07-16
**Status:** Ready for planning

<domain>
## Phase Boundary

Establish the sync-safe local database, clean architecture skeleton, CI privacy guarantees, and the thinnest possible end-to-end vertical slice (profile entry → auto-calculated targets → persisted locally). Every subsequent phase builds on this foundation.

**What this phase does NOT include:**
- Food search, barcode scanning, or meal logging (Phase 2–4)
- Full onboarding wizard (Phase 6)
- Legal Consent screen (Phase 6)
- Keycloak / Account Mode / sync engine (Phase 7)

</domain>

<decisions>
## Implementation Decisions

### Schema Architecture

- **Approach:** Schema registry pattern — define the `SyncSafeTable` abstract Drift mixin once in Phase 1; each subsequent phase materializes its own tables using the mixin. No upfront full-schema dump.
- **SyncSafeTable mixin:** Abstract Dart mixin on Drift's `Table` class. Injects: UUID v7 primary key, HLC timestamp columns (`hlc_millis`, `hlc_counter`, `hlc_node_id`), `dirty` boolean flag, `deleted_at` tombstone nullable timestamp. All user-data tables that need sync must include this mixin.
- **Phase 1 tables materialized:** `user_profile` + `consent_records` only. Food and meal tables are added in Phase 2–4 when fully specced.
- **consent_records:** Append-only audit log — does NOT use `SyncSafeTable` mixin (HLC/LWW conflict resolution is inappropriate for an insert-only legal audit log). Primary key: UUID v7 (time-ordered). Ordering uses the existing `created_at` timestamp column — no additional index needed.
- **Vertical slice reinterpretation:** Phase 1's E2E slice is profile entry + auto-calculated targets displayed and persisted. No food/meal tables are added in Phase 1; those belong to Phase 2–4's scope.
- **co2_methodology_version:** Column added to `user_profile` (and to every CO₂-bearing table as it's created in later phases) even though the methodology update announcement flow ships in Phase 7.

### consent_records Schema

- Stores one row per consent event (not one row per session).
- Columns: `id` (UUID v7), `created_at` (UTC timestamp), `app_version` (string), `policy_version` (string), `consents_given` (JSON column listing which specific checkboxes were accepted: `terms`, `privacy`, `not_medical_advice`, `user_responsibility`, `age_16_plus`).
- `age_16_plus` field is nullable boolean — only present/true when user checked the optional 5th checkbox.
- **Never deleted** except when user executes full local data wipe (PRIV-09 Danger Zone). In Local Mode a full wipe removes everything including consent records; on re-launch onboarding re-captures consent. In Account Mode consent records are NOT synced to backend (consent was given on this device; backend tracks its own consent via registration flow).
- Multiple consent rows from re-installs or bugs are legitimate audit history — no deduplication.

### Profile UI

- **Phase 1 ships a real, styled standalone Profile screen** using the full DESIGN.md token set. Phase 6 re-uses this screen inside the onboarding wizard — no rebuild needed.
- **Formula:** Mifflin-St Jéor + activity factor lives as a pure Dart function in the **domain layer** — no framework dependencies, fully unit-testable.
- **Override strategy:** User overrides replace the calculated value directly. A separate nullable boolean column (`is_overridden`) per target field indicates whether the value was user-set or auto-calculated.
- **Missing fields behavior:** When any Mifflin-St Jéor required field (age, gender, height, weight) is empty, display `—` for that auto-calculated target with the message "Add height and weight to see targets." No fake precision, no population-average fallbacks.
- **CO₂ target in Phase 1:** Not shown. CO₂ target field is stored in `user_profile` schema but hidden in the UI until the CO₂ factor table exists in Phase 3. No placeholder or static average.
- **Unit detection:** Implement locale detection from day 1 — `Localizations.localeOf(context)` → metric or imperial default, user-overrideable. Getting this right in Phase 1 means all Phase 2+ calculations use the correct unit from the start.

### LEG-04 (Legal Documents)

- **Phase 1 does not deliver LEG-04.** The requirement ("View Terms / Privacy / Disclaimer links accessible from Legal Consent screen") is only meaningful when the Legal Consent screen exists (Phase 6). LEG-04 is fully deferred to Phase 6.
- **Content delivery strategy (Phase 6 decision):** Where legal docs live (hosted URLs vs. bundled assets) and the WebView vs. inline approach are Phase 6 decisions. Not scoped to Phase 1.

### Privacy & License Disclosure

- **SDK blocklist:** Broad class block by package-name prefix: `firebase_*`, `crashlytics*`, `amplitude*`, `mixpanel*`, `sentry*`, `segment*`, `datadog*`, `onesignal*`. Any transitive dependency matching a prefix fails CI.
- **Blocklist config:** `.privacy-blocklist.yaml` committed to repo root. CI script reads it. Auditable history, updatable via PR.
- **In-app license disclosure:** Flutter's built-in `LicensePage` widget — auto-discovers all pub.dev package licenses at runtime. No CI generation step needed. Accessible from About / Settings.
- **Exodus Privacy scan:** Phase 6 pre-submission concern only. Phase 1 CI does not include it.

### CI Pipeline

- **Platform:** GitHub Actions.
- **Trigger:** Every PR + every push to `main`. CI must pass before merge.
- **Branch protection:** Require CI green; no required human reviewer (Ali is sole Flutter dev).
- **Flutter version:** Pinned to `3.44.6` (matches verified dev environment). Not `stable` channel.
- **Caching:** `~/.pub-cache` and build output cached, keyed on `pubspec.lock`.
- **Two parallel jobs:**
  1. **ubuntu-latest:** SDK blocklist audit (parse `pubspec.lock` against `.privacy-blocklist.yaml`) → `flutter analyze` → `dart test` → `flutter build apk --debug`
  2. **macos-latest:** `flutter build ios --no-codesign`
- **Pipeline does NOT include:** Exodus scan (Phase 6), license file generation (LicensePage handles runtime), code coverage thresholds (not set in Phase 1).

### Flutter Theme

- **DESIGN.md is the single source of truth.** `ThemeData` maps every token from the DESIGN.md frontmatter verbatim — colors, typography scales, shape radii, spacing. No deviations.
- **Both light and dark mode from Phase 1.** `ThemeData.light()` and `ThemeData.dark()` are wired in Phase 1 using DESIGN.md's color roles. ACC-01 (dark mode) is a cross-cutting invariant — doing it once correctly is better than fixing in Phase 6.
- **Key tokens:**
  - Primary: `#005222`, on-primary: `#ffffff`
  - Background / surface: `#f9f9fc`, on-background: `#1a1c1e`
  - Primary container: `#006d2f`, on-primary-container: `#90ec9f`
  - Error: `#ba1a1a`
  - Typography: Plus Jakarta Sans for all UI levels; Inter (label-caps only: 12px, 600 weight, 0.05em tracking, uppercase)
  - Shape: 8px (standard cards/buttons), 16px (larger containers), 24px (distinct sections), full (status/loading indicators)
  - Spacing: 4px base scale; 20px container margin; 24px (md) and 48px (xl) primary section drivers
  - Elevation: Ambient depth (glow layers at 3–5% opacity, tonal stacking via surface container steps, 2px micro-shadow at 0.05 opacity for interactive lift) — no traditional heavy shadows

### Claude's Discretion

- Drift migration numbering and file structure conventions
- Riverpod provider file organization (feature-based vs. layer-based)
- go_router route naming conventions
- HLC implementation library choice (roll our own vs. hlc Dart package)
- Exact `SyncSafeTable` mixin field types (int64 vs. DateTime for HLC millis)
- Profile screen field ordering and visual grouping
- `—` dash component styling for missing target values

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- None yet — greenfield project. Only docs/ directory exists.

### Established Patterns
- None yet. Phase 1 establishes all patterns.

### Integration Points
- `docs/design/DESIGN.md` — source of truth for ThemeData (color tokens, typography, spacing, shapes, elevation rules)
- `docs/CO2_Diet_Full_Reference.md` — full reference document; may contain additional product context
- Backend (Spring Boot + PostgreSQL + Keycloak) owned by Tomris — **no integration until Phase 7**. Phase 1 must not import or contact any backend.

</code_context>

<specifics>
## Specific Ideas

- "DESIGN.md is the source of truth for ThemeData — use it verbatim" (confirmed explicitly by user)
- Vertical slice for Phase 1 is profile entry + auto-calculated targets only (no food/meal tables)
- `consent_records` is append-only with per-checkbox JSON — designed for GDPR defensibility
- Flutter version `3.44.6` is the dev environment version to pin in CI
- `SyncSafeTable` is the pattern name for the abstract Drift table mixin

</specifics>

<deferred>
## Deferred Ideas

- **LEG-04** (Terms / Privacy / Disclaimer links from Legal Consent screen) — fully deferred to Phase 6 where the Legal Consent screen is built. Not a Phase 1 deliverable.
- **CO₂ target display** — hidden from Profile UI in Phase 1; shown from Phase 3 onward when the CO₂ factor table exists.
- **Exodus Privacy scan in CI** — Phase 6 pre-submission concern only.
- **Dark mode accessibility audit (ACC-01)** — Phase 6 formal verification, though `ThemeData.dark()` is wired in Phase 1.
- **Content delivery strategy for legal docs** (hosted URL vs. bundled asset vs. WebView) — Phase 6 decision.

</deferred>

---

*Phase: 01-foundations-sync-safe-schema*
*Context gathered: 2026-07-16*
