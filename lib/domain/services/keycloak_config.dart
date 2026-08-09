/// Centralized Keycloak realm/client configuration.
///
/// **Every value in this class is an `[ASSUMED]` placeholder** pending
/// Tomris's real Keycloak realm export (see `07-RESEARCH.md`'s Assumptions
/// Log, entries A1/A3/A4/A5). None of these values are a production
/// contract — they exist so every later Phase 7 plan reads from one shared
/// source instead of hardcoding its own copy, making the eventual
/// real-realm handoff a one-file change.
class KeycloakConfig {
  const KeycloakConfig._();

  /// The OIDC issuer base URL.
  ///
  /// `[ASSUMED]` per 07-RESEARCH.md Assumptions Log A1 — the only value
  /// actually found in the backend reference repo (dev-only). The
  /// production issuer URL is completely unknown; MUST NOT be treated as
  /// a production contract.
  static const String issuer = 'http://localhost:8081/realms/co2diet';

  /// The registered public (native) OIDC client ID for the mobile app.
  ///
  /// `[ASSUMED]` per 07-RESEARCH.md Assumptions Log A4.
  static const String clientId = 'co2diet-mobile';

  /// The app's registered OIDC redirect URI.
  ///
  /// `[ASSUMED]` per 07-RESEARCH.md Assumptions Log A4. The scheme portion
  /// (`com.reduceco2now.co2diet.auth`) MUST match both
  /// `android/app/build.gradle.kts`'s `appAuthRedirectScheme`
  /// manifestPlaceholder and `ios/Runner/Info.plist`'s
  /// `CFBundleURLSchemes` entry, byte-for-byte.
  static const String redirectUrl = 'com.reduceco2now.co2diet.auth://callback';

  /// The OIDC scopes requested at login.
  ///
  /// `[ASSUMED]` per 07-RESEARCH.md Assumptions Log A5 — `offline_access` is
  /// assumed enabled by default for this client in the realm (required for
  /// refresh tokens / "stay logged in across sessions," AUTH-02). If false
  /// in the real realm, AUTH-02 would silently fail with no client-side
  /// code fix possible; already flagged as a named backend-coordination
  /// item in STATE.md.
  static const List<String> scopes = [
    'openid',
    'profile',
    'email',
    'offline_access',
  ];

  /// The Keycloak identity-provider alias for Apple Sign-in
  /// (`kc_idp_hint` value).
  ///
  /// `[ASSUMED]` per 07-RESEARCH.md Assumptions Log A3.
  static const String appleIdpAlias = 'apple';

  /// The Keycloak identity-provider alias for Google Sign-in
  /// (`kc_idp_hint` value).
  ///
  /// `[ASSUMED]` per 07-RESEARCH.md Assumptions Log A3.
  static const String googleIdpAlias = 'google';
}
