# Phase 5: Nutrition, CO₂ Estimator, Dashboard, Insights, Weight, Notifications & Export - Research

**Researched:** 2026-07-27
**Domain:** Flutter local-mode feature completion — charting (fl_chart), local notification scheduling (flutter_local_notifications), file export/backup (archive/csv/excel/share_plus), Drift multi-table schema migration, Riverpod codegen notifiers, go_router screen additions
**Confidence:** MEDIUM-HIGH (stack choices HIGH; several fast-moving-plugin API details corrected mid-research — see Pitfalls)

## Summary

This phase is six sub-domains bolted onto an already-mature Phase 1-4 codebase (Drift + `SyncSafeTable`, Riverpod 3.x `@riverpod class` codegen, go_router, established snapshot-not-reference data model). None of the six sub-domains need a new architectural pattern — they all reuse patterns already proven in Phases 1-4. The real risk in this phase is not "what pattern to use" but two things: (1) two fast-moving third-party plugins (`fl_chart` 1.x, `flutter_local_notifications` 22.x) whose APIs changed significantly from the 0.x/pre-20.x versions that dominate tutorials and training data, and (2) a genuine schema gap discovered during this research: `MealEntryTable` does not snapshot sugar/fiber/sodium, but NUTR-01 requires daily totals for exactly those three nutrients. This must be resolved by the planner (schema migration + write-path change), not silently patched over.

`fl_chart` 1.2.0 is confirmed current, BSD-3, and its `ExtraLinesData`/`HorizontalLine` API cleanly supports the weight-goal target line, and its `LineTouchData`/`titlesData` APIs support both the compact Dashboard sparkline (hide titles) and the richer interactive Data-Analysis/Weight chart (touch tooltips). `flutter_local_notifications` 22.2.0 is confirmed current; critically, **as of v20.0.0 every scheduling/init method takes named parameters only** — code written against older (positional-parameter) tutorials will not compile. `share_plus` 13.3.0's modern API is `SharePlus.instance.share(ShareParams(...))`, not the deprecated static `Share.shareXFiles`. `archive` 4.0.9 (already a dependency) supports zip creation via `archive_io.dart`'s `ZipFileEncoder` (already imported in this codebase for gzip decompression, so no new import path), satisfying PRIV-01's zip+manifest requirement without a new package. `csv` 8.0.0 and `excel` 4.0.6 are both viable, verified-publisher packages for the CSV/Excel export formats.

**Primary recommendation:** Reuse every established Phase 1-4 pattern verbatim (SyncSafeTable tables, `@riverpod class` notifiers, `if (from < N)` migration blocks, go_router named routes with query-param screen initialization) for the six new sub-domains; add `fl_chart`, `flutter_local_notifications` (+`timezone`+`flutter_timezone`), `share_plus`, `csv`, `excel` as new dependencies (all via the same human-approval-checkpoint precedent set in Plan 04-11, since pub.dev/Dart is not a slopcheck-supported ecosystem); and resolve the MealEntryTable sugar/fiber/sodium snapshot gap explicitly as a Phase 5 schema task before NUTR-01 can be considered done.

## User Constraints (from CONTEXT.md)

### Locked Decisions

**CO₂ Calculation Settings — Scope & Recalculation Model**
- CO₂ Calculation Settings is a separate personal-footprint layer, not a per-food modifier. Each food keeps its AGRIBALYSE-sourced `co2e100g`/confidence band untouched — Settings (location, food purchasing source, shopping transport, cooking method, storage, household size, waste level) produce an independent personal-consumption multiplier/add-on applied only at the daily/weekly total level. Per-food CO₂ data stays exactly as Phase 3 built it.
- Forward-only recalculation. Changing CO₂ Settings never rewrites already-logged meals — it only affects future logged entries and future daily/weekly total computations going forward. Direct extension of Phase 4's "snapshot, not reference" principle to the settings layer.
- Data Quality Indicator (Basic/Good/Detailed Estimate) lives on the CO₂ Calculation Settings screen as source of truth. When data quality is Basic, Dashboard shows a dismissible "Complete your CO₂ profile for better estimates" prompt card. No permanent badge repeated elsewhere.
- Improvement Opportunities substitution logic: hand-authored substitution clusters (e.g. red meat ↔ poultry ↔ fish ↔ legumes/plant-protein) computed using existing `co2_factors` category averages from Phase 3 — no new data source. Protein-for-protein swaps, not beef-for-lettuce.
- Improvement Opportunities surfaces only inside the Data Analysis screen — never on the Dashboard, never as a notification. Fully opt-in.

**Dashboard Composition (DASH-01–08)**
- Chart library: `fl_chart` — BSD-3, no telemetry/network calls, handles both Dashboard 7-day sparkline and Weight Tracking's richer multi-range chart. Add to pubspec.yaml this phase.
- Card emphasis adapts to the user's selected goal. All three metric cards (CO₂, calories, protein) always shown; the one matching Profile goal is ordered/sized first.
- Quick insight line covers all three metrics: identifies whichever of CO₂/calories/protein is most notable that day, names the contributing meal slot. Factual tone, never judgmental.
- 7-day trend chart is a switchable single-metric sparkline — segmented CO2/Calories/Protein toggle. Tapping opens Data Analysis pre-set to selected metric (DASH-08).
- "Complete your CO₂ profile" prompt card placement: bottom, below the meal list. Only shown when data quality is Basic; dismissible.
- "+ Quick Add Food" behaves exactly like per-slot quick-log buttons — same Phase 4 time-of-day auto-detected slot, editable inside the sheet.
- Mode indicator wording unchanged: Local Mode "Stored on this device" / Account Mode "Synced across devices."

**Weight Tracking (WT-01–05)**
- Placement: Settings-primary + linked from Insights. Weight Tracking screen (logging, history, chart, reminders, goal) lives exclusively under Profile/Settings — no duplicate logging surface elsewhere. Insights/Data Analysis screen gets a "Weight" entry in its metric list; tapping opens a Data-Analysis-style trend breakdown for weight, but all logging stays in Settings.
- Weight goal progress: a horizontal dashed target-weight line on the chart only — no derived pace/projection text.
- Weigh-in reminder "Custom" option: user picks specific weekday + time (same `flutter_local_notifications` scheduling mechanism as Weekly, just user-chosen day/time). Full option set: Never/Weekly/2-Weekly/Monthly/Custom(day+time).
- "Learn More" section (guide, diet book, Discord) excluded entirely from v1.
- Default chart time-range on screen open: 30d. Full 7d/30d/90d/1yr/all filter remains available via tabs.

