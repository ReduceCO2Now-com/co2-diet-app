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
