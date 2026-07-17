import 'package:co2diet/data/local/app_database.dart';
import 'package:co2diet/data/local/daos/user_profile_dao.dart';
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
  /// Does NOT compute `CalcTargets` — that is the responsibility of
  /// `ProfileNotifier` in the presentation layer.
  UserProfile? _rowToProfile(UserProfileRow? row) {
    if (row == null) return null;

    return UserProfile(
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