**Insights / Data Analysis Screen (INS-01–04)**
- Insights Timeline: small fixed rule set for v1, hand-authored pattern families computed from local data. Bounded and testable; extensible later.
- Largest Contributors ranked by whichever metric the screen was entered on. One reusable ranked-list component, per-metric data.
- Estimate Transparency gets a richer inline variant specific to Data Analysis (not just reusing Phase 3's single ConfidenceChip verbatim) — e.g. mix of High/Medium confidence items contributing to today's aggregate CO₂ total.
- Trend section has two independent toggles: metric segmented-control (CO₂/Calories/Protein) and range segmented-control (7d/30d), settable independently. Metric pre-set from whichever Dashboard metric was tapped to enter; range defaults per existing convention.
- Detailed Food Analysis is an expandable panel per meal-entry row in today's already-rendered slot-grouped meal list — reuses Phase 4/Dashboard's existing meal-entry rendering; tap-to-expand reveals per-serving + per-100g values.

**Notifications (NOTIF-01–03)**
- Meal reminders: one independently configurable time per slot (Breakfast/Lunch/Dinner/Snack), each with own enable/disable toggle and time picker.
- Settings location split: meal-reminder config in existing "General Settings" screen. Weigh-in reminder config (day/time/frequency) lives directly inside Weight Tracking screen next to Weight Goal section.
- Notification permission requested just-in-time — only when user first enables any reminder toggle (meal or weigh-in), never upfront during onboarding.
- Permission denied handling: toggle reverts to off with inline "Open Settings" link/message — NOT a full-screen rationale block.
- Tapping a meal reminder notification opens food search with that slot pre-selected.
- All notifications delivered via `flutter_local_notifications` only — zero FCM/APNs, no server-side infrastructure (already locked at requirements level).

**Export & Backup (PRIV-01–04/08/09)**
- Phase 5 implements the Backup & Restore screen directly per the Full Reference doc's existing spec (§3 "Backup & Restore"): Current Storage Status, Create Backup, Automatic Backups, Restore Data, Export Data, Privacy & Ownership statement, Danger Zone.
- "Cloud" backup destination = OS share sheet only (`share_plus` package) — device/iCloud/Google Drive/AirDrop/etc. reached via the user's own share-sheet choice. No new third-party SDK, no network/auth surface.
- Automatic Backups: Off/Daily/Weekly frequency options, writing to a fixed location in the app's own documents directory (not the OS share sheet). User can manually share/export the latest auto-backup file at any time via "Create Backup." No folder-picker/persistent-storage-access flow needed.
- Danger Zone typed confirmation: user types "DELETE" (generic fixed word).
- Export data format (CSV/Excel/JSON, selectable categories, zip + manifest.json) follows PRIV-01's existing literal spec — manifest schema/field naming left as Claude's discretion.

### Claude's Discretion
- Exact `fl_chart` configuration (line styling, annotation API usage for the weight-goal target line)
- Improvement Opportunities' exact substitution-cluster membership (which AGRIBALYSE categories group together)
- Insights Timeline's exact rule thresholds (e.g. how many days constitute "consistently")
- Dashboard/Insights card spacing, sizing, and exact goal-to-metric-priority mapping implementation
- Export data zip/manifest.json exact schema and field naming
- Weight Tracking's "Best Practices" tips section copy
- DAO/repository/provider naming conventions for new CO₂ settings, weight, notification-preference, and backup-related tables/entities

### Deferred Ideas (OUT OF SCOPE)
- Weight Tracking "Learn More" section (guide, diet book, Discord community link) — excluded from v1 entirely.
- iOS text-contrast bug on Profile/Settings screens (Phase 4 deferred item) — stays deferred.
- NFR-07 ED safety-net clamp (visible warning UI for <1200kcal/BMI<17.5 targets) — Phase 6's responsibility.
- Direct cloud-provider integration for backups (vs. OS share sheet) — not pursued.

## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| NUTR-01 | Track per-meal/daily totals: calories, protein, carbs, fat, sugar, fiber, sodium | **Schema gap found** — see Pitfall 1. `MealEntryTable` must gain 3 new snapshot columns before this is achievable for newly-logged entries. |
| NUTR-02 | Dashboard shows calories vs target | Existing `CalcTargets.kcalTarget` + new metric-card widget; no new lib needed |
| NUTR-03 | Dashboard shows protein vs target | Existing `CalcTargets.proteinGTarget`; same pattern as NUTR-02 |
| NUTR-04 | Macro split viewable from Dashboard/Data Analysis | Standard `fl_chart` `PieChart` or simple proportional bar; no annotation API needed |
| CO2-02 | CO₂e per meal/daily/weekly, on-device, deterministic | Extends existing `co2_factors`/`food_co2_overrides` query pattern; personal-multiplier layer is pure Dart, no new lib |
| CO2-03 | CO₂ Calculation Settings screen with regional-average fallback | New `SyncSafeTable`, `@riverpod class` notifier, form screen — same pattern as `ProfileScreen`/`ProfileNotifier` |
| CO2-05 | Estimate Transparency screen enrichment | Extends existing `ConfidenceChip`/`MethodologyScreen` (Phase 3) |
| CO2-06 | Improvement Opportunities with quantified delta | Pure Dart computation over `co2_factors`; Data-Analysis-screen-only placement |
| DASH-01–08 | Dashboard composition | `fl_chart` LineChart (sparkline mode) + existing meal-list/quick-log patterns |
| INS-01–04 | Data Analysis screen | `fl_chart` (bar + line), reusable ranked-list widget, expandable `MealEntryRow` variant |
| WT-01–05 | Weight tracking | New `SyncSafeTable`, `fl_chart` LineChart with `ExtraLinesData`/`HorizontalLine`, `flutter_local_notifications` weekly/custom scheduling |
| NOTIF-01–03 | Local notifications | `flutter_local_notifications` 22.2.0 + `timezone`/`flutter_timezone`, `permission_handler` (existing dep) |
| PRIV-01–04/08/09 | Export/backup | `archive_io.dart` `ZipFileEncoder` (already imported), `csv`, `excel`, `share_plus`, JSON via `dart:convert` (no new dep) |
| AUTH-07 | Local Mode zero-server-contact | Already enforced architecturally (no network client is introduced this phase) — verify no new package makes network calls |
| NFR-05 | Honest uncertainty, no false-precision | Reuse `formatCo2Display`/`ConfidenceChip` conventions on every new CO₂ display surface |

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| CO₂ personal-multiplier calculation | API/Backend-equivalent (local domain service) | Database/Storage | Pure deterministic Dart function over settings + per-meal snapshot data; must stay offline/on-device per CO2-02 |
| CO₂/Weight/Notification/Backup settings persistence | Database/Storage | — | New `SyncSafeTable` tables, Drift DAOs |
| Dashboard metric cards, sparkline, quick insight | Browser/Client (Flutter widget) | Database/Storage (read) | Presentation reads pre-aggregated totals; no business logic in widgets |
| Data Analysis screen (trends, contributors, timeline) | Browser/Client (Flutter widget) | Local domain service | Widgets render; aggregation/ranking logic lives in a domain/service layer (mirrors `TargetCalculator`), not inline in widgets |
| Weight logging + chart + reminders | Browser/Client (Flutter widget) | Database/Storage + local domain service (notification scheduling) | Reminder scheduling delegates to a `NotificationService` wrapper, not called directly from widgets |
| Notification scheduling/permission | Local domain service (`NotificationService`) | OS (platform channel via plugin) | Plugin talks to OS AlarmManager/UNUserNotificationCenter; app code only calls the service wrapper |
| Export/Backup file generation | Local domain service (`BackupService`/`ExportService`) | Database/Storage (read) + OS (share sheet) | Zip/CSV/Excel generation is pure Dart; OS involvement limited to share sheet and documents-directory file I/O |
| CO₂ cache-path fix (categoriesTags at write time) | Database/Storage + local domain service | — | Fix lives in `FoodCatalogRepository`'s cache-write path and `FoodCatalogDao`'s cache-side query, not UI |

## Standard Stack

### Core

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| `fl_chart` | 1.2.0 | Dashboard sparkline + Weight/Data-Analysis interactive line/bar charts | Most widely used pure-Dart chart lib in the Flutter ecosystem; BSD-3, no telemetry; `ExtraLinesData`/`HorizontalLine` directly supports the weight-goal target line CONTEXT.md requires [VERIFIED: pub.dev registry 2026-07-27, homepage flchart.dev, repo github.com/imaNNeo/fl_chart] |
| `flutter_local_notifications` | 22.2.0 | Meal-slot + weigh-in scheduled local notifications (NOTIF-01–03) | The de facto standard cross-platform local-notification plugin; zero server dependency, matches the "zero FCM/APNs" requirement exactly [VERIFIED: pub.dev registry 2026-07-27] |
| `timezone` | 0.11.1 | Required transitive dependency for `flutter_local_notifications`'s `zonedSchedule` (`TZDateTime`) | Mandatory companion package since v2.0 of flutter_local_notifications [VERIFIED: pub.dev registry] |
| `flutter_timezone` | 5.1.0 | Reads the device's actual IANA timezone name at runtime, to feed `timezone` package's `setLocalLocation` | Standard companion recommended by flutter_local_notifications' own docs/examples for correct local-time scheduling [ASSUMED — pairing convention from WebSearch/training data, not confirmed via an official flutter_local_notifications doc page in this session] |
| `share_plus` | 13.3.0 | Hand the generated backup/export zip to the OS share sheet (PRIV-02) | Standard Flutter-community plugin (`fluttercommunity/plus_plugins`) for `ACTION_SEND`/`UIActivityViewController`; only viable "Cloud" backup mechanism per CONTEXT.md's zero-new-SDK constraint [VERIFIED: pub.dev registry 2026-07-27] |

### Supporting

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `csv` | 8.0.0 | Encode selected export categories to CSV (PRIV-01) | `ListToCsvConverter` for one worksheet-shaped table at a time [VERIFIED: pub.dev registry] |
| `excel` | 4.0.6 | Encode selected export categories to `.xlsx` (PRIV-01) | `Excel.createExcel()` + `appendRow`/`encode()`; only path in the Dart ecosystem for genuine `.xlsx` (not just CSV-with-.xlsx-extension) [VERIFIED: pub.dev registry; note lower pub score 115/160 — see Package Legitimacy Audit] |
| `archive` (already a dependency, 4.0.9) | 4.0.9 | Create the export/backup `.zip` via `archive_io.dart`'s `ZipFileEncoder` | No new dependency — `archive_io.dart` is already imported in `lib/core/assets/first_launch_extractor.dart` for `GZipDecoder`; `ZipFileEncoder` lives in the same library [VERIFIED: pub.dev registry + existing codebase import] |
| `dart:convert` (SDK) | — | `manifest.json` and JSON-category export encoding | No new dependency; `JsonEncoder.withIndent` already used in `tool/generate_schema_v1.dart` |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `fl_chart` | `syncfusion_flutter_charts` | Richer built-in annotations/tooltips, but Syncfusion requires a commercial license beyond a free-tier row/column cap and pulls in a much larger dependency footprint — inconsistent with this project's "small, auditable, no telemetry" dependency philosophy already established (flutter_slidable, mobile_scanner picks). |
| `flutter_local_notifications` | `awesome_notifications` | Also popular and FCM-free-capable, but flutter_local_notifications is already the ecosystem-standard choice referenced by NOTIF-03's own requirement wording and has a longer track record; no reason to introduce a second, less-established notification plugin. |
| `excel` for `.xlsx` | Skip `.xlsx`, only offer CSV + JSON | Simpler, one fewer dependency, but PRIV-01's requirement literally lists "CSV, Excel, JSON" as the three formats — dropping Excel would under-deliver the requirement without a CONTEXT.md decision authorizing that cut. Flagged as an Open Question below rather than silently descoped. |
| `share_plus` | Platform channel hand-rolled share intent | Reinventing `ACTION_SEND`/`UIActivityViewController` platform-channel code from scratch for both iOS and Android is exactly the kind of "don't hand-roll" case Flutter plugins exist to solve; no justification to avoid the well-established plugin. |

**Installation:**
```bash
flutter pub add fl_chart flutter_local_notifications timezone flutter_timezone share_plus csv excel
```

**Version verification (ran 2026-07-27 via `pub.dev` API, `curl -s https://pub.dev/api/packages/<pkg>`):**

| Package | Verified version | Published |
|---------|------------------|-----------|
| fl_chart | 1.2.0 | 2026-03-13 |
| flutter_local_notifications | 22.2.0 | 2026-07-25 |
| share_plus | 13.3.0 | 2026-07-23 |
| timezone | 0.11.1 | 2026-06-29 |
| flutter_timezone | 5.1.0 | 2026-05-28 |
| csv | 8.0.0 | 2026-03-19 |
| excel | 4.0.6 | 2024-08-20 (no newer release in ~2 years — see Package Legitimacy Audit) |
| archive (existing dep) | 4.0.9 | 2026-02-17 |

Training data versions for `fl_chart` (commonly recalled as 0.6x with a very different API) and `flutter_local_notifications` (commonly recalled with positional-parameter method signatures) are **stale by at least one major version each** — do not trust remembered code samples for either package without checking the Pitfalls section below.

## Package Legitimacy Audit

> pub.dev/Dart is **not** a slopcheck-supported ecosystem (`slopcheck install --help` lists only `pypi, npm, crates.io, go, rubygems, maven, packagist`). This mirrors the exact situation the project already hit in Plan 04-11 (`flutter_slidable`), which was resolved by an independent-signal review (pub.dev score, likes, verified publisher, active repo) plus an explicit human-approval checkpoint. The same approach is applied here — every new package below is `[ASSUMED]` in the slopcheck sense and **must** be gated behind a `checkpoint:human-verify` task before install, per the graceful-degradation protocol.

| Package | Registry | Age | Score / Likes | Publisher | Source Repo | slopcheck | Disposition |
|---------|----------|-----|----------------|-----------|--------------|-----------|-------------|
| fl_chart | pub.dev | 1.2.0 released 2026-03; package itself is multi-year (imaNNeo/fl_chart, well-known Flutter-favorite chart lib) | 150/160, 7,174 likes | imaNNeo (not verified-publisher badge confirmed this session) | github.com/imaNNeo/fl_chart | N/A (ecosystem unsupported) | Approved — flag `checkpoint:human-verify` |
| flutter_local_notifications | pub.dev | Long-running (MaikuB), v22.2.0 released 2026-07-25 | 150/160, 7,329 likes | MaikuB | github.com/MaikuB/flutter_local_notifications | N/A | Approved — flag `checkpoint:human-verify` |
| timezone | pub.dev | Long-running, mandatory transitive of flutter_local_notifications | 150/160 | — | — | N/A | Approved (required transitive) |
| flutter_timezone | pub.dev | Long-running (tjarvstrand) | 150/160, 335 likes | tjarvstrand | github.com/tjarvstrand/flutter_timezone | N/A | Approved — flag `checkpoint:human-verify` (lower like-count than others; still healthy score) |
| share_plus | pub.dev | Long-running, part of `fluttercommunity/plus_plugins` monorepo | 150/160, 4,008 likes | fluttercommunity | github.com/fluttercommunity/plus_plugins | N/A | Approved — flag `checkpoint:human-verify` |
| csv | pub.dev | Long-running (close2/csv) | 150/160, 404 likes | close2 | github.com/close2/csv | N/A | Approved — flag `checkpoint:human-verify` |
| excel | pub.dev | Last published 2024-08-20 (**~2 years stale as of this research date**) | **115/160** (lower than every other candidate here), 1,240 likes | justkawal.dev (pub.dev-verified publisher badge confirmed) | github.com/justkawal/excel | N/A | **Flagged [SUS]-equivalent — planner must add `checkpoint:human-verify` with explicit reviewer attention to the stale-publish-date + sub-130 score before install** |

**Packages removed due to slopcheck [SLOP] verdict:** none (slopcheck could not run against this ecosystem — no verdicts produced).
**Packages flagged as suspicious (independent-signal equivalent of [SUS]):** `excel` — stale publish date (last release ~2 years old relative to 2026-07-27) combined with the lowest pub score of the candidate set (115/160, versus 150/160 for every other new dependency). The verified-publisher badge and dependency graph (uses `archive`, `xml`, `collection`, `equatable` — all mainstream) are reassuring, but the planner should insert a `checkpoint:human-verify` task specifically calling out these two signals before `excel` is added to `pubspec.yaml`, and should re-check pub.dev for a newer release at execution time in case one has landed since this research.

*All seven new packages above are effectively `[ASSUMED]` per the graceful-degradation rule (ecosystem unsupported by slopcheck) — the planner must gate each new dependency's first install behind a `checkpoint:human-verify` task, following the exact precedent already set in Plan 04-11 for `flutter_slidable`.*

## Architecture Patterns

### System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│  Dashboard screen (Client)                                          │
│  - metric cards (CO2/cal/protein) ── reads ──┐                     │
│  - 7d sparkline (fl_chart LineChart)          │                     │
│  - quick insight line                          │                     │
│  - "Complete CO2 profile" prompt (if Basic)    │                     │
└───────────────┬─────────────────────┬──────────┼─────────────────────┘
                │ tap metric/chart     │ tap prompt
                ▼                      ▼          │
┌───────────────────────────┐  ┌───────────────┐  │
│ Data Analysis screen       │  │ CO2 Settings  │  │
│ (Client)                   │  │ screen        │  │
│ - stacked bar (today)       │  │ (Client)      │  │
│ - ranked contributors        │  └──────┬────────┘  │
│ - trend (metric x range)     │         │ writes     │
│ - Improvement Opportunities  │         ▼            │
│ - expandable food rows       │  ┌───────────────┐  │
│ - Estimate Transparency      │  │ CO2SettingsDao│  │
│ - Insights Timeline          │  │ (new table)   │  │
└──────────────┬───────────────┘  └──────┬────────┘  │
               │ reads aggregates         │           │
               ▼                          ▼           │
┌──────────────────────────────────────────────────┐  │
│  Local domain services (pure Dart, no I/O side   │  │
│  effects beyond DB reads)                         │  │
│  - DailyTotalsCalculator (NUTR-01/CO2-02)         │◄─┘
│  - PersonalCo2MultiplierCalculator (CO2-03)       │
│  - ImprovementOpportunityFinder (CO2-06)          │
│  - InsightsTimelineRuleEngine (INS-03)            │
└───────────────┬────────────────────────────────────┘
                │ reads
                ▼
┌──────────────────────────────────────────────────┐
│  Drift DAOs (Database/Storage tier)                │
│  MealEntryDao, UserFoodDao, FoodCatalogDao         │
│  + new: Co2SettingsDao, WeightEntryDao,            │
│    NotificationPrefsDao, BackupMetadataDao         │
└───────────────┬────────────────────────────────────┘
                │
                ▼
        co2diet.sqlite (+ ATTACHed off_reference.sqlite)

┌─────────────────────────────────────────────────────────────────┐
│  Weight Tracking screen (Client, under Settings)                 │
│  - log entry → WeightEntryDao                                    │
│  - fl_chart LineChart w/ HorizontalLine (goal) + range tabs       │
│  - reminder config → NotificationService.scheduleWeighIn(...)    │
└───────────────┬───────────────────────────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────────────────────────────┐
│  NotificationService (local domain service wrapper)               │
│  - permission_handler.Permission.notification.request() (JIT)     │
│  - flutter_local_notifications.zonedSchedule(...)                 │
│    (per-slot daily, weekly/custom weigh-in)                       │
│  - onDidReceiveNotificationResponse → global router.push(payload) │
└───────────────┬───────────────────────────────────────────────────┘
                │ (OS AlarmManager / UNUserNotificationCenter)
                ▼
        Device notification tray → tap → deep-link into app

┌─────────────────────────────────────────────────────────────────┐
│  Backup & Restore screen (Client, under Settings)                 │
│  - Create Backup / Export Data → BackupService/ExportService      │
│    - reads all DAOs → csv/excel/json encoders → ZipFileEncoder    │
│    - writes to app documents dir OR SharePlus.instance.share(...) │
│  - Restore Data → preview parse → confirm → DAO writes             │
│  - Danger Zone (typed "DELETE") → DAO hard-delete-all              │
└─────────────────────────────────────────────────────────────────┘
```

### Recommended Project Structure

```
lib/
├── data/local/tables/
│   ├── co2_settings_table.dart        # new — SyncSafeTable
│   ├── weight_entry_table.dart        # new — SyncSafeTable
│   ├── notification_prefs_table.dart  # new — SyncSafeTable
│   └── backup_metadata_table.dart     # new — SyncSafeTable
├── data/local/daos/
│   ├── co2_settings_dao.dart
│   ├── weight_entry_dao.dart
│   ├── notification_prefs_dao.dart
│   └── backup_metadata_dao.dart
├── domain/services/
│   ├── daily_totals_calculator.dart       # NUTR-01/CO2-02 aggregation
│   ├── personal_co2_multiplier.dart       # CO2-03 settings → multiplier
│   ├── improvement_opportunity_finder.dart # CO2-06
│   ├── insights_timeline_rule_engine.dart  # INS-03
│   ├── notification_service.dart          # NOTIF-01–03 wrapper
│   └── backup_export_service.dart          # PRIV-01–04
├── features/dashboard/                # extends existing Phase-4 screen
│   └── widgets/ (metric_card.dart, trend_sparkline.dart, quick_insight_line.dart, co2_profile_prompt_card.dart)
├── features/data_analysis/            # new feature folder
│   └── screens/, widgets/
├── features/co2_settings/             # new feature folder
├── features/weight/                   # new feature folder
├── features/notifications/            # new — General Settings extension + weigh-in section widgets
└── features/backup/                   # new feature folder
```

### Pattern 1: SyncSafeTable + `@riverpod class` Notifier (established, reuse verbatim)

**What:** Every new persisted concept (CO₂ Settings, Weight Entry, Notification Prefs, Backup Metadata) gets a Drift table with `SyncSafeTable` mixin, a DAO, a repository (optional — Phase 4 sometimes skips a formal repository interface for simple single-table concerns; CO₂ Settings arguably warrants one since `PersonalCo2MultiplierCalculator` needs to read it during aggregation), and an `@riverpod class XNotifier` following `ProfileNotifier`/`MealEntryNotifier`'s exact shape.

**When to use:** Every new mutable local-only concept this phase introduces.

**Example (established shape, from `MealEntryNotifier`):**
```dart
// Source: lib/features/meal_logging/providers/meal_entry_notifier.dart (existing)
@riverpod
class WeightEntryNotifier extends _$WeightEntryNotifier {
  @override
  Future<List<WeightEntry>> build() =>
      ref.watch(weightEntryRepositoryProvider).getAllEntries();

  Future<void> logWeight(WeightEntry draft) async {
    await ref.read(weightEntryRepositoryProvider).insert(draft);
    ref.invalidateSelf();
  }
}
// Generated provider name: weightEntryProvider (Notifier suffix stripped),
// per [Phase 02-06]/[Phase 01-05] established codegen-naming decisions.
```

### Pattern 2: fl_chart compact sparkline (Dashboard 7-day trend)

**What:** A `LineChart` with all titles/borders hidden, single `LineChartBarData`, no touch interaction (or minimal) — reads as a sparkline.
**Source:** [pub.dev fl_chart docs / GitHub line_chart.md, fetched 2026-07-27]
```dart
LineChart(
  LineChartData(
    lineBarsData: [
      LineChartBarData(
        spots: last7Days, // List<FlSpot>
        isCurved: true,
        color: AppColors.primary,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: true, color: AppColors.primary.withValues(alpha: 0.12)),
      ),
    ],
    titlesData: const FlTitlesData(show: false),
    gridData: const FlGridData(show: false),
    borderData: FlBorderData(show: false),
    lineTouchData: const LineTouchData(enabled: false), // sparkline: tapping the *card* (GestureDetector wrapper), not the chart, opens Data Analysis per DASH-08
  ),
)
```

### Pattern 3: fl_chart interactive multi-range chart with goal reference line (Weight Tracking)

**What:** `LineChartData.extraLinesData.horizontalLines` draws the dashed target-weight line; `lineTouchData.touchTooltipData` shows values on drag/tap.
**Source:** [pub.dev fl_chart docs / GitHub line_chart.md, fetched 2026-07-27]
```dart
LineChartData(
  lineBarsData: [LineChartBarData(spots: weightSpots, isCurved: true)],
  extraLinesData: ExtraLinesData(
    horizontalLines: [
      HorizontalLine(
        y: targetWeightKg,
        color: AppColors.onSurfaceVariant,
        strokeWidth: 1.5,
        dashArray: [6, 4], // CONTEXT.md: "dashed target-weight line"
        label: HorizontalLineLabel(show: true, labelResolver: (line) => 'Goal: ${line.y} kg'),
      ),
    ],
  ),
  lineTouchData: LineTouchData(
    enabled: true,
    touchTooltipData: LineTouchTooltipData(
      getTooltipItems: (spots) => spots
          .map((s) => LineTooltipItem('${s.y} kg', const TextStyle(color: Colors.white)))
          .toList(),
    ),
  ),
)
```
**No pace/projection derivation** — per CONTEXT.md, the `HorizontalLine` is the only goal-related rendering; do not compute or display an "on pace" message anywhere near this chart.

### Pattern 4: Global router access from a notification tap (no BuildContext available)

**What:** `flutter_local_notifications`'s `onDidReceiveNotificationResponse` callback is a plain top-level/static function — it has no `BuildContext` and no Riverpod `ref`. The existing codebase's `ProviderScope.containerOf(context, listen: false)` pattern (used for Undo snackbars) does **not** apply here because there may be no widget tree yet (cold-start-via-notification-tap case).

**When to use:** Any code path that must navigate in response to a notification tap (NOTIF's "tapping a meal reminder opens food search with slot pre-selected").

**Recommended approach (MEDIUM confidence — WebSearch-derived, cross-checked against the plugin's own documented callback shape but not a doc-cited exact recipe):**
1. Capture the app's `ProviderContainer` (or the already-`keepAlive` `appRouterProvider`'s resolved `GoRouter`) in a top-level/static variable set once during `main()`, before `runApp`.
2. In `onDidReceiveNotificationResponse`, read `response.payload` (a route string, e.g. `/food-search?slot=breakfast`) and call `globalRouter.push(payload)` on the captured instance.
3. On cold start, call `flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails()` once after `runApp` to detect "app was launched by tapping a notification while terminated," and perform the same navigation after the first frame.

**Do not** attempt to resolve a `ref` or `BuildContext` inside the top-level callback — none is available in the background-isolate case (`onDidReceiveBackgroundNotificationResponse`, marked `@pragma('vm:entry-point')`).

### Anti-Patterns to Avoid

- **Re-deriving weight "pace" or "on track" language anywhere:** CONTEXT.md explicitly rejects this; do not let a well-meaning "helpful" trend annotation slip this back in via a chart tooltip or Insights Timeline rule.
- **Joining CO₂ settings into the per-food query path:** CO₂ Calculation Settings must never touch `off_ref.co2_factors`/`food_co2_overrides` lookups or `MealEntryTable` snapshot columns — it's a separate multiplier applied only when computing daily/weekly totals, never at food-detail-display time.
- **Copying `flutter_local_notifications` v9-v18-era code samples verbatim:** positional parameters were removed in v20.0.0; `uiLocalNotificationDateInterpretation` was removed in v19.0.0; `onSelectNotification` was replaced by `onDidReceiveNotificationResponse` in v18.0.0. See Pitfall 3.
- **Using `AndroidScheduleMode.exactAllowWhileIdle` or `.alarmClock` for meal/weigh-in reminders:** both require the user-facing `SCHEDULE_EXACT_ALARM` special permission on Android 12+ (a separate grant from `POST_NOTIFICATIONS`, with its own Play Store policy declaration). These reminders are casual, not time-critical — use `AndroidScheduleMode.inexactAllowWhileIdle` instead (see Pitfall 4).

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|--------------|-----|
| Line/bar charting with axes, tooltips, gradients | Custom `CustomPainter` chart | `fl_chart` | Touch handling, tooltip positioning, and animated transitions are non-trivial to get right cross-platform; `fl_chart` already solves this and is BSD-3/telemetry-free |
| Scheduled local notifications, timezone-correct repeat rules | Manual `Timer`/`WorkManager`/background-fetch scheme | `flutter_local_notifications` + `timezone` | OS-level exact/inexact alarm semantics, Doze-mode interaction, and iOS `UNUserNotificationCenter` scheduling are platform APIs this plugin already wraps correctly; hand-rolling risks silent notification loss after app kill |
| Zip archive creation | Manual DEFLATE + zip central-directory writer | `archive` package's `ZipFileEncoder` (already a dependency) | Zip format's central-directory/local-file-header structure is easy to get subtly wrong (e.g. corrupt archives on some unzip tools); zero reason to hand-roll when the dependency is already present |
| Excel `.xlsx` generation | Manual OOXML/zip-of-XML-parts writer | `excel` package | `.xlsx` is itself a zip of several interdependent XML parts (`sharedStrings.xml`, `sheet1.xml`, `[Content_Types].xml`, etc.) — extremely error-prone to hand-write correctly |
| OS share sheet integration | Platform-channel `Intent.ACTION_SEND` / `UIActivityViewController` boilerplate | `share_plus` | Well-trodden plugin path; hand-rolling duplicates work with no benefit given CONTEXT.md's explicit "OS share sheet only" constraint |

**Key insight:** every "don't hand-roll" item above is a case where the underlying OS/file-format primitive has enough edge cases (Doze mode, OOXML structure, zip corruption modes) that a mature, widely-used plugin/package is strictly safer than custom code, and every one of them is either already a dependency or a well-established, verified-publisher package.

## Common Pitfalls

### Pitfall 1: MealEntryTable does not snapshot sugar/fiber/sodium — NUTR-01 cannot be satisfied without a schema change

**What goes wrong:** NUTR-01 requires daily totals for calories, protein, carbs, fat, sugar, fiber, and sodium. `MealEntryTable` (Phase 4) only has `calories100gSnapshot`/`protein100gSnapshot`/`carbs100gSnapshot`/`fat100gSnapshot`/`co2e100gSnapshot` — no sugar/fiber/sodium columns. This is explicitly documented in the table's own doc comment as "a deliberate Phase 4 scope boundary... flagged here explicitly for Phase 5 planning."
**Why it happens:** `PortionSlotForm`'s live-scaling UI (Phase 4) only displayed calories/protein/carbs/fat, so only those were snapshotted at the time.
**How to avoid:** The planner must include a schema migration (schemaVersion bump, `sugar100gSnapshot`/`fiber100gSnapshot`/`sodium100gSnapshot` nullable `real()` columns added to `MealEntryTable`) **and** a write-path change (`MealEntryDao`/`MealEntryRepository`/`logFood` and any UI passing a draft `MealEntry` must now also populate these three fields from the source `FoodItem`/`UserFood`, which already carry `sugar`/`fiber`/`salt`). Daily-total aggregation queries (`DailyTotalsCalculator`) must treat nulls gracefully (existing entries logged before this migration will have null sugar/fiber/sodium — same "partial data, not false precision" handling already used for `co2e100gSnapshot`).
**Warning signs:** If a plan writes an aggregation query that sums `sugar100gSnapshot` without first confirming the column exists, it will fail to compile/migrate — this is a hard blocker, not a nice-to-have.

### Pitfall 2: `flutter_local_notifications` API is version-gated — do not use tutorials/training data assuming pre-v20 signatures

**What goes wrong:** The overwhelming majority of blog posts, StackOverflow answers, and (likely) an LLM's training data show `zonedSchedule(id, title, body, scheduledDate, notificationDetails, androidAllowWhileIdle: true, uiLocalNotificationDateInterpretation: ...)` with **positional** `title`/`body`/`scheduledDate`/`notificationDetails` and a `uiLocalNotificationDateInterpretation` iOS parameter.
**Why it happens:** v19.0.0 removed `uiLocalNotificationDateInterpretation`; v20.0.0 converted every positional parameter (across `initialize()`, `show()`, `zonedSchedule()`, `cancel()`) to named parameters.
**How to avoid:** At v22.2.0 (the version this research verified), `zonedSchedule` is:
```dart
Future<void> zonedSchedule({
  required int id,
  required TZDateTime scheduledDate,
  required NotificationDetails notificationDetails,
  required AndroidScheduleMode androidScheduleMode,
  String? title,
  String? body,
  String? payload,
  DateTimeComponents? matchDateTimeComponents,
})
```
[VERIFIED: pub.dev API docs, fetched 2026-07-27] — all parameters named, no `uiLocalNotificationDateInterpretation`.
**Warning signs:** A build failure citing "too many positional arguments" or "no named parameter with the name 'X'" on any `flutter_local_notifications` call is a strong signal the plan/code was written against stale training-data-era API shape.

### Pitfall 3: `AndroidScheduleMode.exactAllowWhileIdle` DOES require the SCHEDULE_EXACT_ALARM special permission — a WebFetch summary during this research incorrectly claimed otherwise

**What goes wrong:** An initial automated doc-summary pass (WebFetch of the `AndroidScheduleMode` API page) claimed `exactAllowWhileIdle` does **not** require `SCHEDULE_EXACT_ALARM`. A follow-up WebSearch cross-check of the plugin's own documented behavior and independent tutorials contradicts this: `exactAllowWhileIdle` (like `alarmClock`) **does** require the user-grantable `SCHEDULE_EXACT_ALARM` permission on Android 12+, which requires its own manifest declaration and (per current Play Store policy) a declaration form if used broadly.
**Why it happens:** This is exactly the "negative claims without evidence" trap the verification protocol warns about — a single-source automated summary was wrong, and only cross-referencing against a second source caught it.
**How to avoid:** For meal-slot and weigh-in reminders — which are casual, non-time-critical notifications (NFR-04: no aggressive nudging) — use `AndroidScheduleMode.inexactAllowWhileIdle`. This mode requires no special permission, still fires while the device is in Doze/idle mode (just with OS-controlled batching/delay), and completely sidesteps the SCHEDULE_EXACT_ALARM permission-and-policy complexity. Only reach for `exactAllowWhileIdle`/`alarmClock` if a future requirement demands minute-precise delivery (none of NOTIF-01–03 do).
**Warning signs:** Any plan task that adds `<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>` to `AndroidManifest.xml` for this phase should be questioned — it is very likely unnecessary given the casual nature of these reminders.

### Pitfall 4: The FoodCatalogRepository cache-write path silently disables CO₂ enrichment for API-fallback-cached results

**What goes wrong:** `FoodCatalogRepository.lookupByBarcode` and `.searchAndCache` both hardcode `categoriesTags: const Value(null)` when writing to `UserFoodCacheTable`, even when the fetched `FoodItem.categoriesTags` from the OFF API is non-null. Meanwhile, `FoodCatalogDao.searchLocalFoods`'s `user_food_cache_fts` query branch hardcodes `NULL AS co2e_100g, NULL AS confidence_band` and never joins `off_ref.co2_factors` at all — so even after fixing the write path, the read-side query needs a matching join added.
**Why it happens:** This was Phase 4's `2218dbb` commit fixing the `off_ref.products` side of the union query only; the `user_food_cache_table` side was never touched.
**How to avoid:** (1) At cache-write time, store the single most-specific category tag (mirroring `tools/ingest_off.py`'s `primary_category_tag` "most-specific-first" convention and `lookupByBarcodeFromApi`'s existing tag-iteration order) into `categoriesTags` — a single tag string, not the full comma-joined list, so a simple SQL equality `LEFT JOIN off_ref.co2_factors cf ON cf.categories_tag = t.categories_tag` becomes possible on the read side. (2) Update the `user_food_cache_fts` branch of `searchLocalFoods` to add that `LEFT JOIN` (mirroring the existing `off_ref.products` branch's join shape) instead of hardcoding nulls.
**Warning signs:** Any API-fallback-cached food that shows no CO₂ value in local search results (after being online once) despite having category data from OFF is this bug.

### Pitfall 5: `tool/generate_schema_v1.dart`'s hardcoded `schema_version: 1` does not track the live schema — do not assume it needs updating per migration

**What goes wrong:** A plan might assume every schema bump requires regenerating `schema_v1.json`, since that's the conventional Drift workflow. This project's own tool doc comment states it is "documentation-only," hardcoded to `schema_version: 1`, already stale relative to the live `schemaVersion: 3` (Phase 4), and consumed by zero tests.
**Why it happens:** `drift_dev`'s official schema-dump CLI is broken against `drift 2.34.2` (a pre-existing, already-documented incompatibility — `drift_dev` 2.34.5 is now available on pub.dev but was not re-verified against `drift 2.34.2` in this session, and upgrading either pin is out of this phase's scope).
**How to avoid:** This generalizes cleanly to schema v4+ (this phase's CO₂ Settings/Weight/Notification Prefs/Backup Metadata tables) — the migration mechanics themselves (`if (from < N) { await m.createTable(db.xTable); }` in `buildMigrationStrategy`) do not depend on the schema-dump tool at all. **Do not** spend planning effort re-running or "fixing" `tool/generate_schema_v1.dart` for this phase; it remains an intentionally-stale, test-independent artifact. If a future plan wants real migration-testing coverage, that's a separate concern from this phase's scope (flagged as an Open Question below, not resolved here).
**Warning signs:** A task titled something like "regenerate schema_v1.json for schema v4" is very likely unnecessary scope creep for this phase.

### Pitfall 6: Zip-slip / path traversal risk on Restore (PRIV-04)

**What goes wrong:** Restoring from a user-provided backup `.zip` (which by definition can come from anywhere the user's file picker/share-sheet reaches) means archive entry names are untrusted input. A naively-written extraction loop that does `File('${targetDir.path}/${entry.name}')` without validating `entry.name` can be tricked by a maliciously (or corruptly) crafted zip containing a path like `../../../../etc/something` into writing outside the app's sandboxed documents directory.
**Why it happens:** This is a well-known, generically-named vulnerability class ("zip slip") that affects any zip-extraction code path, not specific to this project or the `archive` package.
**How to avoid:** When implementing Restore Data's extraction step, validate every `ArchiveFile.name` resolves to a path that remains within the target extraction directory (e.g., reject any entry whose normalized path starts with `..` or is absolute) before writing. PRIV-04's own requirement ("preview of what will be restored... explicit confirmation before any data is overwritten") is a natural place to also surface this validation — a malformed/malicious entry can be silently skipped or the whole restore rejected with a clear error, consistent with this app's "no silent failure" tone.
**Warning signs:** Any restore-extraction code that doesn't call a path-normalization/containment check before `File.writeAsBytes` on an extracted entry.

## Code Examples

### fl_chart: hiding a compact sparkline's axes (Dashboard)
```dart
// Source: fl_chart GitHub docs, repo_files/documentations/line_chart.md (fetched 2026-07-27)
titlesData: const FlTitlesData(
  show: true,
  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
),
```

### flutter_local_notifications: per-slot daily-repeating reminder
```dart
// Source: pub.dev flutter_local_notifications v22.2.0 API docs (fetched 2026-07-27)
await flutterLocalNotificationsPlugin.zonedSchedule(
  id: mealSlotNotificationId(slot), // stable int per MealSlot, so re-scheduling replaces not duplicates
  scheduledDate: nextInstanceOfTime(hour, minute), // TZDateTime, tz.local-based
  notificationDetails: const NotificationDetails(
    android: AndroidNotificationDetails('meal_reminders', 'Meal reminders'),
    iOS: DarwinNotificationDetails(),
  ),
  androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle, // see Pitfall 3 — no SCHEDULE_EXACT_ALARM needed
  matchDateTimeComponents: DateTimeComponents.time, // daily recurrence
  title: '${slot.displayLabel} reminder',
  payload: '/food-search?slot=${slot.name}', // consumed by onDidReceiveNotificationResponse (Pattern 4)
);
```

### flutter_local_notifications: weekly/custom weigh-in reminder
```dart
// Source: pub.dev flutter_local_notifications v22.2.0 API docs (fetched 2026-07-27)
await flutterLocalNotificationsPlugin.zonedSchedule(
  id: weighInNotificationId,
  scheduledDate: nextInstanceOfWeekdayTime(weekday, hour, minute),
  notificationDetails: const NotificationDetails(
    android: AndroidNotificationDetails('weigh_in_reminders', 'Weigh-in reminders'),
    iOS: DarwinNotificationDetails(),
  ),
  androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
  matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime, // weekly recurrence on a specific weekday
  title: 'Time for your weigh-in',
  payload: '/weight-tracking',
);
```

### share_plus: sharing the generated backup zip
```dart
// Source: pub.dev share_plus v13.3.0 docs / WebSearch cross-check (fetched 2026-07-27)
await SharePlus.instance.share(
  ShareParams(
    files: [XFile(backupZipFile.path)],
    text: 'CO2 Diet backup — ${DateFormat.yMMMd().format(DateTime.now())}',
  ),
);
```

### archive_io: creating the export zip with an in-memory manifest.json
```dart
// Source: pub.dev archive docs (archive_io library) + GitHub example.dart, cross-checked via WebSearch (fetched 2026-07-27)
import 'package:archive/archive_io.dart'; // already imported elsewhere in this codebase

