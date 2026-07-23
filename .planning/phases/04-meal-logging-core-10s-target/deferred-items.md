# Deferred Items — Phase 04

Out-of-scope issues discovered during plan execution but not fixed
(scope boundary: only auto-fix issues directly caused by the current
task's changes).

## From Plan 04-04

- `lib/data/local/daos/food_catalog_dao.dart` has 5 pre-existing
  `flutter analyze` info-level lints (1 `comment_references`, 4
  `lines_longer_than_80_chars`) predating this plan. Not touched by
  Plan 04-04 — file was only read for precedent, never modified.
