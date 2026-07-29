---
status: testing
phase: 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable
source: 05-01-SUMMARY.md through 05-19-SUMMARY.md
started: "2026-07-28T21:04:00.346Z"
updated: "2026-07-29T08:19:50.399Z"
---

## Current Test
<!-- OVERWRITE each test - shows where we are -->

number: 3
name: Data Analysis screen — remaining scope (supplementary, charts already logged)
expected: |
  With the two chart bugs already logged, confirm the rest of the Data Analysis screen: an explicit "this week" total figure, a ranked list of today's largest contributors, a goal-comparison progress bar with a message, independently switchable Metric (CO2/Calories/Protein) and Range (7d/30d) trend toggles (the toggle controls themselves, not the chart rendering), an expandable per-food detail panel (tap a food to see per-serving + per-100g values), an "Estimate Transparency" section, an "Improvement Opportunities" section (if you've logged something CO2-heavy), and an "Insights Timeline" section.
awaiting: user response

## Tests

### 1. Dashboard — general composition
expected: |
  Open the app to the Dashboard (default landing screen). You should see, top to bottom:
  - Mode indicator ("Stored on this device" for Local Mode)
  - Three metric cards (CO2 / Calories / Protein), each showing a value vs. target (or "—" if not yet computable) — whichever metric matches your Profile goal is visually larger/emphasized and shown first
  - A macro split bar (protein/carbs/fat as a colored percentage bar with a legend) below the metric cards
  - A compact row of four stats: Carbs / Sugar / Fiber / Salt totals in grams (or "—" for any not yet logged)
  - A 7-day trend sparkline with a CO2/Calories/Protein segmented toggle
  - A one-line "quick insight" sentence (e.g. "Breakfast contributed most CO2 today") once you've logged something
  - Breakfast/Lunch/Dinner/Snack quick-log buttons + a "+ Quick Add Food" button
  - Today's logged meals grouped by slot below that
  Tapping any metric card or the trend sparkline should navigate to the Data Analysis screen for that metric.
result: pass
notes: "User also explored Data Analysis (reached via metric-card tap) and found two fl_chart rendering bugs there -- logged against Test 3 below rather than here, since Test 1's own scope (Dashboard composition) was fully confirmed working. Metric cards, macro split, nutrient stat row, meal logging, CO2 Calculation Settings, and Weight Tracking were also spot-checked in passing and matched expected behavior."

### 2. CO2 Calculation Settings screen
expected: |
  From Settings, tap "CO2 Calculation Settings" ("Personalize your CO2 footprint estimate"). You should see optional fields for location (country + region), food purchasing source, shopping transport, cooking method, food storage, household size, and food waste level — all optional, auto-saving as you fill them in (no explicit Save button required to persist). A "Data Quality" indicator (Basic/Good/Detailed) should update as you fill in more fields. Going back to the Dashboard, if data quality was Basic, you should have seen a dismissible "Complete your CO2 profile for better estimates" card near the bottom of the Dashboard that links back to this screen.
result: issue
reported: "Originally passed (fields present, auto-save persisted, data quality indicator updated). Revised to issue after a later discovery: the location/country/region text fields lose focus and dismiss the keyboard after every single keystroke (see the cross-screen focus-loss gap below, also affecting Profile Setup and Weight Tracking's goal field) -- this was missed on the first pass because it only manifests while actively typing character-by-character, not from the field's end state."
severity: major
note: "Root cause identified, fixed, and verified with a git-stash-proof regression test (see Gaps below) -- commit 1f58cf1. Not re-tested live on-device yet; will be confirmed as part of the final re-pass."

### 3. Data Analysis screen — general
expected: |
  Tap any Dashboard metric card to open Data Analysis. You should see: today's breakdown by meal as an actual stacked bar chart (not a plain list) with colored segments per macro/CO2 contribution, an explicit "this week" total figure, a ranked list of today's largest contributors for the metric you entered on, a goal-comparison progress bar with a message, independently switchable Metric (CO2/Calories/Protein) and Range (7d/30d) trend toggles, an expandable per-food detail panel (tap a food to see per-serving + per-100g values), an "Estimate Transparency" section explaining the CO2 confidence mix, an "Improvement Opportunities" section suggesting a lower-CO2 swap with a quantified kg CO2 delta (only if you've logged something CO2-heavy), and an "Insights Timeline" section with any detected patterns (may be empty if you don't have enough history yet).
