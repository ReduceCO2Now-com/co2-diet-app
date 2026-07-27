import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'BackupRestoreScreen',
    skip: 'BackupRestoreScreen not yet implemented',
    () {
      testWidgets(
        'Danger Zone delete button stays disabled until the exact '
        'word DELETE is typed',
        (tester) async {},
      );

      testWidgets(
        'Restore Data opens a real OS file picker and can import a '
        "backup zip from outside the app's own documents directory",
        (tester) async {},
      );

      testWidgets(
        'Restore requires an explicit confirmation step after '
        'showing the preview',
        (tester) async {},
      );

      testWidgets(
        'Privacy & Ownership statement discloses that shared '
        'backups are not encrypted by the app',
        (tester) async {},
      );
    },
  );
}
