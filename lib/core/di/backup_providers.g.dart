// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the [BackupMetadataDao] bound to the live `AppDatabase`.
///
/// keepAlive: true — DAO must persist for the full ProviderScope lifetime
/// because it is referenced by [backupMetadataRepositoryProvider], which is
/// also keep-alive.

@ProviderFor(backupMetadataDao)
final backupMetadataDaoProvider = BackupMetadataDaoProvider._();

/// Provides the [BackupMetadataDao] bound to the live `AppDatabase`.
///
/// keepAlive: true — DAO must persist for the full ProviderScope lifetime
/// because it is referenced by [backupMetadataRepositoryProvider], which is
/// also keep-alive.

final class BackupMetadataDaoProvider
    extends
        $FunctionalProvider<
          BackupMetadataDao,
          BackupMetadataDao,
          BackupMetadataDao
        >
    with $Provider<BackupMetadataDao> {
  /// Provides the [BackupMetadataDao] bound to the live `AppDatabase`.
  ///
  /// keepAlive: true — DAO must persist for the full ProviderScope lifetime
  /// because it is referenced by [backupMetadataRepositoryProvider], which is
  /// also keep-alive.
  BackupMetadataDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backupMetadataDaoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backupMetadataDaoHash();

  @$internal
  @override
  $ProviderElement<BackupMetadataDao> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BackupMetadataDao create(Ref ref) {
    return backupMetadataDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BackupMetadataDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BackupMetadataDao>(value),
    );
  }
}

String _$backupMetadataDaoHash() => r'51e0967e06dcd59de95fb6d970d3660bb1c97d49';

/// Provides the [BackupMetadataRepository] for the Backup & Restore feature.

@ProviderFor(backupMetadataRepository)
final backupMetadataRepositoryProvider = BackupMetadataRepositoryProvider._();

/// Provides the [BackupMetadataRepository] for the Backup & Restore feature.

final class BackupMetadataRepositoryProvider
    extends
        $FunctionalProvider<
          BackupMetadataRepository,
          BackupMetadataRepository,
          BackupMetadataRepository
        >
    with $Provider<BackupMetadataRepository> {
  /// Provides the [BackupMetadataRepository] for the Backup & Restore feature.
  BackupMetadataRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backupMetadataRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backupMetadataRepositoryHash();

  @$internal
  @override
  $ProviderElement<BackupMetadataRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BackupMetadataRepository create(Ref ref) {
    return backupMetadataRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BackupMetadataRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BackupMetadataRepository>(value),
    );
  }
}

String _$backupMetadataRepositoryHash() =>
    r'dec27dd74e69c01f3a536a43d331b43a83fa7215';

/// Provides the [BackupExportService], wired to every DAO it reads/writes
/// plus the app's own documents directory (`path_provider`).
///
/// This is an async provider (the only one in this codebase) because
/// `getApplicationDocumentsDirectory()` is inherently async — there is no
/// synchronous way to obtain the platform documents path. keepAlive: true
/// mirrors every other DAO/repository provider's full-session lifetime.

@ProviderFor(backupExportService)
final backupExportServiceProvider = BackupExportServiceProvider._();

/// Provides the [BackupExportService], wired to every DAO it reads/writes
/// plus the app's own documents directory (`path_provider`).
///
/// This is an async provider (the only one in this codebase) because
/// `getApplicationDocumentsDirectory()` is inherently async — there is no
/// synchronous way to obtain the platform documents path. keepAlive: true
/// mirrors every other DAO/repository provider's full-session lifetime.

final class BackupExportServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<BackupExportService>,
          BackupExportService,
          FutureOr<BackupExportService>
        >
    with
        $FutureModifier<BackupExportService>,
        $FutureProvider<BackupExportService> {
  /// Provides the [BackupExportService], wired to every DAO it reads/writes
  /// plus the app's own documents directory (`path_provider`).
  ///
  /// This is an async provider (the only one in this codebase) because
  /// `getApplicationDocumentsDirectory()` is inherently async — there is no
  /// synchronous way to obtain the platform documents path. keepAlive: true
  /// mirrors every other DAO/repository provider's full-session lifetime.
  BackupExportServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backupExportServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backupExportServiceHash();

  @$internal
  @override
  $FutureProviderElement<BackupExportService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BackupExportService> create(Ref ref) {
    return backupExportService(ref);
  }
}

