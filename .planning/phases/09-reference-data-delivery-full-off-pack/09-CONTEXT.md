# Phase 9: Reference Data Delivery (Full OFF Pack) - Context

**Gathered:** 2026-08-12
**Status:** Ready for planning

<domain>
## Phase Boundary

Let users opt into downloading the full Open Food Facts catalog (~300–800MB) via CDN, on top of Phase 2's bundled starter seed pack, with incremental delta refresh so updates don't require a full re-download. Extends Phase 2's existing search/FTS5 architecture — doesn't replace or redesign it.

**Carrying forward from Phase 2's CONTEXT.md** (written before this session's phase renumbering, but the decision is real and now belongs here): "No data-saver / metered-connection check in Phase 2 — Phase 8 concern" — that concern is this phase now. Confirmed independent of the (parked, contingent) Phase 8 — no auth/Account Mode/backend-sync coupling.

**Roadmap wording correction (flag for a small ROADMAP.md fix, not done as part of this discussion):** Success criterion #2 currently reads "never silent background transfer in Local Mode," implicitly leaving room for Account Mode to behave differently. That wording predates this session's Phase 7/8 split. Confirmed during this discussion: Account Mode currently has zero functional difference from Local Mode (same local-only data behavior, per Phase 7's build), so there's no basis for a Local-vs-Account-Mode distinction here. This discussion treats "never silent" as universal — see Delta Refresh decisions below for what "silent" actually means in practice (not hidden, just not interruptive once explicitly enabled).

**What this phase does NOT include:**
- Any Account Mode / backend-sync coupling (Phase 8, contingent and separate)
- Any change to Phase 2's core search/FTS5 behavior beyond which `off_reference.sqlite` is attached
- CDN hosting/infrastructure decisions (who hosts it, what service) — flagged as a coordination point, not blocking this phase's planning

</domain>

<decisions>
## Implementation Decisions

### Entry Point & Settings Screen Structure
- Grouped near **Backup & Restore** in Settings (data-lifecycle/storage family), not near Search foods/My Foods — a deliberate choice over the more obvious "catalog feature" grouping, since this is a storage/maintenance action like backup, not a day-to-day feature.
- Its own dedicated screen (matches Backup & Restore, CO2 Calculation Settings, Weight Tracking precedent) — too much state (status, progress, pause/resume, disk usage, revert) for a single row or inline expansion.
- Settings row shows a label + current catalog status as the subtitle at rest: "Using starter pack" / "Full catalog installed — 650 MB" / "Downloading… 340/650 MB" / "Update available — connect to Wi-Fi".
- Dedicated screen during an active download: determinate progress bar with %, bytes downloaded/total, and a Cancel button (CDN content-length is known upfront). Brief success confirmation on completion before settling to the at-rest state.
- Tapping "Download" starts immediately — no confirmation dialog first. The Wi-Fi-only default plus the visible size estimate on the screen are considered sufficient warning.
- Pre-flight disk-space check before starting: if insufficient free space, block with a clear message ("Not enough storage — need ~650MB, only 200MB free") rather than starting a download that will fail partway through.
- Screen shows a product-count comparison (e.g., "50,000 products (starter pack)" vs "2.5M products (full catalog)") — concrete, honest numbers rather than vague "more products," consistent with the app's established no-false-precision principle.
- Download continues running in the background if the user navigates away from the screen or backgrounds the app — a multi-hundred-MB transfer shouldn't force the user to stare at a progress screen. Settings row subtitle reflects live progress from anywhere in Settings.
- Food search keeps working normally on the existing starter pack throughout the download — no disruption to the core logging flow. Atomic swap to the full pack only happens after it finishes downloading and verifying, mirroring `first_launch_extractor.dart`'s existing version-checked swap pattern.

### Delta Refresh: Schedule & Prompting
- Schedule options: **Manual only** (default), **Weekly**, **Monthly** — mirrors the existing `autoBackupFrequency` pattern from Phase 5's Backup & Restore, not arbitrary custom scheduling.
- Once automatic refresh is enabled, refreshes run quietly on Wi-Fi **without a per-refresh confirmation dialog** — "automatic" means automatic, same as how enabling automatic backups doesn't ask permission every time it fires. This is still visible (not hidden) via the Settings row's subtitle/last-updated timestamp — "never silent" is satisfied by visibility, not by requiring a dialog every time.
- **No true background scheduler exists in this app** (confirmed via codebase scan — no `workmanager`/`background_fetch`/`Timer.periodic` anywhere). "Weekly/Monthly" is implemented as a check on app open/resume, throttled to fire at most once per the configured interval — same pattern as Phase 5's weigh-in reminder re-arm (`AppLifecycleState.resumed` observer). This is an honest constraint to design around, not a corner cut: "weekly" means "next time you open the app after 7+ days have passed," not a true background timer.
- The lightweight "is there an update" version-check ping runs regardless of connection type (tiny payload, just a version number); only the actual multi-MB delta payload waits for Wi-Fi. If an update is found while off Wi-Fi, the Settings row subtitle shows "Update available — connect to Wi-Fi" rather than the app doing nothing until the next scheduled check.
- **No Dashboard-level banner** on delta-refresh completion (unlike the existing CO2 methodology-update banner from Phase 7) — considered and explicitly rejected. Settings row status is sufficient visibility for a routine data-freshness update; this isn't an account/methodology-level event that warrants Dashboard-level interruption.
- Reverting to the starter pack (see below) resets the schedule setting back to "Manual only."

