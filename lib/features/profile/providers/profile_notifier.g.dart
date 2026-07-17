// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// AsyncNotifier that loads the user profile and attaches computed
/// `CalcTargets` via [TargetCalculator.derive] on each build().
///
/// UI consumers: watch this provider to receive a [UserProfile?] with
/// targets pre-computed. Call [saveProfile] or [updateField] to persist
/// changes; the notifier re-runs build() after each save.
///
/// Anti-patterns avoided:
///   - Does NOT import package:drift or AppDatabase.
///   - Does NOT use AutoDisposeRef (Riverpod 3.x uses unified Ref).
///   - Does NOT use StateNotifierProvider.

@ProviderFor(ProfileNotifier)
final profileProvider = ProfileNotifierProvider._();

/// AsyncNotifier that loads the user profile and attaches computed
/// `CalcTargets` via [TargetCalculator.derive] on each build().
///
/// UI consumers: watch this provider to receive a [UserProfile?] with
/// targets pre-computed. Call [saveProfile] or [updateField] to persist
/// changes; the notifier re-runs build() after each save.
///
/// Anti-patterns avoided:
///   - Does NOT import package:drift or AppDatabase.
///   - Does NOT use AutoDisposeRef (Riverpod 3.x uses unified Ref).
///   - Does NOT use StateNotifierProvider.
final class ProfileNotifierProvider
    extends $AsyncNotifierProvider<ProfileNotifier, UserProfile?> {
  /// AsyncNotifier that loads the user profile and attaches computed
  /// `CalcTargets` via [TargetCalculator.derive] on each build().
  ///
  /// UI consumers: watch this provider to receive a [UserProfile?] with
  /// targets pre-computed. Call [saveProfile] or [updateField] to persist
  /// changes; the notifier re-runs build() after each save.
  ///
  /// Anti-patterns avoided:
  ///   - Does NOT import package:drift or AppDatabase.
  ///   - Does NOT use AutoDisposeRef (Riverpod 3.x uses unified Ref).
  ///   - Does NOT use StateNotifierProvider.
  ProfileNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileNotifierHash();

  @$internal
  @override
  ProfileNotifier create() => ProfileNotifier();
}

String _$profileNotifierHash() => r'c70473fadcb1931508c588a1894297512ca71c98';

/// AsyncNotifier that loads the user profile and attaches computed
/// `CalcTargets` via [TargetCalculator.derive] on each build().
///
/// UI consumers: watch this provider to receive a [UserProfile?] with
/// targets pre-computed. Call [saveProfile] or [updateField] to persist
/// changes; the notifier re-runs build() after each save.
///
/// Anti-patterns avoided:
///   - Does NOT import package:drift or AppDatabase.
///   - Does NOT use AutoDisposeRef (Riverpod 3.x uses unified Ref).
///   - Does NOT use StateNotifierProvider.

abstract class _$ProfileNotifier extends $AsyncNotifier<UserProfile?> {
  FutureOr<UserProfile?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<UserProfile?>, UserProfile?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<UserProfile?>, UserProfile?>,
              AsyncValue<UserProfile?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Reactive stream provider that emits [UserProfile?] with targets attached.
///
/// Plan 01-05 (Profile screen) uses this for real-time UI updates without
/// relying on AsyncNotifier's polling approach. Targets are recomputed on
/// each emission from the underlying Drift stream.
///
/// This provider never imports package:drift — it goes through
/// [profileRepositoryProvider].

@ProviderFor(profileStream)
final profileStreamProvider = ProfileStreamProvider._();

/// Reactive stream provider that emits [UserProfile?] with targets attached.
///
/// Plan 01-05 (Profile screen) uses this for real-time UI updates without
/// relying on AsyncNotifier's polling approach. Targets are recomputed on
/// each emission from the underlying Drift stream.
///
/// This provider never imports package:drift — it goes through
/// [profileRepositoryProvider].

final class ProfileStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<UserProfile?>,
          UserProfile?,
          Stream<UserProfile?>
        >
    with $FutureModifier<UserProfile?>, $StreamProvider<UserProfile?> {
  /// Reactive stream provider that emits [UserProfile?] with targets attached.
  ///
  /// Plan 01-05 (Profile screen) uses this for real-time UI updates without
  /// relying on AsyncNotifier's polling approach. Targets are recomputed on
  /// each emission from the underlying Drift stream.
  ///
  /// This provider never imports package:drift — it goes through
  /// [profileRepositoryProvider].
  ProfileStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileStreamHash();

  @$internal
  @override
  $StreamProviderElement<UserProfile?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<UserProfile?> create(Ref ref) {
    return profileStream(ref);
  }
}

String _$profileStreamHash() => r'3be0def341c48089c2a2878dd21f0fc5d9ca5654';
