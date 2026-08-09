/// The app-binary constant this phase's mechanism compares against --
/// deliberately NOT bumped this phase per 07-CONTEXT.md; a future release
/// bumps this to trigger the Dashboard banner for real users.
const currentCo2MethodologyVersion = '1.0';

/// Pure, DB-free comparison logic behind the local-only CO2
/// methodology-update announcement (CO2-04).
///
/// Takes plain version strings as input -- zero Drift/DB imports, fully
/// unit-testable without a database. This class only builds the
/// mechanism; Plan 07-07 composes it with real DB reads to power the
/// Dashboard banner.
class MethodologyVersionChecker {
  /// Creates a const [MethodologyVersionChecker].
  const MethodologyVersionChecker();

  /// Returns `true` when [snapshotVersion] differs from [currentVersion].
  ///
  /// A `null` snapshot version is never stale -- it means the row never
  /// had a CO2 estimate applied (existing Phase 4 rule: null means
  /// CO2-absent or manual source). Comparison is simple string
  /// inequality, not a semver comparison -- versions in this codebase
  /// are simple decimal strings and the mechanism only ever needs to
  /// detect "differs from the constant".
  bool isStale(
    String? snapshotVersion, {
    String currentVersion = currentCo2MethodologyVersion,
  }) {
    if (snapshotVersion == null) {
      return false;
    }
    return snapshotVersion != currentVersion;
  }

  /// Returns `true` when [profileVersion] or any entry in
  /// [mealVersions]/[foodVersions] is stale relative to [currentVersion].
  bool hasAnyStale({
    required String? profileVersion,
    required List<String?> mealVersions,
    required List<String?> foodVersions,
    String currentVersion = currentCo2MethodologyVersion,
  }) {
    if (isStale(profileVersion, currentVersion: currentVersion)) {
      return true;
    }
    if (mealVersions.any(
      (version) => isStale(version, currentVersion: currentVersion),
    )) {
      return true;
    }
    return foodVersions.any(
      (version) => isStale(version, currentVersion: currentVersion),
    );
  }
}
