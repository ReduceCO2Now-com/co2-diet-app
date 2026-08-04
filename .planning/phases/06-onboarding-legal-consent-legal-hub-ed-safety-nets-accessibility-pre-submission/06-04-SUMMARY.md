---
phase: 06-onboarding-legal-consent-legal-hub-ed-safety-nets-accessibility-pre-submission
plan: 04
subsystem: legal
tags: [drift, riverpod, package_info_plus, flutter_markdown_plus, consent, uuid-v7]

# Dependency graph
requires:
  - phase: 06-02
    provides: "legalDocumentLoaderProvider + LegalDocumentLoader.versionOf('terms.md') for policy version extraction; docs/legal/*.md assets"
  - phase: 01
    provides: "ConsentRecordsDao + ConsentRecordsTable (append-only, no update/delete methods) — built but unused until this plan"
provides:
  - "IConsentRepository / DriftConsentRepository real write path turning Phase 1's ConsentRecordsDao into a callable consent-recording flow"
  - "ConsentNotifier.acceptConsent(consentsGiven) — single call site for durably recording a fully-versioned consent event"
  - "LegalDocumentScreen + LegalDocId enum — shared full-document markdown screen for any of the 4 docs/legal/*.md files"
affects: [06-07-legal-consent-screen, 06-08-legal-hub-consent-history]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "DriftConsentRepository mirrors Co2SettingsRepository's structure (const constructor, static const _uuid, Drift/SQLite imports confined to the repository file)"
    - "ConsentNotifier is a pure write-composition @riverpod class (empty FutureOr<void> build()) — mirrors FavoriteNotifier's cross-provider composition style, composing appVersionProvider + legalDocumentLoaderProvider + consentRepositoryProvider"
    - "LegalDocumentScreen uses FutureBuilder + ref.watch(legalDocumentLoaderProvider).load(assetFileName) to render Markdown(data: body), matching WeightScreen/MethodologyScreen's Scaffold(backgroundColor: AppColors.surface) convention"

key-files:
  created:
    - lib/domain/entities/consent_event.dart
    - lib/domain/repositories/i_consent_repository.dart
    - lib/data/repositories/consent_repository.dart
    - lib/features/legal/providers/consent_notifier.dart
    - lib/features/legal/screens/legal_document_screen.dart
  modified:
    - lib/core/di/legal_providers.dart
    - test/data/repositories/consent_repository_test.dart

key-decisions:
  - "policyVersion for the whole consent event is always terms.md's frontmatter version — all 4 legal documents are drafted/versioned together as one dated bundle"
  - "ConsentEvent named distinctly from Drift's generated ConsentRecord class to avoid collision, following MealEntry.fromRow's precedent of importing the row type from app_database.dart"

patterns-established:
  - "Consent domain layer: entity + interface + Drift-backed repository + keepAlive DI providers, directly mirroring Phase 5's Co2SettingsRepository shape"

requirements-completed: [LEGAL-03, LEGAL-04, LEG-02]

# Metrics
duration: ~5min
completed: 2026-08-04
---

# Phase 6 Plan 04: Consent domain layer + shared Legal Document screen Summary

**DriftConsentRepository turns Phase 1's unused ConsentRecordsDao into a real write path; ConsentNotifier.acceptConsent composes package_info_plus + LegalDocumentLoader.versionOf('terms.md') + the repository into one durable, fully-versioned consent write; LegalDocumentScreen renders any of the 4 docs/legal/*.md files via flutter_markdown_plus for reuse by both the Legal Consent screen and Legal Hub.**

## Performance

- **Duration:** ~5 min
- **Tasks:** 2
- **Files modified:** 8 (6 created, 2 modified — counting generated `.g.dart` files)

## Accomplishments
- `IConsentRepository`/`DriftConsentRepository` — real, callable write path backed by `ConsentRecordsDao`, with UUID v7 ids and JSON-encoded `consentsGiven`
- `ConsentEvent` domain entity + `.fromRow` factory, correctly round-tripping through Drift's `ConsentRecord` row and JSON-decoded `consentsGiven`
- `ConsentNotifier.acceptConsent` — a single call site any onboarding screen can invoke to durably record consent with the real app version and real policy version
- `LegalDocumentScreen` + `LegalDocId` enum — shared, ready-to-consume full-document screen for Plans 06-07 and 06-08
- `consent_repository_test.dart` de-skipped and green with 4 real tests, zero skips

## Task Commits

Each task was committed atomically:

1. **Task 1: Consent domain layer (entity, interface, repository, DI)** - `fb1cf97` (feat, tdd)
2. **Task 2: ConsentNotifier + shared LegalDocumentScreen** - `ce32967` (feat)

## Files Created/Modified
- `lib/domain/entities/consent_event.dart` - `ConsentEvent` domain entity + `.fromRow(ConsentRecord)` factory
- `lib/domain/repositories/i_consent_repository.dart` - `IConsentRepository` abstract interface (`recordConsent`, `watchConsents`)
- `lib/data/repositories/consent_repository.dart` - `DriftConsentRepository`, backed by `ConsentRecordsDao`
- `lib/core/di/legal_providers.dart` - added `consentRecordsDaoProvider`, `consentRepositoryProvider`, `appVersionProvider` (keepAlive DAO/repository, non-keepAlive version fetch)
- `lib/features/legal/providers/consent_notifier.dart` - `ConsentNotifier.acceptConsent` cross-provider write composition
- `lib/features/legal/screens/legal_document_screen.dart` - `LegalDocumentScreen` + `LegalDocId` enum, `flutter_markdown_plus` rendering
- `test/data/repositories/consent_repository_test.dart` - de-skipped, 4 real tests (mocktail, mirrors `co2_settings_repository_test.dart`)

## Decisions Made
- `policyVersion` for every consent event is always `terms.md`'s frontmatter version (documented inline in `ConsentNotifier`), since all four legal documents are drafted/versioned together as one dated bundle — not a per-document policy version.
- `ConsentEvent` deliberately named distinct from Drift's `@DataClassName('ConsentRecord')`-generated class, importing the row type from `app_database.dart` (never `package:drift/drift.dart` directly), matching the `MealEntry.fromRow` precedent from Phase 4.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None. `flutter analyze` flagged two redundant-argument-value infos during development (a default-matching `id:` value in the test file, a default-matching `padding:` value on `Markdown`) — both removed before commit; not deviations, just lint cleanup within the same task.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Plan 06-07 (Legal Consent screen) can call `ConsentNotifier.acceptConsent(consentsGiven: [...])` directly and reuse `LegalDocumentScreen(docId: LegalDocId.terms/privacy/healthDisclaimer/impressum)` for "View full document" links.
- Plan 06-08 (Legal Hub + Consent History) can watch `consentRepositoryProvider.watchConsents()` for the consent history list and reuse the same `LegalDocumentScreen` for on-demand document viewing.
- No blockers.

---
*Phase: 06-onboarding-legal-consent-legal-hub-ed-safety-nets-accessibility-pre-submission*
*Completed: 2026-08-04*

## Self-Check: PASSED

All 8 created/modified files verified present on disk; both task commits (`fb1cf97`, `ce32967`) verified present in git history.
