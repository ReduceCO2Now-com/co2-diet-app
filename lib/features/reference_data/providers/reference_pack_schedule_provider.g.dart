// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reference_pack_schedule_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Persists and exposes the delta-refresh schedule + last-checked
/// timestamp.
///
/// keepAlive: true -- mirrors [MethodologyBannerDismissalNotifier]'s
/// established rationale: [setSchedule]/[recordCheckedNow]/[resetToManual]
/// are all called from widget callbacks (a `SegmentedButton` selection, a
/// revert-confirmation dialog, `Co2DietApp`'s lifecycle observer) that may
/// not keep an active watcher of this provider alive across the `await`.

@ProviderFor(ReferencePackScheduleNotifier)
final referencePackScheduleProvider = ReferencePackScheduleNotifierProvider._();

/// Persists and exposes the delta-refresh schedule + last-checked
/// timestamp.
///
/// keepAlive: true -- mirrors [MethodologyBannerDismissalNotifier]'s
/// established rationale: [setSchedule]/[recordCheckedNow]/[resetToManual]
/// are all called from widget callbacks (a `SegmentedButton` selection, a
/// revert-confirmation dialog, `Co2DietApp`'s lifecycle observer) that may
/// not keep an active watcher of this provider alive across the `await`.
final class ReferencePackScheduleNotifierProvider
    extends
        $NotifierProvider<
          ReferencePackScheduleNotifier,
          ReferencePackScheduleState
        > {
  /// Persists and exposes the delta-refresh schedule + last-checked
  /// timestamp.
  ///
  /// keepAlive: true -- mirrors [MethodologyBannerDismissalNotifier]'s
  /// established rationale: [setSchedule]/[recordCheckedNow]/[resetToManual]
  /// are all called from widget callbacks (a `SegmentedButton` selection, a
  /// revert-confirmation dialog, `Co2DietApp`'s lifecycle observer) that may
  /// not keep an active watcher of this provider alive across the `await`.
  ReferencePackScheduleNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'referencePackScheduleProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$referencePackScheduleNotifierHash();

  @$internal
  @override
  ReferencePackScheduleNotifier create() => ReferencePackScheduleNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReferencePackScheduleState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReferencePackScheduleState>(value),
    );
  }
}

String _$referencePackScheduleNotifierHash() =>
    r'0cb4c838bdab3be067a0a51b72bb76e046d38142';

/// Persists and exposes the delta-refresh schedule + last-checked
/// timestamp.
///
/// keepAlive: true -- mirrors [MethodologyBannerDismissalNotifier]'s
/// established rationale: [setSchedule]/[recordCheckedNow]/[resetToManual]
/// are all called from widget callbacks (a `SegmentedButton` selection, a
/// revert-confirmation dialog, `Co2DietApp`'s lifecycle observer) that may
/// not keep an active watcher of this provider alive across the `await`.

abstract class _$ReferencePackScheduleNotifier
    extends $Notifier<ReferencePackScheduleState> {
  ReferencePackScheduleState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<ReferencePackScheduleState, ReferencePackScheduleState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                ReferencePackScheduleState,
                ReferencePackScheduleState
              >,
              ReferencePackScheduleState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
