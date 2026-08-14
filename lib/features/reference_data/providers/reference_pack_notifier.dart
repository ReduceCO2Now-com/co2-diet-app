// ReferencePackNotifier: the single Riverpod presentation-layer surface
// Plan 09-05's Settings row (ReferenceDataRow) and dedicated screen
// (ReferenceDataScreen) both read from and mutate through. Every mutation
// delegates to `referencePackRepositoryProvider` (Plan 09-04's
// `IReferencePackRepository`) -- this file never touches
// background_downloader/http/storage_space directly. Two narrow exceptions:
// `isOnWifi()`, which talks to connectivity_plus directly since it's a
// UI-facing "should I prompt the user" decision, not a data-layer concern;
// and `installedSizeBytes()`, which reads the installed pack file's size
// directly off disk since neither `ReferencePackStatus.ReferencePackFull`
// (Plan 09-02, locked) nor `IReferencePackRepository` (Plan 09-04, locked)
// expose an installed-byte-count -- both doc comments below explain why.

import 'dart:io';

import 'package:co2diet/core/di/reference_pack_providers.dart';
import 'package:co2diet/data/repositories/reference_pack_repository.dart'
    show isReferencePackUpdateAvailable;
import 'package:co2diet/domain/entities/reference_pack_manifest.dart';
import 'package:co2diet/domain/entities/reference_pack_status.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reference_pack_notifier.g.dart';

/// Filename of the installed pack database on disk -- mirrors
/// `ReferencePackExtractor`'s private `_installedFileName` constant
/// (`data/local/reference_pack/reference_pack_extractor.dart`), duplicated
/// here (rather than imported, since it's a private implementation detail
/// of that class) because this is the one presentation-layer read of the
/// installed file's raw size, not a repeat of the swap-in logic itself.
const _installedPackFileName = 'off_reference.sqlite';

/// Live stream of [ReferencePackStatus] transitions, composed by
/// [ReferencePackNotifier] rather than duplicated inline -- keeps
/// [ReferencePackNotifier] a thin `AsyncNotifier` that also exposes the
/// mutation methods below, since `IReferencePackRepository.watchStatus()`
/// is a continuously-updating download-progress stream that doesn't fit
/// `AsyncNotifier.build()`'s single-`Future` shape as cleanly as a
/// dedicated `StreamProvider` does.
@riverpod
Stream<ReferencePackStatus> referencePackStatusStream(Ref ref) {
  return ref.watch(referencePackRepositoryProvider).watchStatus();
}

/// The installed pack database's on-disk size in bytes, recomputed
/// whenever [referencePackProvider]'s status changes (e.g. a
/// download completes or a revert finishes) -- the reactive counterpart to
/// [ReferencePackNotifier.installedSizeBytes], so `ReferenceDataRow`/
/// `ReferenceDataScreen` can `ref.watch` it directly instead of managing
/// their own `FutureBuilder`/local state.
@riverpod
Future<int> referencePackInstalledSizeBytes(Ref ref) async {
  ref.watch(referencePackProvider);
  return ref.read(referencePackProvider.notifier).installedSizeBytes();
}

/// AsyncNotifier presentation-layer wrapper around
/// [referencePackRepositoryProvider] -- the single Riverpod surface the
/// Settings row (`ReferenceDataRow`) and the dedicated screen
/// (`ReferenceDataScreen`) both read from.
///
/// keepAlive: true mirrors `BackupNotifier`/`AuthNotifier`'s established
/// rationale -- mutations here are triggered from widget callbacks that
/// may outlive their triggering widget (e.g. Cancel/Revert confirmed from
/// a dialog after the underlying screen state has moved on).
@Riverpod(keepAlive: true)
class ReferencePackNotifier extends _$ReferencePackNotifier {
  @override
  Future<ReferencePackStatus> build() async {
    // Keeps `state` in sync with every later stream event (download
    // progress ticks, completion, failures) -- `build()` itself only
    // resolves once, on the stream's first value.
    ref.listen(referencePackStatusStreamProvider, (previous, next) {
      next.whenData((status) => state = AsyncData(status));
    });
    return ref.watch(referencePackStatusStreamProvider.future);
  }

