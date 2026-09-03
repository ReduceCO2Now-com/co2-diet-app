import 'dart:io';

import 'package:co2diet/core/assets/first_launch_extractor.dart';
import 'package:co2diet/data/local/app_database.dart';
import 'package:co2diet/data/local/daos/food_catalog_dao.dart';
import 'package:co2diet/data/local/reference_pack/checksum_verifier.dart';
import 'package:co2diet/data/local/reference_pack/delta_applier.dart';
import 'package:co2diet/data/local/reference_pack/disk_space_checker.dart';
import 'package:co2diet/data/local/reference_pack/download_manager.dart';
import 'package:co2diet/data/local/reference_pack/reference_pack_extractor.dart';
import 'package:co2diet/data/local/reference_pack/reference_pack_version_store.dart';
import 'package:co2diet/data/remote/reference_pack_api_client.dart';
import 'package:co2diet/domain/entities/reference_pack_manifest.dart';
import 'package:co2diet/domain/entities/reference_pack_status.dart';
import 'package:co2diet/domain/repositories/i_reference_pack_repository.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Thrown by [ReferencePackRepository.startFullDownload]/
/// [ReferencePackRepository.startDeltaDownload] when
/// [ReferencePackRepository.checkDiskSpace] reports insufficient free
/// space -- surfaced before [DownloadManager] is ever called, matching
/// `09-CONTEXT.md`'s "block with a clear message... rather than starting a
/// download that will fail partway through" decision.
class InsufficientDiskSpaceException implements Exception {
  /// Creates an [InsufficientDiskSpaceException].
  const InsufficientDiskSpaceException();

  @override
  String toString() =>
      'InsufficientDiskSpaceException: not enough free disk space for this '
      'download';
}

/// Thrown by [ReferencePackRepository.startDeltaDownload] when the freshly
/// fetched manifest has no `delta_from` entry for the currently-installed
/// version (e.g. the client is too far behind, or no full pack has ever
/// been installed). Callers should fall back to
/// [ReferencePackRepository.startFullDownload].
class NoDeltaAvailableException implements Exception {
  /// Creates a [NoDeltaAvailableException].
  const NoDeltaAvailableException();

  @override
  String toString() =>
      'NoDeltaAvailableException: no delta path from the installed version '
      'to the latest manifest version';
}

/// Resolves the app documents directory's absolute path -- reuses the same
/// injectable-seam shape as `ReferencePackExtractor.DocumentsDirectoryPath`
/// (Plan 09-03) so tests never touch the real path_provider platform
/// channel.
typedef DocumentsDirectoryPath = Future<String> Function();

Future<String> _defaultDocumentsDirectoryPath() async {
  final dir = await getApplicationDocumentsDirectory();
  return dir.path;
}

/// Resolves the bundled starter seed's decompressed on-disk path, called by
/// [ReferencePackRepository.revertToSeed]. Defaults to the real
/// `ensureOffReferenceDb` (`first_launch_extractor.dart`, Plan 02-03) --
/// tests inject a fake so no real asset bundle / platform channel is ever
/// touched.
typedef BundledSeedPathResolver = Future<String> Function();

/// Returns `true` when [manifestVersion] (the CDN manifest's
/// `current_version`) differs from [installedVersion] -- the sole,
/// centralized version-comparison rule Plan 09-01's Wave 0 stub committed
/// to testing (`'version comparison'` group) and Plan 09-06's
/// `checkForUpdateIfDue()` reuses rather than re-deriving inline.
///
/// A `null` [installedVersion] (only the bundled seed is installed, no
/// full pack has ever completed) always counts as "an update is
/// available" -- there is nothing installed to already match.
///
/// Deliberately a plain string-inequality check, not semver parsing --
/// this project's version tags are simple opaque strings
/// ([ReferencePackManifest.currentVersion]'s doc comment: "never parsed
/// for ordering — only used for equality/lookup").
bool isReferencePackUpdateAvailable(
  String manifestVersion,
  String? installedVersion,
) => installedVersion != manifestVersion;

enum _DownloadKind { full, delta }

/// Everything the repository needs to remember about a full or delta
/// download between the moment it is enqueued and the moment
/// [DownloadManager]'s update stream reports it `complete` -- since a
/// single shared [DownloadManager.updates] stream carries both full-pack
/// and delta events, and [ReferencePackDownloadProgress] itself carries
/// neither a manifest nor a file reference (T-09-04-05).
class _InFlightDownload {
  const _InFlightDownload({
    required this.kind,
    required this.manifest,
    required this.requiresWifi,
    this.deltaInfo,
  });

