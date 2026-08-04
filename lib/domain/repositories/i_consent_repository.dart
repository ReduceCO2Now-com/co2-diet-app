import 'package:co2diet/domain/entities/consent_event.dart';

/// Domain-layer contract for durably recording and reading consent events
/// (LEGAL-03, LEGAL-04, LEG-02).
///
/// Backed by the append-only `ConsentRecordsTable` — implementations must
/// never expose an update or delete path; consent records are legal
/// evidence.
abstract interface class IConsentRepository {
  /// Records a new consent event with the given [policyVersion],
  /// [appVersion], and [consentsGiven] checkbox identifiers.
  Future<void> recordConsent({
    required String policyVersion,
    required String appVersion,
    required List<String> consentsGiven,
  });

  /// Watches every recorded consent event, in insertion order.
  Stream<List<ConsentEvent>> watchConsents();
}
