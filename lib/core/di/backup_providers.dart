// Backup & Restore DI providers: BackupMetadataDao, BackupMetadataRepository.
//
// Kept in a separate file (mirrors co2_settings_providers.dart) to keep
// providers.dart focused on core infrastructure (AppDatabase, profile).

import 'package:co2diet/core/di/providers.dart';
import 'package:co2diet/data/local/daos/backup_metadata_dao.dart';
import 'package:co2diet/data/repositories/backup_metadata_repository.dart';
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
