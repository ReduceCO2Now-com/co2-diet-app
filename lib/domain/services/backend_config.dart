/// Centralized backend base-URL configuration.
///
/// `[ASSUMED]` per 07-RESEARCH.md Assumption A2 / Open Question #1 — the real
/// backend base URL is unknown until Tomris deploys it. This is the one
/// place Plan 07-03's `deleteAccount()` call (and any other future backend
/// call) reads its base URL from, so the eventual real-deployment handoff
/// is a one-file change.
class BackendConfig {
  const BackendConfig._();

  /// The backend API's base URL.
  ///
  /// `[ASSUMED]` per 07-RESEARCH.md Assumption A2 / Open Question #1. MUST
  /// NOT be treated as a production contract.
  static const String baseUrl = 'http://localhost:8080';
}
