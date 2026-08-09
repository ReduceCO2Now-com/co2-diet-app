// Session-cached readiness gate for Keycloak's realm OIDC discovery
// endpoint (07-RESEARCH.md Pattern 3).

import 'package:co2diet/core/di/auth_providers.dart';
import 'package:co2diet/domain/services/keycloak_config.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'realm_discovery_provider.g.dart';

/// Resolves `true` when Keycloak's realm OIDC discovery endpoint
/// (`{KeycloakConfig.issuer}/.well-known/openid-configuration`) responds
/// with HTTP 200; resolves `false` on any non-200 response or thrown
/// exception (timeout, DNS failure, offline) -- never propagates an error
/// state to callers.
///
/// Gates whether Settings' Account section renders at all (07-CONTEXT.md's
/// "Backend-readiness gate" decision) -- a first-party endpoint check, not
/// a third-party remote-config SDK, keeping the "no third-party SDKs"
/// privacy invariant intact.
///
/// keepAlive: true -- the check runs at most once per app session and is
/// cached until restart, per CONTEXT.md's locked "checked once per app
/// session, cached until restart" decision (Settings does not re-ping the
/// endpoint on every visit).
@Riverpod(keepAlive: true)
Future<bool> realmDiscoveryReady(Ref ref) async {
  try {
    final response = await ref
        .watch(authHttpClientProvider)
        .get(
          Uri.parse(
            '${KeycloakConfig.issuer}/.well-known/openid-configuration',
          ),
        )
        .timeout(const Duration(seconds: 3));
    return response.statusCode == 200;
  } on Exception catch (_) {
    return false;
  }
}
