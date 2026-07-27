import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'BackupExportService',
    skip: 'BackupExportService not yet implemented',
    () {
      test(
        'exportData produces a zip containing manifest.json plus one '
        'file per selected category/format',
        () {},
      );

      test(
        'manifest.json includes a formatVersion field alongside the '
        'per-file category/format/row-count entries',
        () {},
      );

      test(
        'previewRestore rejects a manifest.json with an unrecognized '
        'formatVersion before any write',
        () {},
      );

      test(
        'restore preview lists what would change before any write '
        'occurs',
        () {},
      );

      test(
        'restore rejects a zip entry whose normalized path escapes '
        'the target extraction directory (zip-slip)',
        () {},
      );

      test(
        'createBackup writes to the app documents directory; '
        'automatic backup frequency off/daily/weekly is honored',
        () {},
      );
    },
  );
}
