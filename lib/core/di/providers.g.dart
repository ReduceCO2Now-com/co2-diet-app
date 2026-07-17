// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the singleton [AppDatabase] for the entire app lifetime.
///
/// keepAlive: true — the database connection MUST persist for the full
/// ProviderScope lifetime. Disposing and recreating the DB mid-session
/// would drop pending streams and in-flight writes.
///
/// ref.onDispose ensures the SQLite connection is closed cleanly on
/// ProviderScope disposal (e.g., during widget tests).

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

/// Provides the singleton [AppDatabase] for the entire app lifetime.
///
/// keepAlive: true — the database connection MUST persist for the full
/// ProviderScope lifetime. Disposing and recreating the DB mid-session
/// would drop pending streams and in-flight writes.
///
/// ref.onDispose ensures the SQLite connection is closed cleanly on
/// ProviderScope disposal (e.g., during widget tests).

final class AppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  /// Provides the singleton [AppDatabase] for the entire app lifetime.
  ///
  /// keepAlive: true — the database connection MUST persist for the full
  /// ProviderScope lifetime. Disposing and recreating the DB mid-session
  /// would drop pending streams and in-flight writes.
  ///
  /// ref.onDispose ensures the SQLite connection is closed cleanly on
  /// ProviderScope disposal (e.g., during widget tests).
  AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'7b764723bbcb89fc8495c0edf02613ef6f56ec21';

/// Provides an [IProfileRepository] backed by the live [AppDatabase].
///
/// The declared return type is the abstract interface — callers in the
/// presentation layer depend only on [IProfileRepository], not on
/// [DriftProfileRepository]. This enforces the data-layer boundary.

@ProviderFor(profileRepository)
final profileRepositoryProvider = ProfileRepositoryProvider._();

/// Provides an [IProfileRepository] backed by the live [AppDatabase].
///
/// The declared return type is the abstract interface — callers in the
/// presentation layer depend only on [IProfileRepository], not on
/// [DriftProfileRepository]. This enforces the data-layer boundary.

final class ProfileRepositoryProvider
    extends
        $FunctionalProvider<
          IProfileRepository,
          IProfileRepository,
          IProfileRepository
        >
    with $Provider<IProfileRepository> {
  /// Provides an [IProfileRepository] backed by the live [AppDatabase].
  ///
  /// The declared return type is the abstract interface — callers in the
  /// presentation layer depend only on [IProfileRepository], not on
  /// [DriftProfileRepository]. This enforces the data-layer boundary.
  ProfileRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileRepositoryHash();

  @$internal
  @override
  $ProviderElement<IProfileRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IProfileRepository create(Ref ref) {
    return profileRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IProfileRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IProfileRepository>(value),
    );
  }
}

String _$profileRepositoryHash() => r'8a48fca8c7af88f3832e7ca17ecc2e437196a524';
