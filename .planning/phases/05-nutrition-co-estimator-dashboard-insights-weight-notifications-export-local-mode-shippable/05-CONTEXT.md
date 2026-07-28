# Phase 5: Nutrition, CO₂ Estimator, Dashboard, Insights, Weight, Notifications & Export — Local Mode Shippable - Context

**Gathered:** 2026-07-27
**Status:** Ready for planning

<planning_addendum>
## Planning Addendum (post plan-checker review, 2026-07-27)

The first planning pass surfaced four judgment calls the plan-checker correctly flagged as un-escalated decisions rather than legitimate planner discretion. Resolved directly with the user before revision:

- **Backup/export encryption: no encryption in v1.** The "Privacy & Ownership statement" section of Backup & Restore must explicitly disclose that shared backups are not encrypted by the app and the user is responsible for the security of wherever they send it. Design the backup format with a version field so encryption can be added later without breaking compatibility.
- **Restore from backup (PRIV-04) must support importing an external file**, not just backups still in the app's own documents directory — add a minimal file/document-picker package (gated behind the same package-legitimacy checkpoint pattern used elsewhere this phase) so restore works after a reinstall or on a new device, which is the realistic restore scenario.
- **Biweekly/Monthly weigh-in reminders re-arm on every app foreground event**, not only when the Weight Tracking screen itself is opened — `flutter_local_notifications` has no native biweekly/monthly recurrence primitive, so the app must re-check and reschedule on a broader, more reliable trigger than a single screen's lifecycle.
- **INS-01's "today's breakdown by meal" is a real stacked bar chart** (fl_chart's `BarChart` with stacked `BarChartRodStackItem`s), not a plain grouped list — the phase already depends on fl_chart for Dashboard/Weight trend charts, so this reuses the same library rather than adding new scope.

Also addressed from the plan-checker's warnings:
- **CO2-02's "weekly total" must be explicitly computed and displayed somewhere** (Data Analysis screen is the natural home) — day-by-day trend charts alone don't satisfy "daily / weekly totals" from ROADMAP.md's success criteria.
- **`PersonalCo2MultiplierCalculator` giving 3 of 7 CONTEXT.md-listed settings factors (location, storage, household size) no numeric effect** in the first cut is accepted as-is for v1 — confirmed acceptable rather than requiring all 7 factors to produce a distinguishable numeric contribution, consistent with the app's no-false-precision principle (don't fabricate a number when there's no defensible way to compute one yet). Document this narrowing explicitly in code comments rather than treating it as silently-decided scope reduction.

### Execution-time package decision (2026-07-28)

- **`excel` (not `excel_plus`) is locked in for Plan 05-09's Excel export.** Compared directly at Wave 4's package-legitimacy checkpoint: `excel` (justkawal.dev) is stale on pub.dev (v4.0.6, released 2024-08-20, pub score 115/160, 147 open issues) but has real production mileage (1,240 likes, 481 GitHub stars, not discontinued/replaced). `excel_plus` (almasum.dev) has a perfect pub score (160/160) and a very recent release, but its GitHub repo is only ~3.5 months old with 4 stars and 43 likes — too thin a track record for a component that generates user data exports, despite its "faster drop-in replacement" self-description. **Decision: keep `excel`.** Plan 05-09's own package-legitimacy checkpoint does not need to re-litigate this comparison — proceed directly with `excel` when that checkpoint is reached, noting this prior decision.

</planning_addendum>

<domain>
## Phase Boundary

Complete the full local-mode app: nutrition + CO₂ tracking, dashboard, insights, weight tracking, local notifications, and export/backup — so Local Mode is a shippable product independent of any backend. Requirements: NUTR-01–04, CO2-02/03/05/06, DASH-01–08, INS-01–04, WT-01–05, NOTIF-01–03, PRIV-01–04/08/09, AUTH-07, NFR-05.

