import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:co2diet/data/local/app_database.dart';
import 'package:co2diet/data/local/reference_pack/reference_pack_version_store.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

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
  /// 2. Streams-decompresses [downloadedGzFile] via [GZipDecoder]'s
  ///    file-to-file streaming API ([InputFileStream]/[OutputFileStream] --
  ///    never [GZipDecoder.decodeBytes], which would fully buffer a
  ///    300-800MB compressed / 1-2GB decompressed payload in memory) to a
  ///    temp file alongside the installed `off_reference.sqlite`.
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

    final input = InputFileStream(downloadedGzFile.path);
    final output = OutputFileStream(tempPath);
    try {
      GZipDecoder().decodeStream(input, output);
    } finally {
      await input.close();
      await output.close();
    }

    final installedFile = File(installedPath);
    if (installedFile.existsSync()) {
      await installedFile.delete();
    }
    await File(tempPath).rename(installedPath);

    if (downloadedGzFile.existsSync()) {
      await downloadedGzFile.delete();
    }

    await db.customStatement("ATTACH DATABASE '$installedPath' AS off_ref");

    await _versionStore.write(newVersion);
  }

  /// Reverts the currently-ATTACHed `off_ref` database back to the bundled
  /// starter seed at [bundledSeedPath] -- the reverse of [swapIn].
  ///
  /// Runs, in order:
  /// 1. `DETACH DATABASE off_ref`
  /// 2. Deletes the currently-installed full-pack file at the same fixed
  ///    `getApplicationDocumentsDirectory()/off_reference.sqlite` path
  ///    [swapIn] renamed the decompressed download into -- reclaiming disk
  ///    space per `09-CONTEXT.md`'s locked revert behavior ("does not keep
  ///    the full pack around 'just in case'").
  /// 3. `ATTACH DATABASE '<bundledSeedPath>' AS off_ref` -- [bundledSeedPath]
  ///    is the same path `first_launch_extractor.dart`'s
  ///    `ensureOffReferenceDb()` already resolved and decompressed at
  ///    startup, passed in by the caller rather than re-derived here, since
  ///    the bundled seed is already a plain, uncompressed `.sqlite` file
  ///    with no decompression step needed on revert.
  /// 4. Clears the version marker via [ReferencePackVersionStore.clear].
  Future<void> revertToSeed(
    AppDatabase db, {
    required String bundledSeedPath,
  }) async {
    final installedPath = await _installedPath();

    await db.customStatement('DETACH DATABASE off_ref');

    final installedFile = File(installedPath);
    if (installedFile.existsSync()) {
      await installedFile.delete();
    }

    await db.customStatement("ATTACH DATABASE '$bundledSeedPath' AS off_ref");

    await _versionStore.clear();
  }
}
