// Unit tests for BackupSyncNotifier (Plan 08-03). Same ProviderContainer +
// provider-override pattern as test/features/backup/backup_restore_screen_
// test.dart's BackupNotifier group: mock BackupApiClient via mocktail;
// override backupExportServiceProvider and authProvider directly rather
// than hitting real DAOs/HTTP.

import 'dart:io';
import 'dart:typed_data';

import 'package:co2diet/core/di/backup_providers.dart';
import 'package:co2diet/data/remote/backup_api_client.dart';
import 'package:co2diet/domain/entities/auth_state.dart';
import 'package:co2diet/domain/services/backup_export_service.dart';
import 'package:co2diet/features/auth/providers/auth_provider.dart';
import 'package:co2diet/features/backup/providers/backup_sync_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockBackupApiClient extends Mock implements BackupApiClient {}

class _MockBackupExportService extends Mock implements BackupExportService {}

void main() {
  late _MockBackupApiClient mockApiClient;
  late _MockBackupExportService mockExportService;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(File('fallback.zip'));
  });

  setUp(() {
    mockApiClient = _MockBackupApiClient();
    mockExportService = _MockBackupExportService();
  });

  ProviderContainer buildContainer({required AuthState authState}) {
    return ProviderContainer(
      overrides: [
        backupApiClientProvider.overrideWithValue(mockApiClient),
        backupExportServiceProvider.overrideWith(
          (ref) async => mockExportService,
        ),
        backupTempDirGetterProvider.overrideWithValue(
          () async => Directory.systemTemp,
        ),
        authProvider.overrideWith(_FakeAuthNotifier.new),
        _authStateOverrideProvider.overrideWithValue(authState),
      ],
    );
  }

  group('BackupSyncNotifier.pushBackup', () {
    test(
      'calls createBackup(passphrase: ...) then BackupApiClient.push with '
      "the resulting bytes and the authenticated user's token",
      () async {
        final zipFile = File.fromUri(
          Directory.systemTemp.uri.resolve(
            'push_test_${DateTime.now().microsecondsSinceEpoch}.zip',
          ),
        )..writeAsBytesSync([1, 2, 3, 4]);
        addTearDown(() {
          if (zipFile.existsSync()) zipFile.deleteSync();
        });

        when(
          () => mockExportService.createBackup(
            passphrase: any(named: 'passphrase'),
          ),
        ).thenAnswer((_) async => zipFile);
        when(
          () => mockApiClient.push(any(), any()),
        ).thenAnswer((_) async {});

        final container = buildContainer(
          authState: AuthState.authenticated(
            email: 'a@b.com',
            accessToken: 'tok-123',
          ),
        );
        addTearDown(container.dispose);

        await container
            .read(backupSyncProvider.notifier)
            .pushBackup('my passphrase');

        verify(
          () => mockExportService.createBackup(passphrase: 'my passphrase'),
        ).called(1);
        final captured = verify(
          () => mockApiClient.push(captureAny(), captureAny()),
        ).captured;
        expect(captured[0], Uint8List.fromList([1, 2, 3, 4]));
        expect(captured[1], 'tok-123');
      },
    );

    test('throws StateError when not authenticated', () async {
      final container = buildContainer(
        authState: AuthState.unauthenticated(),
      );
      addTearDown(container.dispose);

      expect(
        () => container
            .read(backupSyncProvider.notifier)
            .pushBackup('x'),
        throwsA(isA<StateError>()),
      );
      verifyNever(
        () => mockExportService.createBackup(
          passphrase: any(named: 'passphrase'),
        ),
      );
    });

    test('throws StateError when accessToken is null', () async {
      final container = buildContainer(
        authState: AuthState.authenticated(email: 'a@b.com'),
      );
      addTearDown(container.dispose);

      expect(
        () => container
            .read(backupSyncProvider.notifier)
            .pushBackup('x'),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('BackupSyncNotifier.pullBackup', () {
    test(
      'returns false on a null pull result without calling applyRestore',
      () async {
        when(
          () => mockApiClient.pull(any()),
        ).thenAnswer((_) async => null);

        final container = buildContainer(
          authState: AuthState.authenticated(
            email: 'a@b.com',
            accessToken: 'tok-123',
          ),
        );
        addTearDown(container.dispose);

        final result = await container
            .read(backupSyncProvider.notifier)
            .pullBackup('my passphrase');

        expect(result, isFalse);
        verifyNever(
          () => mockExportService.applyRestore(
            any(),
            passphrase: any(named: 'passphrase'),
          ),
        );
      },
    );

    test(
      'calls applyRestore(file, passphrase: ...) and returns true on a '
      'non-null pull result, deleting the temp file afterward',
      () async {
        when(
          () => mockApiClient.pull(any()),
        ).thenAnswer((_) async => Uint8List.fromList([5, 6, 7]));
        File? capturedFile;
        when(
          () => mockExportService.applyRestore(
            any(),
            passphrase: any(named: 'passphrase'),
          ),
        ).thenAnswer((invocation) async {
          capturedFile = invocation.positionalArguments[0] as File;
        });

        final container = buildContainer(
          authState: AuthState.authenticated(
            email: 'a@b.com',
            accessToken: 'tok-123',
          ),
        );
        addTearDown(container.dispose);

        final result = await container
            .read(backupSyncProvider.notifier)
            .pullBackup('my passphrase');

        expect(result, isTrue);
        verify(
          () => mockExportService.applyRestore(
            any(),
            passphrase: 'my passphrase',
          ),
        ).called(1);
        expect(capturedFile, isNotNull);
        expect(capturedFile!.existsSync(), isFalse);
      },
    );

    test(
      'propagates WrongBackupPassphraseException from a mocked '
      'applyRestore failure and still deletes the temp file',
      () async {
        when(
          () => mockApiClient.pull(any()),
        ).thenAnswer((_) async => Uint8List.fromList([5, 6, 7]));
        File? capturedFile;
        when(
          () => mockExportService.applyRestore(
            any(),
            passphrase: any(named: 'passphrase'),
          ),
        ).thenAnswer((invocation) async {
          capturedFile = invocation.positionalArguments[0] as File;
          throw WrongBackupPassphraseException();
        });

        final container = buildContainer(
          authState: AuthState.authenticated(
            email: 'a@b.com',
            accessToken: 'tok-123',
          ),
        );
        addTearDown(container.dispose);

        try {
          await container
              .read(backupSyncProvider.notifier)
              .pullBackup('wrong passphrase');
          fail('expected WrongBackupPassphraseException');
        } on WrongBackupPassphraseException {
          expect(capturedFile, isNotNull);
          expect(capturedFile!.existsSync(), isFalse);
        }
      },
    );
  });
}

/// A plain override provider carrying the desired [AuthState] into
/// [_FakeAuthNotifier.build] — `authProvider.overrideWith` needs a
/// `Notifier` factory, not a raw value, so this indirection lets each test
/// supply its own state.
final _authStateOverrideProvider = Provider<AuthState>(
  (ref) => AuthState.unauthenticated(),
);

class _FakeAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => ref.watch(_authStateOverrideProvider);
}
