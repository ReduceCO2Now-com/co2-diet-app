// AUTH-07/PRIV-08 offline-path assertion for every Phase 5 code path,
// extending Plan 04-12's `offline_logging_test.dart` pattern.
//
// Unlike `offline_logging_test.dart` (which drives Riverpod providers and
// therefore must explicitly override `appDatabaseProvider`/
// `offApiClientProvider` with throwing mocks), every Phase 5 service/
// repository here is constructed directly against a fresh in-memory
// `AppDatabase` -- no Riverpod container, no `offApiClientProvider`
// override, no `connectivity_plus` method-channel mock is installed at
// all. If any of these eight classes ever reached for `OffApiClient` or
// `Connectivity()`, that call would either fail to compile (no such
// dependency is even threaded through these constructors) or throw a
// `MissingPluginException` at runtime (no handler is registered for the
// connectivity_plus channel in this test) -- there is no mock standing
// in to silently swallow the call.
//
// A final static-source-inspection assertion (mirroring
// `test/ci/blocklist_test.dart`'s config-file scan) additionally confirms
// none of the six new Phase 5 domain-service files contain the strings
// `OffApiClient` or `Connectivity(` at all, closing the gap between
// "didn't happen to call it at runtime" and "structurally cannot".

import 'dart:io';

import 'package:co2diet/data/local/app_database.dart';
import 'package:co2diet/data/local/daos/backup_metadata_dao.dart';
import 'package:co2diet/data/local/daos/co2_settings_dao.dart';
import 'package:co2diet/data/local/daos/food_catalog_dao.dart';
import 'package:co2diet/data/local/daos/meal_entry_dao.dart';
import 'package:co2diet/data/local/daos/notification_prefs_dao.dart';
import 'package:co2diet/data/local/daos/user_food_dao.dart';
import 'package:co2diet/data/local/daos/user_profile_dao.dart';
import 'package:co2diet/data/local/daos/weight_dao.dart';
import 'package:co2diet/data/repositories/co2_settings_repository.dart';
import 'package:co2diet/data/repositories/weight_repository.dart';
import 'package:co2diet/domain/entities/co2_settings.dart';
import 'package:co2diet/domain/entities/meal_entry.dart';
import 'package:co2diet/domain/entities/meal_slot.dart';
import 'package:co2diet/domain/entities/portion_unit.dart';
import 'package:co2diet/domain/entities/weight_entry.dart';
import 'package:co2diet/domain/entities/weight_unit.dart';
import 'package:co2diet/domain/services/backup_export_service.dart';
import 'package:co2diet/domain/services/daily_totals_calculator.dart';
import 'package:co2diet/domain/services/improvement_opportunity_finder.dart';
import 'package:co2diet/domain/services/insights_timeline_rule_engine.dart';
import 'package:co2diet/domain/services/notification_service.dart';
import 'package:co2diet/domain/services/personal_co2_multiplier_calculator.dart';
import 'package:drift/native.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class _MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

/// Every Phase 5 domain-service source file whose static content is
/// scanned for a forbidden network-client reference below. Paths are
/// relative to the repo root (`Directory.current` when `flutter test`
/// runs).
const _phase5ServiceFiles = [
  'lib/domain/services/daily_totals_calculator.dart',
  'lib/domain/services/personal_co2_multiplier_calculator.dart',
  'lib/domain/services/notification_service.dart',
  'lib/domain/services/backup_export_service.dart',
  'lib/domain/services/improvement_opportunity_finder.dart',
  'lib/domain/services/insights_timeline_rule_engine.dart',
];

