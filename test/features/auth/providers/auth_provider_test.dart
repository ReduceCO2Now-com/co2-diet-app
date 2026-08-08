import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'AuthNotifier',
    skip: 'Awaiting Plan 07-03 implementation',
    () {
      // TODO(Plan 07-03): with no stored refresh token, build() resolves
      // to AuthUnauthenticated.
      test(
        'build() returns AuthUnauthenticated with no stored refresh '
        'token',
        () {},
      );

      // TODO(Plan 07-03): with a stored refresh token, build()
      // optimistically returns AuthAuthenticated using a cached email
      // before the silent-refresh network call resolves.
      test(
        'build() optimistically returns AuthAuthenticated using a '
        'cached email when a refresh token exists, before the network '
        'call resolves',
        () {},
      );

      // TODO(Plan 07-03): a successful silent refresh resolves to
      // AuthAuthenticated with the userinfo-resolved email and persists
      // the new refresh token.
      test(
        'successful silent refresh yields AuthAuthenticated with the '
        'userinfo-resolved email and persists the new refresh token',
        () {},
      );

      // TODO(Plan 07-03): CONTEXT.md distinguishes network failure from
      // real token invalidation -- a network-failure refresh error must
      // not delete the stored refresh token.
      test(
        'a network-failure refresh error keeps state AuthAuthenticated '
        'and does not delete the stored refresh token (CONTEXT.md: '
        'network failure vs. real invalidation)',
        () {},
      );

      // TODO(Plan 07-03): a genuine invalid_grant/revoked-token refresh
      // error yields AuthUnauthenticated(sessionExpired: true) and
      // clears stored refresh token + cached email.
      test(
        'a genuine invalid_grant/revoked-token refresh error yields '
        'AuthUnauthenticated(sessionExpired: true) and deletes stored '
        'refresh token + cached email',
        () {},
      );

      // TODO(Plan 07-03): signIn() calls authorizeAndExchangeCode with
      // no kc_idp_hint/prompt params.
      test(
        'signIn() calls authorizeAndExchangeCode with no kc_idp_hint/'
        'prompt params',
        () {},
      );

      // TODO(Plan 07-03): signUp() calls authorizeAndExchangeCode with
      // additionalParameters[prompt]='create' and records an
      // 'account_mode_terms' consent event on success.
      test(
        "signUp() calls authorizeAndExchangeCode with "
        "additionalParameters[prompt]='create' and records an "
        "'account_mode_terms' consent event on success",
        () {},
      );

      // TODO(Plan 07-03): signInWithIdp('apple') and
      // signInWithIdp('google') pass the matching kc_idp_hint alias.
      test(
        "signInWithIdp('apple') and signInWithIdp('google') pass the "
        'matching kc_idp_hint alias',
        () {},
      );

      // TODO(Plan 07-03): a cancelled/dismissed browser flow leaves
      // state unchanged with no rethrown error.
      test(
        'a cancelled/dismissed browser flow leaves state unchanged '
        'with no rethrown error',
        () {},
      );

      // TODO(Plan 07-03): logout() calls endSession, clears secure
      // storage, and sets AuthUnauthenticated(sessionExpired: false).
      test(
        'logout() calls endSession, clears secure storage, and sets '
        'AuthUnauthenticated(sessionExpired: false)',
        () {},
      );

      // TODO(Plan 07-03): deleteAccount() on a 2xx response clears
      // secure storage, sets AuthUnauthenticated, and records an
      // 'account_deletion' consent event.
      test(
        "deleteAccount() on a 2xx response clears secure storage, "
        "sets AuthUnauthenticated, and records an 'account_deletion' "
        'consent event',
        () {},
      );

      // TODO(Plan 07-03): deleteAccount() on a non-2xx response throws
      // AccountDeletionException and leaves state/storage untouched.
      test(
        'deleteAccount() on a non-2xx response throws '
        'AccountDeletionException and leaves state/storage untouched',
        () {},
      );
    },
  );

  group(
    'realmDiscoveryReadyProvider',
    skip: 'Awaiting Plan 07-03 implementation',
    () {
      // TODO(Plan 07-03): returns true on HTTP 200 from the discovery
      // endpoint.
      test(
        'returns true on HTTP 200 from the discovery endpoint',
        () {},
      );

      // TODO(Plan 07-03): returns false on a non-200 response or a
      // thrown exception.
      test(
        'returns false on a non-200 response or a thrown exception',
        () {},
      );
    },
  );
}
