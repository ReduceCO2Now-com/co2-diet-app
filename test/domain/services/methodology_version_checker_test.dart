import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'isStale',
    skip: 'Awaiting Plan 07-04 implementation',
    () {
      // TODO(Plan 07-04): a null snapshot version is never stale --
      // there is nothing to compare against.
      test('null snapshot is never stale', () {});

      // TODO(Plan 07-04): a snapshot equal to the current version is
      // not stale.
      test(
        'snapshot equal to the current version is not stale',
        () {},
      );

      // TODO(Plan 07-04): a snapshot older than the current version is
      // stale.
      test(
        'snapshot older than the current version is stale',
        () {},
      );
    },
  );

  group(
    'hasAnyStale',
    skip: 'Awaiting Plan 07-04 implementation',
    () {
      // TODO(Plan 07-04): false when profile/meal/food versions are
      // all null or current.
      test(
        'false when profile/meal/food versions are all null or '
        'current',
        () {},
      );

      // TODO(Plan 07-04): true when the profile version is stale.
      test(
        'true when the profile version is stale',
        () {},
      );

      // TODO(Plan 07-04): true when any meal-entry snapshot version is
      // stale.
      test(
        'true when any meal-entry snapshot version is stale',
        () {},
      );

      // TODO(Plan 07-04): true when any user-food version is stale.
      test(
        'true when any user-food version is stale',
        () {},
      );
    },
  );
}
