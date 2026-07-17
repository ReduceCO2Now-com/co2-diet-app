import 'package:drift/drift.dart';

/// Append-only audit log of user consent events.
///
/// This table intentionally does NOT use SyncSafeTable. Rationale:
/// - Consent records are legal evidence; LWW conflict resolution could
///   silently overwrite a historical consent record — unacceptable
///   for audit integrity.
/// - Consent is per-device: given on this device, for this device.
///   It is NOT synced to the backend. Backend tracks its own consent
///   via registration flow.
/// - Rows are never updated or deleted (except by full local data
///   wipe, PRIV-09).
///
/// Schema:
///   id            — UUID v7 primary key (time-ordered for audit)
///   createdAt     — UTC timestamp of the consent event
///   appVersion    — App version at time of consent (e.g. '0.1.0+1')
///   policyVersion — Policy version (e.g. '2026-07-16')
///   consentsGiven — JSON array of accepted checkbox identifiers
///
/// Example consentsGiven value:
///   '["terms","privacy","not_medical_advice","user_responsibility"]'
///   or, when optional 5th checkbox was also checked:
///   '["terms","privacy","not_medical_advice","user_responsibility",
///     "age_16_plus"]'
@DataClassName('ConsentRecord')
class ConsentRecordsTable extends Table {
  /// UUID v7 primary key — time-ordered for chronological audit access.
  Column<String> get id => text()();

  /// UTC timestamp of when the consent event was recorded on device.
  Column<DateTime> get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  /// App build version at the time of consent (e.g. '0.1.0+1').
  Column<String> get appVersion => text()();

  /// Policy document version accepted at time of consent
  /// (e.g. '2026-07-16').
  Column<String> get policyVersion => text()();

  /// JSON string array of checkbox IDs the user accepted.
  ///
  /// Required items: 'terms', 'privacy', 'not_medical_advice',
  /// 'user_responsibility'.
  /// Optional item: 'age_16_plus' (included only when the user checked
  /// the 5th self-declaration checkbox).
  Column<String> get consentsGiven => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
