// Core DI providers for AppDatabase and IProfileRepository.
//
// IMPORTANT: Do NOT import package:drift in this file. Import only AppDatabase
// (which imports Drift internally). The provider API exposes only typed
// interfaces — callers never depend on Drift directly.

import 'package:co2diet/data/local/app_database.dart';
import 'package:co2diet/data/repositories/drift_profile_repository.dart';
import 'package:co2diet/domain/repositories/i_profile_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

/// Provides the path to the decompressed `off_reference.sqlite` file.
///
/// The default value is `null` (no reference DB path available). Overridden
/// in `main()` via `ProviderScope(overrides: [offRefPathProvider
/// .overrideWithValue(path)])` after `ensureOffReferenceDb()` completes.
///
/// Using a simple synchronous override avoids async providers at the root
/// level while still allowing the path to flow into [appDatabaseProvider].
@riverpod
String? offRefPath(Ref ref) => null;

/// Provides the singleton [AppDatabase] for the entire app lifetime.
///
/// keepAlive: true — the database connection MUST persist for the full
/// ProviderScope lifetime. Disposing and recreating the DB mid-session
/// would drop pending streams and in-flight writes.
///
/// ref.onDispose ensures the SQLite connection is closed cleanly on
/// ProviderScope disposal (e.g., during widget tests).
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final offRef = ref.watch(offRefPathProvider);
  final db = AppDatabase.connect(offRefPath: offRef);
  ref.onDispose(db.close);
  return db;
}

/// Provides an [IProfileRepository] backed by the live [AppDatabase].
///
/// The declared return type is the abstract interface — callers in the
/// presentation layer depend only on [IProfileRepository], not on
/// [DriftProfileRepository]. This enforces the data-layer boundary.
@riverpod
IProfileRepository profileRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return DriftProfileRepository(db.userProfileDao);
}
