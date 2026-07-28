// Backup & Restore DI providers: BackupMetadataDao, BackupMetadataRepository,
// BackupExportService, and the file_selector picker seam.
//
// Kept in a separate file (mirrors co2_settings_providers.dart) to keep
// providers.dart focused on core infrastructure (AppDatabase, profile).

import 'package:co2diet/core/di/providers.dart';
import 'package:co2diet/data/local/daos/backup_metadata_dao.dart';
import 'package:co2diet/data/repositories/backup_metadata_repository.dart';
import 'package:co2diet/domain/services/backup_export_service.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'backup_providers.g.dart';

/// Provides the [BackupMetadataDao] bound to the live `AppDatabase`.
///
/// keepAlive: true — DAO must persist for the full ProviderScope lifetime
/// because it is referenced by [backupMetadataRepositoryProvider], which is
/// also keep-alive.
@Riverpod(keepAlive: true)
BackupMetadataDao backupMetadataDao(Ref ref) {
  return ref.watch(appDatabaseProvider).backupMetadataDao;
}

/// Provides the [BackupMetadataRepository] for the Backup & Restore feature.
@Riverpod(keepAlive: true)
BackupMetadataRepository backupMetadataRepository(Ref ref) {
  return BackupMetadataRepository(ref.watch(backupMetadataDaoProvider));
}

/// Provides the [BackupExportService], wired to every DAO it reads/writes
/// plus the app's own documents directory (`path_provider`).
///
/// This is an async provider (the only one in this codebase) because
/// `getApplicationDocumentsDirectory()` is inherently async — there is no
/// synchronous way to obtain the platform documents path. keepAlive: true
/// mirrors every other DAO/repository provider's full-session lifetime.
@Riverpod(keepAlive: true)
Future<BackupExportService> backupExportService(Ref ref) async {
  final db = ref.watch(appDatabaseProvider);
  final documentsDir = await getApplicationDocumentsDirectory();
  return BackupExportService(
    mealEntryDao: db.mealEntryDao,
    userFoodDao: db.userFoodDao,
    weightDao: db.weightDao,
    co2SettingsDao: db.co2SettingsDao,
    notificationPrefsDao: db.notificationPrefsDao,
    userProfileDao: db.userProfileDao,
    backupMetadataDao: db.backupMetadataDao,
    documentsDir: documentsDir,
  );
}

/// A seam over `file_selector`'s top-level `openFile` function.
///
/// `openFile` is a top-level function, not a class method — mocktail
/// cannot mock top-level functions directly. Overriding this provider in
/// tests (`filePickerProvider.overrideWithValue(...)`) lets
/// `BackupNotifier.pickAndPreviewRestoreFile` be tested for both a
/// successful pick and a user-cancelled pick (`null`) without touching
/// the real OS document picker.
@riverpod
FilePickerFn filePicker(Ref ref) => openFile;

/// Function type matching `file_selector`'s top-level `openFile` signature,
/// used by [filePickerProvider].
typedef FilePickerFn =
    Future<XFile?> Function({List<XTypeGroup> acceptedTypeGroups});
