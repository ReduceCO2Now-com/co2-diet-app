import 'package:storage_space/storage_space.dart' as storage_space;

/// Signature of the real platform-channel free-bytes query
/// ([storage_space.getStorageSpace]'s `.free` field), injected so tests
/// never touch the real platform channel — mirrors this project's existing
/// seam-injection convention for platform-channel-backed values (e.g.
/// `BackupNotifier`'s `filePickerProvider` seam).
typedef FreeBytesQuery = Future<int> Function();

/// Performs the disk-space preflight check required before any reference
/// pack download starts (disk-preflight-before-download, 09-CONTEXT.md).
class DiskSpaceChecker {
  /// Creates a [DiskSpaceChecker].
  ///
  /// [freeBytesQuery] defaults to the real `storage_space` plugin call;
  /// tests inject a fake to avoid the real platform channel.
  DiskSpaceChecker({FreeBytesQuery? freeBytesQuery})
    : _freeBytesQuery = freeBytesQuery ?? _defaultFreeBytesQuery;

  final FreeBytesQuery _freeBytesQuery;

  static Future<int> _defaultFreeBytesQuery() async {
    final space = await storage_space.getStorageSpace(
      // lowOnSpaceThreshold only affects the plugin's own `.lowOnSpace`
      // flag, which this checker never reads -- required by the plugin's
      // API regardless.
      lowOnSpaceThreshold: 0,
      fractionDigits: 1,
    );
    return space.free;
  }

  /// Returns the device's current free disk space, in bytes.
  Future<int> freeBytes() => _freeBytesQuery();

  /// Returns `true` when there is enough free disk space to safely download
  /// and install a reference pack.
  ///
  /// The required-bytes calculation is `(compressedDownloadBytes +
  /// decompressedFinalBytes) * safetyMultiplierPercent` -- NOT just
  /// [decompressedFinalBytes] alone. Per 09-RESEARCH.md Pitfall
  /// 4, the compressed download and its decompressed output must coexist on
  /// disk briefly during decompression (the compressed file isn't deleted
  /// until decompression succeeds), so both sizes are required
  /// simultaneously at peak usage, not just the final installed footprint.
  /// [safetyMultiplierPercent] adds a margin on top of that peak (defaults
  /// to 1.15, i.e. 15% headroom).
  Future<bool> hasEnoughSpace(
    int compressedDownloadBytes,
    int decompressedFinalBytes, {
    double safetyMultiplierPercent = 1.15,
  }) async {
    final requiredBytes =
        (compressedDownloadBytes + decompressedFinalBytes) *
        safetyMultiplierPercent;
    final free = await freeBytes();
    return free >= requiredBytes;
  }
}