  final _DownloadKind kind;
  final ReferencePackManifest manifest;
  final ReferencePackDeltaInfo? deltaInfo;

  /// The original request's `requiresWifi` value -- kept so
  /// [ReferencePackRepository.resumeDownload]'s from-scratch fallback
  /// re-enqueues with the same Wi-Fi-only/cellular-allowed choice the user
  /// made when they started this download, not a silently-defaulted one.
  final bool requiresWifi;
}

/// The full preflight -> manifest -> download -> verify -> swap
/// orchestration for full-pack downloads, and the preflight -> manifest ->
/// download -> verify -> apply orchestration for delta downloads --
/// composing every Plan 09-02/09-03 primitive into the single, fully-tested
/// place `09-RESEARCH.md`'s architecture diagram describes. No later UI
/// plan re-derives this sequence.
///
/// Mirrors `BackupExportService`'s multi-collaborator constructor-injection
/// precedent (Plan 05-09).
class ReferencePackRepository implements IReferencePackRepository {
  /// Creates a [ReferencePackRepository].
  ///
  /// [documentsDirectoryPath] and [bundledSeedPathResolver] default to the
  /// real platform-channel-backed implementations; tests inject fakes.
  ReferencePackRepository({
    required this.apiClient,
    required this.diskSpaceChecker,
    required this.checksumVerifier,
    required this.downloadManager,
    required this.extractor,
    required this.deltaApplier,
    required this.versionStore,
    required this.foodCatalogDao,
    required this.appDatabase,
    DocumentsDirectoryPath? documentsDirectoryPath,
    BundledSeedPathResolver? bundledSeedPathResolver,
  }) : _documentsDirectoryPath =
           documentsDirectoryPath ?? _defaultDocumentsDirectoryPath,
       _bundledSeedPathResolver =
           bundledSeedPathResolver ?? ensureOffReferenceDb;

  /// Fetches and parses the CDN's `manifest.json`.
  final ReferencePackApiClient apiClient;

  /// Runs the disk-space preflight check.
  final DiskSpaceChecker diskSpaceChecker;

  /// Verifies a downloaded file's SHA-256 digest before it is trusted.
  final ChecksumVerifier checksumVerifier;

  /// Wraps `background_downloader` for the actual full-pack/delta download.
  final DownloadManager downloadManager;

  /// Performs the live DETACH/decompress/ATTACH swap for full-pack
  /// installs and reverts.
  final ReferencePackExtractor extractor;

  /// Applies a checksum-verified delta artifact against `off_ref.products`.
  final DeltaApplier deltaApplier;

  /// Reads/writes the installed full-pack version marker.
  final ReferencePackVersionStore versionStore;

  /// Reads the local product count / `off_ref` schema.
  final FoodCatalogDao foodCatalogDao;

  /// The live database connection, ATTACHed to whichever `off_ref` pack is
  /// currently installed -- passed through to [extractor]/[deltaApplier].
  final AppDatabase appDatabase;

  final DocumentsDirectoryPath _documentsDirectoryPath;
  final BundledSeedPathResolver _bundledSeedPathResolver;

  /// The download currently tracked between enqueue and completion --
  /// `null` when no full/delta download is in flight. Set by
  /// [startFullDownload]/[startDeltaDownload] immediately before enqueuing,
  /// cleared on completion/cancel/terminal-failure (T-09-04-05), so
  /// [watchStatus]'s completion handling can never run the wrong
  /// completion path (a full-pack completion never calls
  /// [DeltaApplier.apply], and a delta completion never calls
  /// [ReferencePackExtractor.swapIn]).
  _InFlightDownload? _inFlight;

  /// Conservative gzip decompression-ratio estimate used by [checkDiskSpace]
  /// to derive the decompressed footprint from the manifest's `pack_size_
  /// bytes` (which describes only the compressed download, per
  /// `docs/data-contracts/reference-pack-manifest.md` Section 3).
  ///
  /// Provenance: this repo's own bundled starter pack --
  /// `assets/off_reference.sqlite` (129,134,592 bytes) vs.
  /// `assets/off_reference.sqlite.gz` (40,703,629 bytes) -- measures a
  /// ~3.17x gzip ratio for this exact schema/content shape
  /// (`129134592 / 40703629 = 3.1726`). `3.5` is a deliberately
  /// conservative round-up so this preflight check never underestimates
  /// required space -- erring toward blocking a download that would
  /// actually have fit, never the reverse.
  static const double _gzipDecompressionRatioEstimate = 3.5;

