import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'ReferenceDataRow',
    skip: 'Awaiting Plan 09-05 implementation',
    () {
      // TODO(Plan 09-05): shows 'Using starter pack' subtitle in the
      // seed state.
      testWidgets(
        "shows 'Using starter pack' subtitle in the seed state",
        (tester) async {},
      );

      // TODO(Plan 09-05): shows a 'Downloading… X/Y MB' subtitle with
      // live byte progress in the downloading state.
      testWidgets(
        "shows a 'Downloading… X/Y MB' subtitle with live byte "
        'progress in the downloading state',
        (tester) async {},
      );

      // TODO(Plan 09-05): shows a 'Full catalog installed — N MB'
      // subtitle in the full state.
      testWidgets(
        "shows a 'Full catalog installed — N MB' subtitle in the full "
        'state',
        (tester) async {},
      );

      // TODO(Plan 09-05): shows an 'Update available — connect to
      // Wi-Fi' subtitle when an update is known but the device is off
      // Wi-Fi.
      testWidgets(
        "shows an 'Update available — connect to Wi-Fi' subtitle when "
        'an update is known but the device is off Wi-Fi',
        (tester) async {},
      );

      // TODO(Plan 09-05): tapping the row navigates to
      // /reference-data.
      testWidgets(
        'tapping the row navigates to /reference-data',
        (tester) async {},
      );
    },
  );
}
