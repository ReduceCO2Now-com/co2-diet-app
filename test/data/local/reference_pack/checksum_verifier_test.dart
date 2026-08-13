import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'ChecksumVerifier',
    skip: 'Awaiting Plan 09-02 implementation',
    () {
      // TODO(Plan 09-02): verify returns true when the file's SHA-256
      // matches the expected hex digest.
      test(
        "verify returns true when the file's SHA-256 matches the "
        'expected hex digest',
        () {},
      );

      // TODO(Plan 09-02): verify returns false when the file's SHA-256
      // does not match.
      test(
        "verify returns false when the file's SHA-256 does not match",
        () {},
      );

      // TODO(Plan 09-02): verify returns false (does not throw) when
      // the target file does not exist.
      test(
        'verify returns false (does not throw) when the target file '
        'does not exist',
        () {},
      );
    },
  );
}
