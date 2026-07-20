// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the path to the decompressed `off_reference.sqlite` file.
///
/// The default value is `null` (no reference DB path available). Overridden
/// in `main()` via `ProviderScope(overrides: [offRefPathProvider
/// .overrideWithValue(path)])` after `ensureOffReferenceDb()` completes.
///
/// Using a simple synchronous override avoids async providers at the root
/// level while still allowing the path to flow into [appDatabaseProvider].

@ProviderFor(offRefPath)
final offRefPathProvider = OffRefPathProvider._();

/// Provides the path to the decompressed `off_reference.sqlite` file.
///
/// The default value is `null` (no reference DB path available). Overridden
/// in `main()` via `ProviderScope(overrides: [offRefPathProvider
/// .overrideWithValue(path)])` after `ensureOffReferenceDb()` completes.
///
/// Using a simple synchronous override avoids async providers at the root
/// level while still allowing the path to flow into [appDatabaseProvider].

final class OffRefPathProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// Provides the path to the decompressed `off_reference.sqlite` file.
  ///
  /// The default value is `null` (no reference DB path available). Overridden
  /// in `main()` via `ProviderScope(overrides: [offRefPathProvider
  /// .overrideWithValue(path)])` after `ensureOffReferenceDb()` completes.
  ///
  /// Using a simple synchronous override avoids async providers at the root
  /// level while still allowing the path to flow into [appDatabaseProvider].
  OffRefPathProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'offRefPathProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$offRefPathHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return offRefPath(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$offRefPathHash() => r'72f92416552325db1aca318d23dccfe209deff57';

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

String _$appDatabaseHash() => r'6d1b5009366a13da03a90406413b43d5abf96d3f';

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
