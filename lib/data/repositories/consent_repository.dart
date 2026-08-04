import 'dart:convert';

import 'package:co2diet/data/local/app_database.dart';
import 'package:co2diet/data/local/daos/consent_records_dao.dart';
import 'package:co2diet/domain/entities/consent_event.dart';
import 'package:co2diet/domain/repositories/i_consent_repository.dart';
import 'package:uuid/uuid.dart';

/// Concrete data-layer implementation of [IConsentRepository].
///
/// Backed by [ConsentRecordsDao] (Drift). All Drift and SQLite imports are
/// intentionally confined to this file — the domain layer and UI layer
/// MUST NOT import `package:drift` directly. Mirrors `Co2SettingsRepository`
/// (Phase 5)'s structure.
///
/// This repository never updates or deletes an existing consent record —
/// every call to [recordConsent] inserts a brand-new row with a fresh
/// UUID v7 id, preserving the append-only legal-evidence guarantee that
/// [ConsentRecordsDao] enforces at the DAO layer.
final class DriftConsentRepository implements IConsentRepository {
  /// Creates a [DriftConsentRepository] backed by the given DAO.
  const DriftConsentRepository(this._dao);

  final ConsentRecordsDao _dao;
  static const _uuid = Uuid();

  @override
  Future<void> recordConsent({
    required String policyVersion,
    required String appVersion,
    required List<String> consentsGiven,
  }) {
    final companion = ConsentRecordsTableCompanion.insert(
      id: _uuid.v7(),
      appVersion: appVersion,
      policyVersion: policyVersion,
      consentsGiven: jsonEncode(consentsGiven),
    );
    return _dao.insertConsent(companion);
  }

  @override
  Stream<List<ConsentEvent>> watchConsents() {
    return _dao.watchConsents().map(
      (rows) => rows.map(ConsentEvent.fromRow).toList(),
    );
  }
}
