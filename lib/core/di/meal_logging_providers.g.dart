// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_logging_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the [MealEntryDao] bound to the live `AppDatabase`.
///
/// keepAlive: true — DAO must persist for the full ProviderScope lifetime
/// because it is referenced by [mealEntryRepositoryProvider] which is also
/// keep-alive.

@ProviderFor(mealEntryDao)
final mealEntryDaoProvider = MealEntryDaoProvider._();

/// Provides the [MealEntryDao] bound to the live `AppDatabase`.
///
/// keepAlive: true — DAO must persist for the full ProviderScope lifetime
/// because it is referenced by [mealEntryRepositoryProvider] which is also
/// keep-alive.

final class MealEntryDaoProvider
    extends $FunctionalProvider<MealEntryDao, MealEntryDao, MealEntryDao>
    with $Provider<MealEntryDao> {
  /// Provides the [MealEntryDao] bound to the live `AppDatabase`.
  ///
  /// keepAlive: true — DAO must persist for the full ProviderScope lifetime
  /// because it is referenced by [mealEntryRepositoryProvider] which is also
  /// keep-alive.
  MealEntryDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mealEntryDaoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mealEntryDaoHash();

  @$internal
  @override
  $ProviderElement<MealEntryDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MealEntryDao create(Ref ref) {
    return mealEntryDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MealEntryDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MealEntryDao>(value),
    );
  }
}

String _$mealEntryDaoHash() => r'bc1946db3bbd30785672499a74265e0768586a6d';

/// Provides the [UserFoodDao] bound to the live `AppDatabase`.
///
/// keepAlive: true — DAO must persist for the full ProviderScope lifetime
/// because it is referenced by [userFoodRepositoryProvider] which is also
/// keep-alive.

@ProviderFor(userFoodDao)
final userFoodDaoProvider = UserFoodDaoProvider._();

/// Provides the [UserFoodDao] bound to the live `AppDatabase`.
///
/// keepAlive: true — DAO must persist for the full ProviderScope lifetime
/// because it is referenced by [userFoodRepositoryProvider] which is also
/// keep-alive.

final class UserFoodDaoProvider
    extends $FunctionalProvider<UserFoodDao, UserFoodDao, UserFoodDao>
    with $Provider<UserFoodDao> {
  /// Provides the [UserFoodDao] bound to the live `AppDatabase`.
  ///
  /// keepAlive: true — DAO must persist for the full ProviderScope lifetime
  /// because it is referenced by [userFoodRepositoryProvider] which is also
  /// keep-alive.
  UserFoodDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userFoodDaoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userFoodDaoHash();

  @$internal
  @override
  $ProviderElement<UserFoodDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UserFoodDao create(Ref ref) {
    return userFoodDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserFoodDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserFoodDao>(value),
    );
  }
}

String _$userFoodDaoHash() => r'3af67b66642fa2293dab2827cc3db039e67bc8bf';

/// Provides the [IMealEntryRepository] for the meal-logging feature.
///
/// The declared return type is the abstract [IMealEntryRepository]
/// interface — callers in the presentation layer (notifiers, Plan 04-07)
/// depend only on the interface, not on [MealEntryRepository].

@ProviderFor(mealEntryRepository)
final mealEntryRepositoryProvider = MealEntryRepositoryProvider._();

/// Provides the [IMealEntryRepository] for the meal-logging feature.
///
/// The declared return type is the abstract [IMealEntryRepository]
/// interface — callers in the presentation layer (notifiers, Plan 04-07)
/// depend only on the interface, not on [MealEntryRepository].

final class MealEntryRepositoryProvider
    extends
        $FunctionalProvider<
          IMealEntryRepository,
          IMealEntryRepository,
          IMealEntryRepository
        >
    with $Provider<IMealEntryRepository> {
  /// Provides the [IMealEntryRepository] for the meal-logging feature.
  ///
  /// The declared return type is the abstract [IMealEntryRepository]
  /// interface — callers in the presentation layer (notifiers, Plan 04-07)
  /// depend only on the interface, not on [MealEntryRepository].
  MealEntryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mealEntryRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mealEntryRepositoryHash();

  @$internal
  @override
  $ProviderElement<IMealEntryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IMealEntryRepository create(Ref ref) {
    return mealEntryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IMealEntryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IMealEntryRepository>(value),
    );
  }
}

String _$mealEntryRepositoryHash() =>
    r'cb272a3429866c9ece5197ffc4f6326a6b8b946c';

/// Provides the [IUserFoodRepository] for the custom-food/override feature.
///
/// The declared return type is the abstract [IUserFoodRepository]
/// interface — callers in the presentation layer depend only on the
/// interface, not on [UserFoodRepository].

@ProviderFor(userFoodRepository)
final userFoodRepositoryProvider = UserFoodRepositoryProvider._();

/// Provides the [IUserFoodRepository] for the custom-food/override feature.
///
/// The declared return type is the abstract [IUserFoodRepository]
/// interface — callers in the presentation layer depend only on the
/// interface, not on [UserFoodRepository].

final class UserFoodRepositoryProvider
    extends
        $FunctionalProvider<
          IUserFoodRepository,
          IUserFoodRepository,
          IUserFoodRepository
        >
    with $Provider<IUserFoodRepository> {
  /// Provides the [IUserFoodRepository] for the custom-food/override feature.
  ///
  /// The declared return type is the abstract [IUserFoodRepository]
  /// interface — callers in the presentation layer depend only on the
  /// interface, not on [UserFoodRepository].
  UserFoodRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userFoodRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userFoodRepositoryHash();

  @$internal
  @override
  $ProviderElement<IUserFoodRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IUserFoodRepository create(Ref ref) {
    return userFoodRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IUserFoodRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IUserFoodRepository>(value),
    );
  }
}

String _$userFoodRepositoryHash() =>
    r'83e5f694f70e9719be00bd1f825e30d395569a21';
