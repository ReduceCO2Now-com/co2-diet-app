// Tests for WeightRepository (WT-01, WT-02, WT-03, WT-04).
//
// Covers:
// - logWeight persists a new entry via the DAO.
// - getEntriesInRange resolves each named WeightRange to a concrete
//   [from, to] window computed from DateTime.now() before delegating to
//   WeightDao.getEntriesInRange.
// - saveGoal / saveReminderSettings independence: each is a
//   read-modify-write that never clobbers the other's fields.

import 'package:co2diet/data/local/app_database.dart';
import 'package:co2diet/data/local/daos/weight_dao.dart';
import 'package:co2diet/data/repositories/weight_repository.dart';
import 'package:co2diet/domain/entities/weight_entry.dart';
import 'package:co2diet/domain/entities/weight_unit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockWeightDao extends Mock implements WeightDao {}

WeightEntryRow _buildEntryRow({
  String id = 'w1',
  double value = 80,
  WeightUnit unit = WeightUnit.kg,
  DateTime? loggedAt,
  String? note,
}) {
  return WeightEntryRow(
    id: id,
    hlcMillis: BigInt.from(1000),
    hlcCounter: 0,
    hlcNodeId: 'local',
    dirty: true,
    value: value,
    unit: unit,
    loggedAt: loggedAt ?? DateTime.utc(2026),
    note: note,
  );
}

WeightSettingsRow _buildSettingsRow({
  String id = 'settings-1',
  double? targetWeightKg,
  DateTime? targetDate,
  String? reminderFrequency,
  int? reminderWeekday,
  String? reminderTime,
  bool reminderEnabled = false,
}) {
  return WeightSettingsRow(
    id: id,
    hlcMillis: BigInt.from(1000),
    hlcCounter: 0,
    hlcNodeId: 'local',
    dirty: true,
    targetWeightKg: targetWeightKg,
    targetDate: targetDate,
    reminderFrequency: reminderFrequency,
    reminderWeekday: reminderWeekday,
    reminderTime: reminderTime,
    reminderEnabled: reminderEnabled,
  );
}