**What this phase does NOT include:**
- Onboarding, Legal Consent, Legal Hub, ED safety nets (NFR-07), accessibility audit (ACC-01–05) — all Phase 6
- Account Mode, Keycloak auth, cross-device sync — Phase 7
- iOS text-contrast bug on Profile/Settings (Phase 4 deferred item, unrelated to this phase's scope, needs its own investigation)
- Social/community features (Discord, diet-book downloads, community contribution) — explicitly out of v1 scope per PROJECT.md

**Folded in from Phase 4's deferred items:** the CO₂ cache-path gap (API-fallback cached search results not CO₂-enriched — `user_food_cache_fts` rows lack a `primary_category_tag` to join against) is fixed in this phase since Phase 5 is already deep in CO₂ calculation code.

</domain>

<decisions>
## Implementation Decisions

### CO₂ Calculation Settings — Scope & Recalculation Model

- **CO₂ Calculation Settings is a separate personal-footprint layer, not a per-food modifier.** Each food keeps its AGRIBALYSE-sourced `co2e100g`/confidence band untouched — Settings (location, food purchasing source, shopping transport, cooking method, storage, household size, waste level) produce an independent personal-consumption multiplier/add-on applied only at the daily/weekly total level. Per-food CO₂ data stays exactly as Phase 3 built it.
- **Forward-only recalculation.** Changing CO₂ Settings never rewrites already-logged meals (today's or historical) — it only affects future logged entries and future daily/weekly total computations going forward. This is a direct extension of Phase 4's "snapshot, not reference" principle to the settings layer.
- **Data Quality Indicator (Basic/Good/Detailed Estimate)** lives on the CO₂ Calculation Settings screen as the source of truth (per the Full Reference doc). Additionally, when data quality is **Basic**, the Dashboard shows a dismissible "Complete your CO₂ profile for better estimates" prompt card — see Dashboard layout below. No permanent badge is repeated elsewhere; this avoids confusing settings-completeness with the per-food confidence chip (a different concept).
- **Improvement Opportunities substitution logic:** hand-authored substitution clusters (e.g. red meat ↔ poultry ↔ fish ↔ legumes/plant-protein) computed using the existing `co2_factors` category averages from Phase 3 — no new data source. This scales beyond a single "beef→chicken" example and stays realistic (protein-for-protein swaps, not beef-for-lettuce).
- **Improvement Opportunities surfaces only inside the Data Analysis screen** — never on the Dashboard, never as a notification. Fully opt-in via navigating to Insights, satisfying CO2-06's "never shown unsolicited."

### Dashboard Composition (DASH-01–08)

- **Chart library: `fl_chart`** — BSD-3, no telemetry/network calls, handles both the Dashboard's 7-day sparkline and Weight Tracking's richer multi-range chart. Add to pubspec.yaml this phase.
- **Card emphasis adapts to the user's selected goal.** All three metric cards (CO₂, calories, protein) are always shown, but the one matching the user's Profile goal (Reduce CO₂ / Lose weight / Gain muscle / etc.) is ordered/sized first — reinforces the onboarding goal choice without hiding any metric.
- **Quick insight line covers all three metrics**, not CO₂-only: identifies whichever of CO₂/calories/protein is most notable that day (furthest above/below target, or largest single-meal share) and names the contributing meal slot. Tone stays factual, consistent with the existing "Lunch contributed most CO₂ today" example — never judgmental.
- **7-day trend chart is a switchable single-metric sparkline** — a segmented CO2/Calories/Protein toggle controls which metric the 7-day trend plots. Tapping the trend opens Data Analysis pre-set to whichever metric is currently selected (DASH-08).
- **"Complete your CO₂ profile" prompt card placement: bottom, below the meal list** — metric cards, quick-log buttons, and today's meals stay the first thing every user sees regardless of data-quality state; the prompt is a lower-priority nudge encountered after scrolling. Only shown when data quality is Basic; dismissible.
- **"+ Quick Add Food" behaves exactly like the per-slot quick-log buttons** — same Phase 4 time-of-day auto-detected slot, editable inside the sheet. No new logic; it's a generic entry point into the same flow.
- **Mode indicator wording unchanged from spec:** Local Mode "Stored on this device" / Account Mode "Synced across devices."

### Weight Tracking (WT-01–05)

- **Placement resolves the flagged open decision:** Settings-primary + linked from Insights. The Weight Tracking screen (logging, history, chart, reminders, goal) lives exclusively under Profile/Settings — no duplicate logging surface elsewhere. The Insights/Data Analysis screen additionally gets a "Weight" entry in its metric list; tapping it opens a Data-Analysis-style trend breakdown for weight, but all actual weigh-in logging stays in Settings.
- **Weight goal progress:** a horizontal dashed target-weight line on the chart only — no derived pace/projection text ("on pace for your target date" is explicitly excluded), avoiding any implied guarantee about whether the user is on track.
- **Weigh-in reminder "Custom" option:** user picks a specific weekday + time (same underlying `flutter_local_notifications` scheduling mechanism as Weekly, just user-chosen day/time). Full option set: Never/Weekly/2-Weekly/Monthly/Custom(day+time).
- **"Learn More" section (guide, diet book, Discord) is excluded entirely** from v1 — these are community/social-adjacent features PROJECT.md explicitly defers to P2, and no Discord server or diet-book asset is confirmed to exist. Weight Tracking ships with Record/History+Chart/Reminders/Goal only.
- **Default chart time-range on screen open: 30d** — matches the 7d/30d convention used elsewhere in Dashboard/Insights; full 7d/30d/90d/1yr/all filter remains available via tabs.

### Insights / Data Analysis Screen (INS-01–04)

- **Insights Timeline: small fixed rule set for v1**, not a single CO₂-only rule and not open-ended ML. Hand-authored pattern families computed from local data — e.g. "CO₂ consistently higher on N weekday evenings," "protein consistently below target on M days," "CO₂ trending up/down over the trailing week." Bounded and testable; extensible in later phases.
- **Largest Contributors ranked by whichever metric the screen was entered on** — opening from a CO₂ tap ranks today's foods by CO₂ contribution; opening from Protein ranks by protein contribution. One reusable ranked-list component, per-metric data.
- **Estimate Transparency gets a richer inline variant specific to Data Analysis** (not just reusing Phase 3's single ConfidenceChip verbatim) — e.g. showing the mix of High/Medium confidence items contributing to today's aggregate CO₂ total, appropriate for an aggregate view rather than a single food.
- **Trend section has two independent toggles:** a metric segmented-control (CO₂/Calories/Protein) and a separate range segmented-control (7d/30d) — settable independently (e.g. view Protein over 30 days), not one combined selector. Metric is pre-set from whichever Dashboard metric was tapped to enter the screen; range defaults per existing convention.
- **Detailed Food Analysis is an expandable panel per meal-entry row** in today's already-rendered slot-grouped meal list — not a separate consolidated food list. Reuses Phase 4/Dashboard's existing meal-entry rendering; tap-to-expand reveals per-serving + per-100g values.

### Notifications (NOTIF-01–03)

- **Meal reminders: one independently configurable time per slot** (Breakfast/Lunch/Dinner/Snack), each with its own enable/disable toggle and time picker — not a single generic daily reminder.
- **Settings location split:** meal-reminder config lives in the existing "General Settings" screen (confirmed in the live-build screen inventory — already covers units/notifications/local-mode-status/export/account). Weigh-in reminder config (day/time/frequency) lives directly inside the Weight Tracking screen next to the Weight Goal section, matching the Full Reference doc's Weight Tracking spec.
- **Notification permission requested just-in-time** — only when the user first enables any reminder toggle (meal or weigh-in), never upfront during onboarding (onboarding is Phase 6 scope anyway). Respects NFR-04's no-aggressive-nudging principle.
- **Permission denied handling:** the toggle reverts to off with an inline "Open Settings" link/message — same lightweight pattern reused, but NOT a full-screen rationale block (that heavier treatment is reserved for Phase 3's camera permission, which blocks a whole feature; reminders are optional/minimal per NOTIF-01's own wording).
- **Tapping a meal reminder notification opens food search with that slot pre-selected** — same pre-set-slot pattern as Dashboard's per-slot quick-log buttons, turning the reminder directly into the 10-second logging action it's meant to prompt.
- All notifications delivered via `flutter_local_notifications` only — zero FCM/APNs, no server-side infrastructure (NOTIF-03, already locked at the requirements level).

### Export & Backup (PRIV-01–04/08/09)

- **Phase 5 implements the Backup & Restore screen directly per the Full Reference doc's existing spec** (§3 "Backup & Restore"): Current Storage Status, Create Backup, Automatic Backups, Restore Data, Export Data, Privacy & Ownership statement, Danger Zone. Not redesigned from scratch.
- **"Cloud" backup destination = OS share sheet only** (`share_plus` package) — device/iCloud/Google Drive/AirDrop/etc. are all reached via the user's own share-sheet choice. The app never integrates directly with any cloud provider API — no new third-party SDK, no network/auth surface, fully consistent with PRIV-08 (no data transmitted without explicit user action) and the zero-backend Local Mode principle.
- **Automatic Backups: Off/Daily/Weekly frequency options**, writing to a fixed location in the app's own documents directory (not the OS share sheet, since that requires interactive per-run user choice). The user can manually share/export the latest auto-backup file at any time via "Create Backup." No folder-picker/persistent-storage-access flow needed.
- **Danger Zone typed confirmation: user types "DELETE"** (generic fixed word) — standard destructive-action confirmation pattern, no personalization needed.
- Export data format (CSV/Excel/JSON, selectable categories, zip + manifest.json) follows PRIV-01's existing literal spec — left as Claude's discretion for exact manifest schema/field naming during planning.

### Claude's Discretion

- Exact `fl_chart` configuration (line styling, annotation API usage for the weight-goal target line)
- Improvement Opportunities' exact substitution-cluster membership (which AGRIBALYSE categories group together)
- Insights Timeline's exact rule thresholds (e.g. how many days constitute "consistently")
- Dashboard/Insights card spacing, sizing, and exact goal-to-metric-priority mapping implementation
- Export data zip/manifest.json exact schema and field naming
- Weight Tracking's "Best Practices" tips section copy (kept — harmless static content, not scope creep, no new capability)
- DAO/repository/provider naming conventions for new CO₂ settings, weight, notification-preference, and backup-related tables/entities

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets

- `PlaceholderDashboardScreen` (`lib/features/dashboard/screens/placeholder_dashboard_screen.dart`) — already has slot-grouped meal entries, swipe-to-Edit/Duplicate/Delete (`flutter_slidable`), empty state, and Undo-snackbar patterns from Phase 4. Phase 5 extends this same screen with metric cards, chart, quick insight, mode indicator, and the CO₂-profile prompt card rather than rebuilding it.
- `MealEntry` / `MealEntryRow` (`lib/features/dashboard/widgets/meal_entry_row.dart`, `lib/domain/entities/meal_entry.dart`) — live-scaling macro/CO₂ math already built; Detailed Food Analysis's expandable panel extends this row rather than creating a new list.
- `ConfidenceChip` (`lib/features/barcode_scan/widgets/confidence_chip.dart`) and `MethodologyScreen` — Phase 3's transparency components; Data Analysis's richer inline variant builds on top of these rather than replacing them.
- `co2_factors` / `food_co2_overrides` tables in `off_reference.sqlite` (Phase 3 ingest) — category-average data reused directly for Improvement Opportunities' substitution-cluster CO₂ deltas; no new data source needed.
- `FoodCatalogDao`/`FoodCatalogRepository` (`lib/data/local/daos/food_catalog_dao.dart`) — `searchLocalFoods` was already fixed (commit `2218dbb`) to LEFT JOIN CO₂ data; the remaining cache-path gap is in `FoodCatalogRepository.searchAndCache`/`lookupByBarcode`'s cache-write path (hardcodes `categoriesTags: const Value(null)`), which this phase fixes by storing the category tag at cache-write time.
- `SyncSafeTable` mixin — all new Phase 5 tables (CO₂ settings, weight entries, notification preferences, backup metadata) apply this mixin, following the established HLC-placeholder convention (`hlcNodeId: 'local'`, `hlcCounter: 0`) until Phase 7.
- `app_settings` (8.0.3, already a dependency) — reused for the "Open Settings" deep-link on notification-permission-denied, same pattern as Phase 3's camera-permission handling.
- `permission_handler` (12.0.3, already a dependency) — reused for notification permission status/request.

### Established Patterns

- Snapshot-not-reference data model (Phase 4) — extended in this phase to CO₂ Settings: settings changes are forward-only, never retroactive.
- No shimmer/loading indicator for fast local DB operations; distinct honest messaging per failure mode; no false-precision numbers (all phases) — apply to every new CO₂/nutrition display surface this phase adds.
- go_router named routes — new routes needed for CO₂ Calculation Settings, Data Analysis, Weight Tracking, Backup & Restore, and General Settings notification section.
- `@riverpod class` codegen notifier pattern (suffix-stripped provider names) — followed for new CO₂ Settings, Weight, and Backup notifiers.

### Integration Points

- `PlaceholderDashboardScreen` becomes the real Dashboard — first phase to add metric-card summaries, the fl_chart trend, and the CO₂-profile prompt card on top of Phase 4's existing meal-list body.
- Data Analysis screen is a new screen reached from Dashboard metric taps (DASH-08) and from the new Weight entry in its own metric list.
- General Settings screen (confirmed in live-build inventory, not yet built) gains notification toggles/times, units, local-mode status, export/clear-data entry points, and account info — this phase builds it out.
- `off_reference.sqlite`'s `co2_factors` table is queried both for per-meal totals (existing Phase 3 use) and now for Improvement Opportunities' substitution deltas (new Phase 5 use) — no schema change needed, new query only.

</code_context>

<specifics>
## Specific Ideas

- "Complete your CO₂ profile for better estimates" — the exact recommended framing for the Basic-data-quality Dashboard prompt card; keeps it actionable rather than a passive badge.
- Improvement Opportunities substitution clusters described as "red meat ↔ poultry ↔ fish ↔ legumes/plant-protein" — the guiding example for how substitution groups should be structured (protein-for-protein swaps within a realistic band, not arbitrary cross-category suggestions).
- "Target line only, no pace projection" for weight goals — an explicit rejection of any derived "on pace" language, consistent with the app's honesty-over-implied-guarantee principle applied elsewhere to CO₂ confidence bands.
- CO₂ cache-path gap fix folded in here specifically because "Phase 5 is already deep in CO₂ calc code" — cheaper to fix now than reopen cold later.

</specifics>

<deferred>
## Deferred Ideas

- **Weight Tracking "Learn More" section** (guide, diet book, Discord community link) — excluded from v1 entirely; PROJECT.md defers social/community features to P2. Revisit only if/when a Discord server and diet-book asset actually exist.
- **iOS text-contrast bug on Profile/Settings screens** (Phase 4 deferred item) — stays deferred; unrelated to Phase 5's scope, needs its own root-cause investigation, likely surfaces again during Phase 6's accessibility audit.
- **NFR-07 ED safety-net clamp (visible warning UI for <1200kcal/BMI<17.5 targets)** — confirmed to stay entirely Phase 6's responsibility, not folded into this phase despite the nutrition-tracking overlap.
- **Direct cloud-provider integration for backups** (vs. OS share sheet) — not pursued; would add a new third-party SDK/network surface Local Mode has avoided everywhere else. No plan to revisit unless a future phase explicitly requires seamless auto-cloud-sync of backups.

</deferred>

---

*Phase: 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable*
*Context gathered: 2026-07-27*
