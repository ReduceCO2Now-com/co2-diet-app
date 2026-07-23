import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'MealEntryDao',
    skip: 'MealEntryDao not yet implemented',
    () {
      test(
        'insert creates a new row with correct logDate computed from '
        'loggedAt',
        () {},
      );

      test(
        'logging same foodRef+slot+day+unit merges into existing row '
        '(adds quantity)',
        () {},
      );

      test(
        'logging same foodRef+slot+day with different unit creates a '
        'separate row',
        () {},
      );

      test(
        'getRecent returns individually logged items deduped by foodRef, '
        'most-recent-first, capped at 15',
        () {},
      );

      test(
        're-logging an item already in Recent moves it to the top instead '
        'of duplicating',
        () {},
      );

      test(
        'softDelete sets deletedAt tombstone; row excluded from '
        'getEntriesForToday',
        () {},
      );

      test(
        'toggleFavorite inserts a favorite row; toggling again removes it',
        () {},
      );

      test(
        'getFavorites returns favorited foods with lastQuantity/lastUnit '
        'for one-tap reuse',
        () {},
      );
    },
  );
}
