import 'package:drift/drift.dart';

/// Abstract mixin that injects sync-safe columns onto any Drift table.
///
/// Apply to every user-data table that participates in
/// Last-Write-Wins (LWW) sync. Tables that are append-only audit logs
/// (e.g. consent_records) must NOT use this mixin.
///
/// Columns injected:
///   id          — UUID v7 string primary key (time-ordered)
///   hlcMillis   — HLC wall-clock component (ms since Unix epoch)
///   hlcCounter  — HLC logical counter (tie-breaking)
///   hlcNodeId   — Stable device installation UUID (UUID v4)
///   dirty       — true when row has uncommitted local changes
///   deletedAt   — tombstone: null = live; non-null = soft-deleted
///
/// Usage:
/// ```dart
/// class UserProfileTable extends Table with SyncSafeTable { ... }
/// ```
mixin SyncSafeTable on Table {
  /// Primary key: UUID v7 stored as TEXT (time-ordered, globally unique).
  Column<String> get id => text()();

  /// HLC wall-clock component: milliseconds since Unix epoch.
  /// Stored as int64 (BigInt in Dart) to fit 64-bit epoch millis.
  Column<BigInt> get hlcMillis => int64()();

  /// HLC logical counter: tie-breaking for same-millisecond writes.
  Column<int> get hlcCounter => integer()();

  /// HLC node identifier: stable device installation UUID (UUID v4).
  /// Generated once on first app install and persisted in secure storage.
  Column<String> get hlcNodeId => text()();

  /// Dirty flag: true = row has local changes not yet synced to backend.
  /// Defaults to true on insert — every new row starts dirty until
  /// sync confirms receipt.
  Column<bool> get dirty =>
      boolean().withDefault(const Constant(true))();

  /// Tombstone: null = row is live; non-null = row was soft-deleted.
  /// Soft-deleted rows are retained for 90 days to allow sync to
  /// propagate the deletion.
  Column<DateTime> get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
