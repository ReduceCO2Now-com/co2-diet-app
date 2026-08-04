---
phase: 06-onboarding-legal-consent-legal-hub-ed-safety-nets-accessibility-pre-submission
plan: 07
subsystem: legal
tags: [flutter, riverpod, go_router, gdpr-consent, accessibility, semantics]

requires:
  - phase: 06-04
    provides: "ConsentNotifier.acceptConsent / IConsentRepository / ConsentRecordsDao durable write path"
provides:
  - "LegalConsentScreen -- the mandatory pre-Profile-Setup GDPR consent gate (4 mandatory + 1 optional checkbox)"
  - "ConsentCheckboxTile -- reusable checkbox row widget with merged semantics + trailing document link, reusable by future consent-style screens"
affects: [06-08, 06-09, phase-7-account-mode]

tech-stack:
  added: []
  patterns:
    - "ref.watch(autoDisposeAsyncNotifierProvider) in build() to keep an autoDispose notifier alive across a multi-await mutation triggered from a callback (extends [Phase 04-09] mealEntryProvider precedent to consentProvider)"
    - "MergeSemantics(Row(Checkbox, Text)) for a single screen-reader-discoverable checkbox row, with the trailing link kept outside the merge boundary so it stays independently tappable"

key-files:
  created:
    - lib/features/legal/widgets/consent_checkbox_tile.dart
    - lib/features/legal/screens/legal_consent_screen.dart
  modified:
    - test/features/legal/legal_consent_screen_test.dart

key-decisions:
  - "consentProvider (not consentNotifierProvider) is the real generated provider variable name for the ConsentNotifier class -- @riverpod strips the 'Notifier' suffix, consistent with the [Phase 06-05] onboardingGateProvider precedent; PLAN.md's action-block prose used the wrong name"
  - "LegalConsentScreen must ref.watch(consentProvider) in build() to keep the autoDispose notifier alive for the duration of _onAccept's multi-await acceptConsent() call -- without it, Riverpod disposes the notifier's ref between awaits and acceptConsent throws UnmountedRefException mid-flight"
  - "Widget test overrides legalDocumentLoaderProvider with a fake in-memory loader (not the real rootBundle asset read already proven by [Phase 06-02]'s legal_document_loader_test.dart) -- repeated real asset loads via rootBundle inside a testWidgets + pumpAndSettle context hung indefinitely on the second call within the same test file/isolate, unrelated to production code correctness"

requirements-completed: [LEGAL-01, LEGAL-02, LEGAL-03, LEGAL-04, LEG-02, ACC-02, ACC-03, ACC-05, NFR-01]

duration: ~25min
completed: 2026-08-04
---

# Phase 6 Plan 07: Legal Consent Screen Summary

**LegalConsentScreen with 4 mandatory + 1 optional checkbox, GDPR-valid never-pre-checked state, and a gated "Accept and Continue" wired to `ConsentNotifier.acceptConsent`.**

## Performance

- **Duration:** ~25 min
- **Tasks:** 1 completed
- **Files modified:** 3

## Accomplishments

