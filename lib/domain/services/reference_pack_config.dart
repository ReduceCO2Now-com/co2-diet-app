/// Centralized reference-pack CDN configuration.
///
/// **Every value in this class is an `[ASSUMED]` placeholder** pending a real
/// CDN/build-pipeline owner (see
/// `docs/data-contracts/reference-pack-manifest.md`'s `status: ASSUMED`
/// frontmatter -- "owner: unassigned... a coordination point per
/// `09-CONTEXT.md`, not yet owned by anyone"). Mirrors `KeycloakConfig`/
/// `BackendConfig`'s placeholder-value precedent ([Phase 07-02]) -- this is
/// the one place `ReferencePackApiClient` reads its manifest URL from, so
/// the eventual real-CDN handoff is a one-file change.
class ReferencePackConfig {
  const ReferencePackConfig._();

  /// Absolute HTTPS URL to the CDN's `manifest.json`.
  ///
  /// `[ASSUMED]` -- CDN hosting itself is an explicit out-of-scope
  /// coordination point per `09-CONTEXT.md`. MUST NOT be treated as a
  /// production contract.
  static const String manifestUrl =
      'https://cdn.example.com/off-pack/manifest.json';
}
