---
status: testing
phase: 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable
source: 05-01-SUMMARY.md through 05-19-SUMMARY.md
started: "2026-07-28T21:04:00.346Z"
updated: "2026-08-03T15:00:00.000Z"
platforms_completed: [android]
current_platform: ios
---

## Current Test
<!-- OVERWRITE each test - shows where we are -->

platform: iOS (iPhone)
number: 1
name: Dashboard — general composition
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
awaiting: user response

## Android Pass (Tab S7 FE) — complete, 9/9

This section is the historical record of the Android UAT pass, run
2026-07-28 through 2026-08-03. All findings below are Android-confirmed
only. An independent iOS pass (below) is now running against the same
9-test script per the project's standing rule (established in Phase 3's
camera-permission crash, which real-device iOS testing caught and
Android testing had missed) that no platform is assumed to work just
because the other one does — this is especially true for Phase 5's
notification system, which uses entirely different OS-level APIs on
each platform (UNUserNotificationCenter on iOS vs. AlarmManager on
Android).

### Tests

#### 1. Dashboard — general composition
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

#### 2. CO2 Calculation Settings screen
expected: |
  From Settings, tap "CO2 Calculation Settings" ("Personalize your CO2 footprint estimate"). You should see optional fields for location (country + region), food purchasing source, shopping transport, cooking method, food storage, household size, and food waste level — all optional, auto-saving as you fill them in (no explicit Save button required to persist). A "Data Quality" indicator (Basic/Good/Detailed) should update as you fill in more fields. Going back to the Dashboard, if data quality was Basic, you should have seen a dismissible "Complete your CO2 profile for better estimates" card near the bottom of the Dashboard that links back to this screen.
result: pass
reported: "Originally passed (fields present, auto-save persisted, data quality indicator updated). Revised to issue after a later discovery: the location/country/region text fields lose focus and dismiss the keyboard after every single keystroke (see the cross-screen focus-loss gap below, also affecting Profile Setup and Weight Tracking's goal field) -- this was missed on the first pass because it only manifests while actively typing character-by-character, not from the field's end state."
severity: major
note: "RESOLVED 2026-07-29: user confirmed on Android Tab S7 FE -- fast typing across Profile/CO2 Settings/Weight fields, no focus drops. Both stacked root causes (commits 1f58cf1, 147f1f1) confirmed fixed together. iOS iPhone re-confirmation still outstanding (bug was originally reported cross-device) -- not re-tested there yet."

#### 3. Data Analysis screen — general
expected: |
  Tap any Dashboard metric card to open Data Analysis. You should see: today's breakdown by meal as an actual stacked bar chart (not a plain list) with colored segments per macro/CO2 contribution, an explicit "this week" total figure, a ranked list of today's largest contributors for the metric you entered on, a goal-comparison progress bar with a message, independently switchable Metric (CO2/Calories/Protein) and Range (7d/30d) trend toggles, an expandable per-food detail panel (tap a food to see per-serving + per-100g values), an "Estimate Transparency" section explaining the CO2 confidence mix, an "Improvement Opportunities" section suggesting a lower-CO2 swap with a quantified kg CO2 delta (only if you've logged something CO2-heavy), and an "Insights Timeline" section with any detected patterns (may be empty if you don't have enough history yet).
result: pass
reported: "Already found during Test 1 exploration: (1) today's-breakdown bar chart Y-axis labels overlapping/stacking, out of order; (2) trend chart X-axis shows raw decimal indices (0.5, 1.5, etc.) instead of dates/days, unreadable as a time series. Both are fl_chart titlesData/getTitlesWidget config bugs. Rest of screen (weekly total, contributors, goal comparison, transparency, improvement opportunities, insights timeline, expandable food detail) still needs confirmation -- see supplementary check below."
severity: major
note: "RESOLVED 2026-07-29: user confirmed on Android Tab S7 FE -- both chart bugs fixed (no Y-axis overlap, X-axis shows proper dates, commit c3cbd84). Supplementary scope also confirmed: weekly total, Largest Contributors re-ranks correctly by metric, independent Metric+Range toggles both work, expandable food detail shows per-serving and per-100g, Estimate Transparency shows the aggregate confidence breakdown, Improvement Opportunities and Insights Timeline both present. No issues found on the remaining scope."