  /// Fetches the CDN manifest -- does not start any download.
  Future<ReferencePackManifest> checkForUpdate() {
    return ref.read(referencePackRepositoryProvider).fetchManifest();
  }

  /// Runs the disk-space preflight check for [manifest].
  Future<bool> hasEnoughDiskSpace(ReferencePackManifest manifest) {
    return ref.read(referencePackRepositoryProvider).checkDiskSpace(manifest);
  }

  /// The device's current free disk space, in bytes -- read directly from
  /// [diskSpaceCheckerProvider] (Plan 09-04's already-public DI provider)
  /// rather than the repository, purely for rendering `09-CONTEXT.md`'s
  /// locked "Not enough storage — need ~NMB, only MMB free" blocking
  /// message's second number; [hasEnoughDiskSpace] above remains the sole
  /// go/no-go decision.
  Future<int> freeDiskSpaceBytes() {
    return ref.read(diskSpaceCheckerProvider).freeBytes();
  }

  /// Approximate bytes required to download+install [manifest] -- mirrors
  /// `ReferencePackRepository.checkDiskSpace`'s internal `(compressed +
  /// decompressed) * 1.15` estimate, duplicated here only to render the
  /// locked disk-space message's first number (the real go/no-go decision
  /// is [hasEnoughDiskSpace], not this display-only estimate); that
  /// calculation is a private implementation detail of the repository, not
  /// part of `IReferencePackRepository`'s public contract.
  int estimatedRequiredDiskSpaceBytes(ReferencePackManifest manifest) {
    const decompressionRatioEstimate = 3.5;
    final decompressed = (manifest.packSizeBytes * decompressionRatioEstimate)
        .round();
    return ((manifest.packSizeBytes + decompressed) * 1.15).round();
  }

  /// `SELECT COUNT(*) FROM products` against whichever pack is currently
  /// installed -- the "local" side of the product-count comparison
  /// `ReferenceDataScreen` renders.
  Future<int> localProductCount() {
    return ref.read(referencePackRepositoryProvider).localProductCount();
  }

