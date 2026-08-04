// Legal document loader: reads bundled docs/legal/*.md assets and extracts
// their frontmatter `version:` field.
//
// Hand-rolled scalar-extraction parser (no `yaml` package) mirrors this
// project's existing check_privacy_deps.dart precedent (Plan 01-06) — only
// one frontmatter key (`version`) needs extracting, so a full YAML parser
// dependency is not justified.

import 'package:flutter/services.dart' show rootBundle;

/// Extracts the `version:` value from a markdown document's frontmatter
/// block (`---\n...\n---\n`) and returns the version alongside the body
/// with the frontmatter stripped.
///
/// Returns `version: 'unknown'` (and the raw input unchanged as `body`)
/// when:
/// - [raw] does not start with a frontmatter marker (`---`), or
/// - the frontmatter block is unterminated (no closing `\n---`).
///
/// Returns `version: 'unknown'` with the frontmatter still stripped from
/// `body` when the frontmatter block exists but has no `version:` line.
({String version, String body}) parseLegalDocument(String raw) {
  if (!raw.startsWith('---')) {
    return (version: 'unknown', body: raw);
  }

  final endIndex = raw.indexOf('\n---', 3);
  if (endIndex == -1) {
    return (version: 'unknown', body: raw);
  }

  final frontmatter = raw.substring(3, endIndex);
  final versionLine = frontmatter
      .split('\n')
      .firstWhere((l) => l.trim().startsWith('version:'), orElse: () => '');
  final version = versionLine.split(':').skip(1).join(':').trim();
  final body = raw.substring(endIndex + 4).trimLeft();

  return (version: version.isEmpty ? 'unknown' : version, body: body);
}

/// Loads legal documents bundled under `docs/legal/` as app assets.
class LegalDocumentLoader {
  /// Creates a stateless [LegalDocumentLoader].
  const LegalDocumentLoader();

  /// Loads and parses the frontmatter-versioned markdown document at
  /// `docs/legal/$assetFileName`.
  Future<({String version, String body})> load(String assetFileName) async {
    final raw = await rootBundle.loadString('docs/legal/$assetFileName');
    return parseLegalDocument(raw);
  }

  /// Returns just the `version:` frontmatter field of the given document.
  Future<String> versionOf(String assetFileName) async {
    return (await load(assetFileName)).version;
  }
}
