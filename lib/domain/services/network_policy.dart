/// Whether the data layer may reach the network for food lookups.
///
/// A one-method port so `data/` can honour the user's connectivity choice
/// without importing Riverpod or knowing where the preference is stored —
/// the same inversion every repository here uses for its DAO.
///
/// Read on every call rather than captured once: the user can change the
/// setting mid-session and the next lookup must respect it.
abstract interface class NetworkPolicy {
  /// `true` when remote food lookups are permitted.
  bool get allowsRemoteLookups;
}