final encoder = ZipFileEncoder();
encoder.create(zipOutputPath);
await encoder.addFile(File(csvFilePath));
await encoder.addFile(File(jsonFilePath));
// In-memory manifest.json (not a disk file):
encoder.addArchiveFile(
  ArchiveFile.string('manifest.json', jsonEncode(manifestMap)),
);
await encoder.close();
```

### csv: encoding meal entries to CSV
```dart
// Source: pub.dev csv v8.0.0 docs / WebSearch cross-check (fetched 2026-07-27)
final rows = <List<dynamic>>[
  ['date', 'slot', 'food', 'quantity', 'unit', 'calories', 'co2e_kg'],
  for (final e in entries) [e.logDate, e.mealSlot.name, e.productNameSnapshot, e.quantity, e.unit.name, e.calories100gSnapshot, e.co2e100gSnapshot],
];
final csvString = const ListToCsvConverter().convert(rows);
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|---------------|--------|
| `fl_chart` 0.x `FlChart` wrapper class, `touchedResultSink` callback, `colors`/`BelowBarData` naming | `LineChart`/`BarChart`/`PieChart` standalone widgets, `touchCallback`/`FlTouchEvent`, `color`/`BarAreaData` | v0.4.0–v1.0.0 (train-of changes through the 0.x/1.x line) | Any remembered fl_chart sample code from pre-1.0 must be re-derived against current class/property names |
| `flutter_local_notifications` positional params, `uiLocalNotificationDateInterpretation`, `onSelectNotification` | Named params only, no iOS date-interpretation param, `onDidReceiveNotificationResponse`/`onDidReceiveBackgroundNotificationResponse` | v18.0.0 (callback rename) → v19.0.0 (iOS param removed) → v20.0.0 (positional→named) | Code from most tutorials (which still show v9-v17-era shape) will not compile against v22.2.0 |
| `share_plus` static `Share.shareXFiles(...)` | `SharePlus.instance.share(ShareParams(...))` instance API | Deprecated in a recent major version (exact version not independently pinned this session — flag as LOW confidence on the precise version number, though the API shift itself is MEDIUM-confidence cross-referenced) | Static methods still exist but are deprecated; new code should use the instance/`ShareParams` API |

