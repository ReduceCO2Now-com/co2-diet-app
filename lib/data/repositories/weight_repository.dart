import 'package:co2diet/data/local/app_database.dart';
import 'package:co2diet/data/local/daos/weight_dao.dart';
import 'package:co2diet/domain/entities/weight_entry.dart';
import 'package:co2diet/domain/entities/weight_settings.dart';
import 'package:co2diet/domain/repositories/i_weight_repository.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// Concrete implementation of [IWeightRepository], backed by [WeightDao].
///
/// Row<->entity mapping lives here (via `WeightEntry.fromRow`/
/// `WeightSettings.fromRow`), not in the DAO, matching
/// `MealEntryRepository`'s existing role.
///
/// `getEntriesInRange` resolves a [WeightRange] to a concrete `[from, to]`
/// window computed from `DateTime.now()` before delegating to the DAO's raw
/// date-bound query — the DAO itself is not aware of named ranges.
///
/// `saveGoal`/`saveReminderSettings` are independent operations: each reads
/// the current settings row first (read-modify-write) so neither ever
/// clobbers the other's fields.
///
/// HLC fields use Phase-1 placeholders, matching every other Phase 1-5
/// repository: `hlcNodeId` is `'local'`, `hlcCounter` is `0`. Phase 7
/// replaces these with full HLC clock logic using a stable device UUID.
final class WeightRepository implements IWeightRepository {
  /// Creates a [WeightRepository] backed by [_dao].
  WeightRepository(this._dao);

  final WeightDao _dao;

  static const _uuid = Uuid();

  BigInt get _nowHlcMillis =>
      BigInt.from(DateTime.now().millisecondsSinceEpoch);

  @override
  Future<WeightEntry> logWeight(WeightEntry draft) async {
    final id = draft.id.isEmpty ? _uuid.v7() : draft.id;
    final companion = WeightEntryTableCompanion.insert(
      id: id,
      hlcMillis: _nowHlcMillis,
      hlcCounter: 0,
      hlcNodeId: 'local',
      dirty: const Value(true),
      value: draft.value,
      unit: draft.unit,
      loggedAt: draft.loggedAt,
      note: Value(draft.note),
    );
    final row = await _dao.logWeight(companion);
    return WeightEntry.fromRow(row);
  }

  @override
  Future<List<WeightEntry>> getEntriesInRange(WeightRange range) async {
    final now = DateTime.now();
    final rows = await _dao.getEntriesInRange(
      from: range.startDate(now),
      to: now,
    );
    return rows.map(WeightEntry.fromRow).toList();
  }

  @override
  Future<void> deleteEntry(String id) => _dao.deleteEntry(id);

  @override
  Future<WeightSettings> getSettings() async {
    final row = await _dao.getSettings();
    if (row == null) return const WeightSettings();
    return WeightSettings.fromRow(row);
  }

  @override
  Future<void> saveGoal({double? targetWeightKg, DateTime? targetDate}) async {
    final existing = await _dao.getSettings();
    final id = existing?.id ?? _uuid.v7();

    final companion = WeightSettingsTableCompanion.insert(
      id: id,
      hlcMillis: _nowHlcMillis,
      hlcCounter: 0,
      hlcNodeId: 'local',
      dirty: const Value(true),
      targetWeightKg: Value(targetWeightKg),
      targetDate: Value(targetDate),
      reminderFrequency: Value(existing?.reminderFrequency),
      reminderWeekday: Value(existing?.reminderWeekday),
      reminderTime: Value(existing?.reminderTime),
      reminderEnabled: Value(existing?.reminderEnabled ?? false),
    );

    await _dao.saveSettings(companion);
  }

  @override
  Future<void> saveReminderSettings({
    required String frequency,
    required bool enabled,
    int? weekday,
    String? time,
  }) async {
    final existing = await _dao.getSettings();
    final id = existing?.id ?? _uuid.v7();

    final companion = WeightSettingsTableCompanion.insert(
      id: id,
      hlcMillis: _nowHlcMillis,
      hlcCounter: 0,
      hlcNodeId: 'local',
      dirty: const Value(true),
      targetWeightKg: Value(existing?.targetWeightKg),
      targetDate: Value(existing?.targetDate),
      reminderFrequency: Value(frequency),
      reminderWeekday: Value(weekday),
      reminderTime: Value(time),
      reminderEnabled: Value(enabled),
    );

    await _dao.saveSettings(companion);
  }
}