  /// The installed pack database's on-disk size in bytes -- used to render
  /// the exact `09-CONTEXT.md`-locked "Full catalog installed — N MB"
  /// shape (Settings row subtitle, `ReferenceDataScreen`'s Full-state body,
  /// and the revert confirmation dialog's interpolated size) from a real
  /// measured size, never a hardcoded number. Returns `0` when the file
  /// doesn't exist yet.
  ///
  /// Reads `dart:io`/`path_provider` directly rather than going through
  /// [referencePackRepositoryProvider] -- neither
  /// `ReferencePackStatus.ReferencePackFull` nor
  /// `IReferencePackRepository` (both Plan 09-02/09-04, locked) expose an
  /// installed-byte-count, and the installed file always lives at the same
  /// well-known `getApplicationDocumentsDirectory()/off_reference.sqlite`
  /// path regardless of whether the starter seed or the full pack is
  /// currently swapped in (`first_launch_extractor.dart`/
  /// `ReferencePackExtractor`'s shared swap-in convention).
  Future<int> installedSizeBytes() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, _installedPackFileName));
    if (!file.existsSync()) return 0;
    return file.length();
  }

  /// `true` when the device currently reports a Wi-Fi connection.
  ///
  /// The structural pattern of calling `Connectivity().checkConnectivity()`
  /// and inspecting the returned `List<ConnectivityResult>` is reused from
  /// `food_search_notifier.dart`/`auth_screen.dart`'s existing connectivity
  /// checks, but the specific check performed here is new -- those two
  /// existing call sites both check `list.contains(ConnectivityResult
  /// .none)` for an offline/online determination; neither checks for
  /// `ConnectivityResult.wifi`. This method's positive Wi-Fi-vs-cellular
  /// distinction is new logic this plan introduces. This is the one place
  /// in the Reference Data feature that talks to connectivity_plus
  /// directly, since it is a UI-facing "should I prompt the user" decision,
  /// not a data-layer concern.
  Future<bool> isOnWifi() async {
    final result = await Connectivity().checkConnectivity();
    return result.contains(ConnectivityResult.wifi);
  }

  /// Starts (or resumes) downloading the full pack. [allowCellular] is the
  /// Wi-Fi override (`09-CONTEXT.md`'s Wi-Fi-by-default-with-explicit-
  /// override decision).
  Future<void> startFullDownload({required bool allowCellular}) {
    return ref
        .read(referencePackRepositoryProvider)
        .startFullDownload(allowCellular: allowCellular);
  }

  /// Cancels the in-progress download, discarding any partial file.
  Future<void> cancelDownload() {
    return ref.read(referencePackRepositoryProvider).cancelDownload();
  }

  /// Resumes a previously-interrupted, resumable download -- trivial
  /// delegation to `IReferencePackRepository.resumeDownload()`, called by
  /// `ReferenceDataScreen`'s "Resume" button when status is
  /// `ReferencePackFailed(canResume: true)`, per `09-CONTEXT.md`'s
  /// manual-Resume-only convention.
  Future<void> resumeDownload() {
    return ref.read(referencePackRepositoryProvider).resumeDownload();
  }

  /// Reverts the installed pack back to the bundled starter seed.
  ///
  /// Only callable when no download is currently in progress -- surfaces a
  /// [StateError] otherwise, which the calling screen is expected to have
  /// already prevented via a disabled button, not something a user should
  /// ever actually trigger.
  Future<void> revertToSeed() async {
    final repo = ref.read(referencePackRepositoryProvider);
    final inProgress = await repo.isDownloadInProgress();
    if (inProgress) {
      throw StateError('Cannot revert while a download is in progress');
    }
    await repo.revertToSeed();
  }

  /// Checks the CDN manifest for a newer version and, if one exists,
  /// either surfaces an "Update available — connect to Wi-Fi" status (off
  /// Wi-Fi) or starts the delta download directly (on Wi-Fi, no per-refresh
  /// confirmation dialog).
  ///
  /// Called exclusively from `Co2DietApp`'s `AppLifecycleState.resumed`
  /// observer (Plan 09-06) once `ReferencePackScheduleNotifier`'s
  /// weekly/monthly interval has elapsed -- never from a manual user tap
  /// (`ReferenceDataScreen`'s Download button always calls
  /// [checkForUpdate] + [startFullDownload] directly, never this method or
  /// a delta download). This is the one call site in the whole feature
  /// that starts a delta download.
  ///
  /// Never surfaces a Dashboard-level banner or notification on completion
  /// (`09-CONTEXT.md`: explicitly rejected, unlike the Phase 7 CO2
  /// methodology banner) -- the Settings row's live-updating subtitle
  /// (Plan 09-05) is this feature's only visibility. Swallows network/
  /// manifest failures silently -- this is a best-effort background check
  /// triggered from a fire-and-forget lifecycle callback, not a
  /// user-initiated action with visible error feedback.
  Future<void> checkForUpdateIfDue() async {
    try {
      final manifest = await checkForUpdate();
      final repo = ref.read(referencePackRepositoryProvider);
      final installed = await repo.installedVersion();
      if (!isReferencePackUpdateAvailable(manifest.currentVersion, installed)) {
        return;
      }

      final onWifi = await isOnWifi();
      state = AsyncData(
        ReferencePackUpdateAvailable(
          currentVersion: installed ?? '',
          newVersion: manifest.currentVersion,
          waitingForWifi: !onWifi,
        ),
      );

      // Only the actual multi-MB delta payload waits for Wi-Fi
      // (`09-CONTEXT.md`) -- the manifest check above always runs
      // regardless of connection type.
      if (onWifi) {
        await repo.startDeltaDownload(allowCellular: false);
      }
    } on Exception {
      // Best-effort background check -- never crash the fire-and-forget
      // lifecycle callback that invoked this.
    }
  }
}
