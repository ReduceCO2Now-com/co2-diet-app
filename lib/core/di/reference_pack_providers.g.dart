// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reference_pack_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the [http.Client] used by [referencePackApiClientProvider].
///
/// keepAlive: true, mirrors [authHttpClientProvider]'s (`auth_providers
/// .dart`) rationale -- `ref.onDispose` closes the client cleanly on
/// ProviderScope disposal.

@ProviderFor(referencePackHttpClient)
final referencePackHttpClientProvider = ReferencePackHttpClientProvider._();

/// Provides the [http.Client] used by [referencePackApiClientProvider].
///
/// keepAlive: true, mirrors [authHttpClientProvider]'s (`auth_providers
/// .dart`) rationale -- `ref.onDispose` closes the client cleanly on
/// ProviderScope disposal.

final class ReferencePackHttpClientProvider
    extends $FunctionalProvider<http.Client, http.Client, http.Client>
    with $Provider<http.Client> {
  /// Provides the [http.Client] used by [referencePackApiClientProvider].
  ///
  /// keepAlive: true, mirrors [authHttpClientProvider]'s (`auth_providers
  /// .dart`) rationale -- `ref.onDispose` closes the client cleanly on
  /// ProviderScope disposal.
  ReferencePackHttpClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'referencePackHttpClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$referencePackHttpClientHash();

  @$internal
  @override
  $ProviderElement<http.Client> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  http.Client create(Ref ref) {
    return referencePackHttpClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(http.Client value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<http.Client>(value),
    );
  }
}

String _$referencePackHttpClientHash() =>
    r'071531da6f0e3d7f2523398a9cc40e4860b7fdd9';

/// Provides the [ReferencePackApiClient] bound to
/// [ReferencePackConfig.manifestUrl].

@ProviderFor(referencePackApiClient)
final referencePackApiClientProvider = ReferencePackApiClientProvider._();

/// Provides the [ReferencePackApiClient] bound to
/// [ReferencePackConfig.manifestUrl].

final class ReferencePackApiClientProvider
    extends
        $FunctionalProvider<
          ReferencePackApiClient,
          ReferencePackApiClient,
          ReferencePackApiClient
        >
    with $Provider<ReferencePackApiClient> {
  /// Provides the [ReferencePackApiClient] bound to
  /// [ReferencePackConfig.manifestUrl].
  ReferencePackApiClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'referencePackApiClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$referencePackApiClientHash();

  @$internal
  @override
  $ProviderElement<ReferencePackApiClient> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReferencePackApiClient create(Ref ref) {
    return referencePackApiClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReferencePackApiClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReferencePackApiClient>(value),
    );
  }
}

String _$referencePackApiClientHash() =>
    r'035a650187e1f42699a37bcb18fbc71afeb9e336';

/// Provides the [DiskSpaceChecker] used for the disk-space preflight check.

@ProviderFor(diskSpaceChecker)
final diskSpaceCheckerProvider = DiskSpaceCheckerProvider._();

/// Provides the [DiskSpaceChecker] used for the disk-space preflight check.

final class DiskSpaceCheckerProvider
    extends
        $FunctionalProvider<
          DiskSpaceChecker,
          DiskSpaceChecker,
          DiskSpaceChecker
        >
    with $Provider<DiskSpaceChecker> {
  /// Provides the [DiskSpaceChecker] used for the disk-space preflight check.
  DiskSpaceCheckerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'diskSpaceCheckerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$diskSpaceCheckerHash();

  @$internal
  @override
  $ProviderElement<DiskSpaceChecker> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DiskSpaceChecker create(Ref ref) {
    return diskSpaceChecker(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DiskSpaceChecker value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DiskSpaceChecker>(value),
    );
  }
}

String _$diskSpaceCheckerHash() => r'534c7cc206ebc9b2b9da661b3364a6ae3e5d258c';

/// Provides the [ChecksumVerifier] used to verify downloaded files before
/// they are trusted.

@ProviderFor(checksumVerifier)
final checksumVerifierProvider = ChecksumVerifierProvider._();

/// Provides the [ChecksumVerifier] used to verify downloaded files before
/// they are trusted.

final class ChecksumVerifierProvider
    extends
        $FunctionalProvider<
          ChecksumVerifier,
          ChecksumVerifier,
          ChecksumVerifier
        >
    with $Provider<ChecksumVerifier> {
  /// Provides the [ChecksumVerifier] used to verify downloaded files before
  /// they are trusted.
  ChecksumVerifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'checksumVerifierProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$checksumVerifierHash();

  @$internal
  @override
  $ProviderElement<ChecksumVerifier> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ChecksumVerifier create(Ref ref) {
    return checksumVerifier(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChecksumVerifier value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChecksumVerifier>(value),
    );
  }
}

String _$checksumVerifierHash() => r'5fbb5debebbb03f746efac5ad24c97967c638ea6';

/// Provides the [DownloadManager] wrapping `background_downloader`.

@ProviderFor(downloadManager)
final downloadManagerProvider = DownloadManagerProvider._();

/// Provides the [DownloadManager] wrapping `background_downloader`.

