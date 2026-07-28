---
status: testing
phase: 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable
source: 05-01-SUMMARY.md through 05-19-SUMMARY.md
started: "2026-07-28T21:04:00.346Z"
updated: "2026-07-28T22:41:18.059Z"
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
  status: resolved
  reason: "User reported (both Android Tab S7 FE and iOS iPhone): typing a single character causes the field to lose focus and the keyboard to dismiss, on both CO2 Calculation Settings AND Profile Setup, requiring a re-tap after every keystroke. Cross-screen, cross-platform -- confirmed shared root cause."
  severity: major
  test: 2
  root_cause: "Three screens keyed their TextFormFields by the field's OWN current value (e.g. `ValueKey('age-${p?.age}')`, `ValueKey('location-country-${settings.locationCountry}')`, `ValueKey('target-weight-${widget.settings.targetWeightKg}')`). Every keystroke fires onChanged -> auto-save -> provider rebuild -> the key changes -> Flutter tears down and recreates the field's Element/State instead of updating it in place, dropping focus and the keyboard. `enterText`-based widget tests never caught this because `enterText` sets the whole value in one call rather than simulating a real keystroke-by-keystroke rebuild cycle."
  artifacts:
    - path: "lib/features/profile/widgets/profile_form.dart"
      issue: "Value-tied ValueKey on Age, Height (cm/ft/in), and Weight (kg/lb) TextFormFields"
    - path: "lib/features/co2_settings/screens/co2_settings_screen.dart"
      issue: "Value-tied ValueKey on all 8 fields (2 TextFormFields + 6 DropdownButtonFormFields)"
    - path: "lib/features/weight/screens/weight_screen.dart"
      issue: "Value-tied ValueKey on the Target weight TextFormField"
  missing: []
  fix_commit: "1f58cf1"
  fix_verification: "Regression tests added (test/features/profile/profile_form_test.dart, extended test/features/co2_settings/co2_settings_screen_test.dart and test/features/weight/weight_screen_test.dart) asserting EditableTextState identity survives an onChanged-driven rebuild. Verified the tests actually fail against the pre-fix code via a temporary git stash of the fix, then confirmed they pass after restoring it. Full suite (366 tests) green, flutter analyze clean."
  debug_session: ""

- truth: "Tapping an empty (dash) target value on the Profile screen does not crash the app"
  status: failed
  reason: "User reported (both Android Tab S7 FE and iOS iPhone): Profile screen shows '—' for calories/protein/carbs/fat targets even though Dashboard correctly computes and shows real values for the same underlying data. Tapping any of the empty target fields on Profile crashes the entire app -- confirmed reproducible on both devices/platforms."
  severity: blocker
  test: null
  root_cause: "UNKNOWN -- explicitly deferred. User is capturing the real crash log (adb logcat on Android / Xcode console on iOS) before any fix is attempted, since a full-app crash should not be diagnosed by guessing. TargetDisplayCard/_showOverrideDialog's tap handler in profile_screen.dart was inspected and shows no obvious unguarded null-dereference, so the actual cause needs the stack trace -- static review was not sufficient here. Also unexplained: why the SAME profile.targets data would render populated on Dashboard's MetricCard 'of X' suffix but empty on Profile's TargetDisplayCard, since both read the same profileProvider -- worth checking whether Dashboard is actually reading a different value (e.g. today's consumed totals) rather than the same target field, which may mean this is not actually a data inconsistency at all and just an independent crash."
  artifacts:
    - path: "lib/features/profile/screens/profile_screen.dart"
      issue: "_showOverrideDialog / TargetDisplayCard onTap -- exact failure point unknown pending crash log"
  missing:
    - "Real crash log/stack trace from adb logcat (Android) or Xcode console (iOS)"
  debug_session: ""
