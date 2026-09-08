/// Compile-time gate for the encrypted-backup cloud push/pull surface
/// (Plan 08-03, AUTH-09).
///
/// `[ASSUMED]` -- no backend endpoint exists yet (verified against
/// `CO2Diet_Backend-reference`@origin/main; see
/// `docs/backend-contracts/encrypted-backup-blob.md`, Plan 08-02). `enabled`
/// MUST stay `false` until that contract is confirmed by Tomris AND at
/// least one real round trip has been observed against a live server.
///
/// This is a `static const bool` literal, not a remote-config value or a
/// build flavor -- flipping it requires an actual source-code change and a
/// new build, not a runtime toggle (T-08-03-02).
class BackupSyncConfig {
  const BackupSyncConfig._();

  /// Whether the cloud backup push/pull UI and network calls are reachable
  /// at all. Defaults to `false` -- see class doc comment.
  static const bool enabled = false;

  /// Matches `docs/backend-contracts/encrypted-backup-blob.md`'s proposed
  /// push path (Plan 08-02) -- update both together if that document
  /// changes.
  static const String pushPath = '/api/v1/backup';

  /// Matches `docs/backend-contracts/encrypted-backup-blob.md`'s proposed
  /// pull path (Plan 08-02) -- same path as [pushPath], the HTTP method
  /// distinguishes push from pull.
  static const String pullPath = '/api/v1/backup';
}
