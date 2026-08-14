import 'dart:io';

import 'package:background_downloader/background_downloader.dart';

/// The task group every reference-pack download (full pack and delta alike)
/// is enqueued under -- the single group `hasActiveTask` queries for the
/// persistent "is a download in progress" check (`09-RESEARCH.md`
/// Pitfall 5).
const String referencePackTaskGroup = 'reference_pack';

/// Status of a reference-pack download, mirroring [TaskStatus] 1:1 so every
/// value maps deterministically with no default/unknown fallthrough (see
/// [statusFromTaskStatus]).
enum ReferencePackDownloadStatus {
  /// Enqueued on the native platform, not yet running.
  enqueued,

  /// Actively downloading.
  running,

  /// Paused -- may be resumable via [DownloadManager.resume].
  paused,

  /// Completed successfully. Final state.
  complete,

  /// Server returned 404 for the download URL. Final state.
  notFound,

  /// Failed due to an exception. Final state -- requires a manual "Resume"
  /// (`09-CONTEXT.md`: no automatic retry loop).
  failed,

  /// Canceled by the user. Final state -- the partial file has already been
  /// deleted by [DownloadManager.cancel].
  canceled,

  /// Failed and waiting to be retried automatically. Never actually reached
  /// by this app's tasks since every task is enqueued with `retries: 0`, but
  /// mapped explicitly so [statusFromTaskStatus] stays exhaustive against
  /// every [TaskStatus] value regardless.
  waitingToRetry,
}

/// Maps every [TaskStatus] value to its [ReferencePackDownloadStatus]
/// equivalent. A Dart switch over an enum is exhaustiveness-checked by the
/// compiler, so no case can silently fall through to an unmapped/default
/// state -- extending a future [TaskStatus] value without updating this
/// function is a compile error, not a silent bug.
ReferencePackDownloadStatus statusFromTaskStatus(TaskStatus status) {
  switch (status) {
    case TaskStatus.enqueued:
      return ReferencePackDownloadStatus.enqueued;
    case TaskStatus.running:
      return ReferencePackDownloadStatus.running;
    case TaskStatus.paused:
      return ReferencePackDownloadStatus.paused;
    case TaskStatus.complete:
      return ReferencePackDownloadStatus.complete;
    case TaskStatus.notFound:
      return ReferencePackDownloadStatus.notFound;
    case TaskStatus.failed:
      return ReferencePackDownloadStatus.failed;
    case TaskStatus.canceled:
      return ReferencePackDownloadStatus.canceled;
    case TaskStatus.waitingToRetry:
      return ReferencePackDownloadStatus.waitingToRetry;
  }
}

/// Computes bytes-downloaded from a `background_downloader`
/// [TaskProgressUpdate.progress] fraction (0.0-1.0) and the manifest's
/// already-known [expectedFileSize] -- the documented fallback
/// (`09-RESEARCH.md` Open Question 3) for when raw byte counts are not
/// directly exposed on [TaskProgressUpdate].
int estimateBytesDownloaded(double progressFraction, int expectedFileSize) =>
    (progressFraction * expectedFileSize).round();

/// A single progress/status update for an in-flight reference-pack
/// download, mapped from `background_downloader`'s [TaskUpdate].
class ReferencePackDownloadProgress {
  /// Creates a [ReferencePackDownloadProgress].
  const ReferencePackDownloadProgress({
    required this.status,
    this.bytesDownloaded,
    this.bytesTotal,
  });

  /// The task's current status.
  final ReferencePackDownloadStatus status;

  /// Bytes downloaded so far, or `null` when not yet known (e.g. before the
  /// first progress update, or when the server didn't report a content
  /// length).
  final int? bytesDownloaded;

  /// Total expected bytes, or `null` when not yet known.
  final int? bytesTotal;
}

/// Wraps the `background_downloader` package's [FileDownloader] singleton,
/// expressing `09-CONTEXT.md`'s locked resumable/Wi-Fi-gated/cancel-vs-
/// interruption download rules natively instead of hand-rolling them
/// (`09-RESEARCH.md` Don't Hand-Roll table, Pitfalls 3/5).
///
/// Every on-disk filename this class constructs is built by
/// [sanitizedFilename] from a sanitized version string it owns -- never
/// taken verbatim from a manifest/server-supplied string (T-09-03-01,
/// extends T-02-03-02).
class DownloadManager {
  /// Creates a [DownloadManager].
  const DownloadManager();

  /// Builds the on-disk filename for a reference-pack artifact from
  /// [version] -- never echoes [version] verbatim; every character outside
  /// `[A-Za-z0-9_.-]` is replaced with `_` before use, so a
  /// manifest-supplied version string can never inject a path separator or
  /// other unexpected character into the constructed filename.
  ///
  /// Full-pack artifacts ship gzip-compressed
  /// (`tools/build_reference_pack_release.py`'s `full_v<version>.sqlite.gz`
  /// convention); delta artifacts ship uncompressed
  /// (`delta_v<version>.sqlite`, per `ReferencePackDeltaInfo`'s doc
  /// comment).
  String sanitizedFilename(String version, {required bool isDelta}) {
    final safe = version.replaceAll(RegExp('[^A-Za-z0-9_.-]'), '_');
    return isDelta ? 'delta_$safe.sqlite' : 'full_$safe.sqlite.gz';
  }

  /// Enqueues a download of the full reference pack at [url], tagged with
  /// [version] (used only to derive the sanitized on-disk filename, never
  /// persisted verbatim elsewhere by this class).
  ///
  /// [requiresWifi] controls [DownloadTask.requiresWiFi] -- `false` when the
  /// user has explicitly opted into the cellular-data override
  /// (`09-CONTEXT.md`).
  Future<void> enqueueFullPack({
    required Uri url,
    required String version,
    required bool requiresWifi,
  }) async {
    await _enqueue(
      url: url,
      filename: sanitizedFilename(version, isDelta: false),
      requiresWifi: requiresWifi,
    );
  }

