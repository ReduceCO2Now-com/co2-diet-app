// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'co2_settings_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// AsyncNotifier that loads and saves the user's CO2 Calculation Settings
/// (CO2-03).
///
/// Mirrors `ProfileNotifier`'s exact shape (per RESEARCH.md: "same pattern
/// as ProfileScreen/ProfileNotifier"). This settings layer is strictly
/// separate from any food's own CO2 data — [saveSettings] never rewrites
/// or recalculates already-logged meal entries.
///
/// Anti-patterns avoided:
///   - Does NOT import package:drift or AppDatabase.
///   - Does NOT use AutoDisposeRef (Riverpod 3.x uses unified Ref).
///   - Does NOT use StateNotifierProvider.

@ProviderFor(Co2SettingsNotifier)
final co2SettingsProvider = Co2SettingsNotifierProvider._();

/// AsyncNotifier that loads and saves the user's CO2 Calculation Settings
/// (CO2-03).
///
/// Mirrors `ProfileNotifier`'s exact shape (per RESEARCH.md: "same pattern
/// as ProfileScreen/ProfileNotifier"). This settings layer is strictly
/// separate from any food's own CO2 data — [saveSettings] never rewrites
/// or recalculates already-logged meal entries.
///
/// Anti-patterns avoided:
///   - Does NOT import package:drift or AppDatabase.
///   - Does NOT use AutoDisposeRef (Riverpod 3.x uses unified Ref).
///   - Does NOT use StateNotifierProvider.
final class Co2SettingsNotifierProvider
    extends $AsyncNotifierProvider<Co2SettingsNotifier, Co2Settings> {
  /// AsyncNotifier that loads and saves the user's CO2 Calculation Settings
  /// (CO2-03).
  ///
  /// Mirrors `ProfileNotifier`'s exact shape (per RESEARCH.md: "same pattern
  /// as ProfileScreen/ProfileNotifier"). This settings layer is strictly
  /// separate from any food's own CO2 data — [saveSettings] never rewrites
  /// or recalculates already-logged meal entries.
  ///
  /// Anti-patterns avoided:
  ///   - Does NOT import package:drift or AppDatabase.
  ///   - Does NOT use AutoDisposeRef (Riverpod 3.x uses unified Ref).
  ///   - Does NOT use StateNotifierProvider.
  Co2SettingsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'co2SettingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$co2SettingsNotifierHash();

  @$internal
  @override
  Co2SettingsNotifier create() => Co2SettingsNotifier();
}

String _$co2SettingsNotifierHash() =>
    r'fc948e53a1b7528bedfb848867b8e85ea25fcdcf';

/// AsyncNotifier that loads and saves the user's CO2 Calculation Settings
/// (CO2-03).
///
/// Mirrors `ProfileNotifier`'s exact shape (per RESEARCH.md: "same pattern
/// as ProfileScreen/ProfileNotifier"). This settings layer is strictly
/// separate from any food's own CO2 data — [saveSettings] never rewrites
/// or recalculates already-logged meal entries.
///
/// Anti-patterns avoided:
///   - Does NOT import package:drift or AppDatabase.
///   - Does NOT use AutoDisposeRef (Riverpod 3.x uses unified Ref).
///   - Does NOT use StateNotifierProvider.

abstract class _$Co2SettingsNotifier extends $AsyncNotifier<Co2Settings> {
  FutureOr<Co2Settings> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Co2Settings>, Co2Settings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Co2Settings>, Co2Settings>,
              AsyncValue<Co2Settings>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
