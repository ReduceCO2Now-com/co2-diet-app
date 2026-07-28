import 'dart:io';

import 'package:co2diet/core/di/backup_providers.dart';
import 'package:co2diet/domain/entities/backup_metadata.dart';
import 'package:co2diet/domain/services/backup_export_service.dart';
import 'package:file_selector/file_selector.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';

part 'backup_notifier.g.dart';

/// AsyncNotifier for the Backup & Restore screen (PRIV-01 through PRIV-04,
/// PRIV-08, PRIV-09).
///
/// `build()` loads the current [BackupMetadata] — the source for the
/// Automatic Backups section's current frequency and last-backup audit
/// trail. Every mutation delegates to [BackupExportService]
/// (`backupExportServiceProvider`) for the actual zip/CSV/Excel/JSON I/O;
/// this notifier only orchestrates + persists the metadata row + hands
/// generated files to `share_plus`.
@riverpod
class BackupNotifier extends _$BackupNotifier {
  /// The most recently picked restore-candidate file, set by
  /// [pickAndPreviewRestoreFile] and cleared once [applyRestore] runs (or
  /// the picker is cancelled). The screen reads this to know which file to
  /// pass to [applyRestore] once the user taps "Confirm Restore" — kept
  /// here (rather than threading the `File` back through the screen's own
  /// state) since `pickAndPreviewRestoreFile`'s return type is the
  /// preview, not the file itself.
  File? _pendingRestoreFile;

  /// The file most recently returned by the picker in
  /// [pickAndPreviewRestoreFile], or `null` if none is pending (picker
  /// never opened, was cancelled, or a restore already completed).
  File? get pendingRestoreFile => _pendingRestoreFile;

  @override
  Future<BackupMetadata> build() {
    return ref.watch(backupMetadataRepositoryProvider).getMetadata();
  }

  /// Exports [categories] in [formats] to a single zip, then hands it to
  /// the OS share sheet via `share_plus`.
  Future<void> shareExport({
    required Set<ExportCategory> categories,
    required Set<ExportFormat> formats,
  }) async {
    final service = await ref.read(backupExportServiceProvider.future);
    final file = await service.exportData(
      categories: categories,
      formats: formats,
    );
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
  }

  /// Writes a full-data backup zip, shares it via the OS share sheet, and
  /// refreshes the notifier's state so `lastBackupAt`/`lastBackupPath`
  /// reflect the new backup.
  Future<void> createAndShareBackup() async {
    final service = await ref.read(backupExportServiceProvider.future);
    final file = await service.createBackup();
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
    ref.invalidateSelf();
  }

  /// Opens the real OS document picker (`file_selector`, via
  /// [filePickerProvider]'s seam) so the user can choose a backup zip from
  /// anywhere on the device — not only this app's own documents directory.
  ///
  /// Returns the parsed [RestorePreview] on a successful pick (and stores
  /// the picked file in [pendingRestoreFile] for a later [applyRestore]
  /// call), or `null` if the user cancelled the picker — no error, no
  /// partial state.
  Future<RestorePreview?> pickAndPreviewRestoreFile() async {
    final pick = ref.read(filePickerProvider);
    final picked = await pick(
      acceptedTypeGroups: const [
        XTypeGroup(label: 'zip', extensions: ['zip']),
      ],
    );
    if (picked == null) {
      _pendingRestoreFile = null;
      return null;
    }

    final file = File(picked.path);
    _pendingRestoreFile = file;
    final service = await ref.read(backupExportServiceProvider.future);
    return service.previewRestore(file);
  }

  /// Applies the restore for [zip] — only ever called after the caller has
  /// already shown [pickAndPreviewRestoreFile]'s preview and the user has
  /// explicitly confirmed. Re-runs `build()` afterward since a restore can
  /// change every table's data, not just backup metadata.
  Future<void> applyRestore(File zip) async {
    final service = await ref.read(backupExportServiceProvider.future);
    await service.applyRestore(zip);
    _pendingRestoreFile = null;
    ref.invalidateSelf();
  }

  /// Persists the automatic-backup frequency (`'off'`/`'daily'`/`'weekly'`)
  /// without touching `lastBackupAt`/`lastBackupPath`.
  Future<void> saveAutoBackupFrequency(String frequency) async {
    final repo = ref.read(backupMetadataRepositoryProvider);
    final current = await repo.getMetadata();
    await repo.saveMetadata(current.copyWith(autoBackupFrequency: frequency));
    ref.invalidateSelf();
  }
}
