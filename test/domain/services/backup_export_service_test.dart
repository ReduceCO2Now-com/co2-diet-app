// Tests for BackupExportService (PRIV-01 through PRIV-04, PRIV-08).
//
// Covers:
// - exportData produces a zip containing manifest.json plus one file per
//   selected category/format, including a genuinely valid .xlsx (not a
//   renamed CSV).
// - manifest.json carries a formatVersion field alongside per-file
//   category/format/row-count entries.
// - previewRestore parses without writing anything, and rejects an
//   unrecognized formatVersion before any DAO write.
// - applyRestore validates every archive entry's path BEFORE any DAO
//   write, rejecting zip-slip attempts (T-05-09-01) all-or-nothing.
// - createBackup writes to the documents directory and preserves an
//   existing (non-'off') autoBackupFrequency across repeated backups.
// - No network client (OffApiClient/Connectivity) is ever touched.

import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:co2diet/data/local/app_database.dart';
import 'package:co2diet/data/local/daos/backup_metadata_dao.dart';
import 'package:co2diet/data/local/daos/co2_settings_dao.dart';
import 'package:co2diet/data/local/daos/meal_entry_dao.dart';
import 'package:co2diet/data/local/daos/notification_prefs_dao.dart';
import 'package:co2diet/data/local/daos/user_food_dao.dart';
import 'package:co2diet/data/local/daos/user_profile_dao.dart';
import 'package:co2diet/data/local/daos/weight_dao.dart';
import 'package:co2diet/domain/entities/weight_unit.dart';
import 'package:co2diet/domain/services/backup_export_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;

class _MockMealEntryDao extends Mock implements MealEntryDao {}

class _MockUserFoodDao extends Mock implements UserFoodDao {}

class _MockWeightDao extends Mock implements WeightDao {}

class _MockCo2SettingsDao extends Mock implements Co2SettingsDao {}

class _MockNotificationPrefsDao extends Mock
    implements NotificationPrefsDao {}

class _MockUserProfileDao extends Mock implements UserProfileDao {}

class _MockBackupMetadataDao extends Mock implements BackupMetadataDao {}

WeightEntryRow _buildWeightRow({
  String id = 'weight-1',
  double value = 70.5,
  WeightUnit unit = WeightUnit.kg,
  DateTime? loggedAt,
}) {
  return WeightEntryRow(
    id: id,
    hlcMillis: BigInt.from(1000),
    hlcCounter: 0,
    hlcNodeId: 'local',
    dirty: true,
    value: value,
    unit: unit,
    loggedAt: loggedAt ?? DateTime.utc(2026, 7, 1, 8),
  );
}

BackupMetadataRow _buildMetadataRow({
  String id = 'meta-1',
  String autoBackupFrequency = 'weekly',
  DateTime? lastBackupAt,
  String? lastBackupPath,
}) {
  return BackupMetadataRow(
    id: id,
    hlcMillis: BigInt.from(1000),
    hlcCounter: 0,
    hlcNodeId: 'local',
    dirty: true,
    autoBackupFrequency: autoBackupFrequency,
    lastBackupAt: lastBackupAt,
    lastBackupPath: lastBackupPath,
  );
}

