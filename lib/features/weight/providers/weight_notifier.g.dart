// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// AsyncNotifier exposing weight-tracking state (all logged entries +
/// current goal/reminder settings) and the mutation surface
/// (log/goal/reminder) the Weight Tracking screen (Plan 05-13) consumes
/// exclusively — that plan never touches `IWeightRepository` or the DAO
/// layer directly.
///
/// Follows `MealEntryNotifier`'s `AsyncValue.guard` + `ref.invalidateSelf()`
/// pattern for every mutation.

@ProviderFor(WeightNotifier)
final weightProvider = WeightNotifierProvider._();

/// AsyncNotifier exposing weight-tracking state (all logged entries +
/// current goal/reminder settings) and the mutation surface
/// (log/goal/reminder) the Weight Tracking screen (Plan 05-13) consumes
/// exclusively — that plan never touches `IWeightRepository` or the DAO
/// layer directly.
///
/// Follows `MealEntryNotifier`'s `AsyncValue.guard` + `ref.invalidateSelf()`
/// pattern for every mutation.
final class WeightNotifierProvider
    extends $AsyncNotifierProvider<WeightNotifier, WeightState> {
  /// AsyncNotifier exposing weight-tracking state (all logged entries +
  /// current goal/reminder settings) and the mutation surface
  /// (log/goal/reminder) the Weight Tracking screen (Plan 05-13) consumes
  /// exclusively — that plan never touches `IWeightRepository` or the DAO
  /// layer directly.
  ///
  /// Follows `MealEntryNotifier`'s `AsyncValue.guard` + `ref.invalidateSelf()`
  /// pattern for every mutation.
  WeightNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'weightProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$weightNotifierHash();

  @$internal
  @override
  WeightNotifier create() => WeightNotifier();
}

String _$weightNotifierHash() => r'9447c8667ca07ef9a53e198c780f13102f5b9190';

/// AsyncNotifier exposing weight-tracking state (all logged entries +
/// current goal/reminder settings) and the mutation surface
/// (log/goal/reminder) the Weight Tracking screen (Plan 05-13) consumes
/// exclusively — that plan never touches `IWeightRepository` or the DAO
/// layer directly.
///
/// Follows `MealEntryNotifier`'s `AsyncValue.guard` + `ref.invalidateSelf()`
/// pattern for every mutation.

abstract class _$WeightNotifier extends $AsyncNotifier<WeightState> {
  FutureOr<WeightState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<WeightState>, WeightState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<WeightState>, WeightState>,
              AsyncValue<WeightState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