**Deprecated/outdated:**
- `flutter_local_notifications`'s `schedule()`, `showDailyAtTime()`, `showWeeklyAtDayAndTime()` convenience methods were removed entirely in v15.0.0 — `zonedSchedule` + `matchDateTimeComponents` is the only supported scheduling API now.
- `share_plus`'s static `Share.shareFiles`/`Share.shareXFiles` are deprecated in favor of the `SharePlus.instance.share(ShareParams(...))` instance API.

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | `flutter_timezone` is the standard companion package (alongside `timezone`) for feeding `flutter_local_notifications`' local-timezone detection, per common ecosystem convention | Standard Stack | If a different/no timezone-detection package is actually needed (e.g. if a newer `timezone` release auto-detects), this is one unnecessary dependency — low impact, easy to drop during planning if a plan-check disagrees |
| A2 | `share_plus`'s deprecation of static `Share.shareXFiles` happened at a specific version not independently pinned this session | State of the Art | Low risk — even if the static API still technically works, using the documented current instance API (`SharePlus.instance.share`) is safe either way |
| A3 | The recommended "global router / captured instance" pattern for notification-tap navigation (Pattern 4) is a common community pattern, not a pattern lifted from an official flutter_local_notifications doc page cited by URL in this session | Architecture Patterns, Pattern 4 | If the planner finds a more idiomatic Riverpod-specific pattern (e.g. a `ProviderContainer` held in a top-level `late` variable set from `main()`, which is functionally the same thing described here), the outcome is identical — this is a naming/packaging risk, not a correctness risk |

