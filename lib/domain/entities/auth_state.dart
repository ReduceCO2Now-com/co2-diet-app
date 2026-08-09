/// Sealed state class for the app's Keycloak auth session.
///
/// Two variants encode every possible session state:
///   - [AuthUnauthenticated] — never logged in, or logged out
///   - [AuthAuthenticated]   — logged in (optimistic/offline-cached or fully
///     token-exchanged)
///
/// Use pattern matching (`switch`) to handle both variants exhaustively —
/// the Dart 3 `sealed` modifier guarantees the compiler warns on missing arms.
///
/// Static factory methods (e.g. `AuthState.unauthenticated()`) provide
/// ergonomic construction, mirroring `FoodSearchState`'s established pattern
/// ([Phase 02-06]).
sealed class AuthState {
  const AuthState();

  /// Returns [AuthUnauthenticated].
  ///
  /// [sessionExpired] defaults to `false` — set `true` only right after a
  /// genuine server-side session invalidation, so the UI can show a
  /// one-time "your session expired" notice (07-CONTEXT.md decision) rather
  /// than a generic logged-out state.
  static AuthState unauthenticated({bool sessionExpired = false}) =>
      AuthUnauthenticated(sessionExpired: sessionExpired);

  /// Returns [AuthAuthenticated] for [email], optionally carrying
  /// [accessToken].
  static AuthState authenticated({
    required String email,
    String? accessToken,
  }) => AuthAuthenticated(email: email, accessToken: accessToken);
}

/// The user has never logged in, or has logged out.
final class AuthUnauthenticated extends AuthState {
  /// Creates an [AuthUnauthenticated] state.
  const AuthUnauthenticated({this.sessionExpired = false});

  /// `true` only immediately after a genuine server-side session
  /// invalidation (e.g. refresh token rejected by Keycloak) — drives a
  /// one-time "your session expired" notice. `false` for a normal
  /// never-logged-in or user-initiated-logout state.
  final bool sessionExpired;
}

/// The user is logged in.
final class AuthAuthenticated extends AuthState {
  /// Creates an [AuthAuthenticated] state.
  const AuthAuthenticated({required this.email, this.accessToken});

  /// The authenticated user's email address.
  final String email;

  /// The current OIDC access token.
  ///
  /// Nullable: immediately after an optimistic/offline-cached session
  /// restore (secure-storage refresh token present, but the fresh token
  /// exchange has not resolved yet), this is `null` until the exchange
  /// completes.
  final String? accessToken;
}
