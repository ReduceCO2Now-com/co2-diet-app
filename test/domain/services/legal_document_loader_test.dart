import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'LegalDocumentLoader',
    skip: 'Awaiting Plan 06-02 implementation',
    () {
      // TODO(Plan 06-02): well-formed frontmatter `version:` line is
      // extracted correctly.
      test(
        'extracts the version from a well-formed frontmatter '
        '`version:` line',
        () {},
      );

      // TODO(Plan 06-02): missing frontmatter block entirely is
      // handled without throwing.
      test(
        'returns null (not a throw) when frontmatter is missing '
        'entirely',
        () {},
      );

      // TODO(Plan 06-02): malformed or empty version line is handled
      // without throwing.
      test(
        'returns null (not a throw) when the version line is '
        'malformed or empty',
        () {},
      );
    },
  );
}