String _$backupExportServiceHash() =>
    r'da5fa70cc36eb6193ef560ed95e4d687455f87e7';

/// A seam over `file_selector`'s top-level `openFile` function.
///
/// `openFile` is a top-level function, not a class method — mocktail
/// cannot mock top-level functions directly. Overriding this provider in
/// tests (`filePickerProvider.overrideWithValue(...)`) lets
/// `BackupNotifier.pickAndPreviewRestoreFile` be tested for both a
/// successful pick and a user-cancelled pick (`null`) without touching
/// the real OS document picker.

@ProviderFor(filePicker)
final filePickerProvider = FilePickerProvider._();

/// A seam over `file_selector`'s top-level `openFile` function.
///
/// `openFile` is a top-level function, not a class method — mocktail
/// cannot mock top-level functions directly. Overriding this provider in
/// tests (`filePickerProvider.overrideWithValue(...)`) lets
/// `BackupNotifier.pickAndPreviewRestoreFile` be tested for both a
/// successful pick and a user-cancelled pick (`null`) without touching
/// the real OS document picker.

final class FilePickerProvider
    extends $FunctionalProvider<FilePickerFn, FilePickerFn, FilePickerFn>
    with $Provider<FilePickerFn> {
  /// A seam over `file_selector`'s top-level `openFile` function.
  ///
  /// `openFile` is a top-level function, not a class method — mocktail
  /// cannot mock top-level functions directly. Overriding this provider in
  /// tests (`filePickerProvider.overrideWithValue(...)`) lets
  /// `BackupNotifier.pickAndPreviewRestoreFile` be tested for both a
  /// successful pick and a user-cancelled pick (`null`) without touching
  /// the real OS document picker.
  FilePickerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filePickerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filePickerHash();

  @$internal
  @override
  $ProviderElement<FilePickerFn> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FilePickerFn create(Ref ref) {
    return filePicker(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FilePickerFn value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FilePickerFn>(value),
    );
  }
}

String _$filePickerHash() => r'3fd6168648cd9f82b56e26ebb71ba85581878153';

/// Provides the [BackupApiClient] used by `BackupSyncNotifier` (Plan
/// 08-03) to push/pull the encrypted backup blob. Reuses the shared
/// `authHttpClientProvider` client (mirrors `AuthNotifier.deleteAccount`'s
/// convention) rather than constructing a second `http.Client`.
///
/// keepAlive: true — mirrors every other DAO/repository/client provider's
/// full-session lifetime in this file.

@ProviderFor(backupApiClient)
final backupApiClientProvider = BackupApiClientProvider._();

/// Provides the [BackupApiClient] used by `BackupSyncNotifier` (Plan
/// 08-03) to push/pull the encrypted backup blob. Reuses the shared
/// `authHttpClientProvider` client (mirrors `AuthNotifier.deleteAccount`'s
/// convention) rather than constructing a second `http.Client`.
///
/// keepAlive: true — mirrors every other DAO/repository/client provider's
/// full-session lifetime in this file.

final class BackupApiClientProvider
    extends
        $FunctionalProvider<BackupApiClient, BackupApiClient, BackupApiClient>
    with $Provider<BackupApiClient> {
  /// Provides the [BackupApiClient] used by `BackupSyncNotifier` (Plan
  /// 08-03) to push/pull the encrypted backup blob. Reuses the shared
  /// `authHttpClientProvider` client (mirrors `AuthNotifier.deleteAccount`'s
  /// convention) rather than constructing a second `http.Client`.
  ///
  /// keepAlive: true — mirrors every other DAO/repository/client provider's
  /// full-session lifetime in this file.
  BackupApiClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backupApiClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backupApiClientHash();

  @$internal
  @override
  $ProviderElement<BackupApiClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BackupApiClient create(Ref ref) {
    return backupApiClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BackupApiClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BackupApiClient>(value),
    );
  }
}

String _$backupApiClientHash() => r'cfb05de50354550485e3ea0352847aa003a35a1a';

/// A thin, non-keepAlive indirection over [BackupSyncConfig.enabled].
///
/// This indirection exists solely so widget tests can override cloud-backup
/// UI visibility with `ProviderScope(overrides:
/// [backupSyncEnabledProvider.overrideWithValue(true)])` without editing
/// the compile-time constant — production code never overrides it, so the
/// shipped default stays `false` regardless of this provider's existence.

