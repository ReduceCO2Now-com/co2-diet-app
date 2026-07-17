import 'package:co2diet/data/local/app_database.dart';
import 'package:co2diet/data/local/tables/user_profile_table.dart';
import 'package:drift/drift.dart';

part 'user_profile_dao.g.dart';

/// DAO for the single-row [UserProfileTable].
///
/// Enforces the single-row constraint via [upsertProfile], which uses
/// insertOnConflictUpdate on the UUID v7 primary key. Callers must
/// always provide the same stable ID for the profile row.
@DriftAccessor(tables: [UserProfileTable])
class UserProfileDao extends DatabaseAccessor<AppDatabase>
    with _$UserProfileDaoMixin {
  /// Creates a [UserProfileDao] bound to [attachedDatabase].
  UserProfileDao(super.attachedDatabase);

  /// Returns the single profile row, or null if no profile exists yet.
  Future<UserProfileRow?> getProfile() =>
      (select(userProfileTable)..limit(1)).getSingleOrNull();

  /// Watches the single profile row for real-time updates.
  ///
  /// Emits null when no profile exists; emits the row whenever it changes.
  Stream<UserProfileRow?> watchProfile() =>
      (select(userProfileTable)..limit(1)).watchSingleOrNull();

  /// Upserts the profile row (insert or update on PK conflict).
  ///
  /// This is the only write method. The single-row invariant is enforced
  /// by always using the same stable UUID v7 as the entry id value.
  Future<void> upsertProfile(UserProfileTableCompanion entry) =>
      into(userProfileTable).insertOnConflictUpdate(entry);
}
