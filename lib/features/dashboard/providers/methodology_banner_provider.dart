// Providers powering the CO2 methodology-update announcement banner
// (CO2-04) -- composes MethodologyVersionChecker's pure staleness logic
// (Plan 07-04) with real DB reads and per-version SharedPreferences
// dismissal state.

import 'package:co2diet/core/di/providers.dart';
import 'package:co2diet/domain/services/methodology_version_checker.dart';
import 'package:co2diet/features/onboarding/providers/onboarding_gate_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'methodology_banner_provider.g.dart';

/// Whether any CO2-bearing row on-device (profile, meal entries, custom
/// foods) was estimated under an older methodology version than
/// [currentCo2MethodologyVersion].
///
/// Whole-table scans via `AppDatabase`'s DAOs directly (not a dedicated
/// repository method) -- mirrors `BackupExportService`'s established
/// precedent for cross-table reads that don't belong in any single
/// per-feature repository interface.
@riverpod
Future<bool> hasStaleMethodologyEntries(Ref ref) async {
  final db = ref.watch(appDatabaseProvider);

  final profile = await db.userProfileDao.getProfile();
  final mealRows = await db.mealEntryDao.getAllEntries();
  final foodRows = await db.userFoodDao.getAllAlphabetical();

  return const MethodologyVersionChecker().hasAnyStale(
    profileVersion: profile?.co2MethodologyVersion,
    mealVersions: mealRows
        .map((row) => row.co2MethodologyVersionSnapshot)
        .toList(),
    foodVersions: foodRows.map((row) => row.co2MethodologyVersion).toList(),
  );
}

/// Tracks the last CO2-methodology version the user dismissed the banner
/// for -- `null` when never dismissed.
///
/// keepAlive: true -- mirrors [OnboardingGateNotifier]'s established
/// rationale: [dismiss] is called from a widget callback (the banner's
/// dismiss IconButton) that may not keep an active watcher of this
/// provider alive across the `await`.
@Riverpod(keepAlive: true)
class MethodologyBannerDismissalNotifier
    extends _$MethodologyBannerDismissalNotifier {
  static const _prefsKey = 'co2MethodologyBannerDismissedVersion';

  @override
  String? build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getString(_prefsKey);
  }

  /// Persists [version] as the last-dismissed methodology version and
  /// updates state synchronously.
  Future<void> dismiss(String version) async {
    await ref.read(sharedPreferencesProvider).setString(_prefsKey, version);
    state = version;
  }
}

/// The single composed value `Co2MethodologyBanner` needs: `true` only
/// when stale entries exist AND the current methodology version hasn't
/// already been dismissed.
@riverpod
Future<bool> showMethodologyBanner(Ref ref) async {
  final hasStale = await ref.watch(hasStaleMethodologyEntriesProvider.future);
  final dismissedVersion = ref.watch<String?>(
    methodologyBannerDismissalProvider,
  );
  return hasStale && dismissedVersion != currentCo2MethodologyVersion;
}