### Download Reliability & Wi-Fi Override
- Wi-Fi-only is the default but not mandatory — an explicit opt-in override is available ("Use cellular data" / prompted "Not on Wi-Fi — download over cellular anyway?") when no Wi-Fi is detected. Matches ROADMAP's literal "Wi-Fi-only **default**" wording (default, not hard-enforced).
- Interrupted downloads (connection drop, Wi-Fi lost, app killed) **resume from where they left off** via HTTP range requests, not a full restart — matches ROADMAP's explicit "pause/resume" success criterion directly.
- Failed/interrupted downloads require a **manual "Resume" tap** — no automatic background retry loop, consistent with this app's existing no-auto-retry convention (Phase 2's search API fallback precedent: "network failure goes to the explicit error state... no auto-retry").
- **Exception:** a momentary Wi-Fi drop during an already-running background download **auto-pauses and auto-resumes silently** once Wi-Fi returns — not treated as a failure requiring manual intervention, since the user already approved this background transfer and didn't do anything wrong. Manual-retry-only applies to genuine failures/interruptions, not routine connectivity blips.
- Explicit **Cancel deletes the partial file** immediately (clean slate, no orphaned disk usage). An **interruption** (app killed, connection lost) **keeps the partial file** so "Resume" has something to resume from.

### Revert-to-Seed Behavior
- Reverting **deletes the downloaded full-catalog database from disk** (reclaiming ~300–800MB) and falls back to querying the bundled starter seed exactly as before — the same swap pattern as `first_launch_extractor.dart`, just reversed. Does not keep the full pack around "just in case" — that would defeat the point of reverting.
- Requires a **confirmation dialog** explaining the consequence: "Revert to starter pack? This deletes the full catalog (650MB) and reduces search coverage back to the starter set." Matches this app's established pattern of confirming actions with real, noticeable consequences (Danger Zone wipe, account deletion).
- Revert is available at any time **except while a download/refresh is actively in progress** (disabled/hidden mid-transfer — nothing meaningful to revert from yet, and it would race with the in-progress transfer).
- Reverting resets the automatic delta-refresh schedule setting back to "Manual only" — avoids leaving a confusing "Weekly" setting configured for a feature the user just turned off.

### Claude's Discretion
- Exact copy/wording throughout (button labels, error messages, confirmation dialog phrasing) beyond the content direction given above
- CDN choice/hosting (S3, Cloudflare R2, Bunny, GitHub Releases, or backend-team-owned infra) — an infrastructure decision, flagged as a coordination point but not blocking this phase's planning
- Resumable-download implementation approach (`dio` vs. bare `http` with manual Range requests) — technical implementation detail
- Manifest/version-check endpoint shape and delta-diff format
- Exact progress bar / row visual design within existing DESIGN.md tokens
- Product-count numbers' exact source (CDN manifest metadata vs. computed client-side after download)

</decisions>

<specifics>
## Specific Ideas

- Settings row subtitle examples: "Using starter pack" / "Full catalog installed — 650 MB" / "Downloading… 340/650 MB" / "Update available — connect to Wi-Fi"
- Revert confirmation copy direction: "Revert to starter pack? This deletes the full catalog (650MB) and reduces search coverage back to the starter set."
- Product-count comparison example: "50,000 products (starter pack)" vs "2.5M products (full catalog)"

</specifics>

<code_context>
## Existing Code Insights

### Reusable Assets
- `first_launch_extractor.dart` (`lib/core/assets/first_launch_extractor.dart`) — existing version-comparison + atomic-swap pattern (bundled version constant vs. on-disk `.version` file, `archive`/`path_provider` already in use) directly analogous to what this phase's full-pack install and delta-refresh versioning need.
- `connectivity_plus` 7.3.0 (already a pubspec dependency) — capable of distinguishing Wi-Fi from cellular (`ConnectivityResult.wifi` vs `.mobile`); not yet used that way elsewhere in the codebase (only used for online/offline checks), but no new package needed for the Wi-Fi-only check itself.
- `BackupMetadata`/`autoBackupFrequency` pattern (`lib/domain/entities/backup_metadata.dart`, Phase 5) — direct precedent for this phase's schedule setting (manual/weekly/monthly), including the same "setting exists, foreground-triggered rather than true background" honesty constraint (Phase 5's own `autoBackupFrequency` scheduling was flagged as never fully wired — see STATE.md's Pre-Launch Blockers; this phase should not repeat that gap).
- Phase 5's weigh-in reminder re-arm pattern (`AppLifecycleState.resumed` observer in `Co2DietApp`) — the established pattern for "check something on app resume, throttled to an interval" that this phase's scheduled-check timing reuses.
- Settings screen (`lib/features/settings/screens/settings_screen.dart`) — existing `ListTile` rows extended with the new entry near Backup & Restore.
- No `dio` or resumable-download package exists yet — will need to be added (planner/researcher decision).

### Established Patterns
- No-auto-retry convention on network failures (Phase 2's search API fallback precedent) — applied to failed downloads here.
- Confirmation dialogs for actions with real, noticeable consequences (Danger Zone wipe, account deletion) — applied to the revert action.
- No false-precision / honest concrete numbers (CO2 confidence bands elsewhere) — applied to the product-count comparison and the honest "checked on app open, not true background" framing.

### Integration Points
- `SettingsScreen` gains a new entry near "Backup & Restore."
- New dedicated screen analogous to `BackupRestoreScreen`'s structure.
- `AppDatabase`'s existing `ATTACH DATABASE` mechanism (`off_reference.sqlite`) is the swap target — full-pack download replaces which file gets attached, doesn't change the attach mechanism itself.
- `Co2DietApp`'s `AppLifecycleState.resumed` observer (Phase 5/7 precedent) gains the scheduled-check throttle logic.

</code_context>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope throughout. (A Dashboard-level banner on delta-refresh completion was considered and explicitly rejected, not deferred — see Delta Refresh decisions above.)

</deferred>

---

*Phase: 09-reference-data-delivery-full-off-pack*
*Context gathered: 2026-08-12*
