// AUTH-09 / 08-01 device benchmark: real on-device encrypted-backup
// archive size and encrypt/decrypt wall-clock time.
//
// 08-RESEARCH.md's Argon2id/AES-256-GCM timings (Pitfall 4) were measured
// on desktop JIT and explicitly flagged MEDIUM confidence as a predictor
// of real device behavior. This test seeds a realistic-sized dataset
// directly via the meal entry / weight / custom food DAOs against a real
// (non-in-memory) AppDatabase on the test device -- mirroring
// meal_logging_benchmark_test.dart's Stopwatch pattern -- then measures
// BackupExportService.createBackup(passphrase: ...) and applyRestore
// end to end, printing the real numbers rather than asserting a hard
// pass/fail threshold. A human judges whether the numbers are acceptable
// UX at this plan's second blocking checkpoint.
//
// Run on a connected physical device:
//   flutter test integration_test/backup_encryption_benchmark_test.dart
//       -d <device>
//
// This writes ~600 rows to the SAME on-device database the real app uses
// (mirrors co2_coverage_benchmark_test.dart's AppDatabase.connect()
// precedent) -- every seeded row uses an `auth09-bench-` id prefix and is
// deleted in tearDown, so the device is left as it was found.

import 'dart:io';

import 'package:co2diet/data/local/app_database.dart';
import 'package:co2diet/domain/entities/meal_slot.dart';
import 'package:co2diet/domain/entities/portion_unit.dart';
import 'package:co2diet/domain/entities/weight_unit.dart';
import 'package:co2diet/domain/services/backup_export_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';

/// Number of seeded rows per category -- 600 total, approximating
/// 08-RESEARCH.md's "multi-year heavy user" estimate (a few hundred to
/// ~1000 rows across categories).
const _mealEntryCount = 300;
const _weightEntryCount = 200;
const _customFoodCount = 100;

/// Every seeded row's id starts with this prefix, so tearDown can delete
/// exactly (and only) what this benchmark inserted.
const _benchIdPrefix = 'auth09-bench-';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'AUTH-09 device benchmark: real archive size + encrypt/decrypt '
    'wall-clock time for a realistic dataset',
    (tester) async {
      final documentsDir = await getApplicationDocumentsDirectory();
      final db = AppDatabase.connect();
      File? zipFile;

      addTearDown(() async {
        // Leave the device exactly as this benchmark found it.
        await db.customStatement(
          "DELETE FROM meal_entry_table WHERE id LIKE '$_benchIdPrefix%'",
        );
        await db.customStatement(
          "DELETE FROM weight_entry_table WHERE id LIKE '$_benchIdPrefix%'",
        );
        await db.customStatement(
          "DELETE FROM user_food_table WHERE id LIKE '$_benchIdPrefix%'",
        );
        final producedZip = zipFile;
        if (producedZip != null && producedZip.existsSync()) {
          producedZip.deleteSync();
        }
        await db.close();
      });

      final service = BackupExportService(
        mealEntryDao: db.mealEntryDao,
        userFoodDao: db.userFoodDao,
        weightDao: db.weightDao,
        co2SettingsDao: db.co2SettingsDao,
        notificationPrefsDao: db.notificationPrefsDao,
        userProfileDao: db.userProfileDao,
        backupMetadataDao: db.backupMetadataDao,
        documentsDir: documentsDir,
      );

      // --- Seed a realistic-sized dataset ---------------------------------
      final baseDate = DateTime.utc(2023);
      for (var i = 0; i < _mealEntryCount; i++) {
        final loggedAt = baseDate.add(Duration(days: i));
        final logDate =
            '${loggedAt.year.toString().padLeft(4, '0')}-'
            '${loggedAt.month.toString().padLeft(2, '0')}-'
            '${loggedAt.day.toString().padLeft(2, '0')}';
        await db.mealEntryDao.insertOrMerge(
          draft: MealEntryRow(
            id: '${_benchIdPrefix}meal-$i',
            hlcMillis: BigInt.from(loggedAt.millisecondsSinceEpoch),
            hlcCounter: 0,
            hlcNodeId: 'auth09-bench',
            dirty: true,
            mealSlot: MealSlot.values[i % MealSlot.values.length],
            foodRef: 'benchmark-food-$i',
            foodRefSource: 'off_ref',
            quantity: 100,
            unit: PortionUnit.g,
            productNameSnapshot: 'Benchmark food $i',
            calories100gSnapshot: 200,
            protein100gSnapshot: 10,
            carbs100gSnapshot: 20,
            fat100gSnapshot: 5,
            co2e100gSnapshot: 1.2,
            confidenceBandSnapshot: 'medium',
            co2MethodologyVersionSnapshot: 'v1',
            loggedAt: loggedAt,
            logDate: logDate,
          ),
        );
      }

      for (var j = 0; j < _weightEntryCount; j++) {
        await db.weightDao.logWeight(
          WeightEntryTableCompanion.insert(
            id: '${_benchIdPrefix}weight-$j',
            hlcMillis: BigInt.from(
              baseDate.add(Duration(days: j)).millisecondsSinceEpoch,
            ),
            hlcCounter: 0,
            hlcNodeId: 'auth09-bench',
            value: 70 + (j % 20) * 0.1,
            unit: WeightUnit.kg,
            loggedAt: baseDate.add(Duration(days: j)),
          ),
        );
      }

      for (var k = 0; k < _customFoodCount; k++) {
        await db.userFoodDao.insert(
          UserFoodTableCompanion.insert(
            id: '${_benchIdPrefix}food-$k',
            hlcMillis: BigInt.from(1000 + k),
            hlcCounter: 0,
            hlcNodeId: 'auth09-bench',
            name: 'Benchmark custom food $k',
            calories: 250,
            quickServingSizes: const [],
          ),
        );
      }

      // --- Measure -----------------------------------------------------
      const passphrase = 'a-test-passphrase-1234';

      final encryptStopwatch = Stopwatch()..start();
      final zip = await service.createBackup(passphrase: passphrase);
      encryptStopwatch.stop();
      zipFile = zip;

      final archiveSizeBytes = await zip.length();

      final decryptStopwatch = Stopwatch()..start();
      await service.applyRestore(zip, passphrase: passphrase);
      decryptStopwatch.stop();

      // Intentional stdout print (not a debug leftover): the only way to
      // surface these measured numbers to the human running this
      // benchmark on a physical device for this plan's device-checkpoint
      // -- debugPrint output is not reliably captured in the `flutter
      // test` integration-test summary (meal_logging_benchmark_test.dart
      // precedent).
      // ignore: avoid_print
      print(
        'AUTH-09 backup encryption benchmark -- '
        'seeded $_mealEntryCount meal entries + $_weightEntryCount '
        'weigh-ins + $_customFoodCount custom foods '
        '(${_mealEntryCount + _weightEntryCount + _customFoodCount} rows '
        'total):\n'
        '  encrypted archive size: $archiveSizeBytes bytes '
        '(${(archiveSizeBytes / 1024).toStringAsFixed(1)} KiB)\n'
        '  encrypt (createBackup) wall-clock: '
        '${encryptStopwatch.elapsedMilliseconds}ms\n'
        '  decrypt (applyRestore) wall-clock: '
        '${decryptStopwatch.elapsedMilliseconds}ms',
      );

      expect(zip.existsSync(), isTrue);
      expect(archiveSizeBytes, greaterThan(0));
    },
  );
}
