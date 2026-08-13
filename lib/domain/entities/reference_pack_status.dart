/// Sealed state class describing the reference (OFF product) pack's current
/// lifecycle stage.
///
/// Five variants encode every possible state:
///   - [ReferencePackSeed]             — starter pack only (default state)
///   - [ReferencePackDownloading]      — a full or delta download is active
///   - [ReferencePackFull]             — the full pack is installed and current
///   - [ReferencePackUpdateAvailable]  — a newer version exists on the CDN
///   - [ReferencePackFailed]           — the last download/apply attempt failed
///
/// Use pattern matching (`switch`) to handle all variants exhaustively — the
/// Dart 3 `sealed` modifier guarantees the compiler warns on missing arms.
/// Plain Dart sealed class (not Freezed) — mirrors `AuthState`/
/// `FoodSearchState`'s established pattern ([Phase 02-06], [Phase 07-02]).
sealed class ReferencePackStatus {
  const ReferencePackStatus();
}

/// The bundled starter pack only — no full/delta download has ever
/// completed. The default state for a fresh install.
final class ReferencePackSeed extends ReferencePackStatus {
  /// Creates a [ReferencePackSeed] status.
  const ReferencePackSeed();
}

/// A full or delta download is currently in progress.
final class ReferencePackDownloading extends ReferencePackStatus {
  /// Creates a [ReferencePackDownloading] status.
  const ReferencePackDownloading({
    required this.bytesDownloaded,
    required this.bytesTotal,
  });

  /// Bytes downloaded so far.
  final int bytesDownloaded;

  /// Total expected byte count for this download.
  final int bytesTotal;
}

/// The full pack is installed and its version matches the latest manifest
/// (or no update check has surfaced a newer version yet).
final class ReferencePackFull extends ReferencePackStatus {
  /// Creates a [ReferencePackFull] status.
  const ReferencePackFull({
    required this.installedVersion,
    required this.productCount,
    required this.installedAt,
  });

  /// The version tag of the currently-installed full pack.
  final String installedVersion;

  /// Product row count in the currently-installed full pack.
  final int productCount;

  /// When the currently-installed full pack finished installing.
  final DateTime installedAt;
}

/// The full pack is installed, but the CDN manifest advertises a newer
/// version than [currentVersion].
final class ReferencePackUpdateAvailable extends ReferencePackStatus {
  /// Creates a [ReferencePackUpdateAvailable] status.
  const ReferencePackUpdateAvailable({
    required this.currentVersion,
    required this.newVersion,
    required this.waitingForWifi,
  });

  /// The version tag of the currently-installed full pack.
  final String currentVersion;

  /// The version tag the CDN manifest currently advertises as latest.
  final String newVersion;

  /// `true` when the update is queued but withheld pending a Wi-Fi
  /// connection (the user has not granted a cellular-download override).
  final bool waitingForWifi;
}

/// The most recent download or delta-apply attempt failed.
final class ReferencePackFailed extends ReferencePackStatus {
  /// Creates a [ReferencePackFailed] status.
  const ReferencePackFailed({required this.message, required this.canResume});

  /// Human-readable failure description.
  final String message;

  /// `true` when the failure left a resumable partial download on disk
  /// (an interruption, e.g. connectivity loss), `false` when it was a
  /// genuine terminal failure (e.g. checksum mismatch, corrupt manifest)
  /// that must restart from scratch.
  final bool canResume;
}

/// How often the app automatically checks the CDN manifest for a delta
/// update. Mirrors `BackupMetadata.autoBackupFrequency`'s off/daily/weekly
/// string-set pattern conceptually, but as a real enum since this value
/// never round-trips through Drift.
enum ReferencePackSchedule {
  /// Never checks automatically — the user must trigger a check manually.
  manual,

  /// Checks for a new version once a week.
  weekly,

  /// Checks for a new version once a month.
  monthly,
}
