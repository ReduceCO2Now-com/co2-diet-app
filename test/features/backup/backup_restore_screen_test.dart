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
import 'package:co2diet/domain/entities/auth_state.dart';
import 'package:co2diet/domain/services/backup_export_service.dart';
import 'package:co2diet/features/auth/providers/auth_provider.dart';
import 'package:co2diet/features/backup/providers/backup_notifier.dart';
import 'package:co2diet/features/backup/providers/backup_sync_notifier.dart';
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

/// A plain override provider carrying the desired [AuthState] into
/// [_FakeAuthNotifier.build] -- `authProvider.overrideWith` needs a
/// `Notifier` factory, not a raw value.
final _authStateOverrideProvider = Provider<AuthState>(
  (ref) => AuthState.unauthenticated(),
);

class _FakeAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => ref.watch(_authStateOverrideProvider);
}

/// A fake [BackupSyncNotifier] whose `pushBackup`/`pullBackup` delegate to
/// test-supplied callbacks -- `backupSyncProvider.overrideWith` needs a
/// `Notifier` factory, and the real notifier's methods reach live DAOs/
/// HTTP that widget tests must not touch.
class _FakeBackupSyncNotifier extends BackupSyncNotifier {
  _FakeBackupSyncNotifier({this.pushImpl, this.pullImpl});

  final Future<void> Function(String passphrase)? pushImpl;
  final Future<bool> Function(String passphrase)? pullImpl;

  @override
  void build() {}

  @override
  Future<void> pushBackup(String passphrase) =>
      pushImpl?.call(passphrase) ?? Future<void>.value();

