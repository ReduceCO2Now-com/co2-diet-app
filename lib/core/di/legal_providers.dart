// Legal document + consent DI providers: LegalDocumentLoader,
// ConsentRecordsDao, IConsentRepository, appVersion.
//
// Kept in a separate file (mirrors co2_settings_providers.dart) to keep
// providers.dart focused on core infrastructure (AppDatabase, profile).

import 'package:co2diet/core/di/providers.dart';
import 'package:co2diet/data/local/daos/consent_records_dao.dart';
import 'package:co2diet/data/repositories/consent_repository.dart';
import 'package:co2diet/domain/repositories/i_consent_repository.dart';
import 'package:co2diet/domain/services/legal_document_loader.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'legal_providers.g.dart';

/// Provides the [LegalDocumentLoader] used by Legal Consent / Legal Hub
/// screens to read `docs/legal/*.md` documents and their versions.
///
/// Not keepAlive — the loader is stateless (const constructor) and holds no
/// DB/stream resources, so it is cheap to reconstruct on demand.
@riverpod
LegalDocumentLoader legalDocumentLoader(Ref ref) => const LegalDocumentLoader();

/// Provides the [ConsentRecordsDao] bound to the live `AppDatabase`.
///
/// keepAlive: true — DAO must persist for the full ProviderScope lifetime
/// because it is referenced by [consentRepositoryProvider], which is also
/// keep-alive.
@Riverpod(keepAlive: true)
ConsentRecordsDao consentRecordsDao(Ref ref) =>
    ref.watch(appDatabaseProvider).consentRecordsDao;

/// Provides the [IConsentRepository] for the consent-recording feature.
///
/// The declared return type is the abstract [IConsentRepository]
/// interface — callers in the presentation layer (`ConsentNotifier`)
/// depend only on the interface, not on [DriftConsentRepository].
@Riverpod(keepAlive: true)
IConsentRepository consentRepository(Ref ref) =>
    DriftConsentRepository(ref.watch(consentRecordsDaoProvider));

/// Provides the running app's version string, formatted as
/// `'{version}+{buildNumber}'` (e.g. `'0.1.0+1'`) — matching the
/// convention documented in `consent_records_table.dart`.
@riverpod
Future<String> appVersion(Ref ref) async {
  final info = await PackageInfo.fromPlatform();
  return '${info.version}+${info.buildNumber}';
}
