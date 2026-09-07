import 'package:co2diet/data/local/app_database.dart';
import 'package:co2diet/data/local/daos/user_profile_dao.dart';
import 'package:co2diet/domain/entities/calc_targets.dart';
import 'package:co2diet/domain/entities/user_profile.dart';
import 'package:co2diet/domain/repositories/i_profile_repository.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// Concrete data-layer implementation of [IProfileRepository].
///
/// Backed by [UserProfileDao] (Drift). All Drift and SQLite imports are
/// intentionally confined to this file — the domain layer and UI layer
/// MUST NOT import package:drift directly.
///
/// HLC fields in Phase 1 use placeholder values:
///   - `hlcNodeId` is `'local'` (Phase 7 replaces with stable device UUID)
///   - `hlcCounter` is `0` (Phase 7 implements full HLC increment logic)
final class DriftProfileRepository implements IProfileRepository {
  /// Creates a [DriftProfileRepository] backed by the given DAO.
  const DriftProfileRepository(this._dao);

  final UserProfileDao _dao;
  static const _uuid = Uuid();

  @override
  Future<UserProfile?> getProfile() async {
    final row = await _dao.getProfile();
    return _rowToProfile(row);
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    // Assign a UUID v7 if this is a brand-new profile without an id.
    final id = profile.id.isEmpty ? _uuid.v7() : profile.id;

    final companion = UserProfileTableCompanion(
      id: Value(id),
      age: Value(profile.age),
      gender: Value(profile.gender),
      heightCm: Value(profile.heightCm),
      weightKg: Value(profile.weightKg),
      activityLevel: Value(profile.activityLevel),
      dietaryPreference: Value(profile.dietaryPreference),
      goal: Value(profile.goal),
      units: Value(profile.units),
      co2MethodologyVersion: Value(profile.co2MethodologyVersion),
      localeTag: Value(profile.localeTag),
      updatedAt: Value(DateTime.now()),
      // Targets and their override flags (PROF-05 / D-06). These columns
      // existed in the schema from Phase 1 and TargetCalculator.derive already
      // honoured the flags, but this companion never wrote them and
      // _rowToProfile never read them back — so `existingTargets` was always
      // null and every manual override was recalculated away on the next
      // build(). The crash on the override dialog masked it until 2026-09-08.
      kcalTarget: Value(profile.targets?.kcalTarget),
      proteinGTarget: Value(profile.targets?.proteinGTarget),
      carbsGTarget: Value(profile.targets?.carbsGTarget),
      fatGTarget: Value(profile.targets?.fatGTarget),
      co2GTarget: Value(profile.targets?.co2GTarget),
      kcalIsOverridden: Value(profile.targets?.kcalIsOverridden ?? false),
      proteinIsOverridden: Value(
        profile.targets?.proteinIsOverridden ?? false,
      ),
      carbsIsOverridden: Value(profile.targets?.carbsIsOverridden ?? false),
      fatIsOverridden: Value(profile.targets?.fatIsOverridden ?? false),
      // HLC Phase-1 placeholders — Phase 7 replaces with full HLC clock.
      hlcMillis: Value(BigInt.from(DateTime.now().millisecondsSinceEpoch)),
      hlcCounter: const Value(0),
      hlcNodeId: const Value('local'),
      dirty: const Value(true),
    );

    await _dao.upsertProfile(companion);
  }

  @override
  Stream<UserProfile?> watchProfile() {
    return _dao.watchProfile().map(_rowToProfile);
  }

  /// Maps a `UserProfileRow` to a [UserProfile] domain entity.
  ///
  /// Returns `null` when `row` is `null` (no profile saved yet).
  ///
  /// Does NOT *compute* `CalcTargets` — that stays with `ProfileNotifier`,
  /// which calls `TargetCalculator.derive`. It does carry the *stored* targets
  /// through, because derive() needs them as `existingTargets` to know which
  /// fields the user has overridden and must not recalculate (D-06).
  UserProfile? _rowToProfile(UserProfileRow? row) {
    if (row == null) return null;

    return UserProfile(
      targets: CalcTargets(
        kcalTarget: row.kcalTarget,
        proteinGTarget: row.proteinGTarget,
        carbsGTarget: row.carbsGTarget,
        fatGTarget: row.fatGTarget,
        co2GTarget: row.co2GTarget,
        kcalIsOverridden: row.kcalIsOverridden,
        proteinIsOverridden: row.proteinIsOverridden,
        carbsIsOverridden: row.carbsIsOverridden,
        fatIsOverridden: row.fatIsOverridden,
      ),
      id: row.id,
      age: row.age,
      gender: row.gender,
      heightCm: row.heightCm,
      weightKg: row.weightKg,
      activityLevel: row.activityLevel,
      dietaryPreference: row.dietaryPreference,
      goal: row.goal,
      units: row.units,
      co2MethodologyVersion: row.co2MethodologyVersion,
      localeTag: row.localeTag,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
