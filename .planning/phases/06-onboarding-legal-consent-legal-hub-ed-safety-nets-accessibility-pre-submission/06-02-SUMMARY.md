---
phase: 06-onboarding-legal-consent-legal-hub-ed-safety-nets-accessibility-pre-submission
plan: 02
subsystem: legal
tags: [flutter_markdown_plus, shared_preferences, package_info_plus, gdpr, legal-documents, frontmatter-parser]

# Dependency graph
requires:
  - phase: 06-01
    provides: Wave 0 test stub for legal_document_loader_test.dart (skip-marked placeholder)
provides:
  - Three new pubspec dependencies (flutter_markdown_plus, shared_preferences, package_info_plus), human-approved via blocking package-legitimacy checkpoint
  - Four complete, store-submittable legal documents (docs/legal/terms.md, privacy.md, health_disclaimer.md, impressum.md) with version: frontmatter
  - Hand-rolled parseLegalDocument() frontmatter scalar extractor (no yaml package dependency)
  - LegalDocumentLoader (asset read + frontmatter parse) and legalDocumentLoaderProvider
affects: [06-04, 06-05, 06-07, 06-08, 06-09]

# Tech tracking
tech-stack:
  added: [flutter_markdown_plus ^1.0.12, shared_preferences ^2.5.5, package_info_plus ^10.2.1]
  patterns: [hand-rolled frontmatter scalar parser (mirrors check_privacy_deps.dart precedent), stateless non-keepAlive @riverpod provider for cheap-to-reconstruct services]

key-files:
  created:
    - docs/legal/terms.md
    - docs/legal/privacy.md
    - docs/legal/health_disclaimer.md
    - docs/legal/impressum.md
    - lib/domain/services/legal_document_loader.dart
    - lib/core/di/legal_providers.dart
  modified:
    - pubspec.yaml
    - test/domain/services/legal_document_loader_test.dart

key-decisions:
  - "Package legitimacy checkpoint approved by user based on independent pub.dev signal review (160/160, 160/160, 150/160 scores; flutter.dev/foresightmobile.com/fluttercommunity.dev publishers; zero network calls) — pub.dev is not slopcheck-supported, so this followed the established human-approval precedent from Plans 04-11/05-08/05-09/05-16"
  - "All four legal documents drafted as complete, realistic, store-submittable text (never lorem/stub) with version: 2026-08-04 frontmatter — pending-legal-review flagged only via HTML comment + STATE.md tracked TODO, never a user-visible banner"
  - "Impressum entity/address/responsible-person rendered as honest, visible placeholder text (Legal Entity Name — pending confirmation, Address TBD, contact@reduceco2now.example — placeholder, Responsible Person — pending confirmation), not hidden or fabricated, per 06-CONTEXT.md's locked decision"
  - "Health Disclaimer uses diagnose/treat only inside the required Google Play Jan-2026 negation sentence (does not diagnose, treat, or prevent any condition); zero other claims-making instances; cure/medical-advice-as-claim never used"

patterns-established:
  - "Legal document markdown files live in docs/legal/ as the single source of truth, bundled via pubspec.yaml assets, rendered by flutter_markdown_plus, and version-tracked via frontmatter parsed by LegalDocumentLoader"

requirements-completed: [LEGAL-03, LEGAL-04, LEG-02, LEG-03]

# Metrics
duration: ~15min
completed: 2026-08-04
---

# Phase 6 Plan 02: Legal Documents + LegalDocumentLoader Summary

**Three new pubspec dependencies installed behind a human-approved package-legitimacy checkpoint, four complete GDPR/TMG-aware legal documents drafted as versioned markdown, and a hand-rolled frontmatter parser (LegalDocumentLoader) built to read them.**

## Performance

- **Duration:** ~15 min
- **Started:** 2026-08-04T08:58:00+02:00 (continuation from prior checkpoint approval)
- **Completed:** 2026-08-04T09:04:05+02:00
- **Tasks:** 2 (checkpoint + 2 auto tasks; 1 TDD task with RED/GREEN gates)
- **Files modified:** 11 (7 tracked in Task 1's commit, 8 in Task 2's commit, 1 overlapping test file)

## Accomplishments

- Installed `flutter_markdown_plus`, `shared_preferences`, `package_info_plus` after human approval of the blocking package-legitimacy checkpoint (pub.dev not slopcheck-supported)
- Drafted `docs/legal/terms.md`, `privacy.md`, `health_disclaimer.md`, `impressum.md` — complete, realistic, store-submittable text with `version: 2026-08-04` frontmatter on every file
- Built `parseLegalDocument()` (hand-rolled scalar frontmatter extractor, no `yaml` dependency) and `LegalDocumentLoader` (asset read + parse) via a full RED → GREEN TDD cycle
- Added `legalDocumentLoaderProvider` (non-keepAlive, stateless) to `lib/core/di/legal_providers.dart`

