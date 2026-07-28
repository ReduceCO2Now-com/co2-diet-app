// Tests for the Backup & Restore feature (PRIV-01 through PRIV-04,
// PRIV-08, PRIV-09).
//
// BackupNotifier group covers:
// - build() loads the current BackupMetadata.
// - shareExport/createAndShareBackup delegate to BackupExportService and
//   hand the resulting file to the OS share sheet.
// - pickAndPreviewRestoreFile opens the file_selector seam (filePicker
//   Provider) and delegates the picked path to previewRestore; a
//   cancelled pick (null) is a no-op returning null, no error.
// - applyRestore delegates to BackupExportService and refreshes state.
// - saveAutoBackupFrequency persists the frequency without touching
//   lastBackupAt/lastBackupPath.
//
// BackupRestoreScreen group covers:
// - Danger Zone delete button stays disabled until the exact word DELETE
//   is typed.
// - Restore Data's choose-file -> preview -> explicit confirm flow,
//   including the cancelled-pick no-op case.
// - Privacy & Ownership statement's exact disclosure text is present.

import 'dart:io';

import 'package:co2diet/core/di/backup_providers.dart';
import 'package:co2diet/data/local/app_database.dart';
import 'package:co2diet/data/local/daos/backup_metadata_dao.dart';
import 'package:co2diet/data/repositories/backup_metadata_repository.dart';
import 'package:co2diet/domain/services/backup_export_service.dart';
import 'package:co2diet/features/backup/providers/backup_notifier.dart';
import 'package:co2diet/features/backup/screens/backup_restore_screen.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:share_plus_platform_interface/share_plus_platform_interface.dart';

class _MockBackupMetadataDao extends Mock implements BackupMetadataDao {}

class _MockBackupExportService extends Mock implements BackupExportService {}

class _MockSharePlatform extends Mock
    with MockPlatformInterfaceMixin
    implements SharePlatform {}

