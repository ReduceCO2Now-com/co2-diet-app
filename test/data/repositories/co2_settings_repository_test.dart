// Tests for Co2SettingsRepository (CO2-03).
//
// Covers:
// - getSettings returns an all-null default when no row has ever been
//   saved (not an exception, not a fabricated default).
// - saveSettings persists via upsertSettings only, reusing the existing
//   row's id on subsequent saves.
// - Co2Settings.dataQuality classification thresholds.
// - Single-table isolation: this repository never touches any other DAO.

import 'package:co2diet/data/local/app_database.dart';
import 'package:co2diet/data/local/daos/co2_settings_dao.dart';
import 'package:co2diet/data/repositories/co2_settings_repository.dart';
import 'package:co2diet/domain/entities/co2_settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCo2SettingsDao extends Mock implements Co2SettingsDao {}

Co2SettingsRow _buildRow({
  String id = 'settings-1',
  String? locationCountry,
  String? locationRegion,
  String? purchasingSource,
  String? shoppingTransport,
  String? cookingMethod,
  String? foodStorage,
  int? householdSize,
  String? foodWasteLevel,
}) {
  return Co2SettingsRow(
    id: id,
    hlcMillis: BigInt.from(1000),
    hlcCounter: 0,
    hlcNodeId: 'local',
    dirty: true,
    locationCountry: locationCountry,
    locationRegion: locationRegion,
    purchasingSource: purchasingSource,
    shoppingTransport: shoppingTransport,
    cookingMethod: cookingMethod,
    foodStorage: foodStorage,
    householdSize: householdSize,
    foodWasteLevel: foodWasteLevel,
  );
}

void main() {
  late _MockCo2SettingsDao mockDao;
  late Co2SettingsRepository repository;

  setUpAll(() {
    registerFallbackValue(const Co2SettingsTableCompanion());
  });

  setUp(() {
    mockDao = _MockCo2SettingsDao();
    repository = Co2SettingsRepository(mockDao);
  });

  group('Co2SettingsRepository.getSettings', () {
    test(
      'returns a default all-unset Co2Settings when no row has ever '
      'been saved',
      () async {
        when(() => mockDao.getSettings()).thenAnswer((_) async => null);

        final result = await repository.getSettings();

        expect(result, const Co2Settings());
        expect(result.locationCountry, isNull);
        expect(result.householdSize, isNull);
      },
    );

    test('maps a persisted row 1:1 onto Co2Settings', () async {
      when(() => mockDao.getSettings()).thenAnswer(
        (_) async => _buildRow(
          locationCountry: 'DE',
          locationRegion: 'Bavaria',
          purchasingSource: 'supermarket',
          shoppingTransport: 'walk_bike',
          cookingMethod: 'induction',
          foodStorage: 'large_fridge_freezer',
          householdSize: 3,
          foodWasteLevel: 'low',
        ),
      );

      final result = await repository.getSettings();

      expect(result.locationCountry, 'DE');
      expect(result.locationRegion, 'Bavaria');
      expect(result.purchasingSource, 'supermarket');
      expect(result.shoppingTransport, 'walk_bike');
      expect(result.cookingMethod, 'induction');
      expect(result.foodStorage, 'large_fridge_freezer');
      expect(result.householdSize, 3);
      expect(result.foodWasteLevel, 'low');
    });
  });

  group('Co2SettingsRepository.saveSettings', () {
    test(
      'saveSettings never rewrites any already-logged MealEntry '
      '(forward-only, no retroactive recalculation) -- persists via '
      'upsertSettings and never touches any other table',
      () async {
        when(() => mockDao.getSettings()).thenAnswer((_) async => null);
        Co2SettingsTableCompanion? captured;
        when(() => mockDao.upsertSettings(any())).thenAnswer((invocation) {
          captured = invocation.positionalArguments[0]
              as Co2SettingsTableCompanion;
          return Future<void>.value();
        });

        await repository.saveSettings(
          const Co2Settings(locationCountry: 'DE', householdSize: 2),
        );

        expect(captured, isNotNull);
        expect(captured!.locationCountry.value, 'DE');
        expect(captured!.householdSize.value, 2);
        verify(() => mockDao.getSettings()).called(1);
        verify(() => mockDao.upsertSettings(any())).called(1);
        verifyNoMoreInteractions(mockDao);
      },
    );

    test('reuses the existing row id on a subsequent save', () async {
      when(() => mockDao.getSettings())
          .thenAnswer((_) async => _buildRow(id: 'existing-id'));
      Co2SettingsTableCompanion? captured;
      when(() => mockDao.upsertSettings(any())).thenAnswer((invocation) {
        captured =
            invocation.positionalArguments[0] as Co2SettingsTableCompanion;
        return Future<void>.value();
      });

      await repository.saveSettings(
        const Co2Settings(locationCountry: 'AT'),
      );

      expect(captured!.id.value, 'existing-id');
    });
  });

  group('Co2Settings.dataQuality', () {
    test('returns basic for 0-2 non-null optional fields set', () {
      expect(const Co2Settings().dataQuality, 'basic');
      expect(
        const Co2Settings(locationCountry: 'DE').dataQuality,
        'basic',
      );
      expect(
        const Co2Settings(
          locationCountry: 'DE',
          locationRegion: 'Bavaria',
        ).dataQuality,
        'basic',
      );
    });

    test('returns good for 3-5 non-null optional fields set', () {
      expect(
        const Co2Settings(
          locationCountry: 'DE',
          locationRegion: 'Bavaria',
          purchasingSource: 'supermarket',
        ).dataQuality,
        'good',
      );
      expect(
        const Co2Settings(
          locationCountry: 'DE',
          locationRegion: 'Bavaria',
          purchasingSource: 'supermarket',
          shoppingTransport: 'walk_bike',
          cookingMethod: 'induction',
        ).dataQuality,
        'good',
      );
    });

    test('returns detailed for 6-7 non-null optional fields set', () {
      expect(
        const Co2Settings(
          locationCountry: 'DE',
          locationRegion: 'Bavaria',
          purchasingSource: 'supermarket',
          shoppingTransport: 'walk_bike',
          cookingMethod: 'induction',
          foodStorage: 'large_fridge_freezer',
        ).dataQuality,
        'detailed',
      );
      expect(
        const Co2Settings(
          locationCountry: 'DE',
          locationRegion: 'Bavaria',
          purchasingSource: 'supermarket',
          shoppingTransport: 'walk_bike',
          cookingMethod: 'induction',
          foodStorage: 'large_fridge_freezer',
          householdSize: 4,
          foodWasteLevel: 'low',
        ).dataQuality,
        'detailed',
      );
    });
  });
}
