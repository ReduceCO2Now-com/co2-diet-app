import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'ReferenceDataScreen',
    skip: 'Awaiting Plan 09-05 implementation',
    () {
      // TODO(Plan 09-05): shows a determinate progress bar with
      // percent and byte counts during an active download.
      testWidgets(
        'shows a determinate progress bar with percent and byte '
        'counts during an active download',
        (tester) async {},
      );

      // TODO(Plan 09-05): the Cancel button is visible only during an
      // active download and calls cancelDownload() when tapped.
      testWidgets(
        'the Cancel button is visible only during an active download '
        'and calls cancelDownload() when tapped',
        (tester) async {},
      );

      // TODO(Plan 09-05): shows the product-count comparison (starter
      // pack vs full catalog) using concrete numbers, not vague
      // language.
      testWidgets(
        'shows the product-count comparison (starter pack vs full '
        'catalog) using concrete numbers, not vague language',
        (tester) async {},
      );

      // TODO(Plan 09-05): tapping Download with insufficient disk
      // space shows the blocking 'Not enough storage' message and
      // never starts a download.
      testWidgets(
        'tapping Download with insufficient disk space shows the '
        "blocking 'Not enough storage' message and never starts a "
        'download',
        (tester) async {},
      );

      // TODO(Plan 09-05): tapping Download while off Wi-Fi shows the
      // 'download over cellular anyway?' prompt before starting, and
      // starting requires an explicit confirmation.
      testWidgets(
        'tapping Download while off Wi-Fi shows the "download over '
        'cellular anyway?" prompt before starting, and starting '
        'requires an explicit confirmation',
        (tester) async {},
      );

      // TODO(Plan 09-05): the Revert action is disabled while a
      // download is actively in progress.
      testWidgets(
        'the Revert action is disabled while a download is actively '
        'in progress',
        (tester) async {},
      );

      // TODO(Plan 09-05): the Revert action shows a confirmation
      // dialog with the exact locked copy from CONTEXT.md; confirming
      // calls revertToSeed() and cancelling does not.
      testWidgets(
        'the Revert action shows a confirmation dialog with the exact '
        'locked copy from CONTEXT.md; confirming calls revertToSeed() '
        'and cancelling does not',
        (tester) async {},
      );
    },
  );
}
