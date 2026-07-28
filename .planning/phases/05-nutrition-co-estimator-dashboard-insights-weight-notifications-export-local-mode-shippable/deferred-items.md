# Deferred Items — Phase 05

Items discovered during plan execution that are out of scope for the
discovering plan's task (per the Scope Boundary rule: only auto-fix issues
directly caused by the current task's changes) and therefore deferred
rather than fixed inline.

## From Plan 05-19

**24 pre-existing `flutter analyze lib/` info-level lint issues**, confirmed
present at commit `36218e7` (the last commit of Plan 05-18, before 05-19
started) and unrelated to any file 05-19 touched:

- `comment_references` (name not visible in scope inside a doc comment) in:
  `lib/core/di/app_providers.dart:23`, `lib/data/local/daos/food_catalog_dao.dart`
  (lines 292, 396, 526), `lib/data/local/tables/favorite_table.dart:12`,
  `lib/domain/entities/food_item.dart` (lines 100, 101, 102, 110, 119, 128),
  `lib/domain/repositories/i_food_catalog_repository.dart:38`,
  `lib/features/barcode_scan/screens/methodology_screen.dart:10`,
  `lib/features/barcode_scan/widgets/confidence_chip.dart:90`
- `lines_longer_than_80_chars` in: `lib/data/remote/off_api_client.dart:112`,
  `lib/domain/repositories/i_food_catalog_repository.dart:36`,
  `lib/features/barcode_scan/screens/methodology_screen.dart` (lines 47, 70),
  `lib/features/barcode_scan/widgets/confidence_chip.dart` (lines 7, 15, 37, 90)
- `prefer_initializing_formals` in `lib/data/local/daos/food_catalog_dao.dart:43`
- `avoid_positional_boolean_parameters` in
  `lib/features/notifications/providers/notification_prefs_notifier.dart:49`

All 24 are `info` severity (not `warning`/`error`) and span Phases 2-5 code
that 05-19's own tasks never modified. Plan 05-19's own verification block
asks for "zero analyzer issues project-wide," but per this executor's Scope
Boundary rule, pre-existing issues in unrelated files are out of scope for
a single plan's fix — flagged here for a future cleanup pass (e.g. a
dedicated lint-debt plan) rather than fixed opportunistically mid-plan.

Two *new* issues 05-19 itself introduced (one `lines_longer_than_80_chars`
in `metric_card.dart`, one `avoid_types_on_closure_parameters` in
`detailed_food_analysis_panel.dart`) were fixed inline before committing —
not deferred.
