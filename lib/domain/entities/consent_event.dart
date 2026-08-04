import 'dart:convert';

import 'package:co2diet/data/local/app_database.dart';
import 'package:flutter/foundation.dart';

/// A single recorded consent event: durable legal evidence that the user
/// accepted a specific set of legal checkboxes at a specific app version
/// and policy version, at a specific point in time.
///
/// Deliberately named `ConsentEvent`, not `ConsentRecord`, to avoid
/// colliding with Drift's `@DataClassName('ConsentRecord')`-generated row
/// class from `ConsentRecordsTable` (mirrors `MealEntry.fromRow`'s
/// precedent of importing the row type from `app_database.dart`, never
/// `package:drift/drift.dart` directly).
@immutable
class ConsentEvent {
  /// Creates a [ConsentEvent] with the given fields.
  const ConsentEvent({
    required this.id,
    required this.createdAt,
    required this.appVersion,
    required this.policyVersion,
    required this.consentsGiven,
  });

  /// Maps a Drift [ConsentRecord] row onto a [ConsentEvent], JSON-decoding
  /// the `consentsGiven` string column back into a `List<String>`.
  factory ConsentEvent.fromRow(ConsentRecord row) {
    final decoded = jsonDecode(row.consentsGiven) as List<dynamic>;
    return ConsentEvent(
      id: row.id,
      createdAt: row.createdAt,
      appVersion: row.appVersion,
      policyVersion: row.policyVersion,
      consentsGiven: decoded.cast<String>(),
    );
  }

  /// Unique UUID v7 id — time-ordered for chronological audit access.
  final String id;

  /// UTC timestamp of when the consent event was recorded on device.
  final DateTime createdAt;

  /// App build version at the time of consent (e.g. `'0.1.0+1'`).
  final String appVersion;

  /// Policy document version accepted at time of consent
  /// (e.g. `'2026-07-16'`).
  final String policyVersion;

  /// The exact checkbox identifiers the user accepted, e.g.
  /// `['terms', 'privacy', 'not_medical_advice', 'user_responsibility']`.
  final List<String> consentsGiven;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ConsentEvent && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ConsentEvent(id: $id, createdAt: $createdAt, '
      'appVersion: $appVersion, policyVersion: $policyVersion, '
      'consentsGiven: $consentsGiven)';
}