## Task Commits

Each task was committed atomically:

1. **Task 1: Draft the four legal documents** (includes `flutter pub add` install) - `07be6b7` (feat)
2. **Task 2 RED: failing LegalDocumentLoader test** - `917d138` (test)
3. **Task 2 GREEN: LegalDocumentLoader implementation** - `b11c954` (feat)

_TDD Gate Compliance: RED commit (`917d138`) precedes GREEN commit (`b11c954`); RED confirmed failing (compilation error: `Method not found: parseLegalDocument`/`LegalDocumentLoader`) before implementation began. No REFACTOR commit needed — implementation matched RESEARCH.md Pattern 3 verbatim on first pass._

**Plan metadata:** (this commit, immediately following)

## Files Created/Modified

- `docs/legal/terms.md` - Terms of Service (acceptance, service description, user responsibilities, no-warranty, governing law Germany, contact)
- `docs/legal/privacy.md` - GDPR Privacy Policy including the PITFALLS.md-C4-mandated OFF API network-call disclosure sentence and data-subject-rights mapping to existing Export Data/Danger Zone features
- `docs/legal/health_disclaimer.md` - Health Disclaimer with the Google Play Jan-2026 "not a medical device" sentence, BMR/TDEE framed as estimates, Germany-specific (BZgA/ANAD e.V.) + international (findahelpline.com) ED helpline resources
- `docs/legal/impressum.md` - TMG §5/MStV §18 disclosures with honest visible placeholder entity data, blocked-decision note tracked as a pre-launch blocker
- `lib/domain/services/legal_document_loader.dart` - `parseLegalDocument()` + `LegalDocumentLoader.load()`/`versionOf()`
- `lib/core/di/legal_providers.dart` - `legalDocumentLoaderProvider` (+ generated `.g.dart`)
- `pubspec.yaml` - three new dependencies with version-comment blocks matching project convention; `docs/legal/` added to `flutter: assets:`
- `test/domain/services/legal_document_loader_test.dart` - real behavior tests replacing Plan 06-01's skip-marked stub

## Decisions Made

- Package legitimacy checkpoint approved by user; independent pub.dev signal review (scores, publishers, zero network calls) accepted as sufficient per this project's established precedent for the unsupported pub.dev/Dart slopcheck ecosystem
- Impressum placeholders rendered literally and visibly rather than hidden, matching 06-CONTEXT.md's locked decision — real entity data remains a tracked pre-launch blocker (already documented in STATE.md's Pre-Launch Blockers section, not modified this plan)
- Health Disclaimer's only uses of "diagnose"/"treat" are inside the required Google Play negation sentence ("does not diagnose, treat, or prevent any condition") — verified via grep before commit, satisfying the must-have's "zero instances in a claims-making sense" bar

## Deviations from Plan

None - plan executed exactly as written. The only incidental side effect was `build_runner`'s riverpod_generator regenerating cache-buster hash comments (no logic changes) in five unrelated `*.g.dart` files as a byproduct of building the new `legal_providers.g.dart` — included in Task 2's commit since they are pure generated-code refresh, not functional changes.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- `LegalDocumentLoader`/`legalDocumentLoaderProvider` and all four versioned `docs/legal/*.md` documents are ready for Plan 06-04/06-07/06-08 (Legal Consent screen, Legal Hub, shared markdown document screen) to consume directly.
- Consent recording (LEGAL-03's `policyVersion`) can now read the real frontmatter version via `LegalDocumentLoader.versionOf('terms.md')` rather than a hardcoded string.
- `package_info_plus` and `shared_preferences` are installed and ready for Plan 06-05 (onboarding gate) and the consent repository's `appVersion` field.
- Pre-launch blockers remain unresolved by design (external legal review, Impressum real identity data) — already tracked in STATE.md, not modified by this plan.

---
*Phase: 06-onboarding-legal-consent-legal-hub-ed-safety-nets-accessibility-pre-submission*
*Completed: 2026-08-04*

## Self-Check: PASSED

All created files verified present on disk: docs/legal/terms.md, privacy.md, health_disclaimer.md, impressum.md, lib/domain/services/legal_document_loader.dart, lib/core/di/legal_providers.dart, lib/core/di/legal_providers.g.dart. All three commits (07be6b7, 917d138, b11c954) verified present in git log.