- Built `ConsentCheckboxTile`, a reusable checkbox row that merges the `Checkbox`'s checked state and its label text into a single screen-reader-discoverable semantics node (ACC-03), with a 44pt minimum tap target (ACC-05) and an independently-tappable trailing document link.
- Built `LegalConsentScreen`: all 5 checkbox booleans hard-coded to `false` at construction (PITFALLS.md C5's "no pre-checked boxes" GDPR requirement), with "Accept and Continue" gated exclusively by the 4 mandatory boxes (Terms, Privacy, not-medical-advice, user-responsibility) — the optional 16+ box never substitutes for or gates on a mandatory one.
- "View Terms" / "View Privacy Policy" / "View Disclaimer" links push the exact same shared `LegalDocumentScreen` route (`/legal-hub/document?doc=...`) the Legal Hub will use, reachable before any box is checked (LEGAL-04).
- Tapping "Accept and Continue" calls `ConsentNotifier.acceptConsent` with the live checkbox state — a 4-element list when only the mandatory boxes are checked, a 5-element list including `'age_16_plus'` when the optional box is also checked — then routes to `/profile`.
- Widget test suite: 8 green cases (0 skips) covering initial-render-unchecked, gating on/off, the "3 mandatory + optional" trap case, pre-checkbox link navigation, the exact `consentsGiven` payload for both accept paths, 1.6x text-scale overflow (ACC-02), and semantics discoverability (ACC-03).

## Task Commits

1. **Task 1: ConsentCheckboxTile + LegalConsentScreen** - `2acc71f` (feat)

**Plan metadata:** (this commit)

## Files Created/Modified

- `lib/features/legal/widgets/consent_checkbox_tile.dart` - Reusable checkbox row: `MergeSemantics(Row(Checkbox, Text))` for one merged accessible node, `ConstrainedBox(minHeight: 44)` for ACC-05, optional `trailingLink` kept outside the merge boundary
- `lib/features/legal/screens/legal_consent_screen.dart` - The Legal Consent screen: 5 `bool` state fields all `false`, `_canAccept` gated on the 4 mandatory fields only, `_onAccept` builds `consentsGiven` and calls `ConsentNotifier.acceptConsent` then `context.go('/profile')`
- `test/features/legal/legal_consent_screen_test.dart` - Replaced the Plan 06-01 skipped stub with 8 real widget tests using a self-contained `GoRouter` test harness (`/legal-consent` → `/legal-hub/document` stub → `/profile` stub) and mocktail-mocked `IConsentRepository`/fake `LegalDocumentLoader`

## Decisions Made

- **`consentProvider`, not `consentNotifierProvider`:** PLAN.md's action-block prose referenced `ref.read(consentNotifierProvider.notifier)`, but the actual codegen output (`consent_notifier.g.dart`) names the provider `consentProvider` — `@riverpod` strips the `Notifier` suffix from the class name, per the already-established `[Phase 06-05]` convention (`onboardingGateProvider`, not `onboardingGateNotifierProvider`). Used the real generated name.
- **`ref.watch(consentProvider)` added in `build()`:** Without an active watch subscription, Riverpod's autoDispose mechanism tears down `consentProvider`'s `Ref` as soon as the initial `ref.read(consentProvider.notifier)` call in `_onAccept` returns (before the notifier's internal `acceptConsent` awaits resolve), throwing `UnmountedRefException` mid-flight. This mirrors the `[Phase 04-09]` `mealEntryProvider` fix exactly — same root cause, same fix shape, applied here to `consentProvider`.
- **Widget test fakes `legalDocumentLoaderProvider`** rather than exercising the real `docs/legal/terms.md` asset read (which `[Phase 06-02]`'s `legal_document_loader_test.dart` already proves works standalone): a real `rootBundle.loadString` call made twice across separate `testWidgets` cases in the same test file hung indefinitely on the second invocation inside a `pumpAndSettle`-driven async chain. This is a test-infrastructure quirk unrelated to `LegalDocumentLoader`'s or `LegalConsentScreen`'s correctness; overriding the provider with a deterministic fake removes the flake and keeps the widget test properly isolated from asset I/O.

## Deviations from Plan

None beyond the two decisions above (both required to make the plan's own specified behavior test-green — not scope additions). No Rule 4 architectural changes were needed.

## Issues Encountered

**Test-order-dependent hang on the second real asset load.** Running the "5-element" and "4-element" `acceptConsent` tests back-to-back in the same file caused the second test's `rootBundle.loadString('docs/legal/terms.md')` call (via the real, un-mocked `legalDocumentLoaderProvider`) to hang forever inside `pumpAndSettle`, even though the identical call succeeded in the first test and in the pre-existing `legal_document_loader_test.dart`'s plain (non-widget) `test()` blocks. Diagnosed via targeted debug prints narrowing the stall to exactly that `await`. Resolved by overriding `legalDocumentLoaderProvider` with a fake in the widget test (see Decisions Made) rather than chasing the Flutter-test-framework-level root cause, since real asset-loading correctness is already covered elsewhere.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

`LegalConsentScreen` and `ConsentCheckboxTile` are built, tested, and ready to be wired into the router in Plan 06-09 (Wave 4: router/redirect/Settings integration) as the mandatory pre-Profile-Setup gate. The `/legal-hub/document?doc=...` route it pushes to does not exist yet — Plan 06-08 (Legal Hub) and/or 06-09 must register it before this screen is reachable end-to-end. `LEGAL-01/02/03/04`, `LEG-02`, `ACC-02/03/05`, and `NFR-01` are functionally complete but the screen itself remains unreachable from the app shell until 06-09 lands, matching the same "built but not yet routed" pattern already used for 06-04/05/06.

---
*Phase: 06-onboarding-legal-consent-legal-hub-ed-safety-nets-accessibility-pre-submission*
*Completed: 2026-08-04*

## Self-Check: PASSED

- FOUND: lib/features/legal/widgets/consent_checkbox_tile.dart
- FOUND: lib/features/legal/screens/legal_consent_screen.dart
- FOUND: test/features/legal/legal_consent_screen_test.dart
- FOUND: commit 2acc71f
