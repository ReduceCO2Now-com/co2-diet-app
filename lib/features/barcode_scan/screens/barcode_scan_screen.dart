import 'dart:async';

import 'package:co2diet/domain/entities/food_item.dart';
import 'package:co2diet/features/barcode_scan/providers/barcode_scan_notifier.dart';
import 'package:co2diet/features/barcode_scan/screens/barcode_no_match_screen.dart';
import 'package:co2diet/features/barcode_scan/widgets/camera_permission_denied_widget.dart';
import 'package:co2diet/features/barcode_scan/widgets/scan_frame_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Full-screen barcode scanner screen.
///
/// Implements the P0 camera scanner requirement (LOG-03).
/// The `_processing` boolean is the critical debounce guard preventing
/// re-entrant barcode handling — `MobileScanner.onDetect` fires at ~30 Hz.
///
/// T-03-03-02 mitigation: `_processing` guard + immediate `_controller.stop()`
/// after first valid scan prevents multiple concurrent `lookupBarcode` calls.
class BarcodeScanScreen extends ConsumerStatefulWidget {
  /// Creates [BarcodeScanScreen].
  const BarcodeScanScreen({super.key});

  @override
  ConsumerState<BarcodeScanScreen> createState() => _BarcodeScanScreenState();
}

class _BarcodeScanScreenState extends ConsumerState<BarcodeScanScreen> {
  late final MobileScannerController _controller;

  /// Debounce guard — prevents re-entrant calls when [MobileScanner.onDetect]
  /// fires multiple times for the same barcode at high frame rate.
  ///
  /// Set to true before any async work; reset to false when the result sheet
  /// or no-match screen is dismissed.
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      formats: const [
        BarcodeFormat.ean13,
        BarcodeFormat.ean8,
        BarcodeFormat.upcA,
      ],
    );
  }

  @override
  void dispose() {
    unawaited(_controller.dispose());
    super.dispose();
  }

  /// Handles a barcode detection event from [MobileScanner.onDetect].
  ///
  /// Applies three guards in order:
  /// 1. `_processing` guard — returns immediately if a lookup is in flight.
  /// 2. Null guard — returns if barcode or rawValue is null.
  /// 3. Format gate — rejects non-product barcodes (QR, DataMatrix, etc.)
  ///    with a SnackBar message (belt-and-suspenders beyond formats filter).
  ///
  /// On a valid product barcode:
  /// - Sets `_processing` = true
  /// - Stops the camera (prevents additional onDetect fires)
  /// - Triggers haptic feedback
  /// - Calls `barcodeScanProvider.notifier.lookupBarcode`
  Future<void> _handleBarcode(BarcodeCapture capture) async {
    if (_processing) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    // Belt-and-suspenders format gate beyond controller.formats filter.
    const productFormats = {
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
    };
    if (!productFormats.contains(barcode.format)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("That doesn't look like a product barcode"),
          ),
        );
      }
      return;
    }

    setState(() => _processing = true);
    unawaited(_controller.stop());
    unawaited(HapticFeedback.lightImpact());
    await ref
        .read(barcodeScanProvider.notifier)
        .lookupBarcode(barcode.rawValue!);
  }

  /// Presents the food detail sheet and resets the scanner state on dismissal.
  ///
  /// Uses [showModalBottomSheet] directly so the future completes when the
  /// sheet is dismissed — allowing camera resumption and state reset.
  Future<void> _showItemSheet(FoodItem item) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _BarcodeScanDetailSheet(item: item),
    );
    if (mounted) {
      setState(() => _processing = false);
      unawaited(_controller.start());
      ref.read(barcodeScanProvider.notifier).resetToIdle();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to state transitions and show result UI.
    ref.listen<AsyncValue<BarcodeScanState>>(barcodeScanProvider, (
      previous,
      next,
    ) {
      final scanState = next.value;
      if (scanState == null) return;

      switch (scanState) {
        case BarcodeScanFound(:final item):
          unawaited(_showItemSheet(item));
        case BarcodeScanNoMatch(:final barcode, :final wasNetworkError):
          unawaited(
            Navigator.of(context)
                .push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => BarcodeScanNoMatchScreen(
                      barcode: barcode,
                      wasNetworkError: wasNetworkError,
                    ),
                  ),
                )
                .then((_) {
                  if (mounted) {
                    setState(() => _processing = false);
                    unawaited(_controller.start());
                    ref.read(barcodeScanProvider.notifier).resetToIdle();
                  }
                }),
          );
        case BarcodeScanIdle():
        case BarcodeScanLooking():
          // No UI action needed for these transitions.
          break;
      }
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        leading: const BackButton(),
        actions: [
          IconButton(
            icon: const Icon(Icons.flashlight_on_outlined),
            tooltip: 'Toggle torch',
            onPressed: () => unawaited(_controller.toggleTorch()),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _handleBarcode,
            overlayBuilder: (ctx, constraints) => const Center(
              child: ScanFrameOverlay(),
            ),
            errorBuilder: (ctx, ex) {
              if (ex.errorCode == MobileScannerErrorCode.permissionDenied) {
                return const CameraPermissionDeniedWidget();
              }
              return const Center(
                child: Icon(Icons.error_outline, color: Colors.white, size: 48),
              );
            },
          ),
          if (_processing)
            Container(
              color: Colors.black54,
              alignment: Alignment.center,
              child: const CircularProgressIndicator.adaptive(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}

/// Bottom sheet content displayed after a successful barcode lookup.
///
/// Mirrors the Phase 2 food detail sheet content so the scanner screen can
/// track sheet dismissal via the [showModalBottomSheet] future — the shared
/// `showFoodDetailSheet` helper wraps the future with `unawaited` which
/// prevents completion tracking.
///
/// CO₂ row is shown when [FoodItem.co2e100g] is non-null.
/// "Log this food" button is deferred to Phase 4.
class _BarcodeScanDetailSheet extends StatelessWidget {
  const _BarcodeScanDetailSheet({required this.item});

  final FoodItem item;

  @override
  Widget build(BuildContext context) {
    final hasBrand = item.brand != null && item.brand!.isNotEmpty;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(item.productName, style: textTheme.titleLarge),
          if (hasBrand) ...[
            const SizedBox(height: 4),
            Text(
              item.brand!,
              style: textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const Divider(height: 24),
          _MacroRow(
            label: 'Calories',
            value: '${item.calories100g?.round() ?? '—'} kcal',
          ),
          _MacroRow(
            label: 'Protein',
            value: '${item.protein100g?.toStringAsFixed(1) ?? '—'} g',
          ),
          _MacroRow(
            label: 'Carbohydrates',
            value: '${item.carbs100g?.toStringAsFixed(1) ?? '—'} g',
          ),
          _MacroRow(
            label: 'Fat',
            value: '${item.fat100g?.toStringAsFixed(1) ?? '—'} g',
          ),
          if (item.co2e100g != null)
            _MacroRow(
              label: 'CO₂e',
              value:
                  '${item.co2e100g!.toStringAsFixed(2)} kg CO₂e/kg '
                  '(${item.confidenceBand ?? 'unknown'})',
            ),
          const SizedBox(height: 16),
          Text('per 100g', style: textTheme.labelSmall),
          // TODO(phase-4): Add 'Log this food' FilledButton here.
        ],
      ),
    );
  }
}

/// A single label/value row used inside [_BarcodeScanDetailSheet].
class _MacroRow extends StatelessWidget {
  const _MacroRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
