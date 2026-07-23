# Phase 4: Meal Logging Core (<10s target) - Research

**Researched:** 2026-07-23
**Domain:** Flutter/Drift/Riverpod local-first data modeling, swipe-gesture UX, sub-10s performance benchmarking
**Confidence:** HIGH (grounded in existing codebase patterns + verified official docs); MEDIUM on the one new package recommendation (flutter_slidable)

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**Barcode/Search Sheet Reconciliation (bug found during discussion)**
- `_BarcodeScanDetailSheet` in `barcode_scan_screen.dart` is a hand-duplicated copy of `FoodDetailBottomSheet`'s content, using raw CO₂ string formatting instead of `ConfidenceChip` — a divergence from Phase 3's explicit "no behavioral difference between scan and search sheets" decision. It happened because the shared `showFoodDetailSheet()` helper wraps its `showModalBottomSheet` call in `unawaited()`, so the scanner (which needs to know when the sheet closes, to resume the camera) couldn't use it.
- **Fix:** change `showFoodDetailSheet()` to return the real `Future<void>` from `showModalBottomSheet` instead of swallowing it. Callers that don't care about dismissal (search screen) simply don't await it; the scanner awaits it and resumes the camera exactly as today.
- Delete `_BarcodeScanDetailSheet` and its private `_MacroRow` entirely. Both search and scan flows render the single shared `_FoodDetailContent` widget.
- "Log this food," the favorite star, and "Edit this food" are added once, to the shared widget — both entry points get them for free.