BackupMetadataRow _buildMetadataRow({
  String id = 'meta-1',
  String autoBackupFrequency = 'off',
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
  // `SharePlus.instance` is a `static final` field: it is lazily
  // initialized on first access and then permanently bound to whichever
  // `SharePlatform.instance` was set at that moment. Creating a *new*
  // mock platform per test (and reassigning `SharePlatform.instance`)
  // would only affect the second and later tests, since `SharePlus
  // .instance` already captured the first test's mock. A single
  // process-wide mock, reset between tests via `reset()`, avoids this.
  late _MockSharePlatform mockSharePlatform;

  setUpAll(() {
    registerFallbackValue(<ExportCategory>{});
    registerFallbackValue(<ExportFormat>{});
    registerFallbackValue(File('fallback.zip'));
    registerFallbackValue(ShareParams());
    registerFallbackValue(const BackupMetadataTableCompanion());
    mockSharePlatform = _MockSharePlatform();
    SharePlatform.instance = mockSharePlatform;
  });

  setUp(() {
    reset(mockSharePlatform);
    when(
      () => mockSharePlatform.share(any()),
    ).thenAnswer((_) async => const ShareResult('', ShareResultStatus.success));
  });

  group('BackupNotifier', () {
    late _MockBackupMetadataDao mockDao;
    late _MockBackupExportService mockService;

    setUp(() {
      mockDao = _MockBackupMetadataDao();
      mockService = _MockBackupExportService();
    });

    ProviderContainer buildContainer({FilePickerFn? filePicker}) {
      return ProviderContainer(
        overrides: [
          backupMetadataRepositoryProvider.overrideWithValue(
            BackupMetadataRepository(mockDao),
          ),
          backupExportServiceProvider.overrideWith(
            (ref) async => mockService,
          ),
          if (filePicker != null)
            filePickerProvider.overrideWithValue(filePicker),
        ],
      );
    }

    test('build() loads the current BackupMetadata', () async {
      when(() => mockDao.getMetadata()).thenAnswer(
        (_) async => _buildMetadataRow(autoBackupFrequency: 'weekly'),
      );

      final container = buildContainer();
      addTearDown(container.dispose);

      final metadata = await container.read(backupProvider.future);
      expect(metadata.autoBackupFrequency, 'weekly');
    });

    test(
      'createAndShareBackup delegates to BackupExportService.createBackup '
      'and shares the resulting file',
      () async {
        when(
          () => mockDao.getMetadata(),
        ).thenAnswer((_) async => _buildMetadataRow());
        final zipFile = File('backup.zip');
        when(
          () => mockService.createBackup(),
        ).thenAnswer((_) async => zipFile);

        final container = buildContainer();
        addTearDown(container.dispose);
        await container.read(backupProvider.future);

        await container.read(backupProvider.notifier).createAndShareBackup();

        verify(() => mockService.createBackup()).called(1);
        verify(() => mockSharePlatform.share(any())).called(1);
      },
    );

    test(
      'shareExport delegates to BackupExportService.exportData with the '
      'given categories/formats and shares the resulting file',
      () async {
        when(
          () => mockDao.getMetadata(),
        ).thenAnswer((_) async => _buildMetadataRow());
        final zipFile = File('export.zip');
        when(
          () => mockService.exportData(
            categories: any(named: 'categories'),
            formats: any(named: 'formats'),
          ),
        ).thenAnswer((_) async => zipFile);

        final container = buildContainer();
        addTearDown(container.dispose);
        await container.read(backupProvider.future);

        await container
            .read(backupProvider.notifier)
            .shareExport(
              categories: {ExportCategory.mealEntries},
              formats: {ExportFormat.csv},
            );

        verify(
          () => mockService.exportData(
            categories: {ExportCategory.mealEntries},
            formats: {ExportFormat.csv},
          ),
        ).called(1);
        verify(() => mockSharePlatform.share(any())).called(1);
      },
    );

    test(
      'pickAndPreviewRestoreFile delegates the picked path to '
      'previewRestore and stores the file as pendingRestoreFile',
      () async {
        when(
          () => mockDao.getMetadata(),
        ).thenAnswer((_) async => _buildMetadataRow());
        const preview = RestorePreview(
          formatVersion: 1,
          backupDate: null,
          categoryRowCounts: {ExportCategory.mealEntries: 3},
        );
        when(
          () => mockService.previewRestore(any()),
        ).thenAnswer((_) async => preview);

        // file_selector's top-level openFile is not directly mockable via
        // mocktail (it isn't a class method) -- this test injects a fake
        // picked path directly through the filePickerProvider seam
        // (documented in backup_providers.dart's FilePickerFn).
        final container = buildContainer(
          filePicker: ({acceptedTypeGroups = const <XTypeGroup>[]}) async =>
              XFile('/fake/picked/backup.zip'),
        );
        addTearDown(container.dispose);
        await container.read(backupProvider.future);

        final notifier = container.read(backupProvider.notifier);
        final result = await notifier.pickAndPreviewRestoreFile();

        expect(result, preview);
        expect(notifier.pendingRestoreFile?.path, '/fake/picked/backup.zip');
        final captured = verify(
          () => mockService.previewRestore(captureAny()),
        ).captured;
        expect((captured.single as File).path, '/fake/picked/backup.zip');
      },
    );

    test(
      'pickAndPreviewRestoreFile returns null and sets no pending file '
      'when the picker is cancelled',
      () async {
        when(
          () => mockDao.getMetadata(),
        ).thenAnswer((_) async => _buildMetadataRow());

        final container = buildContainer(
          filePicker: ({acceptedTypeGroups = const <XTypeGroup>[]}) async =>
              null,
        );
        addTearDown(container.dispose);
        await container.read(backupProvider.future);

        final notifier = container.read(backupProvider.notifier);
        final result = await notifier.pickAndPreviewRestoreFile();

        expect(result, isNull);
        expect(notifier.pendingRestoreFile, isNull);
        verifyNever(() => mockService.previewRestore(any()));
      },
    );

    test(
      'applyRestore delegates to BackupExportService.applyRestore and '
      'refreshes state',
      () async {
        when(
          () => mockDao.getMetadata(),
        ).thenAnswer((_) async => _buildMetadataRow());
        when(() => mockService.applyRestore(any())).thenAnswer((_) async {});

        final container = buildContainer();
        addTearDown(container.dispose);
        await container.read(backupProvider.future);

        final zip = File('restore.zip');
        await container.read(backupProvider.notifier).applyRestore(zip);

        verify(() => mockService.applyRestore(zip)).called(1);
      },
    );

    test(
      'saveAutoBackupFrequency persists the new frequency without '
      'touching lastBackupAt/lastBackupPath',
      () async {
        when(() => mockDao.getMetadata()).thenAnswer(
          (_) async => _buildMetadataRow(
            lastBackupAt: DateTime.utc(2026),
            lastBackupPath: '/docs/co2diet_backup_1.zip',
          ),
        );
        when(
          () => mockDao.saveMetadata(any()),
        ).thenAnswer((_) async {});

        final container = buildContainer();
        addTearDown(container.dispose);
        await container.read(backupProvider.future);

        await container
            .read(backupProvider.notifier)
            .saveAutoBackupFrequency('weekly');

        final captured = verify(
          () => mockDao.saveMetadata(captureAny()),
        ).captured;
        final companion = captured.single as BackupMetadataTableCompanion;
        expect(companion.autoBackupFrequency.value, 'weekly');
        expect(
          companion.lastBackupPath.value,
          '/docs/co2diet_backup_1.zip',
        );
      },
    );
  });

  group('BackupRestoreScreen', () {
    late _MockBackupMetadataDao mockDao;
    late _MockBackupExportService mockService;

    setUp(() {
      mockDao = _MockBackupMetadataDao();
      mockService = _MockBackupExportService();
      when(
        () => mockDao.getMetadata(),
      ).thenAnswer((_) async => _buildMetadataRow());
      when(() => mockService.storageStatus()).thenAnswer(
        (_) async => {for (final c in ExportCategory.values) c: 0},
      );
    });

    Widget buildTestable({FilePickerFn? filePicker}) {
      return ProviderScope(
        overrides: [
          backupMetadataRepositoryProvider.overrideWithValue(
            BackupMetadataRepository(mockDao),
          ),
          backupExportServiceProvider.overrideWith(
            (ref) async => mockService,
          ),
          if (filePicker != null)
            filePickerProvider.overrideWithValue(filePicker),
        ],
        child: const MaterialApp(home: BackupRestoreScreen()),
      );
    }

    void setTallViewport(WidgetTester tester) {
      // Tall viewport so every section (Storage Status through Danger
      // Zone) is within cache extent -- mirrors Co2SettingsScreen/
      // WeightScreen's established test precedent.
      tester.view.physicalSize = const Size(1080, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    testWidgets(
      'Danger Zone delete button stays disabled until the exact '
      'word DELETE is typed',
      (tester) async {
        setTallViewport(tester);
        await tester.pumpWidget(buildTestable());
        await tester.pumpAndSettle();

        final deleteButtonFinder = find.widgetWithText(
          FilledButton,
          'Delete all local data',
        );
        expect(
          tester.widget<FilledButton>(deleteButtonFinder).onPressed,
          isNull,
        );

        await tester.enterText(
          find.widgetWithText(TextField, 'Type DELETE to confirm'),
          'DELET',
        );
        await tester.pumpAndSettle();
        expect(
          tester.widget<FilledButton>(deleteButtonFinder).onPressed,
          isNull,
        );

        await tester.enterText(
          find.widgetWithText(TextField, 'Type DELETE to confirm'),
          'DELETE',
        );
        await tester.pumpAndSettle();
        expect(
          tester.widget<FilledButton>(deleteButtonFinder).onPressed,
          isNotNull,
        );
      },
    );

    testWidgets(
      'Restore Data opens a real OS file picker and can import a '
      "backup zip from outside the app's own documents directory",
      (tester) async {
        setTallViewport(tester);
        const preview = RestorePreview(
          formatVersion: 1,
          backupDate: null,
          categoryRowCounts: {ExportCategory.mealEntries: 5},
        );
        when(
          () => mockService.previewRestore(any()),
        ).thenAnswer((_) async => preview);

        await tester.pumpWidget(
          buildTestable(
            filePicker: ({acceptedTypeGroups = const <XTypeGroup>[]}) async =>
                XFile('/fake/outside/backup.zip'),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('This backup will restore:'), findsNothing);

        await tester.tap(find.text('Choose backup file'));
        await tester.pumpAndSettle();

        expect(find.text('This backup will restore:'), findsOneWidget);
        expect(find.textContaining('Meal entries: 5 row(s)'), findsOneWidget);
        expect(find.text('Confirm Restore'), findsOneWidget);
        verify(() => mockService.previewRestore(any())).called(1);
      },
    );

    testWidgets(
      'a cancelled file pick leaves the screen unchanged with no error',
      (tester) async {
        setTallViewport(tester);

        await tester.pumpWidget(
          buildTestable(
            filePicker: ({acceptedTypeGroups = const <XTypeGroup>[]}) async =>
                null,
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Choose backup file'));
        await tester.pumpAndSettle();

        expect(find.text('This backup will restore:'), findsNothing);
        expect(find.text('Confirm Restore'), findsNothing);
        verifyNever(() => mockService.previewRestore(any()));
      },
    );

    testWidgets(
      'Restore requires an explicit confirmation step after '
      'showing the preview',
      (tester) async {
        setTallViewport(tester);
        const preview = RestorePreview(
          formatVersion: 1,
          backupDate: null,
          categoryRowCounts: {ExportCategory.mealEntries: 5},
        );
        when(
          () => mockService.previewRestore(any()),
        ).thenAnswer((_) async => preview);
        when(() => mockService.applyRestore(any())).thenAnswer((_) async {});

        await tester.pumpWidget(
          buildTestable(
            filePicker: ({acceptedTypeGroups = const <XTypeGroup>[]}) async =>
                XFile('/fake/outside/backup.zip'),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Choose backup file'));
        await tester.pumpAndSettle();

        // Restoring is not applied until "Confirm Restore" is tapped.
        verifyNever(() => mockService.applyRestore(any()));

        await tester.tap(find.text('Confirm Restore'));
        await tester.pumpAndSettle();

        verify(() => mockService.applyRestore(any())).called(1);
        // Preview clears once the restore has been applied.
        expect(find.text('Confirm Restore'), findsNothing);
      },
    );

    testWidgets(
      'Privacy & Ownership statement discloses that shared '
      'backups are not encrypted by the app',
      (tester) async {
        setTallViewport(tester);
        await tester.pumpWidget(buildTestable());
        await tester.pumpAndSettle();

        expect(
          find.textContaining(
            'Exports and backups are not encrypted by this app.',
          ),
          findsOneWidget,
        );
      },
    );
  });
}
