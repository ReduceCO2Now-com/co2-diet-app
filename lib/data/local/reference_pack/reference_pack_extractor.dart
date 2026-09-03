import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:co2diet/core/assets/first_launch_extractor.dart'
    show offReferenceVersionMarkerFilename;
import 'package:co2diet/data/local/app_database.dart';
import 'package:co2diet/data/local/reference_pack/reference_pack_version_store.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Decompresses the gzip file at [paths]'s first path to its second path.
///
/// A top-level function (not a method) so [compute] can run it on a
/// background isolate: `GZipDecoder.decodeStream` (`archive` 3.6.1) is a
/// synchronous, `void`-returning call with no yield points of its own, so
/// running it on the main isolate blocks the Flutter UI thread for the
/// call's entire duration -- confirmed on a real device to ANR
/// ("Input dispatching timed out", ~13s unresponsive) decompressing even
/// this plan's ~40MB-compressed/~123MB-decompressed smoketest fixture; a
/// real 300-800MB pack (per `ChecksumVerifier`'s doc comment) would be far
/// worse (T-09-08-diagnostic).
Future<void> _decompressGzipFile(
  (String inputPath, String outputPath) paths,
) async {
  final input = InputFileStream(paths.$1);
  final output = OutputFileStream(paths.$2);
  try {
    GZipDecoder().decodeStream(input, output);
  } finally {
    await input.close();
    await output.close();
  }
}

/// Resolves the app documents directory's absolute path.
///
/// Signature of the real `getApplicationDocumentsDirectory().path` call,
/// injected so tests never touch the real platform channel -- mirrors this
/// project's established seam-injection convention for platform-channel-
/// backed values (see `DiskSpaceChecker.FreeBytesQuery`, Plan 09-02).
typedef DocumentsDirectoryPath = Future<String> Function();

Future<String> _defaultDocumentsDirectoryPath() async {
  final dir = await getApplicationDocumentsDirectory();
  return dir.path;
}

/// Performs the live DETACH/decompress/replace-file/ATTACH swap that
/// installs a verified, downloaded full reference pack in place of whatever
/// is currently ATTACHed under the `off_ref` alias -- and the reverse
/// operation, reverting to the bundled starter seed.
///
/// Extends `first_launch_extractor.dart`'s startup-only atomic-swap pattern
/// to a live, already-open [AppDatabase] connection (`09-RESEARCH.md`
/// Pattern 3) -- this app's first in-place ATTACH/DETACH cycle that runs
/// while the app is already running, not just once at startup.
///
/// **Caller responsibility (`09-RESEARCH.md` Pitfall 2):** [swapIn] and
/// [revertToSeed] must never run while an in-flight `FoodCatalogDao` query
/// is active against `off_ref`, and must never be called concurrently with
/// each other or with themselves. Serializing calls to this class is the
/// caller's (Plan 09-04's repository) responsibility -- this class performs
/// no internal locking of its own.
///
/// T-09-03-02 (accepted, deferred): both methods trust their input file by
/// design -- checksum verification against the manifest's published
/// `pack_sha256` happens in the calling repository (Plan 09-04) *before*
/// either method is ever invoked.
class ReferencePackExtractor {
  /// Creates a [ReferencePackExtractor].
  ///
  /// [versionStore] defaults to a real [ReferencePackVersionStore].
  /// [documentsDirectoryPath] defaults to the real `path_provider` call;
  /// tests inject a fake pointing at a temp directory.
  ReferencePackExtractor({
    ReferencePackVersionStore? versionStore,
    DocumentsDirectoryPath? documentsDirectoryPath,
  }) : _versionStore = versionStore ?? const ReferencePackVersionStore(),
       _documentsDirectoryPath =
           documentsDirectoryPath ?? _defaultDocumentsDirectoryPath;

  final ReferencePackVersionStore _versionStore;
  final DocumentsDirectoryPath _documentsDirectoryPath;

  static const _installedFileName = 'off_reference.sqlite';

  Future<String> _installedPath() async =>
      p.join(await _documentsDirectoryPath(), _installedFileName);

