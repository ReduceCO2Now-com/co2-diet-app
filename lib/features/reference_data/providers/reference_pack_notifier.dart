// ReferencePackNotifier: the single Riverpod presentation-layer surface
// Plan 09-05's Settings row (ReferenceDataRow) and dedicated screen
// (ReferenceDataScreen) both read from and mutate through. Every mutation
// delegates to `referencePackRepositoryProvider` (Plan 09-04's
// `IReferencePackRepository`) -- this file never touches
// background_downloader/http/storage_space directly. The one exception is
// `isOnWifi()`, which talks to connectivity_plus directly since it's a
// UI-facing "should I prompt the user" decision, not a data-layer concern
// (see doc comment below).

import 'package:co2diet/core/di/reference_pack_providers.dart';
import 'package:co2diet/domain/entities/reference_pack_manifest.dart';
import 'package:co2diet/domain/entities/reference_pack_status.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reference_pack_notifier.g.dart';

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

  /// `SELECT COUNT(*) FROM products` against whichever pack is currently
  /// installed -- the "local" side of the product-count comparison
  /// `ReferenceDataScreen` renders.
  Future<int> localProductCount() {
    return ref.read(referencePackRepositoryProvider).localProductCount();
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
}
