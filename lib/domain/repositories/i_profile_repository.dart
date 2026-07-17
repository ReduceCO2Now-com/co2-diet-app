import 'package:co2diet/domain/entities/user_profile.dart';

/// Abstract interface for persisting and retrieving the user's profile.
///
/// Implementations live in the data layer and may use Drift (local SQLite)
/// or any other storage backend. The domain layer depends only on this
/// interface, ensuring zero framework coupling.
abstract interface class IProfileRepository {
  /// Returns the current [UserProfile], or `null` if no profile exists yet.
  Future<UserProfile?> getProfile();

  /// Persists [profile] to storage (upsert semantics).
  Future<void> saveProfile(UserProfile profile);

  /// Emits the current [UserProfile] and every subsequent change.
  ///
  /// Emits `null` when no profile exists.
  Stream<UserProfile?> watchProfile();
}
