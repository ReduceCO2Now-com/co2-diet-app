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