  /// Swaps the currently-ATTACHed `off_ref` database for [downloadedGzFile]
  /// -- the checksum-verified, still-gzip-compressed download exactly as
  /// `DownloadManager` saved it to disk (mirrors
  /// `tools/build_reference_pack_release.py`'s
  /// `full_v<version>.sqlite.gz` artifact, the same compression convention
  /// `tools/ingest_off.py` already uses for the bundled seed).
  ///
  /// Runs, in order:
  /// 1. `DETACH DATABASE off_ref`
  /// 2. Streams-decompresses [downloadedGzFile] via [_decompressGzipFile]
  ///    on a background isolate ([compute]) -- [GZipDecoder.decodeStream]
  ///    is synchronous with no yield points, so running it on the calling
  ///    isolate blocks the Flutter UI thread for the entire decompression;
  ///    confirmed on a real device to ANR even this plan's ~40MB-compressed
  ///    smoketest fixture (T-09-08-diagnostic). Still file-to-file
  ///    streaming ([InputFileStream]/[OutputFileStream] -- never
  ///    [GZipDecoder.decodeBytes], which would fully buffer a 300-800MB
  ///    compressed / 1-2GB decompressed payload in memory) to a temp file
  ///    alongside the installed `off_reference.sqlite`.
  /// 3. Deletes the currently-installed `off_reference.sqlite` and renames
  ///    the decompressed temp file into its place -- the same fixed
  ///    `getApplicationDocumentsDirectory()/off_reference.sqlite` path
  ///    `first_launch_extractor.dart` already writes to, so
  ///    `FoodCatalogDao`'s existing `off_ref.*` SQL needs zero changes.
  /// 4. Deletes [downloadedGzFile] itself (`09-RESEARCH.md` Pitfall 4 --
  ///    reclaims the transient extra disk space once its decompressed
  ///    contents are safely installed).
  /// 5. `ATTACH DATABASE '<path>' AS off_ref`
  /// 6. Persists [newVersion] via [ReferencePackVersionStore.write].
  Future<void> swapIn(
    AppDatabase db,
    File downloadedGzFile, {
    required String newVersion,
  }) async {
    final installedPath = await _installedPath();
    final tempPath = '$installedPath.tmp';

    await db.customStatement('DETACH DATABASE off_ref');

    await compute(_decompressGzipFile, (downloadedGzFile.path, tempPath));

    final installedFile = File(installedPath);
    if (installedFile.existsSync()) {
      await installedFile.delete();
    }
    await File(tempPath).rename(installedPath);

    if (downloadedGzFile.existsSync()) {
      await downloadedGzFile.delete();
    }

    // Invalidate first_launch_extractor.dart's ensureOffReferenceDb() cache
    // marker -- it lives next to the exact off_reference.sqlite path this
    // method just overwrote with the full pack, and without deleting it,
    // ensureOffReferenceDb would keep reporting "still the valid bundled
    // seed" forever after, since its cache check only ever looks at this
    // marker's content, never the actual file's. A future revertToSeed()
    // resolving "the bundled seed path" via ensureOffReferenceDb() would
    // then wrongly get this full pack's own path back, delete it, and
    // ATTACH a now-nonexistent path -- which SQLite silently satisfies by
    // creating a fresh, empty database (T-09-08-diagnostic).
    final versionMarker = File(
      p.join(
        await _documentsDirectoryPath(),
        offReferenceVersionMarkerFilename,
      ),
    );
    if (versionMarker.existsSync()) {
      await versionMarker.delete();
    }

    await db.customStatement("ATTACH DATABASE '$installedPath' AS off_ref");

    await _versionStore.write(newVersion);
  }

  /// Reverts the currently-ATTACHed `off_ref` database back to the bundled
  /// starter seed at [bundledSeedPath] -- the reverse of [swapIn].
  ///
  /// Runs, in order:
  /// 1. Copies [bundledSeedPath]'s bytes to a staging path *before*
  ///    touching `installedPath` -- [bundledSeedPath] and `installedPath`
  ///    are the exact same file in production (both resolve to
  ///    `getApplicationDocumentsDirectory()/off_reference.sqlite`:
  ///    `first_launch_extractor.dart`'s `ensureOffReferenceDb()` writes the
  ///    bundled seed there, and [swapIn] overwrites the same path with a
  ///    downloaded full pack). Deleting `installedPath` before reading
  ///    [bundledSeedPath] -- what this method used to do -- deletes the
  ///    seed's only copy before ATTACH ever reads it, since they're the
  ///    same file: ATTACH then silently gets a fresh, empty SQLite
  ///    database at the just-deleted path instead (T-09-08-diagnostic --
  ///    reproduced live: every revert after a real full-pack install
  ///    silently corrupted the installed file to 0 bytes).
  /// 2. `DETACH DATABASE off_ref`
  /// 3. Deletes the currently-installed full-pack file at the fixed
  ///    `off_reference.sqlite` path [swapIn] renamed the decompressed
  ///    download into -- reclaiming disk space per `09-CONTEXT.md`'s
  ///    locked revert behavior ("does not keep the full pack around 'just
  ///    in case'").
  /// 4. Renames the staged copy from step 1 into that same fixed path --
  ///    mirrors [swapIn]'s own "off_ref always lives at the one canonical
  ///    `installedPath`" invariant, so [bundledSeedPath] itself (when it is
  ///    genuinely a separate file, e.g. in tests) is only ever read from,
  ///    never deleted.
  /// 5. `ATTACH DATABASE '<installedPath>' AS off_ref`.
  /// 6. Clears the version marker via [ReferencePackVersionStore.clear].
  Future<void> revertToSeed(
    AppDatabase db, {
    required String bundledSeedPath,
  }) async {
    final installedPath = await _installedPath();
    final stagingPath = '$installedPath.seed_staging';

    await File(bundledSeedPath).copy(stagingPath);

    await db.customStatement('DETACH DATABASE off_ref');

    final installedFile = File(installedPath);
    if (installedFile.existsSync()) {
      await installedFile.delete();
    }
    await File(stagingPath).rename(installedPath);

    await db.customStatement("ATTACH DATABASE '$installedPath' AS off_ref");

    await _versionStore.clear();
  }
}