## Open Questions

1. **(RESOLVED — see 05-CONTEXT.md Planning Addendum, 2026-07-27) Should the export/backup zip be encrypted at rest, given it contains full personal nutrition/weight/health-adjacent data?**
   - What we know: PRIV-01/02/03/04 describe the export/backup mechanics (formats, manifest, share-sheet destination, typed-delete confirmation) but say nothing about encryption.
   - What's unclear: Whether an unencrypted zip handed to an arbitrary share-sheet target (which could be an unencrypted cloud-drive upload, email attachment, etc.) is acceptable given this app's otherwise very strong privacy positioning (PRIV-08/09, zero third-party SDKs).
   - **Disposition:** No encryption in v1 — an explicit, user-confirmed decision (05-CONTEXT.md Planning Addendum), not a silently-assumed default. The Backup & Restore screen's "Privacy & Ownership statement" section (Plan 05-16) discloses this plainly to the user with exact specified copy. `manifest.json` carries a `formatVersion` field (Plan 05-09) from v1 onward specifically so an encrypted format can be added later without breaking compatibility with already-created backups.

2. **(DISPOSITIONED — handled as a checkpoint-time recheck, no further action needed) Excel package staleness (~2 years, no release since 2024-08-20) — is a newer/actively-maintained alternative available at actual execution time?**
   - What we know: `excel` 4.0.6 is verified-publisher, has a reasonable dependency graph, and is very likely still the most popular pure-Dart `.xlsx` writer, but its pub score (115/160) is meaningfully lower than every other candidate in this research and its last release predates this research by roughly two years.
   - What's unclear: Whether a newer `excel` release or a viable alternative package has appeared between this research date and actual Phase 5 execution.
   - **Disposition:** Correctly handled as an execution-time recheck rather than a planning-time decision — Plan 05-09's blocking `checkpoint:human-verify` task explicitly instructs the approver to re-check pub.dev for a newer release, a still-present verified-publisher badge, and any critical open security issues immediately before the install runs. No plan change needed; this note exists for traceability only.

