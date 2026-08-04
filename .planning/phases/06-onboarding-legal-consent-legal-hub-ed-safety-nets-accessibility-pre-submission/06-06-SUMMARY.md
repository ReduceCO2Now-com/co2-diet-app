---
phase: 06-onboarding-legal-consent-legal-hub-ed-safety-nets-accessibility-pre-submission
plan: 06
subsystem: infra
tags: [ios-privacy-manifest, play-console, data-safety, age-rating, pre-submission]

# Dependency graph
requires:
  - phase: 06-02
    provides: docs/legal/health_disclaimer.md ("not a medical device" disclaimer sentence)
provides:
  - ios/Runner/PrivacyInfo.xcprivacy — real Apple Privacy Manifest build artifact
  - docs/PLAY_DATA_SAFETY_DRAFT.md — drafted Play Console Data Safety + age rating answers
affects: [pre-submission, app-store-connect, play-console]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Privacy manifest / store-metadata drafts live as real reviewable files (not placeholders), flagged inline with confidence level and re-verification instructions for the real submission owner"

key-files:
  created:
    - ios/Runner/PrivacyInfo.xcprivacy
    - docs/PLAY_DATA_SAFETY_DRAFT.md
  modified: []

key-decisions:
  - "PrivacyInfo.xcprivacy declares only NSPrivacyAccessedAPICategoryFileTimestamp (C617.1) for statically-linked SQLite FFI — does not redeclare UserDefaults, already covered by shared_preferences_foundation's own manifest"
  - "Play Data Safety draft discloses Open Food Facts API queries as third-party data sharing even in Local Mode, since network requests to OFF count as 'sharing' regardless of backend account state"
  - "Age rating targets 16+ / 'Frequent Medical/Treatment Information' descriptor per 06-CONTEXT.md's locked MyFitnessPal-precedent decision, not a generic 'health app = Everyone' assumption"

patterns-established:
  - "Pre-submission draft docs: structured to mirror the real console form section-by-section for direct copy-in, with an explicit confidence rating (MEDIUM/HIGH) and re-verification instruction attached to any claim sourced from a secondary source rather than the platform's own docs"

requirements-completed: [LEG-01]

# Metrics
duration: ~5min
completed: 2026-08-04
---

# Phase 06 Plan 06: Pre-Submission Artifacts (Privacy Manifest + Play Data Safety Draft) Summary

**Real iOS Privacy Manifest declaring zero tracking/collection plus a File Timestamp required-reason entry for statically-linked SQLite, and a drafted Play Console Data Safety/age-rating answer set disclosing Open Food Facts as third-party data sharing.**

## Performance

- **Duration:** ~5 min
- **Started:** 2026-08-04T07:39:20Z
- **Completed:** 2026-08-04T07:43:55Z
- **Tasks:** 2 completed
- **Files modified:** 2 (both new)

## Accomplishments
- `ios/Runner/PrivacyInfo.xcprivacy` created as a real, plutil-valid Apple Privacy Manifest: `NSPrivacyTracking=false`, empty `NSPrivacyTrackingDomains`/`NSPrivacyCollectedDataTypes` arrays (matches PRIV-07's "no data collected" story), plus one `NSPrivacyAccessedAPICategoryFileTimestamp` entry with reason `C617.1` for SQLite's internal `fstat`/`stat` calls (statically FFI-linked into the main binary via drift, not a separate pod).
- `docs/PLAY_DATA_SAFETY_DRAFT.md` created with all four required sections: Data Safety form answers (Local Mode data-stays-on-device story + OFF API third-party sharing disclosure + encryption-in-transit + Danger Zone deletion), age rating questionnaire draft (16+, Frequent Medical/Treatment Information descriptor, not-directed-at-children), the "not a medical device" disclaimer placement note for the Play Store listing description, and open questions (Privacy Policy public-URL hosting gap, external legal review) carried forward as explicit pre-submission blockers.
- Both files include inline confidence flags (MEDIUM where sourced from secondary research rather than Apple/Google's own docs) and explicit instructions for the real submission owner to re-verify before copying into the live consoles.

## Task Commits

Each task was committed atomically:

1. **Task 1: PrivacyInfo.xcprivacy** - `dfc740e` (feat)
2. **Task 2: Play Data Safety and age rating draft doc** - `3d4e6cb` (docs)

**Plan metadata:** (this commit)

## Files Created/Modified
- `ios/Runner/PrivacyInfo.xcprivacy` - Apple Privacy Manifest: no tracking, no collection, File Timestamp required-reason API declaration for SQLite FFI, with inline confidence/re-verification comments
- `docs/PLAY_DATA_SAFETY_DRAFT.md` - Drafted Play Console Data Safety form + age rating questionnaire answers, structured for direct copy-in at real submission time

## Decisions Made
- `NSPrivacyAccessedAPICategoryFileTimestamp` (C617.1) is the one required-reason API declared — verified this is attributable to the main app binary since sqlite3 is FFI-linked directly, not via a separate pod with its own manifest (06-RESEARCH.md Pitfall 3).
- `NSPrivacyAccessedAPICategoryUserDefaults` deliberately NOT redeclared — `shared_preferences_foundation` already ships its own manifest for that category (verified against `github.com/flutter/packages` in the research session).
- Play Data Safety draft answers "third-party data sharing: YES" specifically because of Open Food Facts API queries, even though the app has no backend account contact in Local Mode — network requests to any third-party API count as "sharing" for this form regardless of account state (PITFALLS.md item C4).
- Age rating drafted as 16+ with "Frequent/Intense Medical/Treatment Information" descriptor, per the locked `06-CONTEXT.md` decision (MyFitnessPal precedent), not a default "Everyone" health-app assumption.

## Deviations from Plan

None - plan executed exactly as written. Both tasks completed with no auto-fixes, blocking issues, or architectural questions.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required. Both artifacts are drafted/reviewable files for a human owner to manually copy into App Store Connect / Play Console at real submission time (explicitly out of this phase's reach per `06-CONTEXT.md`).

## Next Phase Readiness

- Wave 2 of Phase 6 is now fully complete: 06-04 (consent domain), 06-05 (onboarding gate + splash/welcome/carousel screens), and 06-06 (privacy manifests) all delivered.
- Both pre-submission artifacts are real, reviewable, non-placeholder outputs ready for manual copy-in — matching this plan's success criteria.
- Two carried-forward pre-submission blockers remain open for the eventual submission owner (not blockers to Phase 6 completion): (1) Privacy Policy public URL hosting location is undecided — no public website exists in this codebase-only project; (2) both `PrivacyInfo.xcprivacy`'s API declarations and the Play Data Safety draft need re-verification against Xcode's own Privacy Report and Play Console's own Health Content policy page, respectively, before real submission — both flagged inline as MEDIUM confidence.
- Ready to proceed to Wave 3 (06-07/06-08: Legal Consent screen, Legal Hub + Consent History).

---
*Phase: 06-onboarding-legal-consent-legal-hub-ed-safety-nets-accessibility-pre-submission*
*Completed: 2026-08-04*

## Self-Check: PASSED

- FOUND: ios/Runner/PrivacyInfo.xcprivacy
- FOUND: docs/PLAY_DATA_SAFETY_DRAFT.md
- FOUND: dfc740e (Task 1 commit)
- FOUND: 3d4e6cb (Task 2 commit)
