# Phase 4: Meal Logging Core (<10s target) - Context

**Gathered:** 2026-07-23
**Status:** Ready for planning

<domain>
## Phase Boundary

Deliver end-to-end meal logging under 10 seconds, fully offline: adding food to Breakfast/Lunch/Dinner/Snack slots with portion units, Recent (individual items, one-tap reuse), Favorites (one-tap re-log), Custom foods (My Foods), personal overrides of existing DB entries (non-destructive, revertible), and edit/delete/duplicate of logged entries. Requirements: LOG-05 through LOG-13.

**What this phase does NOT include:**
- Full Dashboard (7-day trend, contextual insights, swipe actions beyond what Phase 4 itself introduces) — Phase 5
- CO₂/nutrition daily/weekly totals and Data Analysis screen — Phase 5
- Weight tracking, notifications, export/backup — Phase 5
- Onboarding, legal consent, accessibility audit — Phase 6
- iOS real-device verification is required to close this phase (carried forward from Phase 3 — TestFlight + physical iPhone is a Phase 4 prerequisite, not optional)

</domain>

<decisions>
## Implementation Decisions

### Barcode/Search Sheet Reconciliation (bug found during discussion)

- `_BarcodeScanDetailSheet` in `barcode_scan_screen.dart` is a hand-duplicated copy of `FoodDetailBottomSheet`'s content, using raw CO₂ string formatting instead of `ConfidenceChip` — a divergence from Phase 3's explicit "no behavioral difference between scan and search sheets" decision. It happened because the shared `showFoodDetailSheet()` helper wraps its `showModalBottomSheet` call in `unawaited()`, so the scanner (which needs to know when the sheet closes, to resume the camera) couldn't use it.
- **Fix:** change `showFoodDetailSheet()` to return the real `Future<void>` from `showModalBottomSheet` instead of swallowing it. Callers that don't care about dismissal (search screen) simply don't await it; the scanner awaits it and resumes the camera exactly as today.
- Delete `_BarcodeScanDetailSheet` and its private `_MacroRow` entirely. Both search and scan flows render the single shared `_FoodDetailContent` widget.
- "Log this food," the favorite star, and "Edit this food" are added once, to the shared widget — both entry points get them for free.

### Core Logging Flow — Meal Slot Selection