**Core Logging Flow — Meal Slot Selection**
- Segmented control showing all 4 slots, pre-selected via time-of-day auto-detection (e.g. Breakfast/Lunch/Dinner/Snack cutoff hours — exact boundaries are Claude's discretion), user can tap to override.
- No memory/learning of manual corrections — every new log re-guesses fresh from time of day. No per-user adaptive state.
- Dashboard's "Add Breakfast" (etc.) quick-add buttons push to `/food-search` carrying the target slot as a param; the eventual sheet's slot picker is pre-set to that slot (explicit intent overrides the time-of-day guess), still editable.

**Core Logging Flow — Portion/Quantity Input**
- Preset quantity chips sourced from the food's quick-serving-sizes (configured in My Foods) + a "Custom" chip.
- Tapping a chip pre-fills an **editable** numeric field (not locked to the exact preset value) + unit dropdown, defaulted to the food's natural unit.
- When a food has no configured quick-serving-sizes (true for most catalog/OFF items on first use): fall back to generic default chips (100g, 200g, Custom) rather than skipping straight to the numeric field.
- For non-gram/ml units (pieces/cups/portions) on a food with **no configured weight-per-unit**: the unit dropdown only offers g/ml until the user configures a conversion in My Foods. No generic/estimated conversion fallback — avoids false-precision macro numbers.
- Displayed macro/CO₂ numbers in the sheet **scale live** with the selected quantity (e.g. picking 150g shows 225 kcal, not the fixed 100g reference value) — matches the honesty-in-numbers principle already applied to CO₂ confidence bands.
- "Log this food" button stays **disabled** until quantity is valid (>0) — no error-message path needed.

**Core Logging Flow — Confirmation & Feedback**
- On successful log: sheet auto-dismisses, "Added to [Slot]" snackbar appears over whatever screen is now visible, with an **Undo** action. No loading/saving indicator — local DB write is near-instant (same principle as Phase 2's "no shimmer for fast local ops").
- No haptic feedback on successful log (contrast with Phase 3's haptic-on-barcode-detect) — snackbar is sufficient.
- Barcode-scan-sourced logs show the same snackbar over the resumed live camera feed — consistent confirmation regardless of entry point.
- Rare DB write failure: error snackbar with a **Retry** action; sheet stays open so slot/quantity selection isn't lost. No silent retry.
- No explicit close (X) button on the sheet — drag-down / back-gesture / tap-outside remains the only dismissal, unchanged from Phase 2/3.

**Core Logging Flow — Merge Semantics**
- Logging the same food to the **same slot, same day** merges into the existing entry (adds quantity) rather than creating a new row.
- Merge requires **matching portion units** — a unit mismatch (e.g. first log in grams, second in cups) creates a separate entry instead of attempting conversion.
- "Same food" match key for merging: the food's **internal reference/ID** (barcode when present, otherwise catalog/custom-food ID) — never a product-name string match, to avoid false-positive merges between similarly-named products.
- Undo after a merge subtracts only the **just-added delta**, restoring the entry to its pre-merge quantity — never deletes the whole entry (which would incorrectly erase earlier-logged quantity).
- **Duplicate** (the swipe action from Managing Logged Entries) is a distinct code path from the Log flow and deliberately **bypasses** this merge rule — see Managing Logged Entries below.

**Core Logging Flow — Data Model**
- Meal entries store a **snapshot** of macro/CO₂ values at the moment of logging — not a live reference to the food's current catalog data. Historical logs stay accurate even if the underlying food's data later changes (OFF re-sync, CO₂ methodology update, or a personal override created after the fact). This is the single biggest data-model decision in this phase.
- Direct consequence: creating or editing a personal override does **not** retroactively change past logged entries that used the pre-override values.

**Core Logging Flow — Multi-item Logging & Benchmark**
- After logging via search or scan, the user returns to the search results list / live scanner (already true for the scanner via Phase 3's resume-camera behavior) — supports logging several items back-to-back without re-navigating.
- Build an automated Dart integration test timing the full tap-to-saved sequence, following the precedent set by Phase 2's search benchmark and Phase 3's CO₂ coverage benchmark, **plus** the required real-device user testing before the phase closes (LOG-13's literal requirement).

**Recent & Favorites**
- Surface: shown on the food search screen's **empty state**, replacing Phase 2's plain "Search for a food..." prompt — typing a query replaces Recent/Favorites with search results.
- Logging from Recent/Favorites: **one tap = instant log** (sheet skipped entirely) using the item's last-used quantity and the auto-detected slot.
- A small **edit icon** on each Recent/Favorite row opens the full pre-filled sheet, for adjusting quantity/slot before logging instead of accepting the last-used values.
- Recent list: most-recent-first, capped at roughly 10–15 items, **deduped by food** — re-logging an item moves it back to the top rather than adding a duplicate row.
- Favorites: toggled via the star icon in the detail sheet; the same (filled) star reappears on Favorites rows and **tapping it again un-favorites** — one icon, both directions, no swipe gesture needed for this.

**Custom Foods & Personal Overrides (My Foods)**
- **CO₂ input:** defaults to a category dropdown (fixed set matching AGRIBALYSE categories) that auto-estimates via the same category-average lookup used for catalog foods (Medium confidence). A manual numeric override is also available — when used, it's labeled distinctly (e.g. "user-provided") with **no confidence chip**, since a self-entered number has no methodology backing it.
- **Override entry point:** "Edit this food" action in `FoodDetailBottomSheet` (alongside "Log this food" and the favorite star), opening the custom-food form pre-filled with the original's values.
- **Data model:** single `user_foods` table for both brand-new custom foods and overrides. An override additionally stores a reference (barcode/ID) to the original catalog food it overrides.
- **Search display:** when an override exists for a catalog food, search shows **only the override** (replaces the original in results). The original row is untouched in the database — never mutated — just hidden from search unless reverted.
- **Revert:** a "Revert to original" button inside the override's own edit form — deletes the override row; the original reappears in search immediately.
- **Quick serving sizes:** entered as part of the same custom-food creation/edit form — a **dynamic list** (label text + gram-value number field pairs, "+ Add serving size" / remove row), not fixed cup/slice/piece/portion slots. This is exactly where the "no unit shown without a configured conversion" gap (from Core Logging Flow) gets filled in.
- **Required fields:** name + at least a calorie value are required to save; brand, category, other macros, CO₂, and serving sizes are all optional.
- **Barcode field:** custom foods can optionally store a barcode. When the form is reached via the barcode no-match flow, it's pre-filled from the query param — future scans of that barcode resolve to the custom food (so the no-match fallback isn't a dead end on a second scan).
- **Category field:** fixed dropdown matching AGRIBALYSE categories (not freeform text) — guarantees the CO₂ category-estimate option always resolves to a real value.
- **Standalone creation:** My Foods screen has its own "+ Add Custom Food" action (opens the same form, no barcode pre-filled) — covers homemade meals / unlisted items that never went through a failed scan.
- **My Foods navigation:** reachable from Settings/Profile tab (data-management concern, like Export/Backup), not from the food search screen.
- **My Foods list:** alphabetical, with a search/filter field at the top.
- **Search no-results "Add as custom food" link** (closes the gap Phase 2's CONTEXT.md explicitly deferred to Phase 4): appears **only** on the genuine no-match state — not on the offline-with-0-results or network-failure states, since those haven't actually confirmed there's no match. Opens the form with the search query pre-filled as the name (no barcode).

**Managing Logged Entries**
- **Entries home:** a minimal grouped list is injected into the existing `PlaceholderDashboardScreen` (currently just "Dashboard coming in Phase 5") — satisfies LOG-13's "visible on dashboard" requirement without building Phase 5's real dashboard. Phase 5 extends/replaces this same list rather than starting from scratch.
- **Interaction pattern:** swipe actions reveal Edit/Delete/Duplicate — establishes the swipe pattern that ROADMAP.md's Phase 5 Dashboard success criteria already expects ("swipe-to-edit and duplicate"), so Phase 5 inherits it instead of inventing it later.
- **Edit:** opens the same pre-filled sheet pattern already decided for Recent's edit icon (slot/quantity/unit all editable).
- **Duplicate:** creates an **instant copy** into the same slot, no intermediate sheet. Duplicate is a distinct code path from the Log flow and **deliberately bypasses** the same-slot/same-day merge rule — it always produces a separate row even when it would otherwise match the merge criteria, since merging would make "Duplicate" a no-op from the user's point of view.
- **Delete:** no confirmation dialog — immediate delete + "Deleted — Undo" snackbar, consistent with the Log/merge Undo pattern used everywhere else in this phase.
- **List structure:** entries grouped under Breakfast/Lunch/Dinner/Snack headers; a slot with zero entries has its header **hidden entirely** (not shown empty).
- **Row content:** name + quantity + calories + CO₂ per entry (not just name+quantity) — reuses the same live-scaling math already built for the logging sheet, so this isn't a throwaway placeholder.
- **Empty day state:** friendly illustration + "No meals logged yet" — consistent with Phase 2's honest-empty-state philosophy, and pre-empts DASH-07's eventual "No meals yet → Start logging" wording from Phase 5.

### Claude's Discretion

- Exact meal-slot auto-detect time boundaries (hour cutoffs for Breakfast/Lunch/Dinner/Snack)
- Swipe direction mapping (which side reveals which action)
- Snackbar/dialog copy wording (within the app's non-judgmental tone constraint)
- Undo snackbar visible-window duration
- DAO/repository/entity naming conventions for the new MealEntry and UserFood tables
- Drift schema field types, migration numbering, and file structure for new tables
- Exact widget structure/animation for the swipe actions (no existing design token covers this)

### Deferred Ideas (OUT OF SCOPE)

None — discussion stayed within Phase 4 scope (LOG-05 through LOG-13). No new capabilities were proposed during this session.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|--------------------|
| LOG-05 | User can add food to Breakfast, Lunch, Dinner, or Snack meal slots | Pattern 1 (`textEnum<MealSlot>()` column); Architecture Patterns diagram (Portion/Slot Form) |
| LOG-06 | User can input portion in g, ml, cups, pieces, or portions; cup/slice/portion sizes user-configurable via My Foods; metric default, imperial from locale | Pattern 6 / Alternatives Considered (JSON `TypeConverter.json2` for quick-serving-sizes); existing `ProfileNotifier.setLocaleUnits` locale-detection precedent noted for reuse |
| LOG-07 | Recent shows individually logged food items (not combo/meal entries); one-tap reuse with previously used quantity pre-filled | Pattern 3 (`logDate` column enables cheap "most recent per food" queries); Don't Hand-Roll table |
| LOG-08 | User can mark foods as Favorites; Favorites are one-tap re-loggable | Architecture Patterns diagram; no new package needed (single star icon, no swipe) |
| LOG-09 | User can edit, delete, and duplicate logged meal entries | Pattern 4 (`flutter_slidable`); Pattern 5 (Riverpod mutation methods + soft-delete/undo via `deletedAt`) |
| LOG-10 | User can create custom foods in My Foods (name/brand/category, reference amount, full nutrition, CO₂, quick serving sizes) | Pattern 1/6 (`UserFoodTable` schema shape); Security Domain V5 (required-field validation) |
| LOG-11 | User can create a personal override of an existing DB food entry; original never mutated; override/original independent, revertible pair | Pattern 2 (no cross-DB FK — override-reference is a plain app-enforced text column, consistent with the cross-DB case) |
| LOG-12 | All core food logging works fully offline — zero network dependency | Environment Availability (no network deps for this phase); Architecture Patterns diagram (entirely local Drift/Riverpod stack) |
| LOG-13 | End-to-end meal logging (tap to saved+visible) completes in <10s on mid-range device, verified in user testing | Pitfall 3 (`pumpAndSettle()` vs `Stopwatch`+bounded `pump()`); Validation Architecture (Wave 0 gap: `integration_test/meal_logging_benchmark_test.dart`); Environment Availability (manual real-device testing flagged as non-automatable) |
</phase_requirements>

## Summary

Phase 4 is almost entirely an extension of patterns Phases 1–3 already established: `SyncSafeTable`-mixin Drift tables, raw-SQL DAOs with `Variable.withString` parameterization, `@riverpod class` AsyncNotifier codegen, sentinel-pattern `copyWith` entities, and Dart `integration_test` benchmarks that self-skip when fixtures are absent. CONTEXT.md has already made nearly every product decision; the open technical questions are (1) how to shape the two new Drift tables (`MealEntryTable`, `UserFoodTable`) and their migration, (2) what widget implements swipe-to-reveal Edit/Delete/Duplicate, and (3) how to write a trustworthy Dart integration test for the <10s tap-to-saved requirement.

The single most consequential finding is that **SQLite does not support foreign-key constraints across `ATTACH`ed databases** — `off_reference.sqlite` is attached under the alias `off_ref`, so `MealEntryTable`'s reference to a catalog food (which may live in `off_ref.products`, `user_food_cache_table`, or the new `user_foods` table) cannot be a Drift `.references()` FK. It must be a plain nullable text column (barcode or a source-tagged ID), enforced only at the application layer — which aligns naturally with CONTEXT.md's already-decided "snapshot, not reference" data model (the FK would be nearly unused anyway, since historical rows must survive the referenced food changing or disappearing).

The second finding worth flagging before planning: **Drift's default `DateTime` storage is a Unix-epoch integer**, and "same slot, same day" merge-matching needs a same-day equality check. Comparing raw epoch integers or using `strftime` in every query is workable but easy to get wrong across DST/timezone edges. Recommend storing a redundant `logDate` TEXT column (`YYYY-MM-DD`, local calendar day) alongside `loggedAt` specifically to make the merge query and the "group entries by day" dashboard query trivial equality/`WHERE` clauses instead of date-function arithmetic.

**Primary recommendation:** Add `MealEntryTable` and `UserFoodTable` (schemaVersion 2→3) using the same `SyncSafeTable` + raw-SQL-DAO + `@riverpod` AsyncNotifier stack already in the codebase; use `flutter_slidable` for the swipe-to-reveal Edit/Delete/Duplicate pattern (no existing custom-gesture code to reuse, and hand-rolling `PanGestureRecognizer` logic for this is exactly the kind of complexity Don't-Hand-Roll guidance exists to prevent); measure the <10s flow with a `WidgetTester`-driven `integration_test` using `Stopwatch` + bounded `pump(duration)` calls (not unbounded `pumpAndSettle()`, which can hang against the Undo-snackbar's auto-dismiss timer).

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Meal slot selection + auto-detect | Client (Flutter UI state) | — | Pure UI/time-of-day logic, no persistence until log |
| Portion/quantity input + live macro scaling | Client (Flutter UI) | Domain (pure calculation) | Scaling math (`value * qty/100`) is a pure function, testable without DB |
| Meal entry persistence (log/edit/delete/duplicate) | Database / Storage (Drift) | Client (Riverpod AsyncNotifier) | New `MealEntryTable`; local-only, no backend in Phase 4 |
| Recent/Favorites derivation | Database / Storage (Drift query) | Client (Riverpod) | Query against `MealEntryTable` (Recent) — no separate cache table needed |
| Custom foods / overrides (My Foods) | Database / Storage (Drift) | Client (Riverpod) | New `UserFoodTable`; search must merge with existing `off_ref` + `user_food_cache` sources |
| Snapshot macro/CO₂ capture at log time | Database / Storage (Drift) | Domain (copy logic) | Values copied into `MealEntryTable` row at write time — never a live join |
| Swipe-to-reveal actions (Edit/Delete/Duplicate) | Client (Flutter UI widget) | — | Pure presentation/gesture concern; `flutter_slidable` |
| Dashboard grouped-entries list | Client (Flutter UI) | Database (Drift query via repository) | Injected into existing `PlaceholderDashboardScreen` |
| Sub-10s benchmark verification | Client (integration_test) | — | `WidgetTester`-driven, runs on-device |

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| `drift` | 2.34.2 (pinned — already in pubspec) | Local SQLite ORM for `MealEntryTable`/`UserFoodTable` | Already the project's sole persistence layer; new tables must match existing pin (drift_dev 2.34.0 constraint, see 02/03 STATE.md decisions) |
| `flutter_riverpod` | 3.3.2 (pinned — already in pubspec) | State management for new notifiers | Established project standard; `@riverpod class` codegen already used by `ProfileNotifier`, `FoodSearchNotifier`, `BarcodeScanNotifier` |
| `riverpod_annotation` / `riverpod_generator` | 4.0.3 / 4.0.4 (pinned) | Codegen for new notifiers | Same |
| `go_router` | 17.3.0 (pinned) | New routes: My Foods list, My Foods create/edit form | Already the routing standard; `/custom-food-stub` placeholder exists and is meant to be replaced this phase |
| `uuid` | 4.6.0 (pinned) | `id` generation for new table rows | `Uuid().v7()` already used identically in `FoodCatalogRepository` for cache rows |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `flutter_slidable` | 4.0.3 [ASSUMED — see Package Legitimacy Audit] | Swipe-to-reveal Edit/Delete/Duplicate actions on logged meal entries | Managing Logged Entries list only; not needed for Recent/Favorites (single-tap star, no swipe per CONTEXT.md) |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `flutter_slidable` | Flutter's built-in `Dismissible` | `Dismissible` only supports full-removal swipe-to-dismiss, not a persistent multi-action reveal pane (Edit + Delete + Duplicate) — wrong shape for this UX |
| `flutter_slidable` | Hand-rolled `GestureDetector`/`AnimationController` | Reinvents animation curves, direction-locking, auto-close-on-scroll, and dismiss-confirmation logic that `flutter_slidable` already solves; explicitly what "Don't Hand-Roll" guards against |
| JSON `TypeConverter` for quick-serving-sizes | Separate `UserFoodServingSizeTable` (1:many child table) | Child table is more "correctly relational" but adds a join for data that is (a) small, (b) always loaded with its parent, (c) never queried independently. JSON column is simpler and matches Phase 4's scope; flag as Open Question if planner disagrees |

**Installation:**
```bash
flutter pub add flutter_slidable
```

**Version verification:**
```bash
$ curl -s https://pub.dev/api/packages/flutter_slidable | jq '.latest.version, .latest.published'
"4.0.3"
"2025-09-27T14:58:49.289160Z"
```
Verified live against the pub.dev registry API on 2026-07-23. SDK constraint: `sdk: '>=3.6.0 <4.0.0'`, `flutter: '>=3.27.0'` — compatible with this project's Dart 3.12.2 / Flutter 3.44.6.

## Package Legitimacy Audit

> flutter_slidable is the only new external package this phase needs to add.

**slopcheck ecosystem gap:** `slopcheck` (installed successfully: `pip install slopcheck`) supports `{pypi, npm, crates.io, go, rubygems, maven, packagist}` only — **pub.dev (Dart/Flutter) is not a supported ecosystem**. No slopcheck verdict is possible for this package. Per the Package Legitimacy Protocol's graceful-degradation rule, `flutter_slidable` is tagged `[ASSUMED]` and the planner must gate its install behind a `checkpoint:human-verify` task, despite the strong independent signals below.

| Package | Registry | Age | Downloads | Source Repo | slopcheck | Disposition |
|---------|----------|-----|-----------|--------------|-----------|-------------|
| `flutter_slidable` | pub.dev | First published 2019 (6+ yrs); latest 4.0.3 published 2025-09-27 | 626,026 / 30 days | `github.com/letsar/flutter_slidable` (verified via pubspec `homepage`) | N/A — pub.dev unsupported by slopcheck | `[ASSUMED]` — Approved pending human-verify checkpoint |

Independent evidence gathered directly from the pub.dev registry API (not training data): pub score 150/160, `is:flutter-favorite` tag, 6,130 likes, MIT license, `publisher:romainrastel.com` (verified publisher domain). This is strong corroborating evidence of legitimacy, but per the provenance rule the package name itself was surfaced via WebSearch, so it cannot be upgraded past `[ASSUMED]` without an ecosystem-appropriate slopcheck run.

**Packages removed due to slopcheck [SLOP] verdict:** none
**Packages flagged as suspicious [SUS]:** none (flutter_slidable is `[ASSUMED]`, not `[SUS]` — ecosystem coverage gap, not a suspicion signal)

## Architecture Patterns

### System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│  UI Layer (Flutter widgets)                                          │
│                                                                        │
│  FoodDetailBottomSheet ──log/edit tap──▶ Portion/Slot Form (new)      │
│       │  (stateful now: hosts quantity + slot + unit fields)         │
│       │                                                               │
│  Recent/Favorites rows ──1-tap──▶ instant log (skip sheet)           │
│       │                  ──edit icon──▶ Portion/Slot Form (prefilled) │
│                                                                        │
│  My Foods screen ──"+Add"/row tap──▶ Custom Food Form (replaces      │
│                                        /custom-food-stub placeholder) │
│                                                                        │
│  PlaceholderDashboardScreen ──renders──▶ Grouped Entries List         │
│       └── Slidable row ──swipe──▶ Edit / Delete / Duplicate actions   │
└───────────────────────────┬────────────────────────────────────────┘
                             │ ref.watch / ref.read(...).notifier.xxx()
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│  Riverpod Notifiers (@riverpod class, codegen)                       │
│                                                                        │
│  MealEntryNotifier          UserFoodNotifier                          │
│  - logFood() (merge logic)  - saveCustomFood()                        │
│  - editEntry()               - saveOverride()                         │
│  - deleteEntry() (+ undo)    - revertOverride()                       │
│  - duplicateEntry()                                                   │
│                                                                        │
│  FoodSearchNotifier (existing, Phase 2) — extended to also query      │
│  user_foods (override rows replace originals in results)              │
└───────────────────────────┬────────────────────────────────────────┘
                             │ calls
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│  Repositories (implements domain interfaces)                          │
│  MealEntryRepository        UserFoodRepository                        │
│  - IMealEntryRepository     - IUserFoodRepository                     │
└───────────────────────────┬────────────────────────────────────────┘
                             │ calls
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│  DAOs (raw customSelect/customStatement, parameterized)               │
│  MealEntryDao (queries: today's entries, Recent, merge-check)         │
│  UserFoodDao (queries: My Foods list, override lookup by barcode)     │
└───────────────────────────┬────────────────────────────────────────┘
                             │ SQL
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│  AppDatabase (co2diet.sqlite, local, offline)                         │
│  ├── meal_entry_table       (NEW — schemaVersion 3)                   │
│  ├── user_foods_table       (NEW — schemaVersion 3)                   │
│  ├── user_food_cache_table  (existing, Phase 2)                       │
│  ├── user_profile_table     (existing, Phase 1)                       │
│  └── ATTACH off_ref (off_reference.sqlite, read-only, NO cross-DB FK) │
└─────────────────────────────────────────────────────────────────────┘
```

### Recommended Project Structure
```
lib/
├── data/
│   ├── local/
│   │   ├── tables/
│   │   │   ├── meal_entry_table.dart       # NEW
│   │   │   └── user_food_table.dart        # NEW
│   │   ├── daos/
│   │   │   ├── meal_entry_dao.dart         # NEW — template: food_catalog_dao.dart
│   │   │   └── user_food_dao.dart          # NEW
│   │   └── migrations/
│   │       └── migration_strategy.dart     # EDIT — add schemaVersion 2→3 branch
│   └── repositories/
│       ├── meal_entry_repository.dart      # NEW
│       └── user_food_repository.dart       # NEW
├── domain/
│   ├── entities/
│   │   ├── meal_entry.dart                 # NEW — sentinel copyWith, no id-less equality like FoodItem
│   │   └── user_food.dart                  # NEW
│   └── repositories/
│       ├── i_meal_entry_repository.dart    # NEW
│       └── i_user_food_repository.dart     # NEW
└── features/
    ├── meal_logging/                       # NEW feature folder
    │   ├── providers/
    │   │   └── meal_entry_notifier.dart
    │   └── widgets/
    │       ├── portion_slot_form.dart       # hosted inside FoodDetailBottomSheet
    │       └── meal_entry_row.dart          # Slidable-wrapped row for dashboard list
    └── my_foods/                            # NEW feature folder
        ├── providers/
        │   └── user_food_notifier.dart
        ├── screens/
        │   ├── my_foods_screen.dart
        │   └── custom_food_form_screen.dart # replaces /custom-food-stub body
        └── widgets/
            └── serving_size_editor.dart      # dynamic +Add/remove list
```

### Pattern 1: SyncSafeTable + textEnum for MealEntryTable
**What:** New tables inherit the six sync-safe columns via the mixin, and use Drift's `textEnum<T>()` column builder to store the `MealSlot` enum as text (`'breakfast'`/`'lunch'`/`'dinner'`/`'snack'`) rather than a magic-number int.
**When to use:** Any Drift column backed by a closed Dart enum.
**Example:**
```dart
// Source: https://drift.simonbinder.eu/type_converters/ (verified 2026-07-23)
enum MealSlot { breakfast, lunch, dinner, snack }

class MealEntryTable extends Table with SyncSafeTable {
  TextColumn get mealSlot => textEnum<MealSlot>()();
  // ... other columns
}
```
**Caution (verified via official docs):** renaming an enum value after rows exist in production breaks deserialization on read — `Enum.name` is the stored string. Treat `MealSlot` enum member names as append-only/frozen once this phase ships.

### Pattern 2: No cross-attached-database foreign keys
**What:** `off_reference.sqlite` is `ATTACH`ed under alias `off_ref` (see `migration_strategy.dart` `beforeOpen`). SQLite does not support `FOREIGN KEY ... REFERENCES off_ref.products(...)` — this is a hard SQLite limitation, not a Drift limitation.
**When to use:** Whenever a new table needs to reference a food that might live in `off_ref.products`, `user_food_cache_table` (same DB), or the new `user_foods_table` (same DB).
**Example:**
```dart
// MealEntryTable — food reference is a plain nullable text column,
// NOT a Drift .references() FK. Matches CONTEXT.md's "internal
// reference/ID (barcode when present, otherwise catalog/custom-food ID)"
// merge-key decision — which itself never assumed a DB-level FK.
class MealEntryTable extends Table with SyncSafeTable {
  TextColumn get foodRef => text()();       // barcode OR user_foods.id
  TextColumn get foodRefSource => text()(); // 'off_ref' | 'user_food_cache' | 'user_foods'
  // snapshot fields below — never joined back to the source at read time
  TextColumn get productNameSnapshot => text()();
  RealColumn get calories100gSnapshot => real().nullable()();
  // ...
}
```
Note `user_foods_table` (new, same DB) *can* have a real Drift FK from an override row back to nothing in particular — the "original" it overrides is typically in `off_ref` (cross-DB, no FK possible) or occasionally `user_food_cache_table` (same DB, FK possible but inconsistent with the other case) — recommend treating the override-reference column the same way (plain text, app-enforced) for consistency across both cases rather than a real FK for one case and not the other.

### Pattern 3: Redundant `logDate` column for same-day merge queries
**What:** Drift's default `dateTime()` column stores a Unix-epoch integer (seconds) [CITED: drift.simonbinder.eu/guides/datetime-migrations/, verified 2026-07-23] and returns a **non-UTC (local)** value on read. Comparing two epoch integers for "same calendar day" requires `strftime('%Y-%m-%d', loggedAt, 'unixepoch')` in every query, which is easy to get subtly wrong (device timezone changes, DST, and readers not consistently applying `'unixepoch'` modifiers).
**When to use:** `MealEntryTable`'s same-slot/same-day merge check (Core Logging Flow decision) and the "group today's entries" dashboard query.
**Example:**
```dart
class MealEntryTable extends Table with SyncSafeTable {
  DateTimeColumn get loggedAt => dateTime()();
  // Redundant, deliberately denormalized: local calendar day as 'YYYY-MM-DD'.
  // Computed once in Dart at write time (DateTime.now() -> local date),
  // never derived via SQL date functions — makes merge-check and
  // group-by-day queries a plain equality WHERE clause.
  TextColumn get logDate => text()();
}
```
```dart
// Merge check becomes: WHERE food_ref = ? AND meal_slot = ? AND log_date = ?
// instead of WHERE food_ref = ? AND meal_slot = ? AND strftime(...) = ?
```

### Pattern 4: Swipe-to-reveal actions with flutter_slidable
**What:** `Slidable` widget wraps each dashboard meal-entry row; `endActionPane` (or `startActionPane`, per Claude's discretion on direction) holds three `SlidableAction`s for Edit/Delete/Duplicate.
**When to use:** Managing Logged Entries list only (per CONTEXT.md, Recent/Favorites uses a single star icon, not swipe).
**Example:**
```dart
// Source: https://pub.dev/packages/flutter_slidable (verified 2026-07-23, v4.0.3)
Slidable(
  key: ValueKey(entry.id),
  endActionPane: ActionPane(
    motion: const ScrollMotion(),
    children: [
      SlidableAction(
        onPressed: (_) => onEdit(entry),
        icon: Icons.edit_outlined,
        label: 'Edit',
      ),
      SlidableAction(
        onPressed: (_) => onDuplicate(entry),
        icon: Icons.copy_outlined,
        label: 'Duplicate',
      ),
      SlidableAction(
        onPressed: (_) => onDelete(entry), // immediate delete + Undo snackbar
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
        icon: Icons.delete_outline,
        label: 'Delete',
      ),
    ],
  ),
  child: MealEntryRow(entry: entry),
)
```

### Pattern 5: Riverpod codegen notifier for mutable list state
**What:** Follow the exact `ProfileNotifier` shape already in the codebase — `@riverpod class` returning `Future<List<MealEntry>>`, mutation methods call the repository then `ref.invalidateSelf()` to refresh.
**When to use:** `MealEntryNotifier`, `UserFoodNotifier`.
**Example:**
```dart
// Pattern mirrors lib/features/profile/providers/profile_notifier.dart exactly.
@riverpod
class MealEntryNotifier extends _$MealEntryNotifier {
  @override
  Future<List<MealEntry>> build() =>
      ref.watch(mealEntryRepositoryProvider).getEntriesForToday();

  Future<void> logFood(MealEntry draft) async {
    await ref.read(mealEntryRepositoryProvider).logOrMerge(draft);
    ref.invalidateSelf();
  }

  Future<void> deleteEntry(String id) async {
    await ref.read(mealEntryRepositoryProvider).softDelete(id);
    ref.invalidateSelf();
    // Undo snackbar caller re-inserts via a stored copy of the deleted row —
    // simplest correct approach given soft-delete (deletedAt) is already
    // the SyncSafeTable convention; "undo" = clear deletedAt, not re-insert.
  }
}
```
Generated provider name: `mealEntryNotifierProvider` unless the `@riverpod` codegen strips the `Notifier` suffix as it does elsewhere in this codebase (confirmed convention: `ProfileNotifier` → `profileProvider`, `FoodSearchNotifier` → `foodSearchProvider` per STATE.md 02-06 decision) — verify the generated name after running `build_runner`, don't assume it matches the class name.

### Anti-Patterns to Avoid
- **Hand-rolled swipe gestures:** Reimplementing `PanGestureRecognizer` + `AnimationController` for reveal/dismiss/auto-close-on-scroll semantics duplicates `flutter_slidable` for no benefit.
- **Live-reference meal entries:** Storing only a `foodRef` and re-joining to catalog/cache/user_foods at *read* time for macro/CO₂ display would silently rewrite history whenever the referenced food's data changes — directly contradicts the "snapshot, not reference" decision.
- **Cross-DB Drift `.references()`:** Attempting `.references(OffRefProducts, #barcode)` style FK against an attached database will fail at migration time (SQLite syntax error) — don't attempt it even for the same-DB `user_food_cache_table` case, for consistency with the `off_ref` case.
- **`pumpAndSettle()` without a timeout in the benchmark test:** see Pitfall 3 below.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Swipe-to-reveal multi-action row | Custom `GestureDetector`/`Transform.translate` animation | `flutter_slidable` (`ActionPane`/`SlidableAction`) | Direction-locking, auto-close-on-scroll, dismiss confirmation, and platform-consistent motion curves are non-trivial to get right; this is a Flutter Favorite specifically built for this exact UX |
| UUID generation | Custom random-string generator | `uuid` package `.v7()` (already a dependency, already used identically in `FoodCatalogRepository`) | Time-ordered UUIDs matter for the `SyncSafeTable` `id` primary key convention already established |
| Enum-to-DB mapping | Manual `int` index mapping with a switch statement | Drift's `textEnum<T>()()` | Avoids silent data corruption if enum member order changes; self-documenting in `sqlite_master` |
| "Same day" date comparison | `strftime()`/date-math in every query | Redundant `logDate` TEXT column computed once in Dart | Simpler queries, avoids DST/timezone edge cases at day boundaries |
| Full-flow timing measurement | Custom `Timer`/`DateTime.now()` diffing scattered across widget callbacks | `Stopwatch` in a single `integration_test` file, following the existing `food_search_benchmark_test.dart` / `co2_coverage_benchmark_test.dart` precedent | Consistent, already-proven pattern in this codebase; self-skips gracefully when fixtures are absent |

**Key insight:** Every "don't hand-roll" item in this phase already has a working precedent somewhere in Phases 1–3 of this exact codebase — the discipline is reuse, not invention.

## Common Pitfalls

### Pitfall 1: Cross-attached-database foreign keys silently fail or are impossible
**What goes wrong:** A developer writes `.references(OffRefProductsTable, #barcode)` (or the raw-SQL equivalent `REFERENCES off_ref.products(barcode)`) expecting referential integrity on `MealEntryTable.foodRef`.
**Why it happens:** It's the "obviously correct" relational design, and Drift's `.references()` API doesn't warn that the target table lives in a different attached database.
**How to avoid:** `foodRef` is a plain `text()()` column, validated only at the application layer (already true in spirit — CONTEXT.md's merge-key decision never assumed DB-level FK enforcement). This is also *required* by the snapshot-data-model decision: rows must remain valid even after the referenced food is deleted/changed, which a real FK would actively fight against.
**Warning signs:** A `CREATE TABLE` migration statement referencing `off_ref.` fails at `flutter test tool/generate_schema_v1.dart` or at app startup with a SQLite syntax error near `REFERENCES`.

### Pitfall 2: `strftime`-based "same day" queries break at timezone/DST boundaries
**What goes wrong:** Drift's default `dateTime()` storage is Unix-epoch seconds (UTC on disk, converted to local on read). A same-day merge check written as raw epoch-range comparison (`loggedAt >= startOfTodayEpoch AND loggedAt < endOfTodayEpoch`) computed once in Dart at query-build time is fine, but written as SQL-side `strftime('%Y-%m-%d', loggedAt, 'unixepoch')` and compared without care can drift by a day near midnight local time if the device's SQLite build doesn't apply localtime modifiers, or if the app changes timezone (travel) between two logs on what the user perceives as "the same day."
**Why it happens:** SQLite's date functions default to UTC unless `'localtime'` is explicitly chained, and it's easy to forget.
**How to avoid:** Use the redundant `logDate` TEXT column (Pattern 3 above) — computed once in Dart via `DateTime.now()` (already local), so the SQL side is a trivial string-equality `WHERE` clause with zero date-function ambiguity.
**Warning signs:** Merge tests pass locally but a manual QA pass near midnight (or with a device timezone change) produces a duplicate entry instead of a merge, or vice versa.

### Pitfall 3: `pumpAndSettle()` hangs against the Undo-snackbar's auto-dismiss timer
**What goes wrong:** The <10s benchmark integration test calls `await tester.pumpAndSettle()` after tapping "Log this food," expecting it to return once the sheet dismisses and the "Added to [Slot]" snackbar appears. `pumpAndSettle()` only returns once there is **no pending frame-scheduled work** — a `SnackBar`'s built-in auto-dismiss timer (default ~4s, per Material's `SnackBar.duration`) can keep it pumping past the assertion point, or in some Flutter versions cause the call to hit its internal 10-attempt/duration cap and throw, corrupting the very timing measurement the test exists to produce.
**Why it happens:** `pumpAndSettle()` isn't designed for benchmarking — it's designed for "wait until idle," and a running Snackbar timer plus this phase's animated swipe-reveal widgets are exactly the kind of persistent scheduled work that defeats it. [CITED: api.flutter.dev/flutter/flutter_test/WidgetTester/pumpAndSettle.html, verified 2026-07-23 — "avoid using it when animations are ongoing after performing certain actions"]
**How to avoid:** Start the `Stopwatch` immediately before the first `tester.tap()` of the flow; stop it as soon as the specific expected widget (e.g., the snackbar's `Text('Added to Breakfast')`) is found via `tester.pump()` calls with small fixed durations in a bounded loop (or a single `tester.pump(const Duration(milliseconds: 100))` per step, matching the "Add Breakfast tap → food saved → visible on placeholder dashboard" definition from LOG-13) — never rely on `pumpAndSettle()`'s open-ended settle behavior to bound the measured interval.
**Warning signs:** Benchmark test flakes intermittently, or measured times cluster suspiciously close to `pumpAndSettle()`'s internal timeout rather than actual UI completion time.

### Pitfall 4: Enum member renames silently break stored `textEnum` data
**What goes wrong:** A `MealSlot.snack` enum member gets renamed to `MealSlot.snacks` during a later refactor (or localization pass); existing rows with `'snack'` in the `meal_slot` column now fail to deserialize.
**Why it happens:** `textEnum<T>()` stores `Enum.name`, and Dart's tooling has no built-in guard against renaming enum members. [CITED: pub.dev drift documentation, verified 2026-07-23]
**How to avoid:** Treat `MealSlot` (and any future `textEnum`-backed enum in this phase, e.g., a food-source-tag enum) as append-only once shipped; add a code comment on the enum declaration itself warning against renames, matching the project's existing convention of documenting non-obvious constraints inline (see `SyncSafeTable`'s doc comments).
**Warning signs:** A row throws a deserialization/`StateError` on read after a seemingly unrelated refactor PR.

### Pitfall 5: `drift_dev` schema-dump workaround (`tool/generate_schema_v1.dart`) needs updating, or will silently go stale
**What goes wrong:** The project already has a documented incompatibility between `drift_dev 2.34.0` and `drift 2.34.2`'s schema-dump CLI (see `tool/generate_schema_v1.dart` header comment and STATE.md Phase 01-02 decision). That script is hardcoded to `schema_version: 1` and is not referenced by any test — it's a manual documentation dump. Bumping `schemaVersion` to 3 in this phase will make its filename/hardcoded version misleading if left untouched.
**Why it happens:** The workaround was written once for Phase 1 and never generalized to track the live `schemaVersion`.
**How to avoid:** Either (a) parameterize the script to read `AppDatabase().schemaVersion` and write `schema_v{N}.json` accordingly, or (b) explicitly scope-note in the plan that this script is documentation-only and out of scope for Phase 4 — don't silently leave a `schema_v1.json` file claiming to represent a 2-table-older schema without a decision either way.
**Warning signs:** None automated (no test consumes this file today) — this is a maintainability/documentation-drift risk, not a functional bug risk.

### Pitfall 6: `TypeConverter.json()` double-encoding when both row-class JSON serialization and column JSON serialization are in play
**What goes wrong:** If the `UserFoodTable`'s quick-serving-sizes JSON column converter is implemented with the older `TypeConverter.json()` helper rather than `TypeConverter.json2` (or the `JsonTypeConverter2` mixin), values can be encoded twice when the generated Drift row class itself is later serialized to JSON (e.g., for a future export feature in Phase 5's PRIV-01).
**Why it happens:** Drift's docs explicitly call out `json2`/`JsonTypeConverter2` as the newer, corrected API. [CITED: pub.dev/documentation/drift/latest/drift/JsonTypeConverter2-mixin.html, verified 2026-07-23]
**How to avoid:** Use `TypeConverter.json2` (or the `JsonTypeConverter2` mixin directly) for the quick-serving-sizes column, not the older `.json()` helper.
**Warning signs:** Not visible in Phase 4 itself (no export feature yet) — but worth getting right now since a Phase 5 export feature (PRIV-01) will read this exact column.

## Code Examples

### Migration: schemaVersion 2 → 3 (two new tables)
```dart
// Source: pattern mirrors lib/data/local/migrations/migration_strategy.dart
// (existing schemaVersion 1→2 branch for UserFoodCacheTable), verified against
// the actual file in this repo on 2026-07-23.
MigrationStrategy buildMigrationStrategy(AppDatabase db, {String? offRefPath}) {
  return MigrationStrategy(
    onCreate: (m) async => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // ... existing UserFoodCacheTable branch, unchanged
      }
      if (from < 3) {
        await m.createTable(db.mealEntryTable);
        await m.createTable(db.userFoodTable);
      }
    },
    beforeOpen: (_) async { /* unchanged */ },
  );
}
```
And bump `AppDatabase.schemaVersion` from `2` to `3`, add both new tables + their DAOs to the `@DriftDatabase(tables: [...], daos: [...])` annotation, and re-run `build_runner` (per this project's existing `build_runner: 2.15.1` pin — do not attempt to upgrade it mid-phase, see pubspec.yaml comment on the `drift_dev`/`freezed` analyzer-version conflict).

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|---------------|--------|
| N/A — this is new functionality, not a migration off an old pattern | — | — | — |

No deprecated/outdated approaches apply here; every pattern recommended above is already the live convention in this codebase (Phases 1–3) or the current stable release of the relevant package as of 2026-07-23.

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|----------------|
| A1 | `flutter_slidable` is the right/only reasonable choice for swipe-to-reveal actions | Standard Stack, Pattern 4 | Low — it's the dominant, actively maintained Flutter Favorite for this exact UX; if rejected, the fallback (hand-rolled) is explicitly discouraged in Don't Hand-Roll, so an alternative would need to be a different established package, not custom code |
| A2 | Quick-serving-sizes should be a JSON `TypeConverter` column rather than a child table | Alternatives Considered | Medium — reasonable engineers could disagree; if the planner wants relational queryability over serving sizes later (unlikely per current requirements), a schema change would be needed |
| A3 | Generated Riverpod provider name will strip "Notifier" suffix (`mealEntryNotifierProvider` → possibly `mealEntryProvider`) matching the `ProfileNotifier`→`profileProvider` convention | Pattern 5 | Low — cosmetic; verified by running `build_runner`, not a design risk |
| A4 | The `logDate` redundant-column approach is preferable to SQL-side date functions | Pattern 3, Pitfall 2 | Low-Medium — both are technically workable; redundant column adds a tiny write-time computation but removes a whole class of query bugs |

**None of these require blocking user confirmation before planning** — A1 and A2 are Claude's-discretion items per CONTEXT.md, and A3/A4 are low-risk implementation details resolvable during execution.

## Open Questions

1. **Should `UserFoodTable`'s quick-serving-sizes use a JSON column or a child table?**
   - What we know: CONTEXT.md describes it as "a dynamic list (label text + gram-value number field pairs)" — doesn't mandate storage shape.
   - What's unclear: Whether a future phase needs to query/filter across serving sizes independently of their parent food.
   - Recommendation: JSON `TypeConverter.json2` column (Pattern 3/Pitfall 6) — simplest correct solution for Phase 4's scope; revisit only if a future phase needs cross-food serving-size queries.

2. **Which side (start/end) should the swipe reveal Edit/Delete/Duplicate?**
   - What we know: CONTEXT.md explicitly leaves "swipe direction mapping (which side reveals which action)" to Claude's discretion.
   - What's unclear: No existing design-token precedent in this codebase for swipe direction.
   - Recommendation: `endActionPane` (right-to-left swipe, the dominant iOS/Android convention for list-row actions) holding all three actions in a fixed order (Edit, Duplicate, Delete-last-in-red) — matches near-universal platform convention (Mail apps, Gmail, most Material list patterns) and avoids needing a `startActionPane` at all.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Flutter SDK | Entire phase | ✓ | 3.44.6 (stable) | — |
| Dart SDK | Entire phase | ✓ | 3.12.2 | — |
| `flutter_slidable` pub.dev package | Swipe actions | Not yet installed — verified reachable via `pub.dev` API | 4.0.3 (latest) | None viable — see Don't Hand-Roll; must install |
| iOS TestFlight + physical iPhone | Phase-close gate (carried from Phase 3, per CONTEXT.md) | ✗ cannot be probed from this environment | — | No fallback — CONTEXT.md states this is a hard phase-close prerequisite, not optional. Flag for the planner as a checkpoint requiring the user to run the device test manually. |
| Mid-range Android/iOS physical device for the <10s user-testing verification (LOG-13) | Phase-close gate | ✗ cannot be probed from this environment | — | No fallback — same as above; the Dart integration test is a proxy/regression-guard, not a substitute for the literal LOG-13 requirement of real-hardware user testing |

**Missing dependencies with no fallback:**
- iOS TestFlight + physical device verification, and the LOG-13 real-hardware user-testing verification, both require human action outside this research/planning session. The planner should surface these as explicit `checkpoint:human-verify` tasks near phase close, not attempt to automate around them.

**Missing dependencies with fallback:**
- `flutter_slidable` — not yet in `pubspec.yaml`, but trivially installable (`flutter pub add flutter_slidable`); no fallback needed, just an install step gated behind human-verify per the Package Legitimacy Audit.

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | `flutter_test` (unit/widget) + `integration_test` (on-device benchmarks), both already configured |
| Config file | none dedicated — `pubspec.yaml` `dev_dependencies` (`flutter_test`, `integration_test`, `mocktail: 1.0.5`) |
| Quick run command | `flutter test test/` (unit/widget suite, no device needed) |
| Full suite command | `flutter test test/ && flutter test integration_test/ --device-id <id>` (integration tests require a connected device/emulator, consistent with Phase 2/3 precedent) |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|---------------------|-------------|
| LOG-05 | Add food to Breakfast/Lunch/Dinner/Snack slot | unit (DAO/repo) + widget | `flutter test test/data/local/meal_entry_dao_test.dart` | ❌ Wave 0 |
| LOG-06 | Portion input g/ml/cups/pieces/portions, unit-aware | unit | `flutter test test/domain/entities/meal_entry_test.dart -N "portion"` | ❌ Wave 0 |
| LOG-07 | Recent shows individual items, dedup, one-tap reuse with prefilled qty | unit (DAO query) + widget | `flutter test test/data/local/meal_entry_dao_test.dart -N "recent"` | ❌ Wave 0 |
| LOG-08 | Favorites toggle + one-tap re-log | unit + widget | `flutter test test/features/food_search/favorites_test.dart` | ❌ Wave 0 |
| LOG-09 | Edit/delete/duplicate logged entries | unit (repo) + widget (Slidable actions) | `flutter test test/features/meal_logging/meal_entry_notifier_test.dart` | ❌ Wave 0 |
| LOG-10 | Custom food creation (My Foods) with required-fields validation | unit + widget | `flutter test test/features/my_foods/custom_food_form_test.dart` | ❌ Wave 0 |
| LOG-11 | Personal override, non-destructive, revertible pair | unit (DAO — override/original pair integrity) | `flutter test test/data/local/user_food_dao_test.dart -N "override"` | ❌ Wave 0 |
| LOG-12 | Fully offline core logging (zero network dependency) | unit/integration (assert no network calls invoked in the log path) | `flutter test test/features/meal_logging/offline_logging_test.dart` | ❌ Wave 0 |
| LOG-13 | End-to-end tap-to-saved <10s on real hardware | integration_test (Dart proxy) + **manual real-device user testing (non-automatable)** | `flutter test integration_test/meal_logging_benchmark_test.dart --device-id <id>` | ❌ Wave 0 |

### Sampling Rate
- **Per task commit:** `flutter test test/` (fast unit/widget subset relevant to the task)
- **Per wave merge:** `flutter test test/ && flutter test integration_test/meal_logging_benchmark_test.dart` (device required for the latter)
- **Phase gate:** Full suite green + LOG-13's literal manual real-hardware user-testing checkpoint (per CONTEXT.md, this cannot be waived by the automated benchmark alone) before `/gsd-verify-work`

### Wave 0 Gaps
- [ ] `test/data/local/meal_entry_dao_test.dart` — DAO tests for insert/merge/recent-query/same-day logic (covers LOG-05, LOG-07, LOG-09 groundwork)
- [ ] `test/data/local/user_food_dao_test.dart` — DAO tests for custom food + override pair, search precedence (covers LOG-10, LOG-11)
- [ ] `test/domain/entities/meal_entry_test.dart` — sentinel `copyWith`, live macro-scaling pure function (covers LOG-06)
- [ ] `test/domain/entities/user_food_test.dart` — sentinel `copyWith`, required-fields validation
- [ ] `test/features/meal_logging/meal_entry_notifier_test.dart` — AsyncNotifier mutation methods (log/merge/edit/delete/duplicate + undo)
- [ ] `test/features/my_foods/user_food_notifier_test.dart` — AsyncNotifier mutation methods (save/override/revert)
- [ ] `integration_test/meal_logging_benchmark_test.dart` — new file; follow `food_search_benchmark_test.dart`/`co2_coverage_benchmark_test.dart` self-skip precedent (skip when off_reference.sqlite fixture absent), use bounded `pump()` not `pumpAndSettle()` per Pitfall 3
- [ ] Migration schema-dump script decision (Pitfall 5) — either update `tool/generate_schema_v1.dart` to track `schemaVersion` or explicitly scope it out

*(No test framework installs needed — `flutter_test`, `integration_test`, `mocktail` already present.)*

## Security Domain

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|----------------|---------|-------------------|
| V2 Authentication | No | Phase 4 is entirely local/offline, no auth surface (AUTH-* deferred to Phase 7) |
| V3 Session Management | No | Same |
| V4 Access Control | No | Single-user local device, no multi-tenant/role concerns |
| V5 Input Validation | Yes | Quantity must be `>0` (already a CONTEXT.md decision, enforced client-side via disabled button — should ALSO be enforced at the DAO/repository layer, not UI-only, per defense-in-depth); custom-food required fields (name + calories) enforced local-side before DB write; all raw SQL uses `Variable.withString`/parameterized `customStatement`, matching the existing `FoodCatalogDao` convention (`T-02-03-01`/`T-03-02-01` mitigations already established) |
| V6 Cryptography | No | No secrets/crypto surface in this phase — local SQLite, no encryption-at-rest requirement stated in REQUIREMENTS.md for Phase 4 |

### Known Threat Patterns for this stack

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|------------------------|
| SQL injection via free-text food name / brand / custom serving-size labels in raw `customSelect`/`customStatement` calls | Tampering | Parameterized queries only (`Variable.withString(...)`, positional `?` placeholders) — never string-interpolate user input into SQL, exactly as `FoodCatalogDao` already does |
| FTS5 query injection when searching `user_foods` alongside existing FTS sources | Tampering | Reuse the existing `_sanitizeFts5Query` helper pattern from `FoodCatalogDao` (strip metacharacters, parameterize) rather than writing a second, potentially inconsistent sanitizer |
| Unvalidated numeric input (negative/zero/absurdly large quantity, calorie, or CO₂ values) corrupting downstream macro-scaling math | Tampering | Client-side `>0` gate (already decided) PLUS a repository-layer guard before insert — client-only validation is bypassable in principle and the codebase's own convention (`T-03-02-02` max-length guard on barcode) is to validate again at the DAO/repository boundary |

## Sources

### Primary (HIGH confidence)
- `lib/data/local/mixins/sync_safe_table.dart`, `lib/data/local/app_database.dart`, `lib/data/local/migrations/migration_strategy.dart`, `lib/data/local/daos/food_catalog_dao.dart`, `lib/data/repositories/food_catalog_repository.dart`, `lib/domain/entities/food_item.dart`, `lib/features/profile/providers/profile_notifier.dart`, `lib/core/router/app_router.dart`, `lib/features/food_search/widgets/food_detail_sheet.dart`, `lib/features/barcode_scan/screens/barcode_scan_screen.dart`, `integration_test/food_search_benchmark_test.dart`, `tool/generate_schema_v1.dart`, `pubspec.yaml` — all read directly from this repository on 2026-07-23
- pub.dev registry API (`https://pub.dev/api/packages/flutter_slidable`) — queried directly on 2026-07-23 for version, score, publisher, license, download count

### Secondary (MEDIUM confidence)
- https://drift.simonbinder.eu/type_converters/ — `textEnum<T>()`, `TypeConverter.json2`/`JsonTypeConverter2` (WebSearch, cross-checked against pub.dev API docs page)
- https://drift.simonbinder.eu/guides/datetime-migrations/ — DateTime default storage as Unix-epoch integer, non-UTC on read (WebSearch summary of official docs)
- https://pub.dev/documentation/drift/latest/drift/JsonTypeConverter2-mixin.html — JSON converter API guidance
- https://pub.dev/packages/flutter_slidable — WebFetch of official package page for `Slidable`/`ActionPane`/`SlidableAction` usage example, version, SDK constraints
- https://api.flutter.dev/flutter/flutter_test/WidgetTester/pumpAndSettle.html — `pumpAndSettle()` caution around ongoing animations (WebSearch summary of official API docs)
- SQLite forum thread on cross-attached-database foreign keys (sqlite.org/forum) — corroborated by multiple independent sources in the same search that all agree FK-across-ATTACH is unsupported

### Tertiary (LOW confidence)
- None — every claim above was either grounded in this repository's own code or cross-checked against an official/registry source.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — every library except `flutter_slidable` is already pinned and proven in this codebase; `flutter_slidable` verified live against the pub.dev registry API (version, score, publisher) though the package choice itself is `[ASSUMED]` per the slopcheck ecosystem gap
- Architecture: HIGH — new tables/DAOs/notifiers directly extend patterns already implemented and tested in Phases 1–3 of this exact repo
- Pitfalls: HIGH — cross-DB FK and DateTime-storage findings verified against SQLite/Drift official documentation; pumpAndSettle caution verified against official Flutter API docs

**Research date:** 2026-07-23
**Valid until:** 2026-08-22 (30 days — stable stack, no fast-moving dependencies in this phase)