@ProviderFor(backupSyncEnabled)
final backupSyncEnabledProvider = BackupSyncEnabledProvider._();

/// A thin, non-keepAlive indirection over [BackupSyncConfig.enabled].
///
/// This indirection exists solely so widget tests can override cloud-backup
/// UI visibility with `ProviderScope(overrides:
/// [backupSyncEnabledProvider.overrideWithValue(true)])` without editing
/// the compile-time constant — production code never overrides it, so the
/// shipped default stays `false` regardless of this provider's existence.

final class BackupSyncEnabledProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// A thin, non-keepAlive indirection over [BackupSyncConfig.enabled].
  ///
  /// This indirection exists solely so widget tests can override cloud-backup
  /// UI visibility with `ProviderScope(overrides:
  /// [backupSyncEnabledProvider.overrideWithValue(true)])` without editing
  /// the compile-time constant — production code never overrides it, so the
  /// shipped default stays `false` regardless of this provider's existence.
  BackupSyncEnabledProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backupSyncEnabledProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backupSyncEnabledHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return backupSyncEnabled(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$backupSyncEnabledHash() => r'5a1b58068c65c3e9f366f50bfcc920f66596cce3';

/// A seam over `path_provider`'s top-level `getTemporaryDirectory`
/// function, used by `BackupSyncNotifier.pullBackup` to write a pulled
/// backup blob to a temp file before restoring it.
///
/// `getTemporaryDirectory` is a top-level function, not a class method --
/// mocktail cannot mock top-level functions directly, and calling it
/// directly in a unit test throws before `TestWidgetsFlutterBinding` sets
/// up a platform-channel binding (mirrors `filePickerProvider`'s exact
/// problem/solution shape). Overriding this provider in tests
/// (`backupTempDirGetterProvider.overrideWithValue(() async =>
/// Directory.systemTemp)`) lets `pullBackup` be tested without a real
/// platform channel.

@ProviderFor(backupTempDirGetter)
final backupTempDirGetterProvider = BackupTempDirGetterProvider._();

/// A seam over `path_provider`'s top-level `getTemporaryDirectory`
/// function, used by `BackupSyncNotifier.pullBackup` to write a pulled
/// backup blob to a temp file before restoring it.
///
/// `getTemporaryDirectory` is a top-level function, not a class method --
/// mocktail cannot mock top-level functions directly, and calling it
/// directly in a unit test throws before `TestWidgetsFlutterBinding` sets
/// up a platform-channel binding (mirrors `filePickerProvider`'s exact
/// problem/solution shape). Overriding this provider in tests
/// (`backupTempDirGetterProvider.overrideWithValue(() async =>
/// Directory.systemTemp)`) lets `pullBackup` be tested without a real
/// platform channel.

final class BackupTempDirGetterProvider
    extends
        $FunctionalProvider<
          Future<Directory> Function(),
          Future<Directory> Function(),
          Future<Directory> Function()
        >
    with $Provider<Future<Directory> Function()> {
  /// A seam over `path_provider`'s top-level `getTemporaryDirectory`
  /// function, used by `BackupSyncNotifier.pullBackup` to write a pulled
  /// backup blob to a temp file before restoring it.
  ///
  /// `getTemporaryDirectory` is a top-level function, not a class method --
  /// mocktail cannot mock top-level functions directly, and calling it
  /// directly in a unit test throws before `TestWidgetsFlutterBinding` sets
  /// up a platform-channel binding (mirrors `filePickerProvider`'s exact
  /// problem/solution shape). Overriding this provider in tests
  /// (`backupTempDirGetterProvider.overrideWithValue(() async =>
  /// Directory.systemTemp)`) lets `pullBackup` be tested without a real
  /// platform channel.
  BackupTempDirGetterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backupTempDirGetterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backupTempDirGetterHash();

  @$internal
  @override
  $ProviderElement<Future<Directory> Function()> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Future<Directory> Function() create(Ref ref) {
    return backupTempDirGetter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Future<Directory> Function() value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Future<Directory> Function()>(value),
    );
  }
}

String _$backupTempDirGetterHash() =>
    r'e10e00b65cfa3b0ebf8164dd1a47a3af66f8591b';
