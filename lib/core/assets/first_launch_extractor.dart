import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Bumped whenever `assets/off_reference.sqlite.gz` is rebuilt with a new
/// schema or data version. Triggers re-extraction on existing installs so
/// devices never run queries against a stale bundled DB.
///
/// Convention: '{phase}-{ingest-tag}' — update when ingest_off.py output
/// changes the schema or replaces CO₂ data.
const _offRefVersion = '03-02-AGRIBALYSE-3.1.1';

/// Decompresses the bundled `assets/off_reference.sqlite.gz` asset to the
/// app documents directory, re-extracting if the bundled version changed.
///
/// T-02-03-02 mitigation: The output path is always derived from
/// getApplicationDocumentsDirectory; it is never constructed from user input.
///
/// Call this function from the app startup sequence (Plan 02-04 wires it into
/// `main()`) before AppDatabase initializes, so that the resolved path is
/// available when AppDatabase.connect is called.
///
/// If `assets/off_reference.sqlite.gz` has not yet been committed to the repo
/// (the OFF ingest pipeline has not been run), this function throws a
/// [StateError] with a developer-friendly message.
Future<String> ensureOffReferenceDb() async {
  final docsDir = await getApplicationDocumentsDirectory();
  final dbFile = File(p.join(docsDir.path, 'off_reference.sqlite'));
  final versionFile = File(p.join(docsDir.path, 'off_reference.version'));

  // Re-use existing file only when the on-disk version matches the bundled
  // version. Mismatched or absent version → delete and re-extract.
  if (dbFile.existsSync() && versionFile.existsSync()) {
    final onDiskVersion = versionFile.readAsStringSync().trim();
    if (onDiskVersion == _offRefVersion) return dbFile.path;
  }

  // Delete stale file before writing fresh bytes.
  if (dbFile.existsSync()) dbFile.deleteSync();

  // Load the compressed asset from the Flutter bundle.
  late final ByteData byteData;
  try {
    byteData = await rootBundle.load('assets/off_reference.sqlite.gz');
  } on Exception catch (e) {
    throw StateError(
      'assets/off_reference.sqlite.gz not found in Flutter bundle — '
      'run tools/ingest_off.py first and commit the output. '
      'See tools/README.md for instructions.\n'
      'Original error: $e',
    );
  }

  // Decompress using the archive package GZipDecoder (pure Dart, no FFI).
  final compressed = byteData.buffer.asUint8List();
  // archive 3.6.1's GZipDecoder has no explicit const constructor (unlike
  // 4.0.9's) — see pubspec.yaml's `archive` comment for why this project is
  // pinned to 3.6.1 (Plan 05-09's excel compatibility requirement).
  final decompressed = GZipDecoder().decodeBytes(compressed);

  // Write decompressed bytes, then stamp the version so future launches skip
  // re-extraction until _offRefVersion is bumped again.
  await dbFile.writeAsBytes(decompressed);
  await versionFile.writeAsString(_offRefVersion);

  return dbFile.path;
}