void main() {
  late _MockWeightDao mockDao;
  late WeightRepository repository;

  setUpAll(() {
    registerFallbackValue(
      WeightEntryTableCompanion.insert(
        id: 'fallback',
        hlcMillis: BigInt.zero,
        hlcCounter: 0,
        hlcNodeId: 'local',
        value: 0,
        unit: WeightUnit.kg,
        loggedAt: DateTime.utc(2026),
      ),
    );
    registerFallbackValue(
      WeightSettingsTableCompanion.insert(
        id: 'fallback',
        hlcMillis: BigInt.zero,
        hlcCounter: 0,
        hlcNodeId: 'local',
      ),
    );
  });

  setUp(() {
    mockDao = _MockWeightDao();
    repository = WeightRepository(mockDao);
  });

  group('WeightRepository.logWeight', () {
    test('persists a new entry via the DAO and maps the result back',
        () async {
      final row = _buildEntryRow();
      when(() => mockDao.logWeight(any())).thenAnswer((_) async => row);

      final result = await repository.logWeight(
        WeightEntry(
          id: '',
          value: 80,
          unit: WeightUnit.kg,
          loggedAt: DateTime.utc(2026),
        ),
      );

      expect(result.id, 'w1');
      expect(result.value, 80);
      verify(() => mockDao.logWeight(any())).called(1);
    });
  });

  group('WeightRepository.getEntriesInRange', () {
    setUp(() {
      when(
        () => mockDao.getEntriesInRange(
          from: any(named: 'from'),
          to: any(named: 'to'),
        ),
      ).thenAnswer((_) async => [_buildEntryRow()]);
    });

    test('WeightRange.all resolves to a null from bound', () async {
      await repository.getEntriesInRange(WeightRange.all);

      final captured = verify(
        () => mockDao.getEntriesInRange(
          from: captureAny(named: 'from'),
          to: captureAny(named: 'to'),
        ),
      ).captured;
      expect(captured[0], isNull);
      expect(captured[1], isNotNull);
    });

    test('WeightRange.sevenDay resolves to a ~7-day-ago from bound',
        () async {
      await repository.getEntriesInRange(WeightRange.sevenDay);

      final captured = verify(
        () => mockDao.getEntriesInRange(
          from: captureAny(named: 'from'),
          to: captureAny(named: 'to'),
        ),
      ).captured;
      final from = captured[0] as DateTime;
      final to = captured[1] as DateTime;
      expect(to.difference(from).inDays, 7);
    });

    test('WeightRange.thirtyDay resolves to a ~30-day-ago from bound',
        () async {
      await repository.getEntriesInRange(WeightRange.thirtyDay);

      final captured = verify(
        () => mockDao.getEntriesInRange(
          from: captureAny(named: 'from'),
          to: captureAny(named: 'to'),
        ),
      ).captured;
      final from = captured[0] as DateTime;
      final to = captured[1] as DateTime;
      expect(to.difference(from).inDays, 30);
    });

    test('WeightRange.ninetyDay resolves to a ~90-day-ago from bound',
        () async {
      await repository.getEntriesInRange(WeightRange.ninetyDay);

      final captured = verify(
        () => mockDao.getEntriesInRange(
          from: captureAny(named: 'from'),
          to: captureAny(named: 'to'),
        ),
      ).captured;
      final from = captured[0] as DateTime;
      final to = captured[1] as DateTime;
      expect(to.difference(from).inDays, 90);
    });

    test('WeightRange.oneYear resolves to a ~365-day-ago from bound',
        () async {
      await repository.getEntriesInRange(WeightRange.oneYear);

      final captured = verify(
        () => mockDao.getEntriesInRange(
          from: captureAny(named: 'from'),
          to: captureAny(named: 'to'),
        ),
      ).captured;
      final from = captured[0] as DateTime;
      final to = captured[1] as DateTime;
      expect(to.difference(from).inDays, 365);
    });

    test('maps returned rows onto WeightEntry', () async {
      final result = await repository.getEntriesInRange(WeightRange.all);

      expect(result, hasLength(1));
      expect(result.single.id, 'w1');
    });
  });

  group('WeightRepository.saveGoal / saveReminderSettings independence', () {
    test(
      'saveGoal alone does not alter reminderFrequency/reminderEnabled '
      'when no settings exist yet',
      () async {
        when(() => mockDao.getSettings()).thenAnswer((_) async => null);
        WeightSettingsTableCompanion? captured;
        when(() => mockDao.saveSettings(any())).thenAnswer((invocation) {
          captured = invocation.positionalArguments[0]
              as WeightSettingsTableCompanion;
          return Future<void>.value();
        });

        await repository.saveGoal(
          targetWeightKg: 75,
          targetDate: DateTime.utc(2026, 12, 31),
        );

        expect(captured, isNotNull);
        expect(captured!.targetWeightKg.value, 75);
        expect(captured!.reminderFrequency.value, isNull);
        expect(captured!.reminderEnabled.value, isFalse);
      },
    );

    test(
      'saveGoal preserves existing reminder fields (read-modify-write)',
      () async {
        when(() => mockDao.getSettings()).thenAnswer(
          (_) async => _buildSettingsRow(
            reminderFrequency: 'weekly',
            reminderEnabled: true,
            reminderWeekday: 1,
            reminderTime: '08:00',
          ),
        );
        WeightSettingsTableCompanion? captured;
        when(() => mockDao.saveSettings(any())).thenAnswer((invocation) {
          captured = invocation.positionalArguments[0]
              as WeightSettingsTableCompanion;
          return Future<void>.value();
        });

        await repository.saveGoal(targetWeightKg: 70);

        expect(captured!.targetWeightKg.value, 70);
        expect(captured!.reminderFrequency.value, 'weekly');
        expect(captured!.reminderEnabled.value, isTrue);
        expect(captured!.reminderWeekday.value, 1);
        expect(captured!.reminderTime.value, '08:00');
      },
    );

    test(
      'saveReminderSettings alone does not alter targetWeightKg/targetDate '
      'when no settings exist yet',
      () async {
        when(() => mockDao.getSettings()).thenAnswer((_) async => null);
        WeightSettingsTableCompanion? captured;
        when(() => mockDao.saveSettings(any())).thenAnswer((invocation) {
          captured = invocation.positionalArguments[0]
              as WeightSettingsTableCompanion;
          return Future<void>.value();
        });

        await repository.saveReminderSettings(
          frequency: 'weekly',
          enabled: true,
        );

        expect(captured!.reminderFrequency.value, 'weekly');
        expect(captured!.reminderEnabled.value, isTrue);
        expect(captured!.targetWeightKg.value, isNull);
        expect(captured!.targetDate.value, isNull);
      },
    );

    test(
      'saveReminderSettings preserves existing goal fields '
      '(read-modify-write)',
      () async {
        final targetDate = DateTime.utc(2026, 12, 31);
        when(() => mockDao.getSettings()).thenAnswer(
          (_) async => _buildSettingsRow(
            targetWeightKg: 75,
            targetDate: targetDate,
          ),
        );
        WeightSettingsTableCompanion? captured;
        when(() => mockDao.saveSettings(any())).thenAnswer((invocation) {
          captured = invocation.positionalArguments[0]
              as WeightSettingsTableCompanion;
          return Future<void>.value();
        });

        await repository.saveReminderSettings(
          frequency: 'monthly',
          enabled: false,
        );

        expect(captured!.targetWeightKg.value, 75);
        expect(captured!.targetDate.value, targetDate);
        expect(captured!.reminderFrequency.value, 'monthly');
        expect(captured!.reminderEnabled.value, isFalse);
      },
    );

    test('reuses the existing settings row id on subsequent saves',
        () async {
      when(() => mockDao.getSettings())
          .thenAnswer((_) async => _buildSettingsRow(id: 'existing-id'));
      WeightSettingsTableCompanion? captured;
      when(() => mockDao.saveSettings(any())).thenAnswer((invocation) {
        captured = invocation.positionalArguments[0]
            as WeightSettingsTableCompanion;
        return Future<void>.value();
      });

      await repository.saveGoal(targetWeightKg: 70);

      expect(captured!.id.value, 'existing-id');
    });
  });
}
