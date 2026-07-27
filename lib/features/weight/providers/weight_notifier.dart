import 'package:co2diet/core/di/weight_providers.dart';
import 'package:co2diet/domain/entities/weight_entry.dart';
import 'package:co2diet/domain/entities/weight_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'weight_notifier.g.dart';

/// Combined weight-tracking state: the full entry list plus the current
/// goal/reminder settings, loaded together as one state object.
///
/// Plain immutable class (no sentinel `copyWith`) since both fields are
/// always present once `build()` completes.
@immutable
class WeightState {
  /// Creates a [WeightState] with the given [entries] and [settings].
  const WeightState({required this.entries, required this.settings});

  /// All logged weigh-ins (default range: all — the screen itself controls
  /// the visible chart window via [WeightNotifier.entriesForRange]).
  final List<WeightEntry> entries;

  /// Current goal + reminder configuration.
  final WeightSettings settings;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeightState &&
          runtimeType == other.runtimeType &&
          listEquals(entries, other.entries) &&
          settings == other.settings;

  @override
  int get hashCode => Object.hash(Object.hashAll(entries), settings);

  @override
  String toString() =>
      'WeightState(entries: ${entries.length}, settings: $settings)';
}

/// AsyncNotifier exposing weight-tracking state (all logged entries +
/// current goal/reminder settings) and the mutation surface
/// (log/goal/reminder) the Weight Tracking screen (Plan 05-13) consumes
/// exclusively — that plan never touches `IWeightRepository` or the DAO
/// layer directly.
///
/// Follows `MealEntryNotifier`'s `AsyncValue.guard` + `ref.invalidateSelf()`
/// pattern for every mutation.
@riverpod
class WeightNotifier extends _$WeightNotifier {
  @override
  Future<WeightState> build() async {
    final repo = ref.watch(weightRepositoryProvider);
    final entries = await repo.getEntriesInRange(WeightRange.all);
    final settings = await repo.getSettings();
    return WeightState(entries: entries, settings: settings);
  }

  /// Logs [draft] as a new weigh-in and refreshes the combined state.
  Future<void> logWeight(WeightEntry draft) async {
    state = await AsyncValue.guard(() async {
      final repo = ref.read(weightRepositoryProvider);
      await repo.logWeight(draft);
      final entries = await repo.getEntriesInRange(WeightRange.all);
      final settings = await repo.getSettings();
      return WeightState(entries: entries, settings: settings);
    });
    ref.invalidateSelf();
  }

  /// Persists the weight goal (WT-03) and refreshes the combined state.
  /// Independent of reminder settings — never overwrites
  /// [saveReminderSettings]'s fields.
  Future<void> saveGoal({double? targetWeightKg, DateTime? targetDate}) async {
    await ref.read(weightRepositoryProvider).saveGoal(
      targetWeightKg: targetWeightKg,
      targetDate: targetDate,
    );
    ref.invalidateSelf();
  }

  /// Persists the weigh-in reminder configuration (WT-04) and refreshes the
  /// combined state. Independent of the goal fields — never overwrites
  /// [saveGoal]'s fields.
  Future<void> saveReminderSettings({
    required String frequency,
    required bool enabled,
    int? weekday,
    String? time,
  }) async {
    await ref.read(weightRepositoryProvider).saveReminderSettings(
      frequency: frequency,
      enabled: enabled,
      weekday: weekday,
      time: time,
    );
    ref.invalidateSelf();
  }

  /// Re-queries the repository directly for [range]-filtered chart data —
  /// avoids re-fetching the full notifier state (all entries + settings)
  /// just to change the chart's visible window.
  Future<List<WeightEntry>> entriesForRange(WeightRange range) =>
      ref.read(weightRepositoryProvider).getEntriesInRange(range);
}
