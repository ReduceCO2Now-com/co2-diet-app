// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'co2_settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the [Co2SettingsDao] bound to the live `AppDatabase`.
///
/// keepAlive: true — DAO must persist for the full ProviderScope lifetime
/// because it is referenced by [co2SettingsRepositoryProvider] which is
/// also keep-alive.

@ProviderFor(co2SettingsDao)
final co2SettingsDaoProvider = Co2SettingsDaoProvider._();

/// Provides the [Co2SettingsDao] bound to the live `AppDatabase`.
///
/// keepAlive: true — DAO must persist for the full ProviderScope lifetime
/// because it is referenced by [co2SettingsRepositoryProvider] which is
/// also keep-alive.

final class Co2SettingsDaoProvider
    extends $FunctionalProvider<Co2SettingsDao, Co2SettingsDao, Co2SettingsDao>
    with $Provider<Co2SettingsDao> {
  /// Provides the [Co2SettingsDao] bound to the live `AppDatabase`.
  ///
  /// keepAlive: true — DAO must persist for the full ProviderScope lifetime
  /// because it is referenced by [co2SettingsRepositoryProvider] which is
  /// also keep-alive.
  Co2SettingsDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'co2SettingsDaoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$co2SettingsDaoHash();

  @$internal
  @override
  $ProviderElement<Co2SettingsDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Co2SettingsDao create(Ref ref) {
    return co2SettingsDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Co2SettingsDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Co2SettingsDao>(value),
    );
  }
}

String _$co2SettingsDaoHash() => r'bfbad1263efaea3cd76a61df5b492d87d3cb4d72';

/// Provides the [ICo2SettingsRepository] for the CO2 Settings feature.
///
/// The declared return type is the abstract [ICo2SettingsRepository]
/// interface — callers in the presentation layer (notifiers, Plan 05-12)
/// depend only on the interface, not on [Co2SettingsRepository].

@ProviderFor(co2SettingsRepository)
final co2SettingsRepositoryProvider = Co2SettingsRepositoryProvider._();

/// Provides the [ICo2SettingsRepository] for the CO2 Settings feature.
///
/// The declared return type is the abstract [ICo2SettingsRepository]
/// interface — callers in the presentation layer (notifiers, Plan 05-12)
/// depend only on the interface, not on [Co2SettingsRepository].

final class Co2SettingsRepositoryProvider
    extends
        $FunctionalProvider<
          ICo2SettingsRepository,
          ICo2SettingsRepository,
          ICo2SettingsRepository
        >
    with $Provider<ICo2SettingsRepository> {
  /// Provides the [ICo2SettingsRepository] for the CO2 Settings feature.
  ///
  /// The declared return type is the abstract [ICo2SettingsRepository]
  /// interface — callers in the presentation layer (notifiers, Plan 05-12)
  /// depend only on the interface, not on [Co2SettingsRepository].
  Co2SettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'co2SettingsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$co2SettingsRepositoryHash();

  @$internal
  @override
  $ProviderElement<ICo2SettingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ICo2SettingsRepository create(Ref ref) {
    return co2SettingsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ICo2SettingsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ICo2SettingsRepository>(value),
    );
  }
}

String _$co2SettingsRepositoryHash() =>
    r'e23961866cdb596eecebf9bb9fc4964f6ef87985';
