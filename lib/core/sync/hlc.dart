/// Hand-rolled Hybrid Logical Clock (HLC) implementation.
///
/// Based on Kulkarni et al. 2014
/// "Logical Physical Clocks and Consistent Snapshots".
/// This implementation is intentionally minimal — sufficient for Phase 1
/// (Local Mode only) where HLC columns are stored but no sync occurs.
///
// TODO(sync-phase-7): Add a maxDriftMs cap before sync ships.
// If wallMillis > localHlc.millis + maxDriftMs, log a warning and cap the
// advance to localHlc.millis + 1. This bounds clock-manipulation attacks
// where a row written with a far-future timestamp would always "win" LWW.
// See RESEARCH.md Pitfall 5 for details.
class Hlc implements Comparable<Hlc> {
  /// Creates an HLC value from its three components.
  const Hlc(this.millis, this.counter, this.nodeId);

  /// Wall-clock milliseconds since Unix epoch.
  final int millis;

  /// Logical counter for same-millisecond tie-breaking.
  final int counter;

  /// Stable device installation UUID (UUID v4, set once per install).
  final String nodeId;

  /// Advance local clock for a local write.
  ///
  /// If [wallMillis] is strictly greater than the current [millis], the wall
  /// clock has advanced — reset counter to 0 and use the wall time.
  /// Otherwise the wall clock has not advanced — bump the logical counter.
  Hlc increment(int wallMillis) {
    if (wallMillis > millis) {
      return Hlc(wallMillis, 0, nodeId);
    }
    return Hlc(millis, counter + 1, nodeId);
  }

  /// Merge with a [remote] clock on receiving a sync row.
  ///
  /// Takes the maximum of local millis, remote millis, and wall millis.
  /// If both local and remote share the max millis, bump the max counter + 1
  /// to ensure the merged event is strictly greater than both.
  /// Otherwise reset the counter to 0 (the winning millis already dominates).
  Hlc receive(Hlc remote, int wallMillis) {
    final maxMillis = [millis, remote.millis, wallMillis]
        .reduce((a, b) => a > b ? a : b);
    if (maxMillis == millis && maxMillis == remote.millis) {
      final maxCounter = counter > remote.counter ? counter : remote.counter;
      return Hlc(maxMillis, maxCounter + 1, nodeId);
    }
    return Hlc(maxMillis, 0, nodeId);
  }

  /// Compare two HLC values for ordering.
  ///
  /// Order: millis first, then counter, then nodeId lexicographically.
  /// This is the LWW tie-breaking rule:
  /// same-millis, same-counter → node wins.
  @override
  int compareTo(Hlc other) {
    final c = millis.compareTo(other.millis);
    if (c != 0) return c;
    final c2 = counter.compareTo(other.counter);
    if (c2 != 0) return c2;
    return nodeId.compareTo(other.nodeId);
  }

  @override
  String toString() => 'Hlc($millis, $counter, $nodeId)';
}