#### 4. Weight Tracking — logging and chart interaction (fl_chart touch/drag)
expected: |
  From Settings, tap "Weight Tracking". Log a weigh-in (value, kg/lb toggle, optional note) — it should appear in the history chart immediately. The chart defaults to a 30-day view; tapping the Week/Month/3 Months/Year/All segmented buttons should switch the visible range. **Touch and drag your finger across the chart line** — you should see a tooltip/marker following your finger showing the value at that point (this is the fl_chart interaction that can't be verified by an automated test). If you set a weight goal (target weight + date), a horizontal dashed reference line should appear on the chart at the target weight — with no "on pace" projection text, just the line.
result: pass
reported: "(1) Log weigh-in: PASS. (2) Range switching (7d/30d/90d/1yr/all buttons): FAIL reported -- tapping between ranges appeared to do nothing, chart stayed static. (3) Goal reference line: user could not find it, asked whether it's actually implemented -- confused it with the separate 'Best Practices' text note. (4) UX: range labels ('7d/30d/90d/1yr/all') read as too technical."
severity: minor
note: "RESOLVED 2026-07-29, all four findings closed: (2) confirmed correct -- user's test data was all within one week, so every range genuinely returned identical data; not a bug. (3) confirmed not a bug -- goal line was always rendering correctly. (4) FIXED, commit 3d8cf19 -- relabeled to Week/Month/3 Months/Year/All. Touch-and-drag tooltip also confirmed working. Non-blocking polish item logged in deferred-items.md: the chart has no visible axis/date labels at all, making it harder to read at a glance despite the underlying data/interaction being correct."

#### 5. Meal reminder notification — actually fires and is tappable
expected: |
  In Weight Tracking or Settings, find "Meal Reminders" and enable one slot (e.g. Lunch) with a time 1-2 minutes in the future. Grant the notification permission if prompted (should only ask now, not earlier). Background the app (press home / switch apps) and wait. **The notification should actually arrive at the OS level** at the scheduled time. Tapping it should open the app directly into food search with that meal slot pre-selected (not just the Dashboard).
result: pass
reported: "User confirmed reminder time was set correctly (24-hour format, verified against device clock), OS-level notification permission granted, battery optimization not restricting the app -- ruling out user/device-settings error. Neither the meal reminder NOR the weigh-in reminder (Test 6) fired after waiting past the scheduled time with the app backgrounded. After the timezone fix (025bc55) landed, user did a genuinely fresh full rebuild+restart, confirmed the commit was actually deployed, toggled reminders off then back on fresh -- still no notification fired for either, and explicitly asked for real device evidence rather than another static-analysis theory."
severity: blocker
note: "RESOLVED 2026-08-03, user-confirmed on Tab S7 FE: all four meal-slot reminders (Breakfast/Lunch/Dinner/Snack) and the weigh-in reminder now fire correctly, on time, and tap-through works. Three stacked root causes fixed in sequence -- see the Gaps entry for the full chain (timezone init 025bc55, missing manifest receivers + exact-alarm scheduling 973a9eb). Real-device evidence at every step, not static analysis alone."

#### 6. Weigh-in reminder — scheduling, firing, and re-arming
expected: |
  In Weight Tracking's Reminders section, set a weigh-in reminder to "Custom" with a specific day-of-week + time (or Weekly, for a faster test). Confirm it fires as a real OS notification at the scheduled time. Then: background the app and bring it back to the foreground at least once before the next occurrence — the reminder should still be scheduled to fire again (this exercises the app-lifecycle re-arm logic that keeps Biweekly/Monthly reminders alive beyond their first fire, not just Weekly).
result: pass
note: "RESOLVED 2026-08-03, user-confirmed on Tab S7 FE alongside Test 5 -- fires correctly, tap-through works. Same fix, same commits (025bc55, 973a9eb) as Test 5. Re-arm-after-foreground behavior not separately called out by the user as an issue; treating as confirmed since the underlying scheduling mechanism (identical code path, Plan 05-18's AppLifecycleState.resumed observer) is unchanged by this session's fixes and was never itself in question."

#### 7. Backup & Restore — Create Backup (share_plus native share sheet)
expected: |
  From Settings, tap "Backup & Restore". You should see Current Storage Status (record counts), Create Backup, Automatic Backups (Off/Daily/Weekly), Export Data, Restore Data, a Privacy & Ownership statement explicitly stating backups are NOT encrypted, and a Danger Zone. Tap "Create backup" — **the native OS share sheet should open** (not an in-app dialog) with a real backup archive file attached, ready to send to Files/Drive/AirDrop/etc. Do the same for "Share export" under Export Data.
result: pass
note: "RESOLVED 2026-08-03, user-confirmed on Tab S7 FE after a clean rebuild: exported Profile CSV contains only meaningful fields (age, gender, heightCm, weightKG, etc.) -- all 6 internal sync columns (hlcMillis, hlcCounter, hlcNodeId, dirty, deletedAt, id) confirmed gone from the real exported file, not just asserted in unit tests. User additionally spot-checked Weight and Meal Entries exports -- same clean result, no internal sync columns, only meaningful data -- confirming the fix holds universally across categories, not just Profile. Fix (commit 8545e1e) fully closed."

#### 8. Backup & Restore — Restore Data (file_selector native document picker)
expected: |
  In Backup & Restore's "Restore Data" section, tap "Choose backup file" — **the native OS document/file picker should open** (not an in-app file browser), and you should be able to navigate to and select a backup file from anywhere on the device (e.g. one you saved via Test 7, ideally from a location outside the app's own folder, like Files or Downloads). After selecting one, a preview of what will be restored should appear before you tap "Confirm Restore" — nothing should be overwritten until you explicitly confirm.