3. **(OUT OF SCOPE for this phase — confirmed, no action needed) `drift_dev` schema-dump / migration-testing coverage for the new schema version(s) this phase introduces**
   - What we know: The project already has an established, deliberate workaround (custom `tool/generate_schema_v1.dart`, documentation-only) because `drift_dev`'s own schema-dump CLI is broken against the pinned `drift 2.34.2`. `drift_dev` 2.34.5 is now available on pub.dev but was not verified against `drift 2.34.2` in this session.
   - What's unclear: Whether upgrading `drift_dev` (independent of `drift` itself, since the two have separate analyzer-version constraint chains per this project's existing pinning notes) would actually restore the official schema-dump CLI, and whether that's worth doing in this phase versus deferring.
   - **Disposition:** Confirmed out of scope for Phase 5 (Plan 05-03's schema migration work correctly did not attempt to fix or regenerate `tool/generate_schema_v1.dart` — see that plan's Task 2). Flagged only so a future phase doesn't mistake the absence of migration-testing infrastructure for an oversight; it is a known, previously-accepted gap, not a Phase 5 deliverable.

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | `flutter_test` (bundled with Flutter SDK) + `mocktail` 1.0.5 for DAO/repository mocking |
| Config file | none — no `dart_test.yaml`; test discovery is directory-convention-based (`test/**/*_test.dart`) |
| Quick run command | `flutter test test/<path-to-file>_test.dart` |
| Full suite command | `flutter test` (per [Phase 01-07] decision: `flutter test` is required, not `dart test`, because `app_database.dart` transitively imports `dart:ui` via `drift_flutter`; CI's `.github/workflows/ci.yml` currently invokes `dart test` at line 45 — this appears to have been passing so far, but the planner should not assume `dart test` will keep working once Phase 5 adds `flutter_local_notifications`/`fl_chart`, which both have Flutter-engine-dependent code paths; verify CI still passes green after this phase's first plan lands, and flag a CI-config fix as a follow-up if `dart test` starts failing) |

