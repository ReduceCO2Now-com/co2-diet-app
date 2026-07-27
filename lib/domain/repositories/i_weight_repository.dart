import 'package:co2diet/domain/entities/weight_entry.dart';
import 'package:co2diet/domain/entities/weight_settings.dart';

/// Domain contract for weight-tracking persistence: logging weigh-ins
/// (WT-01), history retrieval (WT-02), and goal/reminder configuration
/// (WT-03/WT-04).
///
/// Covers all four concerns in one cohesive interface — mirrors
/// `IMealEntryRepository`'s established precedent of one repository owning
/// multiple closely-related concerns. Implementations live in the data
/// layer and consumers are Riverpod notifiers.
abstract interface class IWeightRepository {
  /// Persists a new immutable weigh-in entry (WT-01).
  Future<WeightEntry> logWeight(WeightEntry draft);

  /// Returns logged entries within [range] (WT-02: 7d/30d/90d/1yr/all),
  /// oldest-first.
  Future<List<WeightEntry>> getEntriesInRange(WeightRange range);

  /// Hard-deletes the weigh-in identified by [id].
  Future<void> deleteEntry(String id);

  /// Returns the current [WeightSettings], or an all-default value when no
  /// settings have ever been saved.
  Future<WeightSettings> getSettings();

  /// Persists the weight goal (WT-03). Independent of reminder settings —
  /// never overwrites [saveReminderSettings]'s fields (read-modify-write on
  /// the single settings row).
  Future<void> saveGoal({double? targetWeightKg, DateTime? targetDate});

  /// Persists the weigh-in reminder configuration (WT-04). Independent of
  /// the goal fields — never overwrites [saveGoal]'s fields
  /// (read-modify-write on the single settings row).
  Future<void> saveReminderSettings({
    required String frequency,
    required bool enabled,
    int? weekday,
    String? time,
  });
}
