// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'methodology_banner_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether any CO2-bearing row on-device (profile, meal entries, custom
/// foods) was estimated under an older methodology version than
/// [currentCo2MethodologyVersion].
///
/// Whole-table scans via `AppDatabase`'s DAOs directly (not a dedicated
/// repository method) -- mirrors `BackupExportService`'s established
/// precedent for cross-table reads that don't belong in any single
/// per-feature repository interface.

@ProviderFor(hasStaleMethodologyEntries)
final hasStaleMethodologyEntriesProvider =
    HasStaleMethodologyEntriesProvider._();

/// Whether any CO2-bearing row on-device (profile, meal entries, custom
/// foods) was estimated under an older methodology version than
/// [currentCo2MethodologyVersion].
///
/// Whole-table scans via `AppDatabase`'s DAOs directly (not a dedicated
/// repository method) -- mirrors `BackupExportService`'s established
/// precedent for cross-table reads that don't belong in any single
/// per-feature repository interface.

final class HasStaleMethodologyEntriesProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether any CO2-bearing row on-device (profile, meal entries, custom
  /// foods) was estimated under an older methodology version than
  /// [currentCo2MethodologyVersion].
  ///
  /// Whole-table scans via `AppDatabase`'s DAOs directly (not a dedicated
  /// repository method) -- mirrors `BackupExportService`'s established
  /// precedent for cross-table reads that don't belong in any single
  /// per-feature repository interface.
  HasStaleMethodologyEntriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hasStaleMethodologyEntriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hasStaleMethodologyEntriesHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return hasStaleMethodologyEntries(ref);
  }
}

String _$hasStaleMethodologyEntriesHash() =>
    r'87b17404ece391196521bf26165113946bdd5dc0';

/// Tracks the last CO2-methodology version the user dismissed the banner
/// for -- `null` when never dismissed.
///
/// keepAlive: true -- mirrors [OnboardingGateNotifier]'s established
/// rationale: [dismiss] is called from a widget callback (the banner's
/// dismiss IconButton) that may not keep an active watcher of this
/// provider alive across the `await`.

@ProviderFor(MethodologyBannerDismissalNotifier)
final methodologyBannerDismissalProvider =
    MethodologyBannerDismissalNotifierProvider._();

/// Tracks the last CO2-methodology version the user dismissed the banner
/// for -- `null` when never dismissed.
///
/// keepAlive: true -- mirrors [OnboardingGateNotifier]'s established
/// rationale: [dismiss] is called from a widget callback (the banner's
/// dismiss IconButton) that may not keep an active watcher of this
/// provider alive across the `await`.
final class MethodologyBannerDismissalNotifierProvider
    extends $NotifierProvider<MethodologyBannerDismissalNotifier, String?> {
  /// Tracks the last CO2-methodology version the user dismissed the banner
  /// for -- `null` when never dismissed.
  ///
  /// keepAlive: true -- mirrors [OnboardingGateNotifier]'s established
  /// rationale: [dismiss] is called from a widget callback (the banner's
  /// dismiss IconButton) that may not keep an active watcher of this
  /// provider alive across the `await`.
  MethodologyBannerDismissalNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'methodologyBannerDismissalProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$methodologyBannerDismissalNotifierHash();

  @$internal
  @override
  MethodologyBannerDismissalNotifier create() =>
      MethodologyBannerDismissalNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$methodologyBannerDismissalNotifierHash() =>
    r'77ba82a44e7081d409e3d1791a23da31dd70f5aa';

/// Tracks the last CO2-methodology version the user dismissed the banner
/// for -- `null` when never dismissed.
///
/// keepAlive: true -- mirrors [OnboardingGateNotifier]'s established
/// rationale: [dismiss] is called from a widget callback (the banner's
/// dismiss IconButton) that may not keep an active watcher of this
/// provider alive across the `await`.

abstract class _$MethodologyBannerDismissalNotifier extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The single composed value `Co2MethodologyBanner` needs: `true` only
/// when stale entries exist AND the current methodology version hasn't
/// already been dismissed.

@ProviderFor(showMethodologyBanner)
final showMethodologyBannerProvider = ShowMethodologyBannerProvider._();

/// The single composed value `Co2MethodologyBanner` needs: `true` only
/// when stale entries exist AND the current methodology version hasn't
/// already been dismissed.

final class ShowMethodologyBannerProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// The single composed value `Co2MethodologyBanner` needs: `true` only
  /// when stale entries exist AND the current methodology version hasn't
  /// already been dismissed.
  ShowMethodologyBannerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'showMethodologyBannerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$showMethodologyBannerHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return showMethodologyBanner(ref);
  }
}

String _$showMethodologyBannerHash() =>
    r'fe41f83d98ffc948572814ee16eec7744aeafb53';