result: issue
reported: "Already found during Test 1 exploration: (1) today's-breakdown bar chart Y-axis labels overlapping/stacking, out of order; (2) trend chart X-axis shows raw decimal indices (0.5, 1.5, etc.) instead of dates/days, unreadable as a time series. Both are fl_chart titlesData/getTitlesWidget config bugs. Rest of screen (weekly total, contributors, goal comparison, transparency, improvement opportunities, insights timeline, expandable food detail) still needs confirmation -- see supplementary check below."
severity: major

### 4. Weight Tracking — logging and chart interaction (fl_chart touch/drag)
expected: |
  From Settings, tap "Weight Tracking". Log a weigh-in (value, kg/lb toggle, optional note) — it should appear in the history chart immediately. The chart defaults to a 30-day view; tapping the 7d/30d/90d/1yr/all segmented buttons should switch the visible range. **Touch and drag your finger across the chart line** — you should see a tooltip/marker following your finger showing the value at that point (this is the fl_chart interaction that can't be verified by an automated test). If you set a weight goal (target weight + date), a horizontal dashed reference line should appear on the chart at the target weight — with no "on pace" projection text, just the line.
result: [pending]

### 5. Meal reminder notification — actually fires and is tappable
expected: |
  In Weight Tracking or Settings, find "Meal Reminders" and enable one slot (e.g. Lunch) with a time 1-2 minutes in the future. Grant the notification permission if prompted (should only ask now, not earlier). Background the app (press home / switch apps) and wait. **The notification should actually arrive at the OS level** at the scheduled time. Tapping it should open the app directly into food search with that meal slot pre-selected (not just the Dashboard).
result: [pending]

### 6. Weigh-in reminder — scheduling, firing, and re-arming
expected: |
  In Weight Tracking's Reminders section, set a weigh-in reminder to "Custom" with a specific day-of-week + time (or Weekly, for a faster test). Confirm it fires as a real OS notification at the scheduled time. Then: background the app and bring it back to the foreground at least once before the next occurrence — the reminder should still be scheduled to fire again (this exercises the app-lifecycle re-arm logic that keeps Biweekly/Monthly reminders alive beyond their first fire, not just Weekly).
result: [pending]

### 7. Backup & Restore — Create Backup (share_plus native share sheet)
expected: |
  From Settings, tap "Backup & Restore". You should see Current Storage Status (record counts), Create Backup, Automatic Backups (Off/Daily/Weekly), Export Data, Restore Data, a Privacy & Ownership statement explicitly stating backups are NOT encrypted, and a Danger Zone. Tap "Create backup" — **the native OS share sheet should open** (not an in-app dialog) with a real backup archive file attached, ready to send to Files/Drive/AirDrop/etc. Do the same for "Share export" under Export Data.
result: [pending]

### 8. Backup & Restore — Restore Data (file_selector native document picker)
expected: |
  In Backup & Restore's "Restore Data" section, tap "Choose backup file" — **the native OS document/file picker should open** (not an in-app file browser), and you should be able to navigate to and select a backup file from anywhere on the device (e.g. one you saved via Test 7, ideally from a location outside the app's own folder, like Files or Downloads). After selecting one, a preview of what will be restored should appear before you tap "Confirm Restore" — nothing should be overwritten until you explicitly confirm.
result: [pending]

### 9. Danger Zone — typed confirmation gate
expected: |
  In Backup & Restore's Danger Zone section, start the "delete all local data" flow. The delete action should stay disabled until you type the exact word "DELETE" into a confirmation field — no accidental one-tap deletion possible.
result: [pending]

## Summary

total: 9
passed: 1
issues: 2
pending: 6
skipped: 0

## Gaps

