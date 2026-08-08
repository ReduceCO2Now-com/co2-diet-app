import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'Co2MethodologyBanner',
    skip: 'Awaiting Plan 07-07 implementation',
    () {
      // TODO(Plan 07-07): renders nothing when no stale entries exist.
      testWidgets(
        'renders nothing when no stale entries exist',
        (tester) async {},
      );

      // TODO(Plan 07-07): renders the banner with the interpolated
      // methodology version when stale entries exist and the version
      // was never dismissed.
      testWidgets(
        'renders the banner with the interpolated methodology version '
        'when stale entries exist and the version was never dismissed',
        (tester) async {},
      );

      // TODO(Plan 07-07): dismissing the banner persists a per-version
      // flag so it does not reappear for the same version.
      testWidgets(
        'dismissing the banner persists a per-version flag so it '
        'does not reappear for the same version',
        (tester) async {},
      );

      // TODO(Plan 07-07): a newer stale version reappears even after a
      // prior version was dismissed.
      testWidgets(
        'a newer stale version reappears even after a prior version '
        'was dismissed',
        (tester) async {},
      );

      // TODO(Plan 07-07): tapping Learn more navigates to
      // /data-analysis.
      testWidgets(
        'tapping Learn more navigates to /data-analysis',
        (tester) async {},
      );
    },
  );
}
