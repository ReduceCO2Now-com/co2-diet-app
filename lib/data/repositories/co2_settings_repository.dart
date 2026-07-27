import 'package:co2diet/data/local/app_database.dart';
import 'package:co2diet/data/local/daos/co2_settings_dao.dart';
import 'package:co2diet/domain/entities/co2_settings.dart';
import 'package:co2diet/domain/repositories/i_co2_settings_repository.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// Concrete data-layer implementation of [ICo2SettingsRepository].
///
/// Backed by [Co2SettingsDao] (Drift). All Drift and SQLite imports are
/// intentionally confined to this file — the domain layer and UI layer
/// MUST NOT import package:drift directly.
///
/// This repository never reads or writes any `MealEntryTable`/`UserFood`
/// row — it is a strictly separate personal-footprint settings layer
/// (per `05-CONTEXT.md`: forward-only, never rewrites already-logged
/// meals).
///
/// HLC fields use Phase-1 placeholder values, matching every other
/// Phase 1-4 repository:
///   - `hlcNodeId` is `'local'` (Phase 7 replaces with stable device UUID)
///   - `hlcCounter` is `0` (Phase 7 implements full HLC increment logic)
final class Co2SettingsRepository implements ICo2SettingsRepository {
  /// Creates a [Co2SettingsRepository] backed by the given DAO.
  const Co2SettingsRepository(this._dao);

  final Co2SettingsDao _dao;
  static const _uuid = Uuid();

  @override
  Future<Co2Settings> getSettings() async {
    final row = await _dao.getSettings();
    if (row == null) return const Co2Settings();

    return Co2Settings(
      locationCountry: row.locationCountry,
      locationRegion: row.locationRegion,
      purchasingSource: row.purchasingSource,
      shoppingTransport: row.shoppingTransport,
      cookingMethod: row.cookingMethod,
      foodStorage: row.foodStorage,
      householdSize: row.householdSize,
      foodWasteLevel: row.foodWasteLevel,
    );
  }

  @override
  Future<void> saveSettings(Co2Settings settings) async {
    // Reuse the existing single row's id if present; otherwise generate a
    // fresh UUID v7 for the first-ever save (mirrors DriftProfileRepository's
    // single-row-id convention).
    final existing = await _dao.getSettings();
    final id = existing?.id ?? _uuid.v7();

    final companion = Co2SettingsTableCompanion(
      id: Value(id),
      locationCountry: Value(settings.locationCountry),
      locationRegion: Value(settings.locationRegion),
      purchasingSource: Value(settings.purchasingSource),
      shoppingTransport: Value(settings.shoppingTransport),
      cookingMethod: Value(settings.cookingMethod),
      foodStorage: Value(settings.foodStorage),
      householdSize: Value(settings.householdSize),
      foodWasteLevel: Value(settings.foodWasteLevel),
      // HLC Phase-1 placeholders — Phase 7 replaces with full HLC clock.
      hlcMillis: Value(BigInt.from(DateTime.now().millisecondsSinceEpoch)),
      hlcCounter: const Value(0),
      hlcNodeId: const Value('local'),
      dirty: const Value(true),
    );

    await _dao.upsertSettings(companion);
  }
}