  @override
  Future<ReferencePackManifest> fetchManifest() => apiClient.fetchManifest();

  @override
  Future<int> localProductCount() => foodCatalogDao.countProducts();

  @override
  Future<String?> installedVersion() => versionStore.read();

  @override
  Future<bool> isDownloadInProgress() =>
      downloadManager.hasActiveTask(referencePackTaskGroup);

  @override
  Future<bool> checkDiskSpace(ReferencePackManifest manifest) {
    // The manifest's pack_size_bytes describes only the compressed
    // download -- never conflated with the decompressed/installed
    // footprint, which is estimated here via a distinct, documented
    // constant (T-09-04-04).
    final estimatedDecompressedBytes =
        (manifest.packSizeBytes * _gzipDecompressionRatioEstimate).round();
    return diskSpaceChecker.hasEnoughSpace(
      manifest.packSizeBytes,
      estimatedDecompressedBytes,
    );
  }

  @override
  Future<void> startFullDownload({required bool allowCellular}) async {
    final manifest = await fetchManifest();
    final hasSpace = await checkDiskSpace(manifest);
    if (!hasSpace) {
      throw const InsufficientDiskSpaceException();
    }

    _inFlight = _InFlightDownload(
      kind: _DownloadKind.full,
      manifest: manifest,
      requiresWifi: !allowCellular,
    );
    await downloadManager.enqueueFullPack(
      url: Uri.parse(manifest.packUrl),
      version: manifest.currentVersion,
      requiresWifi: !allowCellular,
    );
  }

  @override
  Future<void> startDeltaDownload({required bool allowCellular}) async {
    final manifest = await fetchManifest();
    final fromVersion = await installedVersion();
    final deltaInfo = fromVersion == null
        ? null
        : manifest.deltaFrom[fromVersion];
    if (deltaInfo == null) {
      throw const NoDeltaAvailableException();
    }

    final hasSpace = await checkDiskSpace(manifest);
    if (!hasSpace) {
      throw const InsufficientDiskSpaceException();
    }

    _inFlight = _InFlightDownload(
      kind: _DownloadKind.delta,
      manifest: manifest,
      deltaInfo: deltaInfo,
      requiresWifi: !allowCellular,
    );
    await downloadManager.enqueueDelta(
      url: Uri.parse(deltaInfo.url),
      version: manifest.currentVersion,
      requiresWifi: !allowCellular,
    );
  }

  @override
  Stream<ReferencePackStatus> watchStatus() async* {
    yield await _currentInstalledStatus();
    await for (final progress in downloadManager.updates) {
      yield await _mapProgressToStatus(progress);
    }
  }

  Future<ReferencePackStatus> _mapProgressToStatus(
    ReferencePackDownloadProgress progress,
  ) async {
    switch (progress.status) {
      case ReferencePackDownloadStatus.enqueued:
      case ReferencePackDownloadStatus.running:
      case ReferencePackDownloadStatus.paused:
      case ReferencePackDownloadStatus.waitingToRetry:
        return ReferencePackDownloading(
          bytesDownloaded: progress.bytesDownloaded ?? 0,
          bytesTotal: progress.bytesTotal ?? 0,
        );
      case ReferencePackDownloadStatus.complete:
        return _handleDownloadComplete();
      case ReferencePackDownloadStatus.failed:
        // Per DownloadManager's own doc comment: a native TaskStatus.failed
        // "requires a manual Resume" -- 09-CONTEXT.md's no-automatic-retry
        // rule -- so the in-flight manifest/kind is deliberately kept
        // around for resumeDownload() to find, not cleared here.
        return const ReferencePackFailed(
          message: 'Download failed -- tap Resume to try again',
          canResume: true,
        );
      case ReferencePackDownloadStatus.notFound:
        _inFlight = null;
        return const ReferencePackFailed(
          message: 'Download not found on the server',
          canResume: false,
        );
      case ReferencePackDownloadStatus.canceled:
        _inFlight = null;
        return _currentInstalledStatus();
    }
  }