  @override
  Future<bool> pullBackup(String passphrase) =>
      pullImpl?.call(passphrase) ?? Future<bool>.value(true);
}

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
          () => mockService.createBackup(passphrase: any(named: 'passphrase')),
        ).thenAnswer((_) async => zipFile);

        final container = buildContainer();
        addTearDown(container.dispose);
        await container.read(backupProvider.future);

        await container.read(backupProvider.notifier).createAndShareBackup();

        verify(() => mockService.createBackup(passphrase: null)).called(1);
        verify(() => mockSharePlatform.share(any())).called(1);
      },
    );

    test(
      'createAndShareBackup threads a non-null passphrase straight to '
      'BackupExportService.createBackup',
      () async {
        when(
          () => mockDao.getMetadata(),
        ).thenAnswer((_) async => _buildMetadataRow());
        final zipFile = File('backup.zip');
        when(
          () => mockService.createBackup(passphrase: any(named: 'passphrase')),
        ).thenAnswer((_) async => zipFile);

        final container = buildContainer();
        addTearDown(container.dispose);
        await container.read(backupProvider.future);

        await container
            .read(backupProvider.notifier)
            .createAndShareBackup(passphrase: 'my passphrase');

        verify(
          () => mockService.createBackup(passphrase: 'my passphrase'),
        ).called(1);
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
      'pickAndPreviewRestoreFile passes a uniformTypeIdentifiers-bearing '
      'XTypeGroup -- file_selector_ios reads ONLY this field (ignores '
      'extensions entirely) and throws an ArgumentError before the picker '
      'ever opens if it is empty, so this is required for iOS to work at '
      'all, not merely nice-to-have',
      () async {
        when(
          () => mockDao.getMetadata(),
        ).thenAnswer((_) async => _buildMetadataRow());

        List<XTypeGroup>? capturedGroups;
        final container = buildContainer(
          filePicker: ({acceptedTypeGroups = const <XTypeGroup>[]}) async {
            capturedGroups = acceptedTypeGroups;
            return null;
          },
        );
        addTearDown(container.dispose);
        await container.read(backupProvider.future);

        await container
            .read(backupProvider.notifier)
            .pickAndPreviewRestoreFile();

        expect(capturedGroups, isNotNull);
        for (final group in capturedGroups!) {
          final hasUtis = group.uniformTypeIdentifiers?.isNotEmpty ?? false;
          expect(
            group.allowsAny || hasUtis,
            isTrue,
            reason:
                'XTypeGroup "${group.label}" has no uniformTypeIdentifiers -- '
                'file_selector_ios would throw ArgumentError before '
                'presenting the picker on a real iOS device',
          );
        }
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
        when(
          () => mockService.applyRestore(
            any(),
            passphrase: any(named: 'passphrase'),
          ),
        ).thenAnswer((_) async {});

        final container = buildContainer();
        addTearDown(container.dispose);
        await container.read(backupProvider.future);

        final zip = File('restore.zip');
        await container.read(backupProvider.notifier).applyRestore(zip);

        verify(
          () => mockService.applyRestore(zip, passphrase: null),
        ).called(1);
      },
    );

    test(
      'applyRestore threads a non-null passphrase straight to '
      'BackupExportService.applyRestore',
      () async {
        when(
          () => mockDao.getMetadata(),
        ).thenAnswer((_) async => _buildMetadataRow());
        when(
          () => mockService.applyRestore(
            any(),
            passphrase: any(named: 'passphrase'),
          ),
        ).thenAnswer((_) async {});

        final container = buildContainer();
        addTearDown(container.dispose);
        await container.read(backupProvider.future);

        final zip = File('restore.zip');
        await container
            .read(backupProvider.notifier)
            .applyRestore(zip, passphrase: 'correct passphrase');

        verify(
          () => mockService.applyRestore(zip, passphrase: 'correct passphrase'),
        ).called(1);
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

    Widget buildTestable({
      FilePickerFn? filePicker,
      bool? backupSyncEnabled,
      AuthState? authState,
      Future<void> Function(String passphrase)? pushImpl,
      Future<bool> Function(String passphrase)? pullImpl,
    }) {
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
          if (backupSyncEnabled != null)
            backupSyncEnabledProvider.overrideWithValue(backupSyncEnabled),
          if (authState != null) ...[
            authProvider.overrideWith(_FakeAuthNotifier.new),
            _authStateOverrideProvider.overrideWithValue(authState),
          ],
          if (pushImpl != null || pullImpl != null)
            backupSyncProvider.overrideWith(
              () => _FakeBackupSyncNotifier(
                pushImpl: pushImpl,
                pullImpl: pullImpl,
              ),
            ),
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
        when(
          () => mockService.applyRestore(
            any(),
            passphrase: any(named: 'passphrase'),
          ),
        ).thenAnswer((_) async {});

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
        verifyNever(
          () => mockService.applyRestore(
            any(),
            passphrase: any(named: 'passphrase'),
          ),
        );

        await tester.tap(find.text('Confirm Restore'));
        await tester.pumpAndSettle();

        verify(
          () => mockService.applyRestore(
            any(),
            passphrase: any(named: 'passphrase'),
          ),
        ).called(1);
        // Preview clears once the restore has been applied.
        expect(find.text('Confirm Restore'), findsNothing);
      },
    );

    testWidgets(
      'Privacy & Ownership statement discloses that shared backups are '
      'not encrypted by default, AND acknowledges the new optional '
      'passphrase-encrypted backup with its own unrecoverability caveat',
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
        expect(
          find.textContaining(
            'You can optionally encrypt a backup with a passphrase only '
            'you know',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Encrypt toggle opens the create-passphrase dialog, and the entered '
      'passphrase is threaded through to createAndShareBackup',
      (tester) async {
        setTallViewport(tester);
        when(
          () => mockService.createBackup(passphrase: any(named: 'passphrase')),
        ).thenAnswer((_) async => File('backup.zip'));

        await tester.pumpWidget(buildTestable());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Encrypt this backup'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Create backup'));
        await tester.pumpAndSettle();

        // The create-passphrase dialog is now showing.
        expect(find.text('Encrypt this backup'), findsWidgets);
        expect(find.widgetWithText(TextField, 'Passphrase'), findsOneWidget);
        expect(
          find.widgetWithText(TextField, 'Confirm passphrase'),
          findsOneWidget,
        );

        const passphrase = 'a passphrase over ten chars';
        await tester.enterText(
          find.widgetWithText(TextField, 'Passphrase'),
          passphrase,
        );
        await tester.enterText(
          find.widgetWithText(TextField, 'Confirm passphrase'),
          passphrase,
        );
        await tester.pumpAndSettle();

        // The Encrypt button stays disabled until the unrecoverability
        // checkbox is also checked.
        var encryptButton = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Encrypt'),
        );
        expect(encryptButton.onPressed, isNull);

        await tester.tap(find.byType(Checkbox));
        await tester.pumpAndSettle();

        encryptButton = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Encrypt'),
        );
        expect(encryptButton.onPressed, isNotNull);

        await tester.tap(find.widgetWithText(FilledButton, 'Encrypt'));
        await tester.pumpAndSettle();

        verify(
          () => mockService.createBackup(passphrase: passphrase),
        ).called(1);
      },
    );

    testWidgets(
      'an encrypted-preview-detected restore shows "This backup is '
      'encrypted" and an "Enter passphrase" button instead of row counts',
      (tester) async {
        setTallViewport(tester);
        final preview = RestorePreview.encrypted(backupDate: null);
        when(
          () => mockService.previewRestore(any()),
        ).thenAnswer((_) async => preview);

        await tester.pumpWidget(
          buildTestable(
            filePicker: ({acceptedTypeGroups = const <XTypeGroup>[]}) async =>
                XFile('/fake/outside/backup_encrypted.zip'),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Choose backup file'));
        await tester.pumpAndSettle();

        expect(find.text('This backup is encrypted'), findsOneWidget);
        expect(find.text('Enter passphrase'), findsOneWidget);
        expect(find.text('This backup will restore:'), findsNothing);
        expect(find.text('Confirm Restore'), findsNothing);
      },
    );

    testWidgets(
      'a wrong passphrase on restore re-opens the enter-passphrase prompt '
      'with an inline retry error, without re-picking the file, and a '
      'correct passphrase on retry succeeds',
      (tester) async {
        setTallViewport(tester);
        final preview = RestorePreview.encrypted(backupDate: null);
        when(
          () => mockService.previewRestore(any()),
        ).thenAnswer((_) async => preview);

        var callCount = 0;
        when(
          () => mockService.applyRestore(
            any(),
            passphrase: any(named: 'passphrase'),
          ),
        ).thenAnswer((_) async {
          callCount++;
          if (callCount == 1) {
            throw WrongBackupPassphraseException();
          }
        });

        await tester.pumpWidget(
          buildTestable(
            filePicker: ({acceptedTypeGroups = const <XTypeGroup>[]}) async =>
                XFile('/fake/outside/backup_encrypted.zip'),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Choose backup file'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Enter passphrase'));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(TextField, 'Passphrase'),
          'wrong one',
        );
        await tester.pump();
        await tester.tap(find.widgetWithText(FilledButton, 'Unlock'));
        await tester.pumpAndSettle();

        // The retry error is shown, and the enter-passphrase prompt is
        // still open (or reopened) -- the file was never re-picked.
        expect(
          find.textContaining("That passphrase didn't work."),
          findsOneWidget,
        );

        await tester.enterText(
          find.widgetWithText(TextField, 'Passphrase'),
          'the right one',
        );
        await tester.pump();
        await tester.tap(find.widgetWithText(FilledButton, 'Unlock'));
        await tester.pumpAndSettle();

        expect(callCount, 2);
        verify(
          () => mockService.applyRestore(
            any(),
            passphrase: any(named: 'passphrase'),
          ),
        ).called(2);
      },
    );

    group('Cloud Backup (Beta) section (Plan 08-03)', () {
      testWidgets(
        'renders nothing when backupSyncEnabledProvider is left at its '
        'real (shipped) default of false, regardless of auth state',
        (tester) async {
          setTallViewport(tester);

          await tester.pumpWidget(
            buildTestable(
              authState: const AuthAuthenticated(
                email: 'user@example.com',
                accessToken: 'token-123',
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.textContaining('Cloud Backup'), findsNothing);
        },
      );

      testWidgets(
        'renders nothing when the flag is overridden true but the user is '
        'not in Account Mode',
        (tester) async {
          setTallViewport(tester);

          await tester.pumpWidget(
            buildTestable(
              backupSyncEnabled: true,
              authState: AuthState.unauthenticated(),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.textContaining('Cloud Backup'), findsNothing);
        },
      );

      testWidgets(
        'renders and "Push to Cloud" triggers pushBackup with the entered '
        'passphrase when both the flag and Account Mode are true',
        (tester) async {
          setTallViewport(tester);
          String? capturedPassphrase;

          await tester.pumpWidget(
            buildTestable(
              backupSyncEnabled: true,
              authState: const AuthAuthenticated(
                email: 'user@example.com',
                accessToken: 'token-123',
              ),
              pushImpl: (passphrase) async {
                capturedPassphrase = passphrase;
              },
            ),
          );
          await tester.pumpAndSettle();

          expect(find.text('Cloud Backup (Beta)'), findsOneWidget);
          expect(find.widgetWithText(OutlinedButton, 'Push to Cloud'),
              findsOneWidget);
          expect(find.widgetWithText(OutlinedButton, 'Pull from Cloud'),
              findsOneWidget);

          await tester.tap(find.text('Push to Cloud'));
          await tester.pumpAndSettle();

          const passphrase = 'a passphrase over ten chars';
          await tester.enterText(
            find.widgetWithText(TextField, 'Passphrase'),
            passphrase,
          );
          await tester.enterText(
            find.widgetWithText(TextField, 'Confirm passphrase'),
            passphrase,
          );
          await tester.pumpAndSettle();

          await tester.tap(find.byType(Checkbox));
          await tester.pumpAndSettle();

          await tester.tap(find.widgetWithText(FilledButton, 'Encrypt'));
          await tester.pumpAndSettle();

          expect(capturedPassphrase, passphrase);
          expect(
            find.text('Backup pushed to the cloud.'),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        '"Pull from Cloud" with a wrong passphrase re-opens the '
        'enter-passphrase prompt with the same Pitfall-7 retry copy Plan '
        '08-01 uses for local restore',
        (tester) async {
          setTallViewport(tester);
          var callCount = 0;

          await tester.pumpWidget(
            buildTestable(
              backupSyncEnabled: true,
              authState: const AuthAuthenticated(
                email: 'user@example.com',
                accessToken: 'token-123',
              ),
              pullImpl: (passphrase) async {
                callCount++;
                if (callCount == 1) {
                  throw WrongBackupPassphraseException();
                }
                return true;
              },
            ),
          );
          await tester.pumpAndSettle();

          await tester.tap(find.text('Pull from Cloud'));
          await tester.pumpAndSettle();

          await tester.enterText(
            find.widgetWithText(TextField, 'Passphrase'),
            'wrong one',
          );
          await tester.pump();
          await tester.tap(find.widgetWithText(FilledButton, 'Unlock'));
          await tester.pumpAndSettle();

          expect(
            find.textContaining("That passphrase didn't work."),
            findsOneWidget,
          );

          await tester.enterText(
            find.widgetWithText(TextField, 'Passphrase'),
            'the right one',
          );
          await tester.pump();
          await tester.tap(find.widgetWithText(FilledButton, 'Unlock'));
          await tester.pumpAndSettle();

          expect(callCount, 2);
          expect(
            find.text('Backup restored from the cloud.'),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        '"Pull from Cloud" shows "no cloud backup found" (not an error) '
        'when pullBackup returns false',
        (tester) async {
          setTallViewport(tester);

          await tester.pumpWidget(
            buildTestable(
              backupSyncEnabled: true,
              authState: const AuthAuthenticated(
                email: 'user@example.com',
                accessToken: 'token-123',
              ),
              pullImpl: (passphrase) async => false,
            ),
          );
          await tester.pumpAndSettle();

          await tester.tap(find.text('Pull from Cloud'));
          await tester.pumpAndSettle();

          await tester.enterText(
            find.widgetWithText(TextField, 'Passphrase'),
            'some passphrase',
          );
          await tester.pump();
          await tester.tap(find.widgetWithText(FilledButton, 'Unlock'));
          await tester.pumpAndSettle();

          expect(
            find.text('No cloud backup found for this account yet.'),
            findsOneWidget,
          );
        },
      );
    });
  });
}