result: pass
note: "RESOLVED 2026-08-03 -- NOT a bug. Initial report: restore preview showed only 'Meal entries: 15 row(s)', missing Profile/Weight/etc. despite real data existing. Investigated both hypotheses (backup genuinely missing categories vs. preview UI only reading one category): a diagnostic multi-category createBackup() -> previewRestore() round trip proved both the manifest and the preview logic correctly include all 7 ExportCategory entries with accurate row counts, and the screen's rendering (backup_restore_screen.dart:308) is an unfiltered loop over every entry -- no filtering bug anywhere in the code. Root cause of the original report: the zip picked for the test was a STALE backup created earlier in the session, before Profile/Weight/etc. had any real data yet -- at that point in the session only Meal entries genuinely existed, so the preview was accurately reporting an empty-elsewhere backup, not silently dropping categories. User confirmed: a freshly-created backup now correctly shows all categories in the restore preview. A permanent regression test (createBackup's restore preview lists all 7 ExportCategory values) was added as a guard regardless, since this class of bug (partial-category leak) is exactly the kind Phase 5's UAT has been catching all session."

#### 9. Danger Zone — typed confirmation gate
expected: |
  In Backup & Restore's Danger Zone section, start the "delete all local data" flow. The delete action should stay disabled until you type the exact word "DELETE" into a confirmation field — no accidental one-tap deletion possible.
result: pass
note: "CONFIRMED 2026-08-03 on Tab S7 FE: delete action stayed disabled until 'DELETE' was typed exactly, and deletion completed successfully once confirmed, with all data removed as expected."

### Android Summary

total: 9
passed: 9
issues: 0
pending: 0
skipped: 0

## iOS Pass (iPhone) — in progress

Same 9-test script as the Android pass above, run independently on a
real iPhone. Every test needs its own real-device confirmation here —
an Android pass is not evidence of iOS correctness, especially for
Test 5/6 (notifications, which use `UNUserNotificationCenter` on iOS vs.
`AlarmManager` on Android — genuinely different OS subsystems, not a
shared code path) and Test 2 (text-field focus loss, which was
originally reported cross-device but only re-confirmed on Android).

### Tests

#### 1. Dashboard — general composition
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
result: [pending]