  /// Runs the checksum-verify-then-swap-or-apply completion path
  /// (`09-RESEARCH.md` architecture diagram): checksum verification always
  /// runs before [ReferencePackExtractor.swapIn] or [DeltaApplier.apply]
  /// is ever called on a downloaded file -- a mismatch discards the file
  /// and surfaces [ReferencePackFailed] without ever reaching swap/apply
  /// (T-09-04-01).
  Future<ReferencePackStatus> _handleDownloadComplete() async {
    final inFlight = _inFlight;
    if (inFlight == null) {
      // No tracked in-flight download for this completion event (should
      // not happen in practice since every enqueue sets _inFlight first) --
      // fail safe by reporting the current installed state rather than
      // crashing the stream.
      return _currentInstalledStatus();
    }

    final isDelta = inFlight.kind == _DownloadKind.delta;
    final documentsDir = await _documentsDirectoryPath();
    final filename = downloadManager.sanitizedFilename(
      inFlight.manifest.currentVersion,
      isDelta: isDelta,
    );
    final file = File(
      p.join(documentsDir, referencePackTaskGroup, filename),
    );

    final expectedSha256 = isDelta
        ? inFlight.deltaInfo!.sha256
        : inFlight.manifest.packSha256;

    final verified = await checksumVerifier.verify(file, expectedSha256);
    if (!verified) {
      _inFlight = null;
      if (file.existsSync()) {
        await file.delete();
      }
      return const ReferencePackFailed(
        message: 'Downloaded file failed checksum verification',
        canResume: false,
      );
    }

    if (isDelta) {
      await deltaApplier.apply(appDatabase, file);
      await versionStore.write(inFlight.manifest.currentVersion);
    } else {
      await extractor.swapIn(
        appDatabase,
        file,
        newVersion: inFlight.manifest.currentVersion,
      );
    }

    _inFlight = null;
    return _currentInstalledStatus();
  }

  Future<ReferencePackStatus> _currentInstalledStatus() async {
    final version = await installedVersion();
    if (version == null) {
      return const ReferencePackSeed();
    }
    final productCount = await localProductCount();
    return ReferencePackFull(
      installedVersion: version,
      productCount: productCount,
      // ReferencePackVersionStore (Plan 09-02) persists only the version
      // string, not an install timestamp -- this is the query-time moment,
      // not a durable "installed at" record. Not read by any must-have in
      // this plan; documented here rather than silently fabricated.
      installedAt: DateTime.now(),
    );
  }

  @override
  Future<void> cancelDownload() async {
    final taskId = await downloadManager.activeTaskId(referencePackTaskGroup);
    if (taskId != null) {
      await downloadManager.cancel(taskId);
    }
    _inFlight = null;
  }

  @override
  Future<void> resumeDownload() async {
    final taskId = await downloadManager.activeTaskId(referencePackTaskGroup);
    if (taskId != null) {
      final resumed = await downloadManager.resume(taskId);
      if (resumed) return;
    }
    // Either there was no active native task, or DownloadManager.resume
    // returned false -- both mean there is no resume data to continue
    // from. This is the real (not hypothetical) failure mode behind a
    // connection-level error (e.g. "Connection refused" before any bytes
    // arrived): the task reaches TaskStatus.failed with nothing to resume,
    // as distinct from a paused/interrupted task that still has partial
    // bytes and native resume data. Re-enqueue the original request from
    // scratch using the in-flight manifest _mapProgressToStatus's `failed`
    // case deliberately keeps around for exactly this fallback.
    final inFlight = _inFlight;
    if (inFlight == null) return;
    if (inFlight.kind == _DownloadKind.delta) {
      await downloadManager.enqueueDelta(
        url: Uri.parse(inFlight.deltaInfo!.url),
        version: inFlight.manifest.currentVersion,
        requiresWifi: inFlight.requiresWifi,
      );
    } else {
      await downloadManager.enqueueFullPack(
        url: Uri.parse(inFlight.manifest.packUrl),
        version: inFlight.manifest.currentVersion,
        requiresWifi: inFlight.requiresWifi,
      );
    }
  }

  @override
  Future<void> revertToSeed() async {
    final bundledSeedPath = await _bundledSeedPathResolver();
    await extractor.revertToSeed(
      appDatabase,
      bundledSeedPath: bundledSeedPath,
    );
    // TODO(Plan 09-06): also reset the persisted delta-refresh schedule to
    // ReferencePackSchedule.manual once ReferencePackScheduleNotifier (and
    // its backing store) exists -- no schedule persistence exists at this
    // wave for this method to call into (09-CONTEXT.md's revert-to-seed
    // decision).
  }
}