  /// Enqueues a download of a delta artifact at [url], tagged with
  /// [version] (used only to derive the sanitized on-disk filename).
  ///
  /// [requiresWifi] controls [DownloadTask.requiresWiFi] -- `false` when the
  /// user has explicitly opted into the cellular-data override.
  Future<void> enqueueDelta({
    required Uri url,
    required String version,
    required bool requiresWifi,
  }) async {
    await _enqueue(
      url: url,
      filename: sanitizedFilename(version, isDelta: true),
      requiresWifi: requiresWifi,
    );
  }

  Future<void> _enqueue({
    required Uri url,
    required String filename,
    required bool requiresWifi,
  }) async {
    // baseDirectory defaults to BaseDirectory.applicationDocuments and
    // retries defaults to 0 -- both left at their defaults rather than
    // passed explicitly (avoid_redundant_argument_values), but retries: 0
    // is still the deliberate choice this app relies on: no automatic
    // retry loop, manual "Resume" only. Momentary Wi-Fi drops are handled
    // natively by allowPause+requiresWiFi, not by this retry count
    // (09-CONTEXT.md).
    final task = DownloadTask(
      url: url.toString(),
      filename: filename,
      directory: referencePackTaskGroup,
      group: referencePackTaskGroup,
      requiresWiFi: requiresWifi,
      // Enables native Range-based resume + absorbs Android's 9-minute
      // background execution limit automatically (09-RESEARCH.md
      // Pattern 1).
      allowPause: true,
      updates: Updates.statusAndProgress,
    );
    await FileDownloader().enqueue(task);
  }

  /// Stream of progress/status updates for every reference-pack download
  /// task, mapped from [FileDownloader.updates] into
  /// [ReferencePackDownloadProgress].
  Stream<ReferencePackDownloadProgress> get updates =>
      FileDownloader().updates.map(
        (update) => switch (update) {
          TaskStatusUpdate() => ReferencePackDownloadProgress(
            status: statusFromTaskStatus(update.status),
          ),
          TaskProgressUpdate() => ReferencePackDownloadProgress(
            status: ReferencePackDownloadStatus.running,
            bytesDownloaded: update.expectedFileSize >= 0
                ? estimateBytesDownloaded(
                    update.progress,
                    update.expectedFileSize,
                  )
                : null,
            bytesTotal: update.expectedFileSize >= 0
                ? update.expectedFileSize
                : null,
          ),
        },
      );

  /// Cancels the task with [taskId] and explicitly deletes its partial file
  /// from disk.
  ///
  /// `09-CONTEXT.md`: "Explicit Cancel deletes the partial file immediately"
  /// -- this does not rely on the plugin doing so on its own behalf,
  /// per `09-RESEARCH.md`'s Assumptions Log (A1), which flags relying on
  /// undocumented plugin cleanup behavior as needing real-device
  /// confirmation before launch.
  Future<void> cancel(String taskId) async {
    final task = await FileDownloader().taskForId(taskId);
    await FileDownloader().cancelTaskWithId(taskId);
    if (task != null) {
      final path = await task.filePath();
      final file = File(path);
      if (file.existsSync()) {
        await file.delete();
      }
    }
  }

  /// Pauses the task with [taskId]. A genuine interruption (app killed,
  /// connection lost) is expected to leave the partial file on disk via the
  /// plugin's own persistent task database -- no explicit action is needed
  /// from this class beyond not deleting anything, satisfying "interruption
  /// keeps the partial file so Resume has something to resume from"
  /// (`09-CONTEXT.md`).
  Future<void> pause(String taskId) async {
    final task = await FileDownloader().taskForId(taskId);
    if (task is DownloadTask) {
      await FileDownloader().pause(task);
    }
  }

  /// Resumes the task with [taskId].
  Future<void> resume(String taskId) async {
    final task = await FileDownloader().taskForId(taskId);
    if (task is DownloadTask) {
      await FileDownloader().resume(task);
    }
  }

  /// Returns `true` when any task in [taskGroup] is enqueued, running, or
  /// paused.
  ///
  /// Queries `background_downloader`'s own persistent task registry
  /// directly via [FileDownloader.allTasks] -- not any in-memory flag this
  /// class or its caller might hold -- since a download can outlive the
  /// screen and even the app process (`09-RESEARCH.md` Pitfall 5). This is
  /// the single source of truth Plan 09-05's Revert-availability check must
  /// call through.
  Future<bool> hasActiveTask(String taskGroup) async {
    final tasks = await FileDownloader().allTasks(group: taskGroup);
    return tasks.isNotEmpty;
  }

  /// Returns the task ID of the (single) currently active task in
  /// [taskGroup], or `null` when none exists.
  ///
  /// Added for Plan 09-04's `ReferencePackRepository.cancelDownload`/
  /// `resumeDownload`, which the `IReferencePackRepository` contract
  /// declares with no task-ID parameter of their own -- `cancel`/`resume`
  /// need a concrete task ID to act on, and every reference-pack download
  /// (full or delta) is enqueued alone under [referencePackTaskGroup],
  /// serialized by `ReferencePackRepository`'s own in-flight-kind tracking
  /// (T-09-04-05), so there is at most one active task per group at any
  /// time.
  Future<String?> activeTaskId(String taskGroup) async {
    final tasks = await FileDownloader().allTasks(group: taskGroup);
    return tasks.isEmpty ? null : tasks.first.taskId;
  }
}
