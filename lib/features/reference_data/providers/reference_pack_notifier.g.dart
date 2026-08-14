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

/// The installed pack database's on-disk size in bytes, recomputed
/// whenever [referencePackProvider]'s status changes (e.g. a
/// download completes or a revert finishes) -- the reactive counterpart to
/// [ReferencePackNotifier.installedSizeBytes], so `ReferenceDataRow`/
/// `ReferenceDataScreen` can `ref.watch` it directly instead of managing
/// their own `FutureBuilder`/local state.

@ProviderFor(referencePackInstalledSizeBytes)
final referencePackInstalledSizeBytesProvider =
    ReferencePackInstalledSizeBytesProvider._();

/// The installed pack database's on-disk size in bytes, recomputed
/// whenever [referencePackProvider]'s status changes (e.g. a
/// download completes or a revert finishes) -- the reactive counterpart to
/// [ReferencePackNotifier.installedSizeBytes], so `ReferenceDataRow`/
/// `ReferenceDataScreen` can `ref.watch` it directly instead of managing
/// their own `FutureBuilder`/local state.

final class ReferencePackInstalledSizeBytesProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// The installed pack database's on-disk size in bytes, recomputed
  /// whenever [referencePackProvider]'s status changes (e.g. a
  /// download completes or a revert finishes) -- the reactive counterpart to
  /// [ReferencePackNotifier.installedSizeBytes], so `ReferenceDataRow`/
  /// `ReferenceDataScreen` can `ref.watch` it directly instead of managing
  /// their own `FutureBuilder`/local state.
  ReferencePackInstalledSizeBytesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'referencePackInstalledSizeBytesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$referencePackInstalledSizeBytesHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return referencePackInstalledSizeBytes(ref);
  }
}

String _$referencePackInstalledSizeBytesHash() =>
    r'581c64bd3f0082c31a15b1a2b9eb69f2ae2da21b';

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
    r'beb4bb11b15b3b6eebadf19847c7c03a55a88ed5';

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
