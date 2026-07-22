// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'barcode_scan_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod AsyncNotifier driving the barcode scan lookup state machine.
///
/// `build()` returns [BarcodeScanIdle] — the camera screen is ready.
///
/// `lookupBarcode(barcode)` runs the 4-step lookup chain:
///   Step 1+2: [FoodCatalogDao.lookupByBarcodeWithCo2] — local DB with CO₂
///             enrichment (high + medium confidence).
///   Step 3:   OFF API GET via [OffApiClient.fetchByBarcode] when offline check
///             passes and local DB returned null.
///   Step 4:   Emit [BarcodeScanNoMatch] — caller handles no-match UX (LOG-04).
///
/// T-03-03-01 mitigation: barcode string is passed to the DAO which applies
/// Variable.withString parameterization and a max-length guard (> 13 → null).
/// T-03-03-02 mitigation: the [_processing] guard in [BarcodeScanScreen]
/// ensures [lookupBarcode] is called at most once per camera stop.

@ProviderFor(BarcodeScanNotifier)
final barcodeScanProvider = BarcodeScanNotifierProvider._();

/// Riverpod AsyncNotifier driving the barcode scan lookup state machine.
///
/// `build()` returns [BarcodeScanIdle] — the camera screen is ready.
///
/// `lookupBarcode(barcode)` runs the 4-step lookup chain:
///   Step 1+2: [FoodCatalogDao.lookupByBarcodeWithCo2] — local DB with CO₂
///             enrichment (high + medium confidence).
///   Step 3:   OFF API GET via [OffApiClient.fetchByBarcode] when offline check
///             passes and local DB returned null.
///   Step 4:   Emit [BarcodeScanNoMatch] — caller handles no-match UX (LOG-04).
///
/// T-03-03-01 mitigation: barcode string is passed to the DAO which applies
/// Variable.withString parameterization and a max-length guard (> 13 → null).
/// T-03-03-02 mitigation: the [_processing] guard in [BarcodeScanScreen]
/// ensures [lookupBarcode] is called at most once per camera stop.
final class BarcodeScanNotifierProvider
    extends $AsyncNotifierProvider<BarcodeScanNotifier, BarcodeScanState> {
  /// Riverpod AsyncNotifier driving the barcode scan lookup state machine.
  ///
  /// `build()` returns [BarcodeScanIdle] — the camera screen is ready.
  ///
  /// `lookupBarcode(barcode)` runs the 4-step lookup chain:
  ///   Step 1+2: [FoodCatalogDao.lookupByBarcodeWithCo2] — local DB with CO₂
  ///             enrichment (high + medium confidence).
  ///   Step 3:   OFF API GET via [OffApiClient.fetchByBarcode] when offline check
  ///             passes and local DB returned null.
  ///   Step 4:   Emit [BarcodeScanNoMatch] — caller handles no-match UX (LOG-04).
  ///
  /// T-03-03-01 mitigation: barcode string is passed to the DAO which applies
  /// Variable.withString parameterization and a max-length guard (> 13 → null).
  /// T-03-03-02 mitigation: the [_processing] guard in [BarcodeScanScreen]
  /// ensures [lookupBarcode] is called at most once per camera stop.
  BarcodeScanNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'barcodeScanProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$barcodeScanNotifierHash();

  @$internal
  @override
  BarcodeScanNotifier create() => BarcodeScanNotifier();
}

String _$barcodeScanNotifierHash() =>
    r'b1803fa5d7680300bcc6af328c1bfdc574a2b70e';

/// Riverpod AsyncNotifier driving the barcode scan lookup state machine.
///
/// `build()` returns [BarcodeScanIdle] — the camera screen is ready.
///
/// `lookupBarcode(barcode)` runs the 4-step lookup chain:
///   Step 1+2: [FoodCatalogDao.lookupByBarcodeWithCo2] — local DB with CO₂
///             enrichment (high + medium confidence).
///   Step 3:   OFF API GET via [OffApiClient.fetchByBarcode] when offline check
///             passes and local DB returned null.
///   Step 4:   Emit [BarcodeScanNoMatch] — caller handles no-match UX (LOG-04).
///
/// T-03-03-01 mitigation: barcode string is passed to the DAO which applies
/// Variable.withString parameterization and a max-length guard (> 13 → null).
/// T-03-03-02 mitigation: the [_processing] guard in [BarcodeScanScreen]
/// ensures [lookupBarcode] is called at most once per camera stop.

abstract class _$BarcodeScanNotifier extends $AsyncNotifier<BarcodeScanState> {
  FutureOr<BarcodeScanState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<BarcodeScanState>, BarcodeScanState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<BarcodeScanState>, BarcodeScanState>,
              AsyncValue<BarcodeScanState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
