// Tests for ReferencePackRepository (Plan 09-04). Replaces Plan 09-01's
// Wave 0 skip stub.
//
// Covers, per 09-04-PLAN.md's Task 2 behavior spec, using mocktail mocks
// for every injected collaborator (ReferencePackApiClient, DiskSpaceChecker,
// ChecksumVerifier, DownloadManager, ReferencePackExtractor, DeltaApplier,
// ReferencePackVersionStore, FoodCatalogDao):
// - fetchManifest()/localProductCount()/installedVersion()/
//   isDownloadInProgress()/checkDiskSpace()/revertToSeed() each delegate to
//   their respective collaborator, never re-deriving the logic locally.
// - checkDiskSpace() always passes DiskSpaceChecker.hasEnoughSpace two
//   distinct byte values -- the manifest's raw packSizeBytes and a larger
//   computed decompressed estimate (T-09-04-04).
// - A full download's completion path checksum-verifies the still-
//   compressed download before ever calling ReferencePackExtractor.swapIn;
//   a checksum mismatch surfaces ReferencePackFailed and swapIn is never
//   reached (T-09-04-01).
// - A delta download's completion path checksum-verifies the downloaded
//   delta file before ever calling DeltaApplier.apply; a checksum mismatch
//   surfaces ReferencePackFailed and DeltaApplier.apply is never reached.
//   On success, DeltaApplier.apply runs exactly once, then
//   ReferencePackVersionStore.write persists the new version, and
//   watchStatus() resolves to ReferencePackFull without ever calling
//   ReferencePackExtractor.swapIn (T-09-04-05).
// - isReferencePackUpdateAvailable's version-comparison rule.

import 'dart:async';
import 'dart:io';

import 'package:co2diet/data/local/app_database.dart';
import 'package:co2diet/data/local/daos/food_catalog_dao.dart';
import 'package:co2diet/data/local/reference_pack/checksum_verifier.dart';
import 'package:co2diet/data/local/reference_pack/delta_applier.dart';
import 'package:co2diet/data/local/reference_pack/disk_space_checker.dart';
import 'package:co2diet/data/local/reference_pack/download_manager.dart';
import 'package:co2diet/data/local/reference_pack/reference_pack_extractor.dart';
import 'package:co2diet/data/local/reference_pack/reference_pack_version_store.dart';
import 'package:co2diet/data/remote/reference_pack_api_client.dart';
import 'package:co2diet/data/repositories/food_catalog_repository.dart'
    show NetworkException;
import 'package:co2diet/data/repositories/reference_pack_repository.dart';
import 'package:co2diet/domain/entities/reference_pack_manifest.dart';
import 'package:co2diet/domain/entities/reference_pack_status.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;

class _MockReferencePackApiClient extends Mock
    implements ReferencePackApiClient {}

class _MockDiskSpaceChecker extends Mock implements DiskSpaceChecker {}

class _MockChecksumVerifier extends Mock implements ChecksumVerifier {}

class _MockDownloadManager extends Mock implements DownloadManager {}

class _MockReferencePackExtractor extends Mock
    implements ReferencePackExtractor {}

class _MockDeltaApplier extends Mock implements DeltaApplier {}

class _MockReferencePackVersionStore extends Mock
    implements ReferencePackVersionStore {}

class _MockFoodCatalogDao extends Mock implements FoodCatalogDao {}

ReferencePackManifest _buildManifest({
  String currentVersion = 'v2',
  String packUrl = 'https://cdn.example.com/off-pack/full_v2.sqlite.gz',
  int packSizeBytes = 1000000,
  String packSha256 = 'deadbeef',
  int productCount = 500,
  Map<String, ReferencePackDeltaInfo> deltaFrom = const {},
}) {
  return ReferencePackManifest(
    currentVersion: currentVersion,
    packUrl: packUrl,
    packSizeBytes: packSizeBytes,
    packSha256: packSha256,
    productCount: productCount,
    deltaFrom: deltaFrom,
  );
}

