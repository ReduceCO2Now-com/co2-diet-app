// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the [FoodCatalogDao] bound to the live `AppDatabase`.
///
/// keepAlive: true — DAO must persist for the full ProviderScope lifetime
/// because it is referenced by [foodCatalogRepositoryProvider] which is also
/// keep-alive.
///
/// Constructs an explicit [FoodCatalogDao] instance with [UserFoodDao]
/// wired in (LOG-11 override precedence) rather than using
/// `AppDatabase.foodCatalogDao`'s generated accessor — the generated
/// accessor's constructor call has no `userFoodDao` argument since
/// `@DriftAccessor`'s codegen only ever passes the attached database.

@ProviderFor(foodCatalogDao)
final foodCatalogDaoProvider = FoodCatalogDaoProvider._();

/// Provides the [FoodCatalogDao] bound to the live `AppDatabase`.
///
/// keepAlive: true — DAO must persist for the full ProviderScope lifetime
/// because it is referenced by [foodCatalogRepositoryProvider] which is also
/// keep-alive.
///
/// Constructs an explicit [FoodCatalogDao] instance with [UserFoodDao]
/// wired in (LOG-11 override precedence) rather than using
/// `AppDatabase.foodCatalogDao`'s generated accessor — the generated
/// accessor's constructor call has no `userFoodDao` argument since
/// `@DriftAccessor`'s codegen only ever passes the attached database.

final class FoodCatalogDaoProvider
    extends $FunctionalProvider<FoodCatalogDao, FoodCatalogDao, FoodCatalogDao>
    with $Provider<FoodCatalogDao> {
  /// Provides the [FoodCatalogDao] bound to the live `AppDatabase`.
  ///
  /// keepAlive: true — DAO must persist for the full ProviderScope lifetime
  /// because it is referenced by [foodCatalogRepositoryProvider] which is also
  /// keep-alive.
  ///
  /// Constructs an explicit [FoodCatalogDao] instance with [UserFoodDao]
  /// wired in (LOG-11 override precedence) rather than using
  /// `AppDatabase.foodCatalogDao`'s generated accessor — the generated
  /// accessor's constructor call has no `userFoodDao` argument since
  /// `@DriftAccessor`'s codegen only ever passes the attached database.
  FoodCatalogDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'foodCatalogDaoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$foodCatalogDaoHash();

  @$internal
  @override
  $ProviderElement<FoodCatalogDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FoodCatalogDao create(Ref ref) {
    return foodCatalogDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FoodCatalogDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FoodCatalogDao>(value),
    );
  }
}

String _$foodCatalogDaoHash() => r'7e7f68ac0514ca3276e96a5754ba6022af3bee85';

/// Provides the [OffApiClient] singleton.
///
/// keepAlive: true — [OffApiClient] is a stateless wrapper; keeping it alive
/// avoids repeated object allocation on every repository read.
///
/// Note: [configureOff] must be called exactly once before this provider is
/// first used (wired in `main()` — see Plan 02-04 Task 2).

@ProviderFor(offApiClient)
final offApiClientProvider = OffApiClientProvider._();

/// Provides the [OffApiClient] singleton.
///
/// keepAlive: true — [OffApiClient] is a stateless wrapper; keeping it alive
/// avoids repeated object allocation on every repository read.
///
/// Note: [configureOff] must be called exactly once before this provider is
/// first used (wired in `main()` — see Plan 02-04 Task 2).

final class OffApiClientProvider
    extends $FunctionalProvider<OffApiClient, OffApiClient, OffApiClient>
    with $Provider<OffApiClient> {
  /// Provides the [OffApiClient] singleton.
  ///
  /// keepAlive: true — [OffApiClient] is a stateless wrapper; keeping it alive
  /// avoids repeated object allocation on every repository read.
  ///
  /// Note: [configureOff] must be called exactly once before this provider is
  /// first used (wired in `main()` — see Plan 02-04 Task 2).
  OffApiClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'offApiClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$offApiClientHash();

  @$internal
  @override
  $ProviderElement<OffApiClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OffApiClient create(Ref ref) {
    return offApiClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OffApiClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OffApiClient>(value),
    );
  }
}

String _$offApiClientHash() => r'3a3d58c4f95eea5421d48acbb9c292f22259af3e';

/// Provides the [IFoodCatalogRepository] for the food search feature.
///
/// keepAlive: true — repository holds a reference to the DAO and API client
/// which are both keep-alive; consistency requires this provider to be
/// keep-alive as well.
///
/// The declared return type is the abstract [IFoodCatalogRepository]
/// interface — callers in the presentation layer (FoodSearchNotifier, Plan
/// 02-05) depend only on the interface, not on [FoodCatalogRepository].

@ProviderFor(foodCatalogRepository)
final foodCatalogRepositoryProvider = FoodCatalogRepositoryProvider._();

/// Provides the [IFoodCatalogRepository] for the food search feature.
///
/// keepAlive: true — repository holds a reference to the DAO and API client
/// which are both keep-alive; consistency requires this provider to be
/// keep-alive as well.
///
/// The declared return type is the abstract [IFoodCatalogRepository]
/// interface — callers in the presentation layer (FoodSearchNotifier, Plan
/// 02-05) depend only on the interface, not on [FoodCatalogRepository].

final class FoodCatalogRepositoryProvider
    extends
        $FunctionalProvider<
          IFoodCatalogRepository,
          IFoodCatalogRepository,
          IFoodCatalogRepository
        >
    with $Provider<IFoodCatalogRepository> {
  /// Provides the [IFoodCatalogRepository] for the food search feature.
  ///
  /// keepAlive: true — repository holds a reference to the DAO and API client
  /// which are both keep-alive; consistency requires this provider to be
  /// keep-alive as well.
  ///
  /// The declared return type is the abstract [IFoodCatalogRepository]
  /// interface — callers in the presentation layer (FoodSearchNotifier, Plan
  /// 02-05) depend only on the interface, not on [FoodCatalogRepository].
  FoodCatalogRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'foodCatalogRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$foodCatalogRepositoryHash();

  @$internal
  @override
  $ProviderElement<IFoodCatalogRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IFoodCatalogRepository create(Ref ref) {
    return foodCatalogRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IFoodCatalogRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IFoodCatalogRepository>(value),
    );
  }
}

String _$foodCatalogRepositoryHash() =>
    r'1aa1b2d661ec9c3b52a32a97ae3dd8fa7a31166f';
