import 'package:co2diet/core/di/legal_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'consent_notifier.g.dart';

/// Pure write-composition notifier: a single call site (`acceptConsent`)
/// any onboarding screen can invoke to durably record a fully-versioned
/// consent event (LEGAL-03, LEGAL-04, LEG-02).
///
/// Holds no persistent state beyond the async `build()` placeholder —
/// mirrors `FavoriteNotifier.logFromFavorite`'s cross-provider composition
/// style (RESEARCH.md Pattern 2), composing `appVersionProvider` +
/// `legalDocumentLoaderProvider` + `consentRepositoryProvider` into a
/// single durable write.
@riverpod
class ConsentNotifier extends _$ConsentNotifier {
  @override
  FutureOr<void> build() {}

  /// Records a new consent event carrying the exact [consentsGiven]
  /// checkbox identifiers, the real running app version, and the real
  /// policy version.
  ///
  /// Uses `terms.md`'s frontmatter version as the single canonical
  /// `policyVersion` for the whole consent event, since all four legal
  /// documents (terms, privacy, health disclaimer, impressum) are
  /// drafted/versioned together as one dated bundle.
  Future<void> acceptConsent({required List<String> consentsGiven}) async {
    final appVersion = await ref.read(appVersionProvider.future);
    final policyVersion = await ref
        .read(legalDocumentLoaderProvider)
        .versionOf('terms.md');
    await ref
        .read(consentRepositoryProvider)
        .recordConsent(
          policyVersion: policyVersion,
          appVersion: appVersion,
          consentsGiven: consentsGiven,
        );
  }
}
