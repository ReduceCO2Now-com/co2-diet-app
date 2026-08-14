// Reference Pack DI providers: ReferencePackApiClient, DiskSpaceChecker,
// ChecksumVerifier, DownloadManager, ReferencePackExtractor, DeltaApplier,
// ReferencePackVersionStore, and the top-level ReferencePackRepository that
// composes all of them.
//
// Kept in a separate file (mirrors backup_providers.dart/auth_providers.dart)
// to keep providers.dart focused on core infrastructure (AppDatabase,
// profile).

import 'package:co2diet/core/di/providers.dart';
import 'package:co2diet/data/local/reference_pack/checksum_verifier.dart';
import 'package:co2diet/data/local/reference_pack/delta_applier.dart';
import 'package:co2diet/data/local/reference_pack/disk_space_checker.dart';
import 'package:co2diet/data/local/reference_pack/download_manager.dart';
import 'package:co2diet/data/local/reference_pack/reference_pack_extractor.dart';
import 'package:co2diet/data/local/reference_pack/reference_pack_version_store.dart';
import 'package:co2diet/data/remote/reference_pack_api_client.dart';
import 'package:co2diet/data/repositories/reference_pack_repository.dart';
import 'package:co2diet/domain/repositories/i_reference_pack_repository.dart';
import 'package:co2diet/domain/services/reference_pack_config.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reference_pack_providers.g.dart';

/// Provides the [http.Client] used by [referencePackApiClientProvider].
///
/// keepAlive: true, mirrors [authHttpClientProvider]'s (`auth_providers
/// .dart`) rationale -- `ref.onDispose` closes the client cleanly on
/// ProviderScope disposal.
@Riverpod(keepAlive: true)
http.Client referencePackHttpClient(Ref ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
}

/// Provides the [ReferencePackApiClient] bound to
/// [ReferencePackConfig.manifestUrl].
@Riverpod(keepAlive: true)
ReferencePackApiClient referencePackApiClient(Ref ref) {
  return ReferencePackApiClient(
    ref.watch(referencePackHttpClientProvider),
    manifestUrl: ReferencePackConfig.manifestUrl,
  );
}

/// Provides the [DiskSpaceChecker] used for the disk-space preflight check.
@Riverpod(keepAlive: true)
DiskSpaceChecker diskSpaceChecker(Ref ref) => DiskSpaceChecker();

/// Provides the [ChecksumVerifier] used to verify downloaded files before
/// they are trusted.
@Riverpod(keepAlive: true)
ChecksumVerifier checksumVerifier(Ref ref) => const ChecksumVerifier();

/// Provides the [DownloadManager] wrapping `background_downloader`.
@Riverpod(keepAlive: true)
DownloadManager downloadManager(Ref ref) => const DownloadManager();

/// Provides the [ReferencePackExtractor] used for full-pack swap-in/revert.
@Riverpod(keepAlive: true)
ReferencePackExtractor referencePackExtractor(Ref ref) =>
    ReferencePackExtractor();

/// Provides the [DeltaApplier] used for delta-download completion.
@Riverpod(keepAlive: true)
DeltaApplier deltaApplier(Ref ref) => const DeltaApplier();

/// Provides the [ReferencePackVersionStore] used to read/write the
/// installed full-pack version marker.
@Riverpod(keepAlive: true)
ReferencePackVersionStore referencePackVersionStore(Ref ref) =>
    const ReferencePackVersionStore();

/// Provides the [IReferencePackRepository] -- the single, fully-wired
/// orchestration point Plan 09-05's UI and Plan 09-06's automatic refresh
/// consume. The declared return type is the abstract interface, matching
/// [profileRepositoryProvider]'s (`providers.dart`) data-layer-boundary
/// convention -- callers never depend on the concrete
/// [ReferencePackRepository] class.
@Riverpod(keepAlive: true)
IReferencePackRepository referencePackRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return ReferencePackRepository(
    apiClient: ref.watch(referencePackApiClientProvider),
    diskSpaceChecker: ref.watch(diskSpaceCheckerProvider),
    checksumVerifier: ref.watch(checksumVerifierProvider),
    downloadManager: ref.watch(downloadManagerProvider),
    extractor: ref.watch(referencePackExtractorProvider),
    deltaApplier: ref.watch(deltaApplierProvider),
    versionStore: ref.watch(referencePackVersionStoreProvider),
    foodCatalogDao: db.foodCatalogDao,
    appDatabase: db,
  );
}