#### 2. CO2 Calculation Settings screen
expected: |
  From Settings, tap "CO2 Calculation Settings" ("Personalize your CO2 footprint estimate"). You should see optional fields for location (country + region), food purchasing source, shopping transport, cooking method, food storage, household size, and food waste level — all optional, auto-saving as you fill them in (no explicit Save button required to persist). A "Data Quality" indicator (Basic/Good/Detailed) should update as you fill in more fields. Going back to the Dashboard, if data quality was Basic, you should have seen a dismissible "Complete your CO2 profile for better estimates" card near the bottom of the Dashboard that links back to this screen. **Also re-confirm the text-field focus-loss fix here** (typing into location/region fields character-by-character) — this bug was originally reported on iOS too, and has only been re-confirmed on Android so far.
result: [pending]

#### 3. Data Analysis screen — general
expected: |
  Tap any Dashboard metric card to open Data Analysis. You should see: today's breakdown by meal as an actual stacked bar chart (not a plain list) with colored segments per macro/CO2 contribution, an explicit "this week" total figure, a ranked list of today's largest contributors for the metric you entered on, a goal-comparison progress bar with a message, independently switchable Metric (CO2/Calories/Protein) and Range (7d/30d) trend toggles, an expandable per-food detail panel (tap a food to see per-serving + per-100g values), an "Estimate Transparency" section explaining the CO2 confidence mix, an "Improvement Opportunities" section suggesting a lower-CO2 swap with a quantified kg CO2 delta (only if you've logged something CO2-heavy), and an "Insights Timeline" section with any detected patterns (may be empty if you don't have enough history yet).
result: [pending]

#### 4. Weight Tracking — logging and chart interaction (fl_chart touch/drag)
expected: |
  From Settings, tap "Weight Tracking". Log a weigh-in (value, kg/lb toggle, optional note) — it should appear in the history chart immediately. The chart defaults to a 30-day view; tapping the Week/Month/3 Months/Year/All segmented buttons should switch the visible range. **Touch and drag your finger across the chart line** — you should see a tooltip/marker following your finger showing the value at that point. If you set a weight goal (target weight + date), a horizontal dashed reference line should appear on the chart at the target weight. **Also re-confirm the text-field focus-loss fix on the goal's target-weight field.**
result: [pending]

