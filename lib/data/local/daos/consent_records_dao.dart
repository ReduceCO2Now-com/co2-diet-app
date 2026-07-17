import 'package:co2diet/data/local/app_database.dart';
import 'package:co2diet/data/local/tables/consent_records_table.dart';
import 'package:drift/drift.dart';

part 'consent_records_dao.g.dart';

/// DAO for the append-only [ConsentRecordsTable].
///
/// This DAO intentionally has no update or delete methods — consent
/// records are legal evidence and must never be mutated after insert.
/// Rows are removed only by the Danger Zone full wipe (Phase 5 / PRIV-09).
@DriftAccessor(tables: [ConsentRecordsTable])
class ConsentRecordsDao extends DatabaseAccessor<AppDatabase>
    with _$ConsentRecordsDaoMixin {
  /// Creates a [ConsentRecordsDao] bound to [attachedDatabase].
  ConsentRecordsDao(super.attachedDatabase);

  /// Inserts a new consent record.
  ///
  /// The caller is responsible for generating a UUID v7 as the entry id
  /// and capturing the current app version and policy version.
  Future<void> insertConsent(ConsentRecordsTableCompanion entry) =>
      into(consentRecordsTable).insert(entry);

  /// Returns all consent records in insertion order.
  Future<List<ConsentRecord>> getAllConsents() =>
      select(consentRecordsTable).get();

  /// Watches all consent records for real-time updates.
  Stream<List<ConsentRecord>> watchConsents() =>
      select(consentRecordsTable).watch();
}
