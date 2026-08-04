// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'legal_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the [LegalDocumentLoader] used by Legal Consent / Legal Hub
/// screens to read `docs/legal/*.md` documents and their versions.
///
/// Not keepAlive — the loader is stateless (const constructor) and holds no
/// DB/stream resources, so it is cheap to reconstruct on demand.

@ProviderFor(legalDocumentLoader)
final legalDocumentLoaderProvider = LegalDocumentLoaderProvider._();

/// Provides the [LegalDocumentLoader] used by Legal Consent / Legal Hub
/// screens to read `docs/legal/*.md` documents and their versions.
///
/// Not keepAlive — the loader is stateless (const constructor) and holds no
/// DB/stream resources, so it is cheap to reconstruct on demand.

final class LegalDocumentLoaderProvider
    extends
        $FunctionalProvider<
          LegalDocumentLoader,
          LegalDocumentLoader,
          LegalDocumentLoader
        >
    with $Provider<LegalDocumentLoader> {
  /// Provides the [LegalDocumentLoader] used by Legal Consent / Legal Hub
  /// screens to read `docs/legal/*.md` documents and their versions.
  ///
  /// Not keepAlive — the loader is stateless (const constructor) and holds no
  /// DB/stream resources, so it is cheap to reconstruct on demand.
  LegalDocumentLoaderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'legalDocumentLoaderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$legalDocumentLoaderHash();

  @$internal
  @override
  $ProviderElement<LegalDocumentLoader> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LegalDocumentLoader create(Ref ref) {
    return legalDocumentLoader(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LegalDocumentLoader value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LegalDocumentLoader>(value),
    );
  }
}

String _$legalDocumentLoaderHash() =>
    r'f6f7e0f60d3369546920b30f8e92f24074a60043';
