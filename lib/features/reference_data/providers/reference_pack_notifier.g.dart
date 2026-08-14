// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reference_pack_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Live stream of [ReferencePackStatus] transitions, composed by
/// [ReferencePackNotifier] rather than duplicated inline -- keeps
/// [ReferencePackNotifier] a thin `AsyncNotifier` that also exposes the
/// mutation methods below, since `IReferencePackRepository.watchStatus()`
/// is a continuously-updating download-progress stream that doesn't fit
/// `AsyncNotifier.build()`'s single-`Future` shape as cleanly as a
/// dedicated `StreamProvider` does.

@ProviderFor(referencePackStatusStream)
final referencePackStatusStreamProvider = ReferencePackStatusStreamProvider._();

/// Live stream of [ReferencePackStatus] transitions, composed by
/// [ReferencePackNotifier] rather than duplicated inline -- keeps
/// [ReferencePackNotifier] a thin `AsyncNotifier` that also exposes the
/// mutation methods below, since `IReferencePackRepository.watchStatus()`
/// is a continuously-updating download-progress stream that doesn't fit
/// `AsyncNotifier.build()`'s single-`Future` shape as cleanly as a
/// dedicated `StreamProvider` does.

final class ReferencePackStatusStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<ReferencePackStatus>,
          ReferencePackStatus,
          Stream<ReferencePackStatus>
        >
    with
        $FutureModifier<ReferencePackStatus>,
        $StreamProvider<ReferencePackStatus> {
  /// Live stream of [ReferencePackStatus] transitions, composed by
  /// [ReferencePackNotifier] rather than duplicated inline -- keeps
  /// [ReferencePackNotifier] a thin `AsyncNotifier` that also exposes the
  /// mutation methods below, since `IReferencePackRepository.watchStatus()`
  /// is a continuously-updating download-progress stream that doesn't fit
  /// `AsyncNotifier.build()`'s single-`Future` shape as cleanly as a
  /// dedicated `StreamProvider` does.
  ReferencePackStatusStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'referencePackStatusStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$referencePackStatusStreamHash();

  @$internal
  @override
  $StreamProviderElement<ReferencePackStatus> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<ReferencePackStatus> create(Ref ref) {
    return referencePackStatusStream(ref);
  }
}

String _$referencePackStatusStreamHash() =>
    r'1b543e256d2df99e1c982956946019c2cb4d47c4';

/// AsyncNotifier presentation-layer wrapper around
/// [referencePackRepositoryProvider] -- the single Riverpod surface the
/// Settings row (`ReferenceDataRow`) and the dedicated screen
/// (`ReferenceDataScreen`) both read from.
///
/// keepAlive: true mirrors `BackupNotifier`/`AuthNotifier`'s established
/// rationale -- mutations here are triggered from widget callbacks that
/// may outlive their triggering widget (e.g. Cancel/Revert confirmed from
/// a dialog after the underlying screen state has moved on).

@ProviderFor(ReferencePackNotifier)
final referencePackProvider = ReferencePackNotifierProvider._();

/// AsyncNotifier presentation-layer wrapper around
/// [referencePackRepositoryProvider] -- the single Riverpod surface the
/// Settings row (`ReferenceDataRow`) and the dedicated screen
/// (`ReferenceDataScreen`) both read from.
///
/// keepAlive: true mirrors `BackupNotifier`/`AuthNotifier`'s established
/// rationale -- mutations here are triggered from widget callbacks that
/// may outlive their triggering widget (e.g. Cancel/Revert confirmed from
/// a dialog after the underlying screen state has moved on).
final class ReferencePackNotifierProvider
    extends $AsyncNotifierProvider<ReferencePackNotifier, ReferencePackStatus> {
  /// AsyncNotifier presentation-layer wrapper around
  /// [referencePackRepositoryProvider] -- the single Riverpod surface the
  /// Settings row (`ReferenceDataRow`) and the dedicated screen
  /// (`ReferenceDataScreen`) both read from.
  ///
  /// keepAlive: true mirrors `BackupNotifier`/`AuthNotifier`'s established
  /// rationale -- mutations here are triggered from widget callbacks that
  /// may outlive their triggering widget (e.g. Cancel/Revert confirmed from
  /// a dialog after the underlying screen state has moved on).
  ReferencePackNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'referencePackProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$referencePackNotifierHash();

  @$internal
  @override
  ReferencePackNotifier create() => ReferencePackNotifier();
}

String _$referencePackNotifierHash() =>
    r'782e787be96c71f0eb847f98c50c7ccf3ded8544';

/// AsyncNotifier presentation-layer wrapper around
/// [referencePackRepositoryProvider] -- the single Riverpod surface the
/// Settings row (`ReferenceDataRow`) and the dedicated screen
/// (`ReferenceDataScreen`) both read from.
///
/// keepAlive: true mirrors `BackupNotifier`/`AuthNotifier`'s established
/// rationale -- mutations here are triggered from widget callbacks that
/// may outlive their triggering widget (e.g. Cancel/Revert confirmed from
/// a dialog after the underlying screen state has moved on).

abstract class _$ReferencePackNotifier
    extends $AsyncNotifier<ReferencePackStatus> {
  FutureOr<ReferencePackStatus> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<ReferencePackStatus>, ReferencePackStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ReferencePackStatus>, ReferencePackStatus>,
              AsyncValue<ReferencePackStatus>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
