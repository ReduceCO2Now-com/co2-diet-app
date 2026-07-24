// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_entry_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// AsyncNotifier exposing today's logged [MealEntry] rows and the mutation
/// surface (log/edit/delete/duplicate/undo) the UI layer (Plans 04-08
/// through 04-11) consumes exclusively — those plans never touch
/// `IMealEntryRepository` or the DAO layer directly.
///
/// Follows `ProfileNotifier`'s exact codegen shape: `build()` returns the
/// current state, every mutation method calls the repository then
/// `ref.invalidateSelf()` so the dashboard's today-list picks up the change.

@ProviderFor(MealEntryNotifier)
final mealEntryProvider = MealEntryNotifierProvider._();

/// AsyncNotifier exposing today's logged [MealEntry] rows and the mutation
/// surface (log/edit/delete/duplicate/undo) the UI layer (Plans 04-08
/// through 04-11) consumes exclusively — those plans never touch
/// `IMealEntryRepository` or the DAO layer directly.
///
/// Follows `ProfileNotifier`'s exact codegen shape: `build()` returns the
/// current state, every mutation method calls the repository then
/// `ref.invalidateSelf()` so the dashboard's today-list picks up the change.
final class MealEntryNotifierProvider
    extends $AsyncNotifierProvider<MealEntryNotifier, List<MealEntry>> {
  /// AsyncNotifier exposing today's logged [MealEntry] rows and the mutation
  /// surface (log/edit/delete/duplicate/undo) the UI layer (Plans 04-08
  /// through 04-11) consumes exclusively — those plans never touch
  /// `IMealEntryRepository` or the DAO layer directly.
  ///
  /// Follows `ProfileNotifier`'s exact codegen shape: `build()` returns the
  /// current state, every mutation method calls the repository then
  /// `ref.invalidateSelf()` so the dashboard's today-list picks up the change.
  MealEntryNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mealEntryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mealEntryNotifierHash();

  @$internal
  @override
  MealEntryNotifier create() => MealEntryNotifier();
}

String _$mealEntryNotifierHash() => r'003d16461cb89c0578a4153d6cec7984af1f6c9d';

/// AsyncNotifier exposing today's logged [MealEntry] rows and the mutation
/// surface (log/edit/delete/duplicate/undo) the UI layer (Plans 04-08
/// through 04-11) consumes exclusively — those plans never touch
/// `IMealEntryRepository` or the DAO layer directly.
///
/// Follows `ProfileNotifier`'s exact codegen shape: `build()` returns the
/// current state, every mutation method calls the repository then
/// `ref.invalidateSelf()` so the dashboard's today-list picks up the change.

abstract class _$MealEntryNotifier extends $AsyncNotifier<List<MealEntry>> {
  FutureOr<List<MealEntry>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<MealEntry>>, List<MealEntry>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<MealEntry>>, List<MealEntry>>,
              AsyncValue<List<MealEntry>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
