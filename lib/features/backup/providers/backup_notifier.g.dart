// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// AsyncNotifier for the Backup & Restore screen (PRIV-01 through PRIV-04,
/// PRIV-08, PRIV-09).
///
/// `build()` loads the current [BackupMetadata] — the source for the
/// Automatic Backups section's current frequency and last-backup audit
/// trail. Every mutation delegates to [BackupExportService]
/// (`backupExportServiceProvider`) for the actual zip/CSV/Excel/JSON I/O;
/// this notifier only orchestrates + persists the metadata row + hands
/// generated files to `share_plus`.

@ProviderFor(BackupNotifier)
final backupProvider = BackupNotifierProvider._();

/// AsyncNotifier for the Backup & Restore screen (PRIV-01 through PRIV-04,
/// PRIV-08, PRIV-09).
///
/// `build()` loads the current [BackupMetadata] — the source for the
/// Automatic Backups section's current frequency and last-backup audit
/// trail. Every mutation delegates to [BackupExportService]
/// (`backupExportServiceProvider`) for the actual zip/CSV/Excel/JSON I/O;
/// this notifier only orchestrates + persists the metadata row + hands
/// generated files to `share_plus`.
final class BackupNotifierProvider
    extends $AsyncNotifierProvider<BackupNotifier, BackupMetadata> {
  /// AsyncNotifier for the Backup & Restore screen (PRIV-01 through PRIV-04,
  /// PRIV-08, PRIV-09).
  ///
  /// `build()` loads the current [BackupMetadata] — the source for the
  /// Automatic Backups section's current frequency and last-backup audit
  /// trail. Every mutation delegates to [BackupExportService]
  /// (`backupExportServiceProvider`) for the actual zip/CSV/Excel/JSON I/O;
  /// this notifier only orchestrates + persists the metadata row + hands
  /// generated files to `share_plus`.
  BackupNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backupProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backupNotifierHash();

  @$internal
  @override
  BackupNotifier create() => BackupNotifier();
}

String _$backupNotifierHash() => r'a282674816f0646f26a9cfda677ebd8182d14d6c';

/// AsyncNotifier for the Backup & Restore screen (PRIV-01 through PRIV-04,
/// PRIV-08, PRIV-09).
///
/// `build()` loads the current [BackupMetadata] — the source for the
/// Automatic Backups section's current frequency and last-backup audit
/// trail. Every mutation delegates to [BackupExportService]
/// (`backupExportServiceProvider`) for the actual zip/CSV/Excel/JSON I/O;
/// this notifier only orchestrates + persists the metadata row + hands
/// generated files to `share_plus`.

abstract class _$BackupNotifier extends $AsyncNotifier<BackupMetadata> {
  FutureOr<BackupMetadata> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<BackupMetadata>, BackupMetadata>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<BackupMetadata>, BackupMetadata>,
              AsyncValue<BackupMetadata>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