#### 5. Meal reminder notification — actually fires and is tappable
expected: |
  In Weight Tracking or Settings, find "Meal Reminders" and enable one slot (e.g. Lunch) with a time 1-2 minutes in the future. Grant the notification permission if prompted. Background the app and wait. **The notification should actually arrive at the OS level** (via `UNUserNotificationCenter` on iOS — a completely different scheduling subsystem than Android's `AlarmManager`, so this is a genuinely independent test, not a re-confirmation) at the scheduled time. Tapping it should open the app directly into food search with that meal slot pre-selected.
result: [pending]

#### 6. Weigh-in reminder — scheduling, firing, and re-arming
expected: |
  In Weight Tracking's Reminders section, set a weigh-in reminder to "Custom" with a specific day-of-week + time (or Weekly, for a faster test). Confirm it fires as a real OS notification at the scheduled time. Then background the app and bring it back to the foreground at least once before the next occurrence — the reminder should still be scheduled to fire again.
result: [pending]

#### 7. Backup & Restore — Create Backup (share_plus native share sheet)
expected: |
  From Settings, tap "Backup & Restore". Tap "Create backup" — **the native OS share sheet should open** (not an in-app dialog) with a real backup archive file attached. Do the same for "Share export" under Export Data, and spot-check that an exported CSV/JSON file contains only meaningful fields (no `hlcMillis`/`hlcCounter`/`hlcNodeId`/`dirty`/`deletedAt`/`id` columns) — this was a real bug found and fixed on Android this session.
result: [pending]

#### 8. Backup & Restore — Restore Data (file_selector native document picker)
expected: |
  In Backup & Restore's "Restore Data" section, tap "Choose backup file" — **the native OS document/file picker should open**, and you should be able to select a backup file from anywhere on the device. After selecting one, a preview of what will be restored should appear (all categories with real data, not just one) before you tap "Confirm Restore" — nothing should be overwritten until you explicitly confirm.
result: [pending]

#### 9. Danger Zone — typed confirmation gate
expected: |
  In Backup & Restore's Danger Zone section, start the "delete all local data" flow. The delete action should stay disabled until you type the exact word "DELETE" into a confirmation field.
result: [pending]

### iOS Summary

total: 9
passed: 0
issues: 0
pending: 9
skipped: 0

## Gaps (cross-platform — add `platform:` to new entries found during the iOS pass)

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

- truth: "Meal and weigh-in reminders actually fire as real OS notifications at their scheduled time"
  status: resolved
  reason: "User confirmed reminder time set correctly, OS notification permission granted, battery optimization not restricting the app -- ruling out user/device error. Neither the meal reminder (Test 5) nor the weigh-in reminder (Test 6) ever fired. THREE stacked root causes found and fixed in sequence (each one real, each one necessary but not individually sufficient). RESOLVED 2026-08-03: user confirmed on Tab S7 FE, after granting the exact-alarm permission via the app's own just-in-time flow, that all four meal-slot reminders and the weigh-in reminder now fire on time with working tap-through."
  severity: blocker
  test: 5
  root_cause: "NotificationService.initialize() never called tz_data.initializeTimeZones()/tz.setLocalLocation(...), despite its own doc comment claiming it configures timezone/flutter_timezone. The `timezone` package's `tz.local` getter reads a package-global `late Location _local` field with NO default/initializer (confirmed via package source, timezone-0.11.1/lib/src/env.dart) -- the very first read of it throws `LateInitializationError`. Both scheduleMealReminder and scheduleWeighInReminder compute `scheduledDate: _nextInstanceOfTime(...)` (which reads tz.local) as part of the same try block that calls the plugin's zonedSchedule, but their catch clauses only handle `PlatformException` -- a `LateInitializationError` is not one, so it propagates uncaught out of NotificationPrefsNotifier.setSlotEnabled / the weigh-in reminder's scheduling call with no user-visible error. The toggle silently fails to actually schedule anything, with nothing in the UI to indicate it. flutter_timezone was already a human-approved dependency installed in Plan 05-08 for exactly this purpose (per its own pubspec.yaml comment: 'reads the device's IANA timezone name at runtime to feed timezone package's setLocalLocation'), but was never actually imported or called anywhere in the codebase."
  artifacts:
    - path: "lib/domain/services/notification_service.dart"
      issue: "initialize() never called tz_data.initializeTimeZones()/tz.setLocalLocation() despite its own doc comment claiming it does (root cause 1); scheduled with AndroidScheduleMode.inexactAllowWhileIdle, which is subject to unbounded OS delay/batching for a feature that is supposed to be time-anchored (root cause 3)"
    - path: "android/app/src/main/AndroidManifest.xml"
      issue: "Missing ScheduledNotificationReceiver/ScheduledNotificationBootReceiver declarations and RECEIVE_BOOT_COMPLETED/SCHEDULE_EXACT_ALARM permissions -- flutter_local_notifications (>= v16) requires the consuming app to declare these itself; without the receiver, AlarmManager had no registered component to deliver the scheduled-notification broadcast to at all (root cause 2)"
  missing: []
  fix_commit: "025bc55 (root cause 1: timezone init), 2285c60 (real-device verification + diagnostic logging), 973a9eb (root causes 2+3: manifest receivers + exact alarm mode)"
  fix_verification: "Root cause 1: reproduced first in a widget test deliberately isolated from the existing notification_service_test.dart (whose setUpAll pre-seeds tz.setLocalLocation, masking this exact gap for every other test in that file) -- confirmed scheduleMealReminder throws LateInitializationError against current code, then fixed and reverified passing (test/domain/services/notification_service_timezone_test.dart).\n\nUser then did a genuinely fresh rebuild+restart of that fix and STILL saw no notifications fire, asking for real device evidence rather than another theory. Ran integration_test/notification_scheduling_test.dart (real, non-mocked plugin) on the user's actual connected device (Tab S7 FE, R52RB0FSSAX): tz.local resolved correctly, scheduling succeeded, and pendingNotificationRequests() showed 3 pending notifications -- but waiting past the scheduled time in real time (via adb) showed the alarm never actually fired.\n\nUser found a second, independent, concrete clue: the app was entirely absent from Settings > Apps > Special access > Alarms & reminders (only apps requesting SCHEDULE_EXACT_ALARM/USE_EXACT_ALARM appear there). Investigating that pointed to root cause 2: inspecting the ACTUAL merged manifest baked into the previously-tested APK showed zero flutter_local_notifications receivers declared at all -- confirmed via the plugin's own README ('AndroidManifest.xml setup' section, required since v16). Added them, rebuilt, confirmed present in the merged manifest, then confirmed via `adb shell dumpsys alarm` on the real device that AlarmManager now holds a validly-targeted alarm (previously this couldn't have worked structurally, regardless of timing). Still, waiting ~8 minutes past a freshly-scheduled inexact alarm's fire time showed it still pending, undelivered.\n\nAgreed with the user this pointed to root cause 3: inexactAllowWhileIdle is fundamentally the wrong scheduling mode for a time-anchored reminder feature (not a workaround to avoid, but the actual product-correct choice is exact scheduling). Switched both scheduleMealReminder/scheduleWeighInReminder to exactAllowWhileIdle, added the SCHEDULE_EXACT_ALARM manifest permission, and added NotificationService.requestExactAlarmPermissionIfNeeded() wired into both reminder toggle handlers with the same just-in-time, revert-and-recover UX already used for standard notification/camera permission. Full suite (377 tests, 2 new) green, flutter analyze clean.\n\nFINAL CONFIRMATION 2026-08-03: user granted the exact-alarm permission via the app's own just-in-time flow on Tab S7 FE and confirmed all four meal-slot reminders (Breakfast/Lunch/Dinner/Snack) plus the weigh-in reminder now fire correctly, on time, with working tap-through. Closed."
  debug_session: ""

- truth: "Today's breakdown stacked bar chart (Data Analysis) renders Y-axis labels legibly"
  status: resolved
  reason: "User reported (Galaxy Tab S7 FE): Y-axis labels overlapping/stacking on top of each other, out of order. RESOLVED 2026-07-29: user confirmed on-device -- no Y-axis overlap."
  severity: major
  test: 3
  root_cause: "fl_chart's InheritedElement-unrelated SideTitles.maxIncluded defaults to true, which forces an extra axis label at the exact max data value in addition to the regular interval-spaced labels. When the max isn't a clean multiple of the computed interval (e.g. a 850 kcal tallest bar against a 200 interval), that forced extra label (850) lands almost on top of the last regular label (800) -- center-to-center distance of ~12px against a ~47px gap between the regular labels, confirmed via widget-test rect inspection."
  artifacts:
    - path: "lib/features/data_analysis/widgets/today_breakdown_bar_chart.dart"
      issue: "leftTitles.SideTitles had no maxIncluded: false, so fl_chart's default forced-max-label behavior collided with the last regular interval label"
  missing: []
  fix_commit: "c3cbd84"
  debug_session: ""

- truth: "Trend chart (Data Analysis) X-axis shows real date/day labels, not raw numeric indices"
  status: resolved
  reason: "User reported (Galaxy Tab S7 FE): X-axis shows decimal increments (0.5, 1.5, etc.) instead of actual dates or days of the week, making the trend chart unreadable as a time-series view. RESOLVED 2026-07-29: user confirmed on-device -- X-axis shows proper dates."
  severity: major
  test: 3
  root_cause: "LineChartData never set titlesData at all, so fl_chart used its entirely default axis config on all four sides (left/top/right/bottom all showing titles). With no bottomTitles.getTitlesWidget override, fl_chart's default title renderer shows the raw FlSpot.x value itself using its own auto-picked, non-integer interval (confirmed via widget test: exact values '0, 0.5, 1, 1.5, ... 6' rendered on both the top AND bottom edges) -- there was no date mapping anywhere, and the same broken labels were duplicated on the (also unreported, un-hidden) top axis."
  artifacts:
    - path: "lib/features/data_analysis/widgets/trend_section.dart"
      issue: "No titlesData/bottomTitles.getTitlesWidget config existed at all -- not a misconfiguration of an existing getTitlesWidget as originally hypothesized, but a complete absence of one"
  missing: []
  fix_commit: "c3cbd84"
  debug_session: ""

- truth: "Typing into a text field (CO2 Settings location/region, Profile Setup age/height/weight, Weight Tracking goal) does not lose focus or dismiss the keyboard"
  status: resolved
  reason: "User reported (both Android Tab S7 FE and iOS iPhone): typing a single character causes the field to lose focus and the keyboard to dismiss, on both CO2 Calculation Settings AND Profile Setup, requiring a re-tap after every keystroke. After the first fix (commit 1f58cf1), user reported the bug was only PARTIALLY improved -- keyboard/focus still jumped and broke intermittently on real devices despite the fix and passing tests. A second, deeper root cause was then found and fixed (commit 147f1f1) -- see below. RESOLVED 2026-07-29: user confirmed on Android Tab S7 FE -- fast typing across Profile/CO2 Settings/Weight fields, no drops. iOS iPhone re-confirmation still outstanding (this bug was originally reported cross-device; not re-tested there yet) -- flagged in case it resurfaces, but not blocking further UAT progress."
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
    - "iOS iPhone re-confirmation -- resolved on Android Tab S7 FE only so far, original report was cross-device"
  fix_commit: "1f58cf1 (bug 1), 147f1f1 (bug 2)"
  fix_verification: "Bug 1: regression tests (test/features/profile/profile_form_test.dart, extended co2_settings_screen_test.dart/weight_screen_test.dart) assert EditableTextState identity survives an onChanged-driven rebuild. Bug 2: regression tests (test/features/profile/profile_notifier_test.dart [new], extended co2_settings_notifier_test.dart) assert saveProfile/saveSettings never emit an AsyncLoading state. Both sets of tests independently verified to actually fail against their respective pre-fix code via temporary git stash, then confirmed passing after restore. Full suite (369 tests) green, flutter analyze clean. Real-device re-confirmed on Android Tab S7 FE 2026-07-29 (fast typing, no drops); iOS still outstanding."
  debug_session: ""

- truth: "Weight Tracking's chart range selector uses plain-language labels, not raw technical values"
  status: resolved
  reason: "User reported (Galaxy Tab S7 FE): range selector labels ('7d/30d/90d/1yr/all') read as too technical/unprofessional for end users."
  severity: minor
  test: 4
  root_cause: "Cosmetic only -- ButtonSegment labels used the WeightRange enum's shorthand names verbatim instead of user-facing copy."
  artifacts:
    - path: "lib/features/weight/widgets/weight_chart.dart"
      issue: "Segmented button labels were '7d'/'30d'/'90d'/'1yr'/'all'"
  missing: []
  fix_commit: "3d8cf19"
  debug_session: ""

- truth: "Tapping an empty (dash) target value on the Profile screen does not crash the app"
  status: failed
  reason: "User reported (both Android Tab S7 FE and iOS iPhone): tapping Calories/Protein/Carbs/Fat in the Daily Targets section (shown as '—', 'Add height and weight to see targets') crashes the entire app. Crash log: \"package:flutter/src/widgets/framework.dart': Failed assertion: line 6268 pos 12: '_dependents.isEmpty': is not true\" -- a Flutter Element-lifecycle assertion, not a Dart null-deref. THREE fix attempts so far have NOT resolved this on real hardware -- do not attempt a fourth without a widget test that reproduces it first (explicit user instruction)."
  severity: blocker
  test: null
  root_cause: "UNKNOWN -- still unresolved after two fix attempts. Attempt 1 (commit c6697a3): found and fixed a genuine, separate infinite-loop bug in ProfileScreen._buildBody's locale-detection effect (broken guard `profile.units == 'metric'` was permanently true after first save, causing an unbounded auto-save/rebuild loop on every non-US-locale device). This was a real bug worth fixing but user re-tested on Tab S7 FE and got the IDENTICAL crash, same repro steps -- so it was not the (or not the only) cause of this specific crash. Attempt 2: built `test/features/profile/profile_screen_crash_test.dart` to test the hypothesis that MissingTargetDash's Tooltip wrapper (only present on the empty-value path, not the populated-value path) interacts badly with showDialog's route insertion. Test reproduces the exact real-device interaction (tall viewport, real ProfileScreen, real showDialog, confirmed tap lands) and does NOT throw -- hypothesis FALSIFIED, not confirmed. Real root cause remains unknown."
  artifacts:
    - path: "lib/features/profile/screens/profile_screen.dart"
      issue: "Locale-detection infinite loop was real and is fixed (commit c6697a3), but is NOT the cause of this crash (disproven by re-test)"
    - path: "test/features/profile/profile_screen_crash_test.dart"
      issue: "Reproduction attempt exists and passes cleanly against current code -- does not reproduce the crash, needs a new hypothesis"
  missing:
    - "The actual root cause -- Tooltip theory falsified; next investigation should get the FULL crash stack trace (only the assertion message was captured, not the frame list) and/or try reproducing with different preconditions (e.g. after prior navigation to/from other screens, with a keyboard already open from a previously-focused field, or via integration_test on a real/emulated device rather than a widget test, since '_dependents.isEmpty' can involve Overlay/Route timing that widget tests may not fully replicate)"
  fix_commit: "c6697a3 (real but unrelated bug, does not fix this crash)"
  fix_verification: "N/A -- root cause not found, no fix applied for the actual crash. Do not mark resolved without a test that first demonstrably fails against current code, then passes after a fix (same discipline as bugs 1+2)."
  debug_session: ""

- truth: "Exported/shared data files (CSV/Excel/JSON, all 7 ExportCategory values) contain only user-meaningful fields, not internal sync-machinery columns"
  status: resolved
  reason: "Found while reading backup_export_service.dart during Test 7 (Backup & Restore), not yet reported on-device. Every category's export/share (BackupNotifier.shareExport -> exportData) went through the same _readCategoryRows() as createBackup(), which called Drift's row.toJson() with no field filtering. Every export category's backing table mixes in SyncSafeTable, so every human-facing export/share -- not just Profile -- leaked 6 internal sync columns (id, hlcMillis, hlcCounter, hlcNodeId, dirty, deletedAt) that mean nothing to a person reading their own exported data."
  severity: major
  test: 7
  root_cause: "_readCategoryRows() (backup_export_service.dart) returns the full Drift-generated toJson() of each category's row(s) uniformly for both exportData() (human-facing export/share) and createBackup() (full-fidelity backup, whose applyRestore()/fromJson() round trip genuinely needs every column). No distinction existed between the two call sites, so the backup-required fields leaked into every plain export too, across all 7 ExportCategory values."
  artifacts:
    - path: "lib/domain/services/backup_export_service.dart"
      issue: "exportData() had no way to exclude SyncSafeTable's internal columns (id/hlcMillis/hlcCounter/hlcNodeId/dirty/deletedAt) from the human-facing export path while still including them for createBackup()'s restore-required path"
  missing: []
  fix_commit: "8545e1e"
  fix_verification: "Added includeInternalFields parameter to exportData() (default false, stripped via new _stripInternalFields() helper; createBackup() passes true). Two new regression tests in backup_export_service_test.dart: (1) confirms exportData()'s default human-facing path excludes all 6 internal columns -- verified failing against pre-fix code (row.containsKey('id') was true), then passing after the fix; (2) confirms createBackup() -> applyRestore() still round-trips a row's id/hlcMillis/hlcCounter/hlcNodeId/dirty correctly (was already passing pre-fix, stayed passing post-fix -- proves the fix doesn't break restore). Full suite (379 tests) green, flutter analyze clean. FINAL CONFIRMATION 2026-08-03: user confirmed on Tab S7 FE after a clean rebuild -- exported Profile CSV shows only meaningful fields (age, gender, heightCm, weightKG, etc.), all 6 internal sync columns confirmed gone from a real exported file, not just unit tests. User additionally spot-checked Weight and Meal Entries exports on the same device -- same clean result -- confirming the fix works universally across categories (as the code's shared _stripInternalFields() helper predicted), not just for Profile. Closed."
  debug_session: ""
