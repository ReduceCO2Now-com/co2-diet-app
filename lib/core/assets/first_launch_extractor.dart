import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Decompresses the bundled `assets/off_reference.sqlite.gz` asset to the
/// app documents directory on first launch.
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

  // Idempotent: skip extraction if the decompressed file already exists.
  if (dbFile.existsSync()) return dbFile.path;

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
  final decompressed = const GZipDecoder().decodeBytes(compressed);

  // Write decompressed bytes to the app documents directory.
  await dbFile.writeAsBytes(decompressed);

  return dbFile.path;
}
