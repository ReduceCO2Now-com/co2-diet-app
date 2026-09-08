import 'dart:io';

import 'package:co2diet/core/di/backup_providers.dart';
import 'package:co2diet/domain/entities/auth_state.dart';
import 'package:co2diet/domain/services/backup_export_service.dart';
import 'package:co2diet/features/auth/providers/auth_provider.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'backup_sync_notifier.g.dart';

/// Orchestrates the client push/pull surface for the encrypted-backup cloud
/// sync feature (Plan 08-03, AUTH-09) — encrypt-then-push and
/// pull-then-decrypt, gated to an authenticated (Account Mode) user.
///
/// Every push always goes through [BackupExportService.createBackup] with a
/// non-null passphrase first (Plan 08-01) — there is no code path in this
/// class that can send an unencrypted archive to
/// `BackupApiClient.push` (T-08-03-03).
///
/// keepAlive: true -- `pushBackup`/`pullBackup` are triggered from a
/// button tap (`BackupSyncSection`, Task 3) but nothing `ref.watch`es this
/// provider's (`void`) state to keep it alive for the duration of the
/// in-flight network call. Without `keepAlive`, this autoDispose provider
/// can be torn down between the synchronous `ref.read(...)` and the first
/// `await` inside `pushBackup`/`pullBackup`, throwing "Cannot use the Ref
/// of ... after it has been disposed" -- the same disposal-risk class
/// already documented for `mealEntryProvider`/`OnboardingGateNotifier`
/// ([Phase 04-09]), and the same reasoning `AuthNotifier` uses for its own
/// `keepAlive: true` ("read from mutation methods that may outlive the
/// widget that triggered them").
@Riverpod(keepAlive: true)
class BackupSyncNotifier extends _$BackupSyncNotifier {
  @override
  void build() {}

  /// Encrypts the full local backup with [passphrase] (Plan 08-01's
  /// `BackupExportService.createBackup`) and pushes the resulting archive
  /// bytes to the backend via `BackupApiClient.push`.
  ///
  /// Throws [StateError] if the caller is not authenticated, or if the
  /// authenticated session's `accessToken` is `null` — defensive: the UI
  /// only ever calls this when both are true, but this method must not
  /// silently no-op on a bad precondition.
  Future<void> pushBackup(String passphrase) async {
    final accessToken = _requireAccessToken();
    final service = await ref.read(backupExportServiceProvider.future);
    final file = await service.createBackup(passphrase: passphrase);
    final bytes = await file.readAsBytes();
    await ref.read(backupApiClientProvider).push(bytes, accessToken);
  }

  /// Pulls the stored backup blob via `BackupApiClient.pull` and, if one
  /// exists, decrypts and restores it with [passphrase] (Plan 08-01's
  /// `BackupExportService.applyRestore`).
  ///
  /// Returns `false` (no exception) when the server holds no backup for
  /// this account yet — an expected, normal state, not an error. Returns
  /// `true` on a successful restore. Lets
  /// [WrongBackupPassphraseException] propagate uncaught to the caller,
  /// which maps it to the same retry UX Plan 08-01 already built for local
  /// restore.
  ///
  /// Throws [StateError] under the same precondition as [pushBackup].
  Future<bool> pullBackup(String passphrase) async {
    final accessToken = _requireAccessToken();
    final bytes = await ref.read(backupApiClientProvider).pull(accessToken);
    if (bytes == null) {
      return false;
    }

    final tempDir = await ref.read(backupTempDirGetterProvider)();
    final tempFile = File(
      p.join(
        tempDir.path,
        'co2diet_cloud_restore_${DateTime.now().millisecondsSinceEpoch}.zip',
      ),
    );
    await tempFile.writeAsBytes(bytes);
    try {
      final service = await ref.read(backupExportServiceProvider.future);
      await service.applyRestore(tempFile, passphrase: passphrase);
      return true;
    } finally {
      if (tempFile.existsSync()) {
        await tempFile.delete();
      }
    }
  }

  /// Returns the current session's non-null `accessToken`, or throws
  /// [StateError] if the caller is not authenticated or the token isn't
  /// available yet.
  String _requireAccessToken() {
    final authState = ref.read(authProvider);
    if (authState is! AuthAuthenticated || authState.accessToken == null) {
      throw StateError('Not signed in');
    }
    return authState.accessToken!;
  }
}