- truth: "Android build succeeds with flutter_local_notifications installed"
  status: resolved
  reason: "User reported: Android build failed with 'Dependency :flutter_local_notifications requires core library desugaring to be enabled for :app.' while attempting Test 1 -- a real build-configuration gap in Plan 05-08's package install (never caught by any automated test, since flutter test never invokes a Gradle build)."
  severity: blocker
  test: 1
  root_cause: "android/app/build.gradle.kts never enabled isCoreLibraryDesugaringEnabled or added the desugar_jdk_libs dependency when flutter_local_notifications was installed in Plan 05-08."
  artifacts:
    - path: "android/app/build.gradle.kts"
      issue: "Missing compileOptions.isCoreLibraryDesugaringEnabled = true and missing coreLibraryDesugaring dependency"
  missing: []
  fix_commit: "08e7bc1"
  debug_session: ""

- truth: "Today's breakdown stacked bar chart (Data Analysis) renders Y-axis labels legibly"
  status: failed
  reason: "User reported (Galaxy Tab S7 FE): Y-axis labels overlapping/stacking on top of each other, out of order."
  severity: major
  test: 3
  root_cause: ""
  artifacts:
    - path: "lib/features/data_analysis/widgets/today_breakdown_bar_chart.dart"
      issue: "Likely fl_chart BarChart titlesData/leftTitles getTitlesWidget missing interval/reservedSize/rotation config, causing label collisions"
  missing: []
  debug_session: ""

- truth: "Trend chart (Data Analysis) X-axis shows real date/day labels, not raw numeric indices"
  status: failed
  reason: "User reported (Galaxy Tab S7 FE): X-axis shows decimal increments (0.5, 1.5, etc.) instead of actual dates or days of the week, making the trend chart unreadable as a time-series view."
  severity: major
  test: 3
  root_cause: ""
  artifacts:
    - path: "lib/features/data_analysis/widgets/trend_section.dart"
      issue: "fl_chart bottomTitles getTitlesWidget likely returning the raw FlSpot x-index (double) instead of mapping it to a formatted date/day label"
  missing: []
  debug_session: ""

- truth: "Typing into a text field (CO2 Settings location/region, Profile Setup age/height/weight, Weight Tracking goal) does not lose focus or dismiss the keyboard"
  status: partial
  reason: "User reported (both Android Tab S7 FE and iOS iPhone): typing a single character causes the field to lose focus and the keyboard to dismiss, on both CO2 Calculation Settings AND Profile Setup, requiring a re-tap after every keystroke. After the first fix (commit 1f58cf1), user reported the bug was only PARTIALLY improved -- keyboard/focus still jumped and broke intermittently on real devices despite the fix and passing tests. A second, deeper root cause was then found and fixed (commit 147f1f1) -- see below. Not yet re-confirmed live on-device after the second fix; keeping this as 'partial' rather than re-declaring 'resolved' until the user actually verifies it on real hardware, since this exact bug was already prematurely marked resolved once."
  severity: major
  test: 2
  root_cause: "Two distinct, stacked bugs, both now addressed:\n(1) [fix_commit 1f58cf1] Three screens keyed their TextFormFields by the field's OWN current value (e.g. `ValueKey('age-${p?.age}')`, `ValueKey('location-country-${settings.locationCountry}')`, `ValueKey('target-weight-${widget.settings.targetWeightKg}')`). Every keystroke fires onChanged -> auto-save -> provider rebuild -> the key changes -> Flutter tears down and recreates the field's Element/State instead of updating it in place. `enterText`-based widget tests never caught this because `enterText` sets the whole value in one call rather than simulating a real keystroke-by-keystroke rebuild cycle.\n(2) [fix_commit 147f1f1, found only after the user reported the first fix was incomplete] `ProfileNotifier.saveProfile` and `Co2SettingsNotifier.saveSettings` both set `state = const AsyncValue.loading()` synchronously before every write. Since `ProfileScreen`/`Co2SettingsScreen` gate their entire body on `.when(loading: () => CircularProgressIndicator(), data: ...)`, and these methods fire on every keystroke, this tore out and rebuilt the WHOLE screen body (not just one field) on every keystroke -- a strictly worse version of bug (1) that (1)'s per-field key fix could never have addressed, since the whole ancestor subtree was being replaced regardless of any child widget's own key. This explains why the symptom was 'intermittent' post-(1)-fix: whether the user actually perceives/experiences the drop depends on how fast the write + rebuild completes relative to the next frame, which varies with real-device timing (I/O latency, GC pauses, thermal state) -- not reproducible deterministically, which is exactly why `Widget`-level regression tests for (1) alone didn't catch it. `WeightNotifier.saveGoal`/`saveReminderSettings` (same phase, Plan 05-07/05-13) never had this pattern, which is consistent with Weight's target-weight field not being re-reported as still-broken."
  artifacts:
    - path: "lib/features/profile/widgets/profile_form.dart"
      issue: "(1) Value-tied ValueKey on Age, Height (cm/ft/in), and Weight (kg/lb) TextFormFields -- fixed"
    - path: "lib/features/co2_settings/screens/co2_settings_screen.dart"
      issue: "(1) Value-tied ValueKey on all 8 fields (2 TextFormFields + 6 DropdownButtonFormFields) -- fixed"
    - path: "lib/features/weight/screens/weight_screen.dart"
      issue: "(1) Value-tied ValueKey on the Target weight TextFormField -- fixed"
    - path: "lib/features/profile/providers/profile_notifier.dart"
      issue: "(2) saveProfile set state = AsyncValue.loading() before every auto-save write -- fixed"
    - path: "lib/features/co2_settings/providers/co2_settings_notifier.dart"
      issue: "(2) saveSettings set state = AsyncValue.loading() before every auto-save write -- fixed"
  missing:
    - "Live on-device re-test after fix (2) -- not yet performed"
  fix_commit: "1f58cf1 (bug 1), 147f1f1 (bug 2)"
  fix_verification: "Bug 1: regression tests (test/features/profile/profile_form_test.dart, extended co2_settings_screen_test.dart/weight_screen_test.dart) assert EditableTextState identity survives an onChanged-driven rebuild. Bug 2: regression tests (test/features/profile/profile_notifier_test.dart [new], extended co2_settings_notifier_test.dart) assert saveProfile/saveSettings never emit an AsyncLoading state. Both sets of tests independently verified to actually fail against their respective pre-fix code via temporary git stash, then confirmed passing after restore. Full suite (369 tests) green, flutter analyze clean. Real-device re-confirmation still outstanding."
  debug_session: ""