### Phase Requirement → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|--------------------|--------------|
| NUTR-01 | Daily totals sum calories/protein/carbs/fat/sugar/fiber/sodium correctly, including null-snapshot entries | unit | `flutter test test/domain/services/daily_totals_calculator_test.dart` | ❌ Wave 0 |
| CO2-02 | Personal CO₂ multiplier applied only to daily/weekly totals, never per-food | unit | `flutter test test/domain/services/personal_co2_multiplier_test.dart` | ❌ Wave 0 |
| CO2-03 | CO₂ Settings screen persists all 7 optional fields; regional-average fallback when unset | widget + DAO | `flutter test test/features/co2_settings/ test/data/local/co2_settings_dao_test.dart` | ❌ Wave 0 |
| CO2-06 | Improvement Opportunities never appears on Dashboard/notifications, only Data Analysis | widget | `flutter test test/features/data_analysis/improvement_opportunities_test.dart` | ❌ Wave 0 |
| DASH-01–08 | Dashboard renders 3 metric cards, sparkline, quick insight, mode indicator, empty state, prompt card gating on data-quality | widget | `flutter test test/features/dashboard/` | ❌ Wave 0 (extends existing `test/features/dashboard/` dir) |
| WT-01–05 | Weight logging, chart range filters, goal line, reminder scheduling calls | unit + widget | `flutter test test/features/weight/ test/domain/services/notification_service_test.dart` | ❌ Wave 0 |
| NOTIF-01–03 | Permission JIT request, denied-state revert, scheduling calls `zonedSchedule` with expected `matchDateTimeComponents`/`androidScheduleMode` | unit (mocked plugin) | `flutter test test/domain/services/notification_service_test.dart` | ❌ Wave 0 |
| PRIV-01–04 | Export produces valid zip+manifest; restore rejects zip-slip paths; Danger Zone requires exact "DELETE" text | unit + integration | `flutter test test/domain/services/backup_export_service_test.dart` | ❌ Wave 0 |
| PRIV-08/09/AUTH-07 | No network client instantiated/called by any new Phase 5 code path | static/offline-proof test (mirrors Phase 4's `offline_logging_test.dart` pattern) | `flutter test test/core/offline_phase5_test.dart` (new, modeled on existing `offline_logging_test.dart`) | ❌ Wave 0 |

### Sampling Rate
- **Per task commit:** `flutter test test/<touched-area>/`
- **Per wave merge:** `flutter test` (full suite)
- **Phase gate:** Full suite green before `/gsd-verify-work`

### Wave 0 Gaps
- [ ] `test/domain/services/daily_totals_calculator_test.dart` — covers NUTR-01/CO2-02, including the sugar/fiber/sodium null-snapshot handling from Pitfall 1
- [ ] `test/domain/services/personal_co2_multiplier_test.dart` — covers CO2-02/CO2-03
- [ ] `test/domain/services/notification_service_test.dart` — covers NOTIF-01–03 with a mocked `FlutterLocalNotificationsPlugin`
- [ ] `test/domain/services/backup_export_service_test.dart` — covers PRIV-01–04, including a zip-slip-attempt fixture (Pitfall 6)
- [ ] `test/data/local/co2_settings_dao_test.dart`, `weight_entry_dao_test.dart`, `notification_prefs_dao_test.dart` — new DAO coverage, mirroring existing `food_catalog_dao_ranking_test.dart` conventions
- [ ] `test/core/offline_phase5_test.dart` — extends the Phase-4 `offline_logging_test.dart` pattern to prove no Phase-5-introduced code path touches the network (AUTH-07/PRIV-08)
- [ ] Framework install: none — `flutter_test`/`mocktail` already present; no new test framework needed

## Security Domain

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|----------------|---------|-------------------|
| V2 Authentication | no | Local Mode has no authentication surface this phase |
| V3 Session Management | no | N/A — no session concept in Local Mode |
| V4 Access Control | no | Single-local-user app; no multi-tenant/role concept |
| V5 Input Validation | yes | Typed-confirmation ("DELETE") exact-match check; CO₂ Settings numeric fields (household size) bounded/sanitized before persistence, mirroring existing `T-02-03-01`-style parameterization discipline already used throughout the DAO layer |
| V6 Cryptography | conditionally yes | No encryption is currently specified for the export/backup zip — see Open Question 1. If a future decision requires it, use a well-audited Dart crypto package, never hand-rolled cipher code |
| V12 File & Resources | yes | Zip-slip/path-traversal protection on Restore extraction (Pitfall 6); documents-directory-scoped file writes only (mirrors the existing `offRefPath`-from-`path_provider`-only convention, `T-02-03-02`) |

### Known Threat Patterns for this stack

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|----------------------|
| Zip-slip on backup restore | Tampering | Validate every `ArchiveFile.name` resolves within the target extraction directory before writing (Pitfall 6) |
| Unencrypted personal health/nutrition data leaving the device via an arbitrary share-sheet target | Information Disclosure | Explicit, unambiguous copy in the "Privacy & Ownership statement" section of Backup & Restore disclosing that shared backups are not encrypted by the app itself, unless Open Question 1 resolves toward adding encryption |
| Notification payload used as a raw route string, parsed and pushed without validation | Tampering (low severity — payload is app-generated, not user/network-supplied) | Since payloads are always constructed by this app's own `NotificationService` (never derived from external/network input), standard input validation is lower-priority here, but the deep-link parser should still reject any payload string that doesn't match one of the app's known route patterns before calling `router.push` |

## Sources

### Primary (HIGH confidence)
- pub.dev registry API (`https://pub.dev/api/packages/<name>` and `/score`) — fetched 2026-07-27 for `fl_chart`, `flutter_local_notifications`, `share_plus`, `timezone`, `flutter_timezone`, `csv`, `excel`, `archive`, `permission_handler`, `drift`, `drift_dev`, `flutter_riverpod`, `riverpod_generator`, `riverpod_annotation`, `go_router` — version numbers, publish dates, pub scores, like counts
- `flutter_local_notifications` API docs (`pub.dev/documentation/flutter_local_notifications/latest/...`) — `zonedSchedule` exact signature, `AndroidScheduleMode` enum values (with a caught inconsistency — see Pitfall 3)
- fl_chart GitHub documentation (`github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/line_chart.md`) — `ExtraLinesData`/`HorizontalLine`/`LineTouchData`/`FlTitlesData` API shapes
- This project's own codebase (`lib/data/local/`, `lib/features/`, `lib/domain/`, `.planning/STATE.md` decision log) — established patterns, existing schema, and the sugar/fiber/sodium gap discovery

### Secondary (MEDIUM confidence)
- WebSearch cross-checks of `flutter_local_notifications` changelog (v18.0.0–v22.2.0 breaking changes) — corroborated the version-gated API pitfalls
- WebSearch cross-check of `AndroidScheduleMode.exactAllowWhileIdle`'s actual permission requirement, which **corrected** an earlier WebFetch summary error (see Pitfall 3)
- `archive`/`archive_io` `ZipFileEncoder` API shape (WebSearch + pub.dev doc page, no single authoritative code sample fetched verbatim)
- `csv`/`excel` package API usage patterns (WebSearch-derived, cross-checked against pub.dev package descriptions)
- `share_plus` `SharePlus.instance.share(ShareParams(...))` current API shape (WebSearch, not independently fetched from an official migration-guide page in this session)

### Tertiary (LOW confidence)
- The exact `share_plus` version at which `Share.shareXFiles` became deprecated (Assumption A2) — not independently pinned
- The "global router capture" notification-navigation pattern (Pattern 4) — a common community pattern, not lifted from an official flutter_local_notifications doc page with Riverpod-specific guidance

## Metadata

**Confidence breakdown:**
- Standard stack (package choices/versions): HIGH — every version verified directly against the pub.dev registry API this session
- Architecture (reuse of existing Phase 1-4 patterns): HIGH — directly read from the existing codebase, not inferred
- fl_chart/flutter_local_notifications specific API details: MEDIUM — verified against official doc pages, but this session caught and corrected one factual error mid-research (Pitfall 3), which argues for the planner independently spot-checking exact method signatures against `pub.dev/documentation/...` at execution time rather than trusting this document as the final word
- Pitfalls (schema gap, cache-path gap, zip-slip): HIGH — directly discovered by reading this project's own source code, not third-party research

**Research date:** 2026-07-27
**Valid until:** 2026-08-10 (14 days — shorter than the default 30 given two of the five new dependencies are fast-moving plugins that have each had a major breaking-change release within the last 6 months; re-verify exact versions/APIs at plan-check or execution time if this phase's planning/execution spans more than ~2 weeks from this research date)
