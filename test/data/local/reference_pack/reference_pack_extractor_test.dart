// Real-fixture proof that ReferencePackExtractor.swapIn genuinely
// decompresses its gzip input before ATTACHing (replaces Plan 09-01's
// Wave 0 stub). Mirrors:
//  - food_catalog_cache_co2_test.dart's real-fixture-plus-real-AppDatabase
//    precedent (build a real on-disk file with package:sqlite3 directly,
//    ATTACH it via a real AppDatabase(NativeDatabase.memory())).
//  - checksum_verifier_test.dart's real-temp-file convention
//    (Directory.systemTemp.createTemp()).
//
// SQLite's ATTACH DATABASE throws immediately on a still-gzip-compressed
// file, so a subsequent SELECT against off_ref succeeding is itself the
// hard, deterministic proof that swapIn decompressed before ATTACHing.

import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:co2diet/data/local/app_database.dart';
import 'package:co2diet/data/local/reference_pack/reference_pack_extractor.dart';
import 'package:co2diet/data/local/reference_pack/reference_pack_version_store.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as sqlite3;

/// Records write/clear calls without ever touching the real path_provider
/// platform channel -- [ReferencePackExtractor] accepts this seam directly
/// via its constructor, so no path_provider mocking is needed for this test
/// (unlike [ReferencePackExtractor]'s own installed-file path, which uses
/// the constructor's injectable [DocumentsDirectoryPath] seam instead).
class _FakeVersionStore implements ReferencePackVersionStore {
  String? writtenVersion;
  bool cleared = false;

  @override
  Future<void> write(String version) async {
    writtenVersion = version;
  }

  @override
  Future<void> clear() async {
    cleared = true;
  }

  @override
  Future<String?> read() async => writtenVersion;
}

/// Builds a small real SQLite fixture at [path] with a single `meta` table
/// carrying [marker] -- enough to prove which fixture is actually ATTACHed
/// after a swap, without needing the full products/products_fts schema.
void _buildFixtureDb(String path, {required String marker}) {
  final db = sqlite3.sqlite3.open(path)
    ..execute('CREATE TABLE meta (marker TEXT NOT NULL);');
  db.execute('INSERT INTO meta (marker) VALUES (?)', [marker]);
  db.close();
}

/// Gzip-compresses [sourcePath]'s bytes and writes the result to
/// [destPath] -- this is swapIn's input, mirroring
/// `tools/build_reference_pack_release.py`'s `full_v<version>.sqlite.gz`
/// convention.
void _gzipCompress(String sourcePath, String destPath) {
  final bytes = File(sourcePath).readAsBytesSync();
  final compressed = GZipEncoder().encode(bytes)!;
  File(destPath).writeAsBytesSync(compressed);
}

void main() {
  late Directory tempDir;
  late AppDatabase db;
  late ReferencePackExtractor extractor;
  late _FakeVersionStore versionStore;
  late String installedPath;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('reference_pack_extractor_');
    installedPath = p.join(tempDir.path, 'off_reference.sqlite');
    versionStore = _FakeVersionStore();
    extractor = ReferencePackExtractor(
      versionStore: versionStore,
      documentsDirectoryPath: () async => tempDir.path,
    );
  });

  tearDown(() async {
    await db.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('ReferencePackExtractor.swapIn', () {
    test(
      'decompresses the gzip download before ATTACHing, installs it at the '
      'fixed off_reference.sqlite path, deletes the original .gz file, and '
      'persists the new version',
      () async {
        // Currently-installed off_ref, standing in for whatever was
        // ATTACHed before this swap (starter seed or a prior full pack).
        _buildFixtureDb(installedPath, marker: 'OLD_INSTALLED');

        db = AppDatabase(NativeDatabase.memory());
        await db.customStatement(
          "ATTACH DATABASE '$installedPath' AS off_ref",
        );

        // Build the "downloaded" fixture and gzip-compress it -- this is
        // swapIn's input, still compressed exactly as DownloadManager saved
        // it to disk.
        final newFixturePath = p.join(tempDir.path, 'new_fixture.sqlite');
        _buildFixtureDb(newFixturePath, marker: 'NEW_FULL_PACK');
        final gzPath = p.join(tempDir.path, 'full_vTEST.sqlite.gz');
        _gzipCompress(newFixturePath, gzPath);
        final downloadedGzFile = File(gzPath);

        await extractor.swapIn(
          db,
          downloadedGzFile,
          newVersion: 'vTEST',
        );

        // Only passes if the file was genuinely decompressed before ATTACH
        // -- SQLite's ATTACH DATABASE throws immediately on a still-gzip
        // -compressed file.
        final row = await db
            .customSelect('SELECT marker FROM off_ref.meta')
            .getSingle();
        expect(row.read<String>('marker'), 'NEW_FULL_PACK');

        // Pitfall 4's disk-reclaim step: the original .gz download is gone.
        expect(downloadedGzFile.existsSync(), isFalse);

        expect(versionStore.writtenVersion, 'vTEST');
      },
    );
  });

  group('ReferencePackExtractor.revertToSeed', () {
    test(
      're-attaches the bundled seed fixture, deletes the previously '
      'installed full-pack file, and clears the version marker',
      () async {
        // Simulate a previously-swapped-in full pack sitting at the fixed
        // installed path.
        _buildFixtureDb(installedPath, marker: 'PREVIOUSLY_INSTALLED_FULL');

        db = AppDatabase(NativeDatabase.memory());
        await db.customStatement(
          "ATTACH DATABASE '$installedPath' AS off_ref",
        );

        final bundledSeedPath = p.join(tempDir.path, 'bundled_seed.sqlite');
        _buildFixtureDb(bundledSeedPath, marker: 'BUNDLED_SEED');

        await extractor.revertToSeed(db, bundledSeedPath: bundledSeedPath);

        final row = await db
            .customSelect('SELECT marker FROM off_ref.meta')
            .getSingle();
        expect(row.read<String>('marker'), 'BUNDLED_SEED');

        // The previously-downloaded full-pack file is deleted; the bundled
        // seed itself is untouched (revertToSeed never writes to its path).
        expect(File(installedPath).existsSync(), isFalse);
        expect(File(bundledSeedPath).existsSync(), isTrue);

        expect(versionStore.cleared, isTrue);
      },
    );
  });
}