- truth: "Tapping an empty (dash) target value on the Profile screen does not crash the app"
  status: resolved
  reason: "User reported (both Android Tab S7 FE and iOS iPhone): tapping Calories/Protein/Carbs/Fat in the Daily Targets section (shown as '—', 'Add height and weight to see targets') crashes the entire app -- confirmed reproducible on both devices/platforms. User captured the real crash log: \"package:flutter/src/widgets/framework.dart': Failed assertion: line 6268 pos 12: '_dependents.isEmpty': is not true\" -- a Flutter Element-lifecycle assertion, not a Dart null-deref."
  severity: blocker
  test: null
  root_cause: "ProfileScreen._buildBody's locale-detection effect had a broken guard: `if (profile == null || profile.units == 'metric')` scheduled a postFrameCallback that called updateField(...) -- but 'metric' is UserProfile's own default value, so once ANY field was ever saved (creating a real DB row with units: 'metric'), this condition was permanently true. Every build scheduled another auto-save write, which triggered a rebuild via ref.invalidateSelf(), which scheduled another write -- an infinite loop, silently running on every non-US-locale device (this app's entire target market is EU/Germany) since Phase 1. Opening the target-override dialog via `showDialog(context: context, ...)` anchors on ProfileScreen's own Element; with that Element being torn down and rebuilt at high frequency underneath the dialog's route insertion, the framework's InheritedElement dependent-tracking got left in an inconsistent state, tripping the `_dependents.isEmpty` assertion on unmount. This is very likely also a contributing factor to bugs 1+2 above (extra background rebuild churn on top of the keystroke-driven ones), though the Daily Targets tap was the only path that actually crashed outright."
  artifacts:
    - path: "lib/features/profile/screens/profile_screen.dart"
      issue: "_buildBody's locale-detection guard checked profile.units == 'metric' instead of only profile == null -- fixed"
  missing: []
  fix_commit: "c6697a3"
  fix_verification: "flutter analyze clean, full suite (369 tests) green. No new widget test added for the infinite-loop/crash itself (would require a fake clock or frame-count assertion harness beyond this session's scope) -- flagged as a follow-up; real-device re-confirmation still outstanding, same as bugs 1+2 above."
  debug_session: ""
