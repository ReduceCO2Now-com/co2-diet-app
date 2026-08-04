// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consent_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Pure write-composition notifier: a single call site (`acceptConsent`)
/// any onboarding screen can invoke to durably record a fully-versioned
/// consent event (LEGAL-03, LEGAL-04, LEG-02).
///
/// Holds no persistent state beyond the async `build()` placeholder —
/// mirrors `FavoriteNotifier.logFromFavorite`'s cross-provider composition
/// style (RESEARCH.md Pattern 2), composing `appVersionProvider` +
/// `legalDocumentLoaderProvider` + `consentRepositoryProvider` into a
/// single durable write.

@ProviderFor(ConsentNotifier)
final consentProvider = ConsentNotifierProvider._();

/// Pure write-composition notifier: a single call site (`acceptConsent`)
/// any onboarding screen can invoke to durably record a fully-versioned
/// consent event (LEGAL-03, LEGAL-04, LEG-02).
///
/// Holds no persistent state beyond the async `build()` placeholder —
/// mirrors `FavoriteNotifier.logFromFavorite`'s cross-provider composition
/// style (RESEARCH.md Pattern 2), composing `appVersionProvider` +
/// `legalDocumentLoaderProvider` + `consentRepositoryProvider` into a
/// single durable write.
final class ConsentNotifierProvider
    extends $AsyncNotifierProvider<ConsentNotifier, void> {
  /// Pure write-composition notifier: a single call site (`acceptConsent`)
  /// any onboarding screen can invoke to durably record a fully-versioned
  /// consent event (LEGAL-03, LEGAL-04, LEG-02).
  ///
  /// Holds no persistent state beyond the async `build()` placeholder —
  /// mirrors `FavoriteNotifier.logFromFavorite`'s cross-provider composition
  /// style (RESEARCH.md Pattern 2), composing `appVersionProvider` +
  /// `legalDocumentLoaderProvider` + `consentRepositoryProvider` into a
  /// single durable write.
  ConsentNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'consentProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$consentNotifierHash();

  @$internal
  @override
  ConsentNotifier create() => ConsentNotifier();
}

String _$consentNotifierHash() => r'782afc58b43573ab497ebd4d13fb8fef9f8621ca';

/// Pure write-composition notifier: a single call site (`acceptConsent`)
/// any onboarding screen can invoke to durably record a fully-versioned
/// consent event (LEGAL-03, LEGAL-04, LEG-02).
///
/// Holds no persistent state beyond the async `build()` placeholder —
/// mirrors `FavoriteNotifier.logFromFavorite`'s cross-provider composition
/// style (RESEARCH.md Pattern 2), composing `appVersionProvider` +
/// `legalDocumentLoaderProvider` + `consentRepositoryProvider` into a
/// single durable write.

abstract class _$ConsentNotifier extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
