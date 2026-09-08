// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_sync_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(BackupSyncNotifier)
final backupSyncProvider = BackupSyncNotifierProvider._();

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
final class BackupSyncNotifierProvider
    extends $NotifierProvider<BackupSyncNotifier, void> {
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
  BackupSyncNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backupSyncProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backupSyncNotifierHash();

  @$internal
  @override
  BackupSyncNotifier create() => BackupSyncNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$backupSyncNotifierHash() =>
    r'c3d1fefe189c69820083219d2d68fba439c91def';

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

abstract class _$BackupSyncNotifier extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
