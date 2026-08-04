import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'ConsentHistoryScreen',
    skip: 'Awaiting Plan 06-08 implementation',
    () {
      // TODO(Plan 06-08): renders one row per ConsentEvent (PRIV-06
      // consent-history read path).
      testWidgets(
        'renders one row per ConsentEvent',
        (tester) async {},
      );

      // TODO(Plan 06-08): empty state renders when no consent has
      // ever been recorded.
      testWidgets(
        'shows an empty state when no consent has been recorded yet',
        (tester) async {},
      );
    },
  );
}
