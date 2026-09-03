import 'package:co2diet/domain/entities/reference_pack_manifest.dart';
import 'package:co2diet/domain/entities/reference_pack_status.dart';

/// Contract every later Phase 9 data-layer plan implements against
/// (`ReferencePackRepository`, Plan 09-04) and every UI-layer plan
/// (Plan 09-05/09-06) consumes.
///
/// Each method's doc comment cites the `09-CONTEXT.md` decision it exists
/// to satisfy, so Plan 09-04's implementer does not have to re-derive
/// intent from `09-CONTEXT.md` line-by-line.
abstract interface class IReferencePackRepository {
  /// Fetches and validates the CDN's `manifest.json`
  /// (`docs/data-contracts/reference-pack-manifest.md`).
  ///
  /// Small enough to fetch on any connection type — never gated behind a
  /// Wi-Fi check. Throws on a network failure or a manifest that fails
  /// [ReferencePackManifest.fromJson]'s validation (HTTPS-only,
  /// sanity-bound size).
  Future<ReferencePackManifest> fetchManifest();

  /// Returns `SELECT COUNT(*) FROM products` against the currently
  /// attached `off_ref.products` table (whichever pack — seed or full — is
  /// currently installed).
  Future<int> localProductCount();

  /// Runs the disk-space preflight check
  /// (disk-preflight-before-download, `09-CONTEXT.md`) against [manifest],
  /// via `DiskSpaceChecker`. Must be called — and must return `true` —
  /// before [startFullDownload] or [startDeltaDownload] ever starts moving
  /// bytes.
  Future<bool> checkDiskSpace(ReferencePackManifest manifest);

  /// Starts (or resumes) downloading the full pack.
  ///
  /// [allowCellular] is the Wi-Fi override (`09-CONTEXT.md`'s Wi-Fi-by-
  /// default-with-explicit-override decision) — `false` restricts the
  /// download to Wi-Fi only; `true` allows cellular after explicit user
  /// consent.
  Future<void> startFullDownload({required bool allowCellular});

  /// Starts (or resumes) downloading and applying a delta update from the
  /// currently-installed version to the manifest's latest version.
  ///
  /// Same [allowCellular] Wi-Fi-override semantics as [startFullDownload].
  Future<void> startDeltaDownload({required bool allowCellular});

  /// A live stream of [ReferencePackStatus] transitions, so the UI never
  /// has to poll.
  Stream<ReferencePackStatus> watchStatus();

  /// Returns `true` when a full or delta download is currently active.
  Future<bool> isDownloadInProgress();

  /// Cancels the in-progress download, discarding any partial file.
  Future<void> cancelDownload();

  /// Resumes a previously-interrupted download from where it left off
  /// (`09-CONTEXT.md`'s "resume from where they left off" decision) when
  /// native resume data exists, or re-enqueues the same request from
  /// scratch when it doesn't (e.g. a connection-level failure like
  /// "Connection refused" before any bytes arrived — there is nothing to
  /// resume from in that case). Only valid when the current status is
  /// `ReferencePackFailed(canResume: true)`.
  Future<void> resumeDownload();

  /// Reverts the installed pack back to the bundled starter seed
  /// (`09-CONTEXT.md`'s revert-to-seed decision), deleting the downloaded
  /// full pack and resetting [ReferencePackSchedule] to `manual`.
  Future<void> revertToSeed();

  /// Returns the version tag of the currently-installed full pack, or
  /// `null` when only the bundled seed is installed (no full download has
  /// ever completed).
  Future<String?> installedVersion();
}
