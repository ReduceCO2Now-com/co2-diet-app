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

/// Provides the [ConsentRecordsDao] bound to the live `AppDatabase`.
///
/// keepAlive: true — DAO must persist for the full ProviderScope lifetime
/// because it is referenced by [consentRepositoryProvider], which is also
/// keep-alive.

@ProviderFor(consentRecordsDao)
final consentRecordsDaoProvider = ConsentRecordsDaoProvider._();

/// Provides the [ConsentRecordsDao] bound to the live `AppDatabase`.
///
/// keepAlive: true — DAO must persist for the full ProviderScope lifetime
/// because it is referenced by [consentRepositoryProvider], which is also
/// keep-alive.

final class ConsentRecordsDaoProvider
    extends
        $FunctionalProvider<
          ConsentRecordsDao,
          ConsentRecordsDao,
          ConsentRecordsDao
        >
    with $Provider<ConsentRecordsDao> {
  /// Provides the [ConsentRecordsDao] bound to the live `AppDatabase`.
  ///
  /// keepAlive: true — DAO must persist for the full ProviderScope lifetime
  /// because it is referenced by [consentRepositoryProvider], which is also
  /// keep-alive.
  ConsentRecordsDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'consentRecordsDaoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$consentRecordsDaoHash();

  @$internal
  @override
  $ProviderElement<ConsentRecordsDao> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ConsentRecordsDao create(Ref ref) {
    return consentRecordsDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConsentRecordsDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConsentRecordsDao>(value),
    );
  }
}

String _$consentRecordsDaoHash() => r'097d4d4e755f9ab015e872e4c5da6e5e38b7e897';

/// Provides the [IConsentRepository] for the consent-recording feature.
///
/// The declared return type is the abstract [IConsentRepository]
/// interface — callers in the presentation layer (`ConsentNotifier`)
/// depend only on the interface, not on [DriftConsentRepository].

@ProviderFor(consentRepository)
final consentRepositoryProvider = ConsentRepositoryProvider._();

/// Provides the [IConsentRepository] for the consent-recording feature.
///
/// The declared return type is the abstract [IConsentRepository]
/// interface — callers in the presentation layer (`ConsentNotifier`)
/// depend only on the interface, not on [DriftConsentRepository].

final class ConsentRepositoryProvider
    extends
        $FunctionalProvider<
          IConsentRepository,
          IConsentRepository,
          IConsentRepository
        >
    with $Provider<IConsentRepository> {
  /// Provides the [IConsentRepository] for the consent-recording feature.
  ///
  /// The declared return type is the abstract [IConsentRepository]
  /// interface — callers in the presentation layer (`ConsentNotifier`)
  /// depend only on the interface, not on [DriftConsentRepository].
  ConsentRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'consentRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$consentRepositoryHash();

  @$internal
  @override
  $ProviderElement<IConsentRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IConsentRepository create(Ref ref) {
    return consentRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IConsentRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IConsentRepository>(value),
    );
  }
}

String _$consentRepositoryHash() => r'e1a7bd14d4f2bab16be3138f2fab0f5be7f231fe';

/// Provides the running app's version string, formatted as
/// `'{version}+{buildNumber}'` (e.g. `'0.1.0+1'`) — matching the
/// convention documented in `consent_records_table.dart`.

@ProviderFor(appVersion)
final appVersionProvider = AppVersionProvider._();

/// Provides the running app's version string, formatted as
/// `'{version}+{buildNumber}'` (e.g. `'0.1.0+1'`) — matching the
/// convention documented in `consent_records_table.dart`.

final class AppVersionProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// Provides the running app's version string, formatted as
  /// `'{version}+{buildNumber}'` (e.g. `'0.1.0+1'`) — matching the
  /// convention documented in `consent_records_table.dart`.
  AppVersionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appVersionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appVersionHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return appVersion(ref);
  }
}

String _$appVersionHash() => r'9634514c60acb1f79941bdacd697f695d6621e0c';