final class DownloadManagerProvider
    extends
        $FunctionalProvider<DownloadManager, DownloadManager, DownloadManager>
    with $Provider<DownloadManager> {
  /// Provides the [DownloadManager] wrapping `background_downloader`.
  DownloadManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'downloadManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$downloadManagerHash();

  @$internal
  @override
  $ProviderElement<DownloadManager> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DownloadManager create(Ref ref) {
    return downloadManager(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DownloadManager value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DownloadManager>(value),
    );
  }
}

String _$downloadManagerHash() => r'6fe42f348dc5dffe20c45a216581f84d33e461b5';

/// Provides the [ReferencePackExtractor] used for full-pack swap-in/revert.

@ProviderFor(referencePackExtractor)
final referencePackExtractorProvider = ReferencePackExtractorProvider._();

/// Provides the [ReferencePackExtractor] used for full-pack swap-in/revert.

final class ReferencePackExtractorProvider
    extends
        $FunctionalProvider<
          ReferencePackExtractor,
          ReferencePackExtractor,
          ReferencePackExtractor
        >
    with $Provider<ReferencePackExtractor> {
  /// Provides the [ReferencePackExtractor] used for full-pack swap-in/revert.
  ReferencePackExtractorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'referencePackExtractorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$referencePackExtractorHash();

  @$internal
  @override
  $ProviderElement<ReferencePackExtractor> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReferencePackExtractor create(Ref ref) {
    return referencePackExtractor(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReferencePackExtractor value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReferencePackExtractor>(value),
    );
  }
}

String _$referencePackExtractorHash() =>
    r'c135b2d01744a6b44b7e1092dc0ccf34aa45ab9f';

/// Provides the [DeltaApplier] used for delta-download completion.

@ProviderFor(deltaApplier)
final deltaApplierProvider = DeltaApplierProvider._();

/// Provides the [DeltaApplier] used for delta-download completion.

final class DeltaApplierProvider
    extends $FunctionalProvider<DeltaApplier, DeltaApplier, DeltaApplier>
    with $Provider<DeltaApplier> {
  /// Provides the [DeltaApplier] used for delta-download completion.
  DeltaApplierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deltaApplierProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deltaApplierHash();

  @$internal
  @override
  $ProviderElement<DeltaApplier> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeltaApplier create(Ref ref) {
    return deltaApplier(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeltaApplier value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeltaApplier>(value),
    );
  }
}

String _$deltaApplierHash() => r'27adf98336c2220b6188180838f52a142310014e';

/// Provides the [ReferencePackVersionStore] used to read/write the
/// installed full-pack version marker.

@ProviderFor(referencePackVersionStore)
final referencePackVersionStoreProvider = ReferencePackVersionStoreProvider._();

/// Provides the [ReferencePackVersionStore] used to read/write the
/// installed full-pack version marker.

final class ReferencePackVersionStoreProvider
    extends
        $FunctionalProvider<
          ReferencePackVersionStore,
          ReferencePackVersionStore,
          ReferencePackVersionStore
        >
    with $Provider<ReferencePackVersionStore> {
  /// Provides the [ReferencePackVersionStore] used to read/write the
  /// installed full-pack version marker.
  ReferencePackVersionStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'referencePackVersionStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$referencePackVersionStoreHash();

  @$internal
  @override
  $ProviderElement<ReferencePackVersionStore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReferencePackVersionStore create(Ref ref) {
    return referencePackVersionStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReferencePackVersionStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReferencePackVersionStore>(value),
    );
  }
}

String _$referencePackVersionStoreHash() =>
    r'8a14ed5d0287d8eec8479854a951324af6a9a096';

/// Provides the [IReferencePackRepository] -- the single, fully-wired
/// orchestration point Plan 09-05's UI and Plan 09-06's automatic refresh
/// consume. The declared return type is the abstract interface, matching
/// [profileRepositoryProvider]'s (`providers.dart`) data-layer-boundary
/// convention -- callers never depend on the concrete
/// [ReferencePackRepository] class.

@ProviderFor(referencePackRepository)
final referencePackRepositoryProvider = ReferencePackRepositoryProvider._();

/// Provides the [IReferencePackRepository] -- the single, fully-wired
/// orchestration point Plan 09-05's UI and Plan 09-06's automatic refresh
/// consume. The declared return type is the abstract interface, matching
/// [profileRepositoryProvider]'s (`providers.dart`) data-layer-boundary
/// convention -- callers never depend on the concrete
/// [ReferencePackRepository] class.

final class ReferencePackRepositoryProvider
    extends
        $FunctionalProvider<
          IReferencePackRepository,
          IReferencePackRepository,
          IReferencePackRepository
        >
    with $Provider<IReferencePackRepository> {
  /// Provides the [IReferencePackRepository] -- the single, fully-wired
  /// orchestration point Plan 09-05's UI and Plan 09-06's automatic refresh
  /// consume. The declared return type is the abstract interface, matching
  /// [profileRepositoryProvider]'s (`providers.dart`) data-layer-boundary
  /// convention -- callers never depend on the concrete
  /// [ReferencePackRepository] class.
  ReferencePackRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'referencePackRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$referencePackRepositoryHash();

  @$internal
  @override
  $ProviderElement<IReferencePackRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IReferencePackRepository create(Ref ref) {
    return referencePackRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IReferencePackRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IReferencePackRepository>(value),
    );
  }
}

String _$referencePackRepositoryHash() =>
    r'61581ea99b6db22cedabd648fe9b0fa87b0f9364';
