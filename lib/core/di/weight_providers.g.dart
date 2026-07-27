// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the [WeightDao] bound to the live `AppDatabase`.
///
/// keepAlive: true — DAO must persist for the full ProviderScope lifetime
/// because it is referenced by [weightRepositoryProvider] which is also
/// keep-alive.

@ProviderFor(weightDao)
final weightDaoProvider = WeightDaoProvider._();

/// Provides the [WeightDao] bound to the live `AppDatabase`.
///
/// keepAlive: true — DAO must persist for the full ProviderScope lifetime
/// because it is referenced by [weightRepositoryProvider] which is also
/// keep-alive.

final class WeightDaoProvider
    extends $FunctionalProvider<WeightDao, WeightDao, WeightDao>
    with $Provider<WeightDao> {
  /// Provides the [WeightDao] bound to the live `AppDatabase`.
  ///
  /// keepAlive: true — DAO must persist for the full ProviderScope lifetime
  /// because it is referenced by [weightRepositoryProvider] which is also
  /// keep-alive.
  WeightDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'weightDaoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$weightDaoHash();

  @$internal
  @override
  $ProviderElement<WeightDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  WeightDao create(Ref ref) {
    return weightDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WeightDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WeightDao>(value),
    );
  }
}

String _$weightDaoHash() => r'c2eec26ea3ace63026b5a939a6f2db4cba7e0b96';

/// Provides the [IWeightRepository] for the Weight Tracking feature.
///
/// The declared return type is the abstract [IWeightRepository]
/// interface — callers in the presentation layer (`WeightNotifier`, Plan
/// 05-13's screen) depend only on the interface, not on [WeightRepository].

@ProviderFor(weightRepository)
final weightRepositoryProvider = WeightRepositoryProvider._();

/// Provides the [IWeightRepository] for the Weight Tracking feature.
///
/// The declared return type is the abstract [IWeightRepository]
/// interface — callers in the presentation layer (`WeightNotifier`, Plan
/// 05-13's screen) depend only on the interface, not on [WeightRepository].

final class WeightRepositoryProvider
    extends
        $FunctionalProvider<
          IWeightRepository,
          IWeightRepository,
          IWeightRepository
        >
    with $Provider<IWeightRepository> {
  /// Provides the [IWeightRepository] for the Weight Tracking feature.
  ///
  /// The declared return type is the abstract [IWeightRepository]
  /// interface — callers in the presentation layer (`WeightNotifier`, Plan
  /// 05-13's screen) depend only on the interface, not on [WeightRepository].
  WeightRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'weightRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$weightRepositoryHash();

  @$internal
  @override
  $ProviderElement<IWeightRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IWeightRepository create(Ref ref) {
    return weightRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IWeightRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IWeightRepository>(value),
    );
  }
}

String _$weightRepositoryHash() => r'f0315f2c55928baa8870c0f3f72445b4bd689aee';