- Segmented control showing all 4 slots, pre-selected via time-of-day auto-detection (e.g. Breakfast/Lunch/Dinner/Snack cutoff hours — exact boundaries are Claude's discretion), user can tap to override.
- No memory/learning of manual corrections — every new log re-guesses fresh from time of day. No per-user adaptive state.
- Dashboard's "Add Breakfast" (etc.) quick-add buttons push to `/food-search` carrying the target slot as a param; the eventual sheet's slot picker is pre-set to that slot (explicit intent overrides the time-of-day guess), still editable.

### Core Logging Flow — Portion/Quantity Input

- Preset quantity chips sourced from the food's quick-serving-sizes (configured in My Foods) + a "Custom" chip.
- Tapping a chip pre-fills an **editable** numeric field (not locked to the exact preset value) + unit dropdown, defaulted to the food's natural unit.
- When a food has no configured quick-serving-sizes (true for most catalog/OFF items on first use): fall back to generic default chips (100g, 200g, Custom) rather than skipping straight to the numeric field.
- For non-gram/ml units (pieces/cups/portions) on a food with **no configured weight-per-unit**: the unit dropdown only offers g/ml until the user configures a conversion in My Foods. No generic/estimated conversion fallback — avoids false-precision macro numbers.
- Displayed macro/CO₂ numbers in the sheet **scale live** with the selected quantity (e.g. picking 150g shows 225 kcal, not the fixed 100g reference value) — matches the honesty-in-numbers principle already applied to CO₂ confidence bands.
- "Log this food" button stays **disabled** until quantity is valid (>0) — no error-message path needed.

### Core Logging Flow — Confirmation & Feedback

- On successful log: sheet auto-dismisses, "Added to [Slot]" snackbar appears over whatever screen is now visible, with an **Undo** action. No loading/saving indicator — local DB write is near-instant (same principle as Phase 2's "no shimmer for fast local ops").
- No haptic feedback on successful log (contrast with Phase 3's haptic-on-barcode-detect) — snackbar is sufficient.
- Barcode-scan-sourced logs show the same snackbar over the resumed live camera feed — consistent confirmation regardless of entry point.
- Rare DB write failure: error snackbar with a **Retry** action; sheet stays open so slot/quantity selection isn't lost. No silent retry.
- No explicit close (X) button on the sheet — drag-down / back-gesture / tap-outside remains the only dismissal, unchanged from Phase 2/3.

### Core Logging Flow — Merge Semantics

- Logging the same food to the **same slot, same day** merges into the existing entry (adds quantity) rather than creating a new row.
- Merge requires **matching portion units** — a unit mismatch (e.g. first log in grams, second in cups) creates a separate entry instead of attempting conversion.
- "Same food" match key for merging: the food's **internal reference/ID** (barcode when present, otherwise catalog/custom-food ID) — never a product-name string match, to avoid false-positive merges between similarly-named products.
- Undo after a merge subtracts only the **just-added delta**, restoring the entry to its pre-merge quantity — never deletes the whole entry (which would incorrectly erase earlier-logged quantity).
- **Duplicate** (the swipe action from Managing Logged Entries) is a distinct code path from the Log flow and deliberately **bypasses** this merge rule — see Managing Logged Entries below.

### Core Logging Flow — Data Model

- Meal entries store a **snapshot** of macro/CO₂ values at the moment of logging — not a live reference to the food's current catalog data. Historical logs stay accurate even if the underlying food's data later changes (OFF re-sync, CO₂ methodology update, or a personal override created after the fact). This is the single biggest data-model decision in this phase.
- Direct consequence: creating or editing a personal override does **not** retroactively change past logged entries that used the pre-override values.

### Core Logging Flow — Multi-item Logging & Benchmark

- After logging via search or scan, the user returns to the search results list / live scanner (already true for the scanner via Phase 3's resume-camera behavior) — supports logging several items back-to-back without re-navigating.
- Build an automated Dart integration test timing the full tap-to-saved sequence, following the precedent set by Phase 2's search benchmark and Phase 3's CO₂ coverage benchmark, **plus** the required real-device user testing before the phase closes (LOG-13's literal requirement).

### Recent & Favorites

- Surface: shown on the food search screen's **empty state**, replacing Phase 2's plain "Search for a food..." prompt — typing a query replaces Recent/Favorites with search results.
- Logging from Recent/Favorites: **one tap = instant log** (sheet skipped entirely) using the item's last-used quantity and the auto-detected slot.
- A small **edit icon** on each Recent/Favorite row opens the full pre-filled sheet, for adjusting quantity/slot before logging instead of accepting the last-used values.
- Recent list: most-recent-first, capped at roughly 10–15 items, **deduped by food** — re-logging an item moves it back to the top rather than adding a duplicate row.
- Favorites: toggled via the star icon in the detail sheet; the same (filled) star reappears on Favorites rows and **tapping it again un-favorites** — one icon, both directions, no swipe gesture needed for this.

### Custom Foods & Personal Overrides (My Foods)

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

### Managing Logged Entries

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

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets

- `FoodDetailBottomSheet` / `_FoodDetailContent` (`lib/features/food_search/widgets/food_detail_sheet.dart`) — has an explicit `TODO(phase-4)` comment at line 132 marking where "Log this food" slots in; also gains the favorite star and "Edit this food" action this phase. Currently `StatelessWidget` — will likely need to become stateful/Consumer to host the portion form.
- `showFoodDetailSheet()` helper — needs a signature/behavior fix (return the real dismissal `Future<void>`) as part of the sheet-reconciliation fix above.
- `FoodItem` entity (`lib/domain/entities/food_item.dart`) — sentinel `copyWith` pattern (`static const _sentinel = Object()`) to replicate for new `MealEntry`/`UserFood` entities with nullable fields. Note: `FoodItem` itself has no `id` field and its equality is barcode+productName only — a `MealEntry` needs its own FK/reference strategy since the merge match-key decision requires a real internal food ID, not name matching.
- `SyncSafeTable` mixin (`lib/data/local/mixins/sync_safe_table.dart`) — new tables (`MealEntryTable`, `UserFoodTable`) apply this mixin; follow the existing HLC placeholder convention (`hlcNodeId: 'local'`, `hlcCounter: 0`) until Phase 7.
- `ConfidenceChip` (`lib/features/barcode_scan/widgets/confidence_chip.dart`) — reused for the CO₂ confidence display in the custom-food form's category-estimate path.
- `/custom-food-stub` route (`lib/core/router/app_router.dart`, lines 98–113) — Phase 4 replaces the placeholder body with the real form; must keep reading `barcode` from `state.uri.queryParameters['barcode']` for the pre-fill contract Phase 3 already established.
- `PlaceholderDashboardScreen` (`lib/core/router/app_router.dart`, lines 16–32) — Phase 4 injects the minimal grouped entries list here instead of the "Dashboard coming in Phase 5" text.
- `FoodCatalogDao` / `FoodCatalogRepository` (`lib/data/local/daos/food_catalog_dao.dart`, `lib/data/repositories/food_catalog_repository.dart`) — template for new `MealEntryDao`/`MealEntryRepository` and `UserFoodDao`/`UserFoodRepository`: raw `customSelect`/`customStatement` with `Variable.withString(...)` parameterization, `try`/`on Exception catch` with `debugPrint` fallback.
- `IFoodCatalogRepository` (`lib/domain/repositories/`) — template for new `IMealEntryRepository` / `IUserFoodRepository` domain interfaces.
- `ProfileNotifier` (`lib/features/profile/providers/profile_notifier.dart`) — `@riverpod class` codegen pattern (generates e.g. `mealEntryProvider`, suffix-stripped) to follow for new notifiers.

### Established Patterns

- No shimmer/loading indicator for fast local DB operations (Phase 2 decision) — applies directly to the "feels instant" Log confirmation decision.
- Distinct, honest messaging per failure mode (genuine no-match vs. offline vs. network failure) — applies to the "Add as custom food" link's genuine-no-match-only scoping.
- No false-precision numbers — applies to CO₂ input methodology consistency (category-estimate vs. flagged manual entry) and the "no unit without a configured conversion" portion-input decision.
- go_router named routes — new routes needed for the My Foods screen and its create/edit form (the create/edit form likely reuses/extends `/custom-food-stub` rather than introducing a second parallel flow).

### Integration Points

- `FoodDetailBottomSheet` becomes the single surface for search-result, barcode-scan, AND override-edit-entry — the three actions added (Log, Favorite star, Edit-this-food) must coexist without cluttering it.
- Food search/lookup must now also query the `user_foods` table, with override rows taking precedence over (replacing) the original catalog row in results.
- `PlaceholderDashboardScreen` becomes a real, if minimal, consumer of the new `MealEntryRepository` — the first non-profile screen in the app to read logged data.
- The food search screen's empty state is repurposed to show Recent/Favorites — extends Phase 2's `FoodSearchNotifier`/state.

</code_context>

<specifics>
## Specific Ideas

- "No behavioral difference between scan and search sheets" (Phase 3's original decision) — the `_BarcodeScanDetailSheet` divergence found during this discussion was an implementation slip, not an intentional change; Phase 4 restores that original intent while adding the Log/Favorite/Edit actions.
- "Snapshot, not reference" — explicit, deliberate decision to protect historical log accuracy against future catalog/methodology/override changes. This is the single most important data-model decision in the phase.
- "Merge is real, but Duplicate deliberately isn't" — automatic merge (same food/slot/day/unit via the Log flow) is a distinct mechanism from manual Duplicate (an explicit swipe action on an existing entry), which always creates a separate row even when it would otherwise match the merge criteria.
- Custom food CO₂ defaults to the same AGRIBALYSE-based category-estimate methodology used for catalog foods — manual entry is an explicit escape hatch, not the default, preserving methodology consistency across the whole app.
- Phase 2's search no-results state explicitly deferred "Add custom food" link to "once the flow exists" — this phase closes that exact gap.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within Phase 4 scope (LOG-05 through LOG-13). No new capabilities were proposed during this session.

</deferred>

---

*Phase: 04-meal-logging-core-10s-target*
*Context gathered: 2026-07-23*