MealEntry _entry({
  required String id,
  required MealSlot mealSlot,
  required String logDate,
  String productName = 'Test Food',
  double quantity = 100,
  double? calories100g = 100,
  double? protein100g = 10,
  double? co2e100g = 2,
}) => MealEntry(
  id: id,
  mealSlot: mealSlot,
  foodRef: 'ref-$id',
  foodRefSource: 'off_ref',
  quantity: quantity,
  unit: PortionUnit.g,
  productNameSnapshot: productName,
  loggedAt: DateTime.utc(2026, 7, 27, 12),
  logDate: logDate,
  calories100gSnapshot: calories100g,
  protein100gSnapshot: protein100g,
  co2e100gSnapshot: co2e100g,
);

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.UTC);
    registerFallbackValue(tz.TZDateTime.now(tz.local));
    registerFallbackValue(
      const NotificationDetails(
        android: AndroidNotificationDetails('fallback_channel', 'Fallback'),
      ),
    );
    registerFallbackValue(AndroidScheduleMode.inexactAllowWhileIdle);
  });

  group('Phase 5 offline proof (AUTH-07/PRIV-08)', () {
    late AppDatabase db;

    setUp(() {
      // offRefPath deliberately omitted (null) -- no ATTACH DATABASE, no
      // off_ref access. Every DAO/repository below is constructed
      // directly, with no offApiClientProvider/connectivity_plus mock
      // registered anywhere in this test.
      db = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test(
      'Co2SettingsRepository.getSettings completes offline',
      () async {
        final repo = Co2SettingsRepository(Co2SettingsDao(db));
        final settings = await repo.getSettings();
        expect(settings, const Co2Settings());
      },
    );

    test(
      'WeightRepository.logWeight completes offline',
      () async {
        final repo = WeightRepository(WeightDao(db));
        final logged = await repo.logWeight(
          WeightEntry(
            id: '',
            value: 70,
            unit: WeightUnit.kg,
            loggedAt: DateTime.utc(2026, 7, 27, 8),
          ),
        );
        expect(logged.id, isNotEmpty);
      },
    );

    test(
      'NotificationService.scheduleMealReminder completes offline '
      '(mocked plugin -- no platform channel, no Connectivity)',
      () async {
        final mockPlugin = _MockFlutterLocalNotificationsPlugin();
        when(
          () => mockPlugin.zonedSchedule(
            id: any(named: 'id'),
            scheduledDate: any(named: 'scheduledDate'),
            notificationDetails: any(named: 'notificationDetails'),
            androidScheduleMode: any(named: 'androidScheduleMode'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            payload: any(named: 'payload'),
            matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
          ),
        ).thenAnswer((_) async {});

        final service = NotificationService(mockPlugin);
        final scheduled = await service.scheduleMealReminder(
          MealSlot.breakfast,
          '08:00',
        );
        expect(scheduled, isTrue);
      },
    );

    test(
      'BackupExportService.exportData completes offline against a temp '
      'dir, backed by real DAOs against the in-memory AppDatabase',
      () async {
        final service = BackupExportService(
          mealEntryDao: MealEntryDao(db),
          userFoodDao: UserFoodDao(db),
          weightDao: WeightDao(db),
          co2SettingsDao: Co2SettingsDao(db),
          notificationPrefsDao: NotificationPrefsDao(db),
          userProfileDao: UserProfileDao(db),
          backupMetadataDao: BackupMetadataDao(db),
          documentsDir: Directory.systemTemp.createTempSync(
            'offline_phase5_test_',
          ),
        );

        final zip = await service.exportData(
          categories: {ExportCategory.profile},
          formats: {ExportFormat.json},
        );

        expect(zip.existsSync(), isTrue);
        addTearDown(() {
          if (zip.existsSync()) zip.deleteSync();
        });
      },
    );

    test(
      'DailyTotalsCalculator.compute completes offline (pure, no I/O)',
      () {
        final totals = DailyTotalsCalculator.compute([
          _entry(id: 'a', mealSlot: MealSlot.lunch, logDate: '2026-07-27'),
        ]);
        expect(totals.calories, 100);
      },
    );

    test(
      'PersonalCo2MultiplierCalculator.compute completes offline '
      '(pure, no I/O)',
      () {
        final multiplier = PersonalCo2MultiplierCalculator.compute(
          const Co2Settings(purchasingSource: 'local_farm'),
        );
        expect(multiplier, closeTo(0.92, 0.0001));
      },
    );

    test(
      'ImprovementOpportunityFinder.findOpportunities completes offline '
      '(FoodCatalogDao against in-memory db, offRefPath null)',
      () async {
        final finder = ImprovementOpportunityFinder(FoodCatalogDao(db));
        final opportunities = await finder.findOpportunities([
          _entry(
            id: 'beef',
            mealSlot: MealSlot.dinner,
            logDate: '2026-07-27',
            productName: 'Beef Steak',
            quantity: 300,
            co2e100g: 4,
          ),
        ]);
        // offRefPath is null -- getCo2ForCategory returns null for every
        // alternative, so no opportunity is produced. The assertion that
        // matters is that this completes at all, without a
        // MissingPluginException/SocketException.
        expect(opportunities, isEmpty);
      },
    );

    test(
      'InsightsTimelineRuleEngine.evaluate completes offline '
      '(pure, no I/O)',
      () {
        const engine = InsightsTimelineRuleEngine();
        final observations = engine.evaluate([
          _entry(id: 'a', mealSlot: MealSlot.lunch, logDate: '2026-07-27'),
        ]);
        expect(observations, isA<List<String>>());
      },
    );
  });

  test(
    'Static source scan: no Phase 5 domain service references '
    'OffApiClient or Connectivity(',
    () {
      for (final path in _phase5ServiceFiles) {
        final file = File(path);
        expect(
          file.existsSync(),
          isTrue,
          reason: '$path is expected to exist',
        );
        // Strip `///`/`//` doc/line comments before scanning -- this file
        // set's doc comments are allowed to *mention* these class names
        // prose-style (e.g. "this service never instantiates
        // `OffApiClient`") to document the very invariant this test
        // enforces; only actual code referencing them is disallowed.
        final codeOnly = file
            .readAsLinesSync()
            .where((line) => !line.trim().startsWith('//'))
            .join('\n');
        expect(
          codeOnly.contains('OffApiClient'),
          isFalse,
          reason: '$path must never reference OffApiClient in code',
        );
        expect(
          codeOnly.contains('Connectivity('),
          isFalse,
          reason: '$path must never reference Connectivity( in code',
        );
      }
    },
  );
}
