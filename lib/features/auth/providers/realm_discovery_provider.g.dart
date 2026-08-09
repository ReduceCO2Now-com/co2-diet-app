// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realm_discovery_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(realmDiscoveryReady)
final realmDiscoveryReadyProvider = RealmDiscoveryReadyProvider._();

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

final class RealmDiscoveryReadyProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
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
  RealmDiscoveryReadyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'realmDiscoveryReadyProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$realmDiscoveryReadyHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return realmDiscoveryReady(ref);
  }
}

String _$realmDiscoveryReadyHash() =>
    r'be86fd16ef9f81ef3b2e8026dd21b779b8d3b70b';
