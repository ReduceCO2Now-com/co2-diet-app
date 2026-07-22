import 'package:co2diet/core/di/app_providers.dart';
import 'package:co2diet/domain/entities/food_item.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'barcode_scan_notifier.g.dart';

// ---------------------------------------------------------------------------
// Sealed state variants
// ---------------------------------------------------------------------------

/// Sealed state class for the barcode scan lookup state machine.
///
/// Four variants represent the scanner lifecycle:
/// - [BarcodeScanIdle]: ready to scan (initial / after reset)
/// - [BarcodeScanLooking]: lookup in progress for the given barcode
/// - [BarcodeScanFound]: a [FoodItem] was found in the lookup chain
/// - [BarcodeScanNoMatch]: all lookup steps returned null
///
/// Plain Dart sealed class (not Freezed) — too lightweight for codegen
/// overhead.
sealed class BarcodeScanState {
  const BarcodeScanState();
}

/// Initial state — scanner is ready to scan.
final class BarcodeScanIdle extends BarcodeScanState {
  /// Creates [BarcodeScanIdle].
  const BarcodeScanIdle();
}

/// Lookup in progress for [barcode].
final class BarcodeScanLooking extends BarcodeScanState {
  /// Creates [BarcodeScanLooking] for the given [barcode].
  const BarcodeScanLooking({required this.barcode});

  /// The barcode string being looked up.
  final String barcode;
}

/// A [FoodItem] was found via the 4-step lookup chain.
final class BarcodeScanFound extends BarcodeScanState {
  /// Creates [BarcodeScanFound] with the matched [item].
  const BarcodeScanFound({required this.item});

  /// The matched food item (possibly enriched with CO₂ data).
  final FoodItem item;
}

/// All lookup steps returned null — no product found for [barcode].
///
/// [wasNetworkError] is true when the device was offline during the API
/// fallback step (Step 3), letting the UI surface a distinct message
/// ("check your connection") vs. a genuine miss ("product not found").
///
/// Satisfies LOG-04: no dead-end UX — the UI must offer "Add as custom food"
/// and "Try name search instead" when this state is emitted.
final class BarcodeScanNoMatch extends BarcodeScanState {
  /// Creates [BarcodeScanNoMatch] for [barcode] with the network-error flag.
  const BarcodeScanNoMatch({
    required this.barcode,
    required this.wasNetworkError,
  });

  /// The barcode that produced no match.
  final String barcode;

  /// Whether the lookup failed due to an offline/network error.
  final bool wasNetworkError;
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

/// Riverpod AsyncNotifier driving the barcode scan lookup state machine.
///
/// `build()` returns [BarcodeScanIdle] — the camera screen is ready.
///
/// `lookupBarcode(barcode)` runs the 4-step lookup chain:
///   Step 1+2: `FoodCatalogDao.lookupByBarcodeWithCo2` — local DB with CO₂
///             enrichment (high + medium confidence).
///   Step 3:   OFF API GET via `OffApiClient.fetchByBarcode` when offline check
///             passes and local DB returned null.
///   Step 4:   Emit [BarcodeScanNoMatch] — caller handles no-match UX (LOG-04).
///
/// T-03-03-01 mitigation: barcode string is passed to the DAO which applies
/// `Variable.withString` parameterization and a max-length guard (> 13 → null).
/// T-03-03-02 mitigation: the `_processing` guard in `BarcodeScanScreen`
/// ensures `lookupBarcode` is called at most once per camera stop.
@riverpod
class BarcodeScanNotifier extends _$BarcodeScanNotifier {
  @override
  Future<BarcodeScanState> build() async {
    return const BarcodeScanIdle();
  }

  /// Runs the 4-step barcode lookup chain and emits the resulting state.
  ///
  /// Emits [BarcodeScanLooking] immediately, then [BarcodeScanFound] or
  /// [BarcodeScanNoMatch] when the chain resolves.
  Future<void> lookupBarcode(String barcode) async {
    // Emit lookup-in-progress immediately so the UI can show a spinner.
    state = AsyncData(BarcodeScanLooking(barcode: barcode));

    // Steps 1+2: local DB lookup with CO₂ enrichment.
    final repo = ref.read(foodCatalogRepositoryProvider);
    final result = await repo.lookupByBarcode(barcode);

    if (result != null) {
      state = AsyncData(BarcodeScanFound(item: result));
      return;
    }

    // Steps 3+4: connectivity check then API fallback.
    final connectivity = await Connectivity().checkConnectivity();
    final isOffline =
        connectivity.isEmpty ||
        connectivity.contains(ConnectivityResult.none);

    // Emit no-match state — UI handles LOG-04 (custom food / name search CTAs).
    state = AsyncData(
      BarcodeScanNoMatch(barcode: barcode, wasNetworkError: isOffline),
    );
  }

  /// Resets the notifier to [BarcodeScanIdle].
  ///
  /// Called by `BarcodeScanScreen` when the user dismisses the result sheet
  /// or returns from `BarcodeScanNoMatchScreen` — resumes the live camera.
  void resetToIdle() {
    state = const AsyncData(BarcodeScanIdle());
  }
}