void main() {
  late _MockMealEntryDao mealEntryDao;
  late _MockUserFoodDao userFoodDao;
  late _MockWeightDao weightDao;
  late _MockCo2SettingsDao co2SettingsDao;
  late _MockNotificationPrefsDao notificationPrefsDao;
  late _MockUserProfileDao userProfileDao;
  late _MockBackupMetadataDao backupMetadataDao;
  late Directory tempDir;
  late BackupExportService service;

  setUpAll(() {
    registerFallbackValue(<MealEntryRow>[]);
    registerFallbackValue(<FavoriteRow>[]);
    registerFallbackValue(<UserFoodRow>[]);
    registerFallbackValue(<WeightEntryRow>[]);
    registerFallbackValue(const UserProfileTableCompanion());
    registerFallbackValue(const BackupMetadataTableCompanion());
    registerFallbackValue(const Co2SettingsTableCompanion());
    registerFallbackValue(const NotificationPrefsTableCompanion());
  });

  setUp(() {
    mealEntryDao = _MockMealEntryDao();
    userFoodDao = _MockUserFoodDao();
    weightDao = _MockWeightDao();
    co2SettingsDao = _MockCo2SettingsDao();
    notificationPrefsDao = _MockNotificationPrefsDao();
    userProfileDao = _MockUserProfileDao();
    backupMetadataDao = _MockBackupMetadataDao();
    tempDir = Directory.systemTemp.createTempSync(
      'backup_export_service_test',
    );

    // Defaults: every category empty unless a specific test overrides it.
    when(() => userProfileDao.getProfile()).thenAnswer((_) async => null);
    when(() => mealEntryDao.getAllEntries()).thenAnswer((_) async => []);
    when(() => mealEntryDao.getFavorites()).thenAnswer((_) async => []);
    when(() => userFoodDao.getAllAlphabetical()).thenAnswer((_) async => []);
    when(() => weightDao.getEntriesInRange()).thenAnswer((_) async => []);
    when(() => co2SettingsDao.getSettings()).thenAnswer((_) async => null);
    when(
      () => notificationPrefsDao.getPrefs(),
    ).thenAnswer((_) async => null);
    when(
      () => backupMetadataDao.getMetadata(),
    ).thenAnswer((_) async => null);
    when(
      () => backupMetadataDao.saveMetadata(any()),
    ).thenAnswer((_) async {});
    when(() => mealEntryDao.restoreEntries(any())).thenAnswer((_) async {});
    when(
      () => mealEntryDao.restoreFavorites(any()),
    ).thenAnswer((_) async {});
    when(
      () => userFoodDao.restoreCustomFoods(any()),
    ).thenAnswer((_) async {});
    when(() => weightDao.restoreEntries(any())).thenAnswer((_) async {});
    when(() => userProfileDao.upsertProfile(any())).thenAnswer((_) async {});
    when(
      () => co2SettingsDao.upsertSettings(any()),
    ).thenAnswer((_) async {});
    when(() => notificationPrefsDao.savePrefs(any())).thenAnswer((
      _,
    ) async {});

    service = BackupExportService(
      mealEntryDao: mealEntryDao,
      userFoodDao: userFoodDao,
      weightDao: weightDao,
      co2SettingsDao: co2SettingsDao,
      notificationPrefsDao: notificationPrefsDao,
      userProfileDao: userProfileDao,
      backupMetadataDao: backupMetadataDao,
      documentsDir: tempDir,
    );
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('BackupExportService', () {
    test(
      'exportData produces a zip containing manifest.json plus one '
      'file per selected category/format',
      () async {
        when(
          () => weightDao.getEntriesInRange(),
        ).thenAnswer((_) async => [_buildWeightRow()]);

        final zip = await service.exportData(
          categories: {ExportCategory.weightEntries},
          formats: {ExportFormat.csv, ExportFormat.json},
        );

        expect(zip.existsSync(), isTrue);
        final archive = ZipDecoder().decodeBytes(zip.readAsBytesSync());
        final names = archive.files.map((f) => f.name).toSet();
        expect(
          names,
          {'manifest.json', 'weightEntries.csv', 'weightEntries.json'},
        );

        final csvContent = _stringContent(archive, 'weightEntries.csv');
        expect(csvContent, contains('value'));
        expect(csvContent, contains('70.5'));

        final jsonContent =
            jsonDecode(_stringContent(archive, 'weightEntries.json'))
                as List<dynamic>;
        expect(jsonContent, hasLength(1));
        expect((jsonContent.first as Map<String, dynamic>)['value'], 70.5);
      },
    );

    test(
      'manifest.json includes a formatVersion field alongside the '
      'per-file category/format/row-count entries -- excel output is a '
      'genuinely valid .xlsx, not a CSV with a renamed extension',
      () async {
        when(() => weightDao.getEntriesInRange()).thenAnswer(
          (_) async => [
            _buildWeightRow(),
            _buildWeightRow(id: 'weight-2', value: 71),
          ],
        );

        final zip = await service.exportData(
          categories: {ExportCategory.weightEntries},
          formats: {ExportFormat.excel},
        );

        final archive = ZipDecoder().decodeBytes(zip.readAsBytesSync());
        final manifest =
            jsonDecode(_stringContent(archive, 'manifest.json'))
                as Map<String, dynamic>;

        expect(manifest['formatVersion'], 1);
        expect(manifest['createdAt'], isNotNull);
        final files = manifest['files'] as List<dynamic>;
        expect(files, hasLength(1));
        final fileEntry = files.first as Map<String, dynamic>;
        expect(fileEntry['category'], 'weightEntries');
        expect(fileEntry['format'], 'excel');
        expect(fileEntry['fileName'], 'weightEntries.xlsx');
        expect(fileEntry['rowCount'], 2);

        // A genuine .xlsx is itself a zip of interdependent XML parts --
        // confirms the excel package produced real OOXML, not CSV text
        // wearing a .xlsx extension.
        final excelBytes = archive.findFile('weightEntries.xlsx')!.content
            as List<int>;
        final excelArchive = ZipDecoder().decodeBytes(excelBytes);
        expect(excelArchive.findFile('[Content_Types].xml'), isNotNull);
      },
    );

    test(
      'previewRestore rejects a manifest.json with an unrecognized '
      'formatVersion before any write',
      () async {
        final badZipPath = p.join(tempDir.path, 'bad_format.zip');
        final encoder = ZipFileEncoder()
          ..create(badZipPath)
          ..addArchiveFile(
            ArchiveFile.string(
              'manifest.json',
              jsonEncode({
                'formatVersion': 99,
                'createdAt': DateTime.now().toIso8601String(),
                'files': <Map<String, dynamic>>[],
              }),
            ),
          );
        await encoder.close();

        await expectLater(
          () => service.previewRestore(File(badZipPath)),
          throwsA(isA<UnsupportedBackupFormatException>()),
        );

        verifyNever(() => userProfileDao.upsertProfile(any()));
        verifyNever(() => mealEntryDao.restoreEntries(any()));
        verifyNever(() => weightDao.restoreEntries(any()));
      },
    );

    test(
      'restore preview lists what would change before any write occurs',
      () async {
        when(
          () => weightDao.getEntriesInRange(),
        ).thenAnswer((_) async => [_buildWeightRow()]);

        final zip = await service.createBackup();
        clearInteractions(weightDao);
        clearInteractions(userProfileDao);
        clearInteractions(mealEntryDao);

        final preview = await service.previewRestore(zip);

        expect(preview.formatVersion, 1);
        expect(preview.categoryRowCounts[ExportCategory.weightEntries], 1);
        expect(preview.categoryRowCounts[ExportCategory.mealEntries], 0);
        expect(preview.backupDate, isNotNull);

        verifyNever(() => weightDao.restoreEntries(any()));
        verifyNever(() => mealEntryDao.restoreEntries(any()));
        verifyNever(() => userProfileDao.upsertProfile(any()));
      },
    );

    test(
      'restore rejects a zip entry whose normalized path escapes '
      'the target extraction directory (zip-slip)',
      () async {
        final maliciousZipPath = p.join(tempDir.path, 'malicious.zip');
        final encoder = ZipFileEncoder()
          ..create(maliciousZipPath)
          ..addArchiveFile(
            ArchiveFile.string(
              'manifest.json',
              jsonEncode({
                'formatVersion': 1,
                'createdAt': DateTime.now().toIso8601String(),
                'files': [
                  {
                    'category': 'weightEntries',
                    'format': 'json',
                    'fileName': '../../../etc/passwd',
                    'rowCount': 0,
                  },
                ],
              }),
            ),
          )
          ..addArchiveFile(ArchiveFile.string('../../../etc/passwd', '[]'));
        await encoder.close();

        await expectLater(
          () => service.applyRestore(File(maliciousZipPath)),
          throwsA(isA<ZipSlipException>()),
        );

        verifyNever(() => weightDao.restoreEntries(any()));
        verifyNever(() => userProfileDao.upsertProfile(any()));
        verifyNever(() => mealEntryDao.restoreEntries(any()));

        // The malicious path must never have been written to disk outside
        // the temp (documents) directory.
        expect(File('/tmp/etc/passwd').existsSync(), isFalse);
      },
    );

    test(
      "createBackup's restore preview lists all 7 ExportCategory values "
      '-- not just the ones with data -- so the Restore Data screen '
      'never silently under-reports what a full backup actually contains',
      () async {
        when(() => userProfileDao.getProfile()).thenAnswer(
          (_) async => UserProfileRow(
            id: 'p1',
            hlcMillis: BigInt.from(1),
            hlcCounter: 0,
            hlcNodeId: 'local',
            dirty: true,
            units: 'metric',
            kcalIsOverridden: false,
            proteinIsOverridden: false,
            carbsIsOverridden: false,
            fatIsOverridden: false,
            co2IsOverridden: false,
            co2MethodologyVersion: 'v1',
            createdAt: DateTime.utc(2026),
          ),
        );
        when(
          () => weightDao.getEntriesInRange(),
        ).thenAnswer((_) async => [_buildWeightRow()]);

        final zip = await service.createBackup();
        final preview = await service.previewRestore(zip);

        expect(
          preview.categoryRowCounts.keys.toSet(),
          ExportCategory.values.toSet(),
        );
        expect(preview.categoryRowCounts[ExportCategory.profile], 1);
        expect(preview.categoryRowCounts[ExportCategory.weightEntries], 1);
        expect(preview.categoryRowCounts[ExportCategory.mealEntries], 0);
        expect(preview.categoryRowCounts[ExportCategory.favorites], 0);
        expect(preview.categoryRowCounts[ExportCategory.customFoods], 0);
        expect(preview.categoryRowCounts[ExportCategory.co2Settings], 0);
        expect(preview.categoryRowCounts[ExportCategory.notificationPrefs], 0);
      },
    );

    test(
      'exportData (human-facing export) excludes internal sync-machinery '
      'columns (id/hlcMillis/hlcCounter/hlcNodeId/dirty/deletedAt) from '
      'the encoded rows',
      () async {
        when(
          () => weightDao.getEntriesInRange(),
        ).thenAnswer((_) async => [_buildWeightRow()]);

        final zip = await service.exportData(
          categories: {ExportCategory.weightEntries},
          formats: {ExportFormat.json},
        );

        final archive = ZipDecoder().decodeBytes(zip.readAsBytesSync());
        final jsonContent =
            jsonDecode(_stringContent(archive, 'weightEntries.json'))
                as List<dynamic>;
        final row = jsonContent.first as Map<String, dynamic>;

        expect(row.containsKey('id'), isFalse);
        expect(row.containsKey('hlcMillis'), isFalse);
        expect(row.containsKey('hlcCounter'), isFalse);
        expect(row.containsKey('hlcNodeId'), isFalse);
        expect(row.containsKey('dirty'), isFalse);
        expect(row.containsKey('deletedAt'), isFalse);
        // User-meaningful fields survive.
        expect(row['value'], 70.5);
        expect(row['unit'], 'kg');
      },
    );

    test(
      'createBackup retains internal sync-machinery columns so a restore '
      'can reconstruct the original row',
      () async {
        final original = _buildWeightRow();
        when(
          () => weightDao.getEntriesInRange(),
        ).thenAnswer((_) async => [original]);

        final zip = await service.createBackup();
        clearInteractions(weightDao);
        when(() => weightDao.restoreEntries(any())).thenAnswer((_) async {});

        await service.applyRestore(zip);

        final captured = verify(
          () => weightDao.restoreEntries(captureAny()),
        ).captured.single as List<WeightEntryRow>;
        expect(captured, hasLength(1));
        expect(captured.first.id, original.id);
        expect(captured.first.hlcMillis, original.hlcMillis);
        expect(captured.first.hlcCounter, original.hlcCounter);
        expect(captured.first.hlcNodeId, original.hlcNodeId);
        expect(captured.first.dirty, original.dirty);
        expect(captured.first.value, original.value);
      },
    );

    test(
      'createBackup writes to the app documents directory; automatic '
      'backup frequency off/daily/weekly is honored',
      () async {
        BackupMetadataTableCompanion? captured;
        when(() => backupMetadataDao.getMetadata()).thenAnswer(
          (_) async => null,
        );
        when(() => backupMetadataDao.saveMetadata(any())).thenAnswer((
          invocation,
        ) async {
          captured =
              invocation.positionalArguments[0]
                  as BackupMetadataTableCompanion;
        });

        final zip = await service.createBackup();

        expect(zip.existsSync(), isTrue);
        expect(p.isWithin(tempDir.path, zip.path), isTrue);
        expect(captured, isNotNull);
        expect(captured!.lastBackupPath.value, zip.path);
        expect(captured!.lastBackupAt.value, isNotNull);
        // No prior metadata row -- defaults to 'off', not fabricated.
        expect(captured!.autoBackupFrequency.value, 'off');

        // A subsequent backup preserves an existing non-'off' frequency
        // rather than silently resetting it, and reuses the existing row's
        // id (single-row upsert invariant).
        when(() => backupMetadataDao.getMetadata()).thenAnswer(
          (_) async => _buildMetadataRow(
            lastBackupAt: DateTime.utc(2026),
            lastBackupPath: '/old/path.zip',
          ),
        );

        await service.createBackup();

        expect(captured!.autoBackupFrequency.value, 'weekly');
        expect(captured!.id.value, 'meta-1');
      },
    );
  });
}

String _stringContent(Archive archive, String fileName) {
  final file = archive.findFile(fileName);
  if (file == null) {
    fail('Expected "$fileName" in archive but it was missing');
  }
  final content = file.content;
  return content is String ? content : utf8.decode(content as List<int>);
}
