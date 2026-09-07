/// Whether the app may make outbound requests for food data.
///
/// See `docs/decisions/0001-connectivity-choice-not-account-mode.md`. This is
/// the axis the onboarding "Mode Choice" actually turns on — *not* account
/// versus local, since the backend's catalog endpoints are public and it
/// stores no user data either way.
enum NetworkMode {
  /// Bundled catalog and the user's own foods only. No remote lookups.
  offlineOnly,

  /// Remote lookups allowed for products the bundled catalog lacks. Still no
  /// account, and no personal data is transmitted.
  onlineAllowed;

  /// Parses a persisted value, defaulting to [onlineAllowed].
  ///
  /// Defaulting to online preserves the behaviour that shipped before this
  /// preference existed — the bundled pack is deliberately small, so
  /// defaulting to offline would silently remove food search for most users.
  static NetworkMode fromStorage(String? value) => switch (value) {
    'offlineOnly' => NetworkMode.offlineOnly,
    _ => NetworkMode.onlineAllowed,
  };

  /// Whether remote food lookups are permitted in this mode.
  bool get allowsRemoteLookups => this == NetworkMode.onlineAllowed;
}
