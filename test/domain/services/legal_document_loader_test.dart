import 'package:co2diet/domain/services/legal_document_loader.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseLegalDocument', () {
    test(
      'extracts the version and strips frontmatter from well-formed input',
      () {
        const raw = '---\nversion: 2026-08-04\n---\nBody text';
        final result = parseLegalDocument(raw);
        expect(result.version, '2026-08-04');
        expect(result.body, 'Body text');
      },
    );

    test(
      'returns version unknown and the raw input unchanged when there is '
      'no leading frontmatter marker',
      () {
        const raw = 'Just a plain document with no frontmatter at all.';
        final result = parseLegalDocument(raw);
        expect(result.version, 'unknown');
        expect(result.body, raw);
      },
    );

    test(
      'returns version unknown and the raw input unchanged when the '
      'frontmatter block is unterminated',
      () {
        const raw = '---\nversion: 2026-08-04\nBody text with no closing '
            'marker';
        final result = parseLegalDocument(raw);
        expect(result.version, 'unknown');
        expect(result.body, raw);
      },
    );

    test(
      'returns version unknown but a stripped body when the frontmatter '
      'block is present but has no version: line',
      () {
        const raw = '---\nname: Some Doc\n---\nBody text';
        final result = parseLegalDocument(raw);
        expect(result.version, 'unknown');
        expect(result.body, 'Body text');
      },
    );
  });

  group('LegalDocumentLoader', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    const loader = LegalDocumentLoader();

    test('load() returns the real version/body from docs/legal/terms.md', () async {
      final result = await loader.load('terms.md');
      expect(result.version, '2026-08-04');
      expect(result.body, isNotEmpty);
      expect(result.body, contains('Terms of Service'));
    });

    test('versionOf() returns just the version string', () async {
      final version = await loader.versionOf('terms.md');
      expect(version, '2026-08-04');
    });
  });
}