void main() {
  late _MockReferencePackApiClient mockApiClient;
  late _MockDiskSpaceChecker mockDiskSpaceChecker;
  late _MockChecksumVerifier mockChecksumVerifier;
  late _MockDownloadManager mockDownloadManager;
  late _MockReferencePackExtractor mockExtractor;
  late _MockDeltaApplier mockDeltaApplier;
  late _MockReferencePackVersionStore mockVersionStore;
  late _MockFoodCatalogDao mockFoodCatalogDao;
  late AppDatabase db;
  late Directory tempDir;
  late StreamController<ReferencePackDownloadProgress> updatesController;
  late ReferencePackRepository repository;

  setUpAll(() {
    registerFallbackValue(File('fallback'));
    registerFallbackValue(Uri.parse('https://cdn.example.com/fallback'));
  });

  setUp(() async {
    mockApiClient = _MockReferencePackApiClient();
    mockDiskSpaceChecker = _MockDiskSpaceChecker();
    mockChecksumVerifier = _MockChecksumVerifier();
    mockDownloadManager = _MockDownloadManager();
    mockExtractor = _MockReferencePackExtractor();
    mockDeltaApplier = _MockDeltaApplier();
    mockVersionStore = _MockReferencePackVersionStore();
    mockFoodCatalogDao = _MockFoodCatalogDao();
    db = AppDatabase(NativeDatabase.memory());
    tempDir = await Directory.systemTemp.createTemp(
      'reference_pack_repository_',
    );
    updatesController =
        StreamController<ReferencePackDownloadProgress>.broadcast();

    when(
      () => mockDownloadManager.updates,
    ).thenAnswer((_) => updatesController.stream);
    when(
      () => mockDownloadManager.sanitizedFilename(
        any(),
        isDelta: any(named: 'isDelta'),
      ),
    ).thenReturn('artifact.sqlite');
    when(
      () => mockDownloadManager.enqueueFullPack(
        url: any(named: 'url'),
        version: any(named: 'version'),
        requiresWifi: any(named: 'requiresWifi'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockDownloadManager.enqueueDelta(
        url: any(named: 'url'),
        version: any(named: 'version'),
        requiresWifi: any(named: 'requiresWifi'),
      ),
    ).thenAnswer((_) async {});

    repository = ReferencePackRepository(
      apiClient: mockApiClient,
      diskSpaceChecker: mockDiskSpaceChecker,
      checksumVerifier: mockChecksumVerifier,
      downloadManager: mockDownloadManager,
      extractor: mockExtractor,
      deltaApplier: mockDeltaApplier,
      versionStore: mockVersionStore,
      foodCatalogDao: mockFoodCatalogDao,
      appDatabase: db,
      documentsDirectoryPath: () async => tempDir.path,
      bundledSeedPathResolver: () async =>
          p.join(tempDir.path, 'bundled_seed.sqlite'),
    );
  });

  tearDown(() async {
    unawaited(updatesController.close());
    await db.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('fetchManifest', () {
    test(
      'delegates to ReferencePackApiClient and returns its parsed '
      'ReferencePackManifest',
      () async {
        final manifest = _buildManifest();
        when(
          () => mockApiClient.fetchManifest(),
        ).thenAnswer((_) async => manifest);

        final result = await repository.fetchManifest();

        expect(result, same(manifest));
        verify(() => mockApiClient.fetchManifest()).called(1);
      },
    );

    test(
      'propagates a non-https pack_url validation failure from the api '
      'client rather than swallowing it',
      () async {
        when(() => mockApiClient.fetchManifest()).thenThrow(
          const FormatException('pack_url must be an https:// URL'),
        );

        await expectLater(
          repository.fetchManifest,
          throwsA(isA<FormatException>()),
        );
      },
    );

    test(
      'propagates a pack_size_bytes-exceeds-sanity-bound validation '
      'failure from the api client rather than swallowing it',
      () async {
        when(() => mockApiClient.fetchManifest()).thenThrow(
          const FormatException('pack_size_bytes is implausible'),
        );

        await expectLater(
          repository.fetchManifest,
          throwsA(isA<FormatException>()),
        );
      },
    );

    test('propagates a network failure from the api client', () async {
      when(
        () => mockApiClient.fetchManifest(),
      ).thenThrow(const NetworkException('Manifest fetch failed: HTTP 500'));

      await expectLater(
        repository.fetchManifest,
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('localProductCount', () {
    test(
      'returns the row count from the currently attached '
      'off_ref.products table via FoodCatalogDao',
      () async {
        when(
          () => mockFoodCatalogDao.countProducts(),
        ).thenAnswer((_) async => 12345);

        final count = await repository.localProductCount();

        expect(count, 12345);
        verify(() => mockFoodCatalogDao.countProducts()).called(1);
      },
    );
  });

  group('installedVersion', () {
    test(
      'returns null before any full-pack download has ever completed',
      () async {
        when(() => mockVersionStore.read()).thenAnswer((_) async => null);

        expect(await repository.installedVersion(), isNull);
      },
    );

    test(
      'returns the persisted version once a full pack is installed',
      () async {
        when(() => mockVersionStore.read()).thenAnswer((_) async => 'v7');

        expect(await repository.installedVersion(), 'v7');
      },
    );
  });

  group('isDownloadInProgress', () {
    test(
      'always reads through DownloadManager.hasActiveTask, never a '
      'locally-held boolean',
      () async {
        when(
          () => mockDownloadManager.hasActiveTask(referencePackTaskGroup),
        ).thenAnswer((_) async => true);
        expect(await repository.isDownloadInProgress(), isTrue);

        when(
          () => mockDownloadManager.hasActiveTask(referencePackTaskGroup),
        ).thenAnswer((_) async => false);
        expect(await repository.isDownloadInProgress(), isFalse);

        verify(
          () => mockDownloadManager.hasActiveTask(referencePackTaskGroup),
        ).called(2);
      },
    );
  });

  group('checkDiskSpace', () {
    test(
      'returns insufficient when DiskSpaceChecker reports the free bytes '
      'do not clear the margin',
      () async {
        when(
          () => mockDiskSpaceChecker.hasEnoughSpace(any(), any()),
        ).thenAnswer((_) async => false);

        final result = await repository.checkDiskSpace(_buildManifest());

        expect(result, isFalse);
      },
    );

    test(
      'returns sufficient when DiskSpaceChecker reports the free bytes '
      'clear the margin',
      () async {
        when(
          () => mockDiskSpaceChecker.hasEnoughSpace(any(), any()),
        ).thenAnswer((_) async => true);

        final result = await repository.checkDiskSpace(_buildManifest());

        expect(result, isTrue);
      },
    );

    test(
      'never calls DiskSpaceChecker.hasEnoughSpace with the same value for '
      'both the compressed and decompressed parameters (T-09-04-04)',
      () async {
        when(
          () => mockDiskSpaceChecker.hasEnoughSpace(any(), any()),
        ).thenAnswer((_) async => true);
        final manifest = _buildManifest(packSizeBytes: 40703629);

        await repository.checkDiskSpace(manifest);

        final captured = verify(
          () => mockDiskSpaceChecker.hasEnoughSpace(
            captureAny(),
            captureAny(),
          ),
        ).captured;
        final compressedArg = captured[0] as int;
        final decompressedArg = captured[1] as int;

        expect(compressedArg, manifest.packSizeBytes);
        expect(decompressedArg, isNot(compressedArg));
        expect(decompressedArg, greaterThan(compressedArg));
      },
    );
  });

  group('revertToSeed', () {
    test(
      'reverts via ReferencePackExtractor.revertToSeed using the resolved '
      'bundled-seed path',
      () async {
        when(
          () => mockExtractor.revertToSeed(
            db,
            bundledSeedPath: any(named: 'bundledSeedPath'),
          ),
        ).thenAnswer((_) async {});

        await repository.revertToSeed();

        verify(
          () => mockExtractor.revertToSeed(
            db,
            bundledSeedPath: p.join(tempDir.path, 'bundled_seed.sqlite'),
          ),
        ).called(1);
      },
    );
  });

  group('full download completion path', () {
    test(
      'checksum-verifies the still-compressed download, then calls '
      'ReferencePackExtractor.swapIn, and watchStatus() resolves to '
      'ReferencePackFull',
      () async {
        final manifest = _buildManifest(
          packSizeBytes: 1000,
          packSha256: 'full-sha',
        );
        when(
          () => mockApiClient.fetchManifest(),
        ).thenAnswer((_) async => manifest);
        when(
          () => mockDiskSpaceChecker.hasEnoughSpace(any(), any()),
        ).thenAnswer((_) async => true);
        when(
          () => mockVersionStore.read(),
        ).thenAnswer((_) async => null);
        when(
          () => mockFoodCatalogDao.countProducts(),
        ).thenAnswer((_) async => 500);
        when(
          () => mockChecksumVerifier.verify(any(), 'full-sha'),
        ).thenAnswer((_) async => true);
        when(
          () => mockExtractor.swapIn(
            db,
            any(),
            newVersion: 'v2',
          ),
        ).thenAnswer((_) async {
          // The real ReferencePackExtractor.swapIn persists the new version
          // via ReferencePackVersionStore.write internally (Plan 09-03) --
          // simulated here since extractor is mocked, so the post-swap
          // watchStatus() emission reflects the newly-installed version.
          when(
            () => mockVersionStore.read(),
          ).thenAnswer((_) async => 'v2');
        });

        final statuses = <ReferencePackStatus>[];
        final sub = repository.watchStatus().listen(statuses.add);
        await pumpEventQueue();
        expect(statuses, hasLength(1));
        expect(statuses.single, isA<ReferencePackSeed>());

        await repository.startFullDownload(allowCellular: false);
        updatesController.add(
          const ReferencePackDownloadProgress(
            status: ReferencePackDownloadStatus.complete,
          ),
        );
        await pumpEventQueue();

        expect(statuses.last, isA<ReferencePackFull>());
        verify(
          () => mockChecksumVerifier.verify(any(), 'full-sha'),
        ).called(1);
        verify(
          () => mockExtractor.swapIn(db, any(), newVersion: 'v2'),
        ).called(1);
        verifyNever(() => mockDeltaApplier.apply(db, any()));

        // NB: sub.cancel() is deliberately not awaited -- an async*
        // generator suspended inside `await for` on an idle broadcast
        // stream (downloadManager.updates) does not resolve cancel()'s
        // Future until the generator next reaches a yield point, which
        // never happens on an idle stream (a genuine Dart async*
        // cancellation quirk, not a bug in ReferencePackRepository).
        unawaited(sub.cancel());
      },
    );

    test(
      'a checksum mismatch discards the file, surfaces ReferencePackFailed, '
      'and ReferencePackExtractor.swapIn is never reached (T-09-04-01)',
      () async {
        final manifest = _buildManifest(
          packSha256: 'full-sha',
        );
        when(
          () => mockApiClient.fetchManifest(),
        ).thenAnswer((_) async => manifest);
        when(
          () => mockDiskSpaceChecker.hasEnoughSpace(any(), any()),
        ).thenAnswer((_) async => true);
        when(() => mockVersionStore.read()).thenAnswer((_) async => null);
        when(
          () => mockChecksumVerifier.verify(any(), 'full-sha'),
        ).thenAnswer((_) async => false);

        final statuses = <ReferencePackStatus>[];
        final sub = repository.watchStatus().listen(statuses.add);
        await pumpEventQueue();

        await repository.startFullDownload(allowCellular: false);
        updatesController.add(
          const ReferencePackDownloadProgress(
            status: ReferencePackDownloadStatus.complete,
          ),
        );
        await pumpEventQueue();

        expect(statuses.last, isA<ReferencePackFailed>());
        expect((statuses.last as ReferencePackFailed).canResume, isFalse);
        verifyNever(
          () => mockExtractor.swapIn(
            db,
            any(),
            newVersion: any(named: 'newVersion'),
          ),
        );

        // NB: sub.cancel() is deliberately not awaited -- an async*
        // generator suspended inside `await for` on an idle broadcast
        // stream (downloadManager.updates) does not resolve cancel()'s
        // Future until the generator next reaches a yield point, which
        // never happens on an idle stream (a genuine Dart async*
        // cancellation quirk, not a bug in ReferencePackRepository).
        unawaited(sub.cancel());
      },
    );
  });

  group('delta download completion path', () {
    test(
      'checksum-verifies the downloaded delta file, then calls '
      'DeltaApplier.apply(appDatabase, deltaFile) exactly once, persists '
      'the new version, and watchStatus() resolves to ReferencePackFull '
      'without ever calling ReferencePackExtractor.swapIn (key_link)',
      () async {
        const deltaInfo = ReferencePackDeltaInfo(
          url: 'https://cdn.example.com/off-pack/delta_v1_to_v2.sqlite',
          sizeBytes: 5000,
          sha256: 'delta-sha',
        );
        final manifest = _buildManifest(
          deltaFrom: {'v1': deltaInfo},
        );
        when(
          () => mockApiClient.fetchManifest(),
        ).thenAnswer((_) async => manifest);
        when(
          () => mockDiskSpaceChecker.hasEnoughSpace(any(), any()),
        ).thenAnswer((_) async => true);
        when(() => mockVersionStore.read()).thenAnswer((_) async => 'v1');
        when(
          () => mockVersionStore.write('v2'),
        ).thenAnswer((_) async {});
        when(
          () => mockFoodCatalogDao.countProducts(),
        ).thenAnswer((_) async => 500);
        when(
          () => mockChecksumVerifier.verify(any(), 'delta-sha'),
        ).thenAnswer((_) async => true);
        when(
          () => mockDeltaApplier.apply(db, any()),
        ).thenAnswer((_) async {});

        final statuses = <ReferencePackStatus>[];
        final sub = repository.watchStatus().listen(statuses.add);
        await pumpEventQueue();

        await repository.startDeltaDownload(allowCellular: false);
        updatesController.add(
          const ReferencePackDownloadProgress(
            status: ReferencePackDownloadStatus.complete,
          ),
        );
        await pumpEventQueue();

        expect(statuses.last, isA<ReferencePackFull>());
        verify(
          () => mockChecksumVerifier.verify(any(), 'delta-sha'),
        ).called(1);
        verify(() => mockDeltaApplier.apply(db, any())).called(1);
        verify(() => mockVersionStore.write('v2')).called(1);
        verifyNever(
          () => mockExtractor.swapIn(
            db,
            any(),
            newVersion: any(named: 'newVersion'),
          ),
        );

        // NB: sub.cancel() is deliberately not awaited -- an async*
        // generator suspended inside `await for` on an idle broadcast
        // stream (downloadManager.updates) does not resolve cancel()'s
        // Future until the generator next reaches a yield point, which
        // never happens on an idle stream (a genuine Dart async*
        // cancellation quirk, not a bug in ReferencePackRepository).
        unawaited(sub.cancel());
      },
    );

    test(
      'a checksum mismatch discards the delta file, surfaces '
      'ReferencePackFailed, and DeltaApplier.apply is never called',
      () async {
        const deltaInfo = ReferencePackDeltaInfo(
          url: 'https://cdn.example.com/off-pack/delta_v1_to_v2.sqlite',
          sizeBytes: 5000,
          sha256: 'delta-sha',
        );
        final manifest = _buildManifest(
          deltaFrom: {'v1': deltaInfo},
        );
        when(
          () => mockApiClient.fetchManifest(),
        ).thenAnswer((_) async => manifest);
        when(
          () => mockDiskSpaceChecker.hasEnoughSpace(any(), any()),
        ).thenAnswer((_) async => true);
        when(() => mockVersionStore.read()).thenAnswer((_) async => 'v1');
        when(
          () => mockFoodCatalogDao.countProducts(),
        ).thenAnswer((_) async => 500);
        when(
          () => mockChecksumVerifier.verify(any(), 'delta-sha'),
        ).thenAnswer((_) async => false);

        final statuses = <ReferencePackStatus>[];
        final sub = repository.watchStatus().listen(statuses.add);
        await pumpEventQueue();

        await repository.startDeltaDownload(allowCellular: false);
        updatesController.add(
          const ReferencePackDownloadProgress(
            status: ReferencePackDownloadStatus.complete,
          ),
        );
        await pumpEventQueue();

        expect(statuses.last, isA<ReferencePackFailed>());
        verifyNever(() => mockDeltaApplier.apply(db, any()));
        verifyNever(() => mockVersionStore.write(any()));

        // NB: sub.cancel() is deliberately not awaited -- an async*
        // generator suspended inside `await for` on an idle broadcast
        // stream (downloadManager.updates) does not resolve cancel()'s
        // Future until the generator next reaches a yield point, which
        // never happens on an idle stream (a genuine Dart async*
        // cancellation quirk, not a bug in ReferencePackRepository).
        unawaited(sub.cancel());
      },
    );

    test(
      'throws NoDeltaAvailableException when the manifest has no '
      'delta_from entry for the currently-installed version',
      () async {
        final manifest = _buildManifest();
        when(
          () => mockApiClient.fetchManifest(),
        ).thenAnswer((_) async => manifest);
        when(() => mockVersionStore.read()).thenAnswer((_) async => 'v1');

        await expectLater(
          repository.startDeltaDownload(allowCellular: false),
          throwsA(isA<NoDeltaAvailableException>()),
        );
        verifyNever(
          () => mockDownloadManager.enqueueDelta(
            url: any(named: 'url'),
            version: any(named: 'version'),
            requiresWifi: any(named: 'requiresWifi'),
          ),
        );
      },
    );
  });

  group('version comparison', () {
    test(
      'an update is available when manifest.currentVersion differs from '
      'the installed version',
      () {
        expect(isReferencePackUpdateAvailable('v2', 'v1'), isTrue);
        expect(isReferencePackUpdateAvailable('v2', null), isTrue);
      },
    );

    test(
      'no update is available when manifest.currentVersion matches the '
      'installed version',
      () {
        expect(isReferencePackUpdateAvailable('v2', 'v2'), isFalse);
      },
    );
  });
}
