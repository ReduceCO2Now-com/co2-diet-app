// Real widget tests for ReferenceDataScreen (replaces Plan 09-01's Wave 0
// skip stub).
//
// referencePackProvider is overridden with a small
// `_FakeReferencePackNotifier` (extends the real `ReferencePackNotifier`
// and stubs every method it calls) rather than mocking the repository's
// OFF/download internals directly -- mirrors AccountSection/WeightScreen's
// established widget-test convention of overriding a generated Notifier
// provider wholesale, extended to this screen's `IReferencePackRepository`
// -delegating mutation surface (checkForUpdate/hasEnoughDiskSpace/
// freeDiskSpaceBytes/localProductCount/isOnWifi/startFullDownload/
// cancelDownload/resumeDownload/revertToSeed/installedSizeBytes).

import 'package:co2diet/domain/entities/reference_pack_manifest.dart';
import 'package:co2diet/domain/entities/reference_pack_status.dart';
import 'package:co2diet/features/onboarding/providers/onboarding_gate_provider.dart';
import 'package:co2diet/features/reference_data/providers/reference_pack_notifier.dart';
import 'package:co2diet/features/reference_data/screens/reference_data_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

ReferencePackManifest _buildManifest({
  String currentVersion = 'v3',
  int packSizeBytes = 200 * 1024 * 1024,
  int productCount = 2500000,
}) {
  return ReferencePackManifest(
    currentVersion: currentVersion,
    packUrl: 'https://cdn.example.com/off-pack/full_v3.sqlite.gz',
    packSizeBytes: packSizeBytes,
    packSha256: 'deadbeef',
    productCount: productCount,
    deltaFrom: const {},
  );
}

/// A controllable stand-in for the real `ReferencePackNotifier` -- overrides
/// every method `ReferenceDataScreen` calls, never the repository-backed
/// internals directly.
class _FakeReferencePackNotifier extends ReferencePackNotifier {
  _FakeReferencePackNotifier(
    this._status, {
    ReferencePackManifest? manifest,
    this.hasEnoughDiskSpaceResult = true,
    this.freeDiskSpaceBytesResult = 1000 * 1024 * 1024,
    this.isOnWifiResult = true,
    this.installedSizeBytesResult = 0,
  }) : manifestResult = manifest ?? _buildManifest();

  final ReferencePackStatus _status;
  ReferencePackManifest manifestResult;
  bool hasEnoughDiskSpaceResult;
  int freeDiskSpaceBytesResult;
  final int estimatedRequiredDiskSpaceBytesResult = 650 * 1024 * 1024;
  final int localProductCountResult = 50000;
  bool isOnWifiResult;
  int installedSizeBytesResult;

  int startFullDownloadCallCount = 0;
  bool? lastAllowCellular;
  int cancelDownloadCallCount = 0;
  int resumeDownloadCallCount = 0;
  int revertToSeedCallCount = 0;

  @override
  Future<ReferencePackStatus> build() async => _status;

  @override
  Future<ReferencePackManifest> checkForUpdate() async => manifestResult;

  @override
  Future<bool> hasEnoughDiskSpace(ReferencePackManifest manifest) async =>
      hasEnoughDiskSpaceResult;

  @override
  Future<int> freeDiskSpaceBytes() async => freeDiskSpaceBytesResult;

  @override
  int estimatedRequiredDiskSpaceBytes(ReferencePackManifest manifest) =>
      estimatedRequiredDiskSpaceBytesResult;

  @override
  Future<int> localProductCount() async => localProductCountResult;

  @override
  Future<bool> isOnWifi() async => isOnWifiResult;

  @override
  Future<int> installedSizeBytes() async => installedSizeBytesResult;

  @override
  Future<void> startFullDownload({required bool allowCellular}) async {
    startFullDownloadCallCount++;
    lastAllowCellular = allowCellular;
  }

  @override
  Future<void> cancelDownload() async {
    cancelDownloadCallCount++;
  }

  @override
  Future<void> resumeDownload() async {
    resumeDownloadCallCount++;
  }

  @override
  Future<void> revertToSeed() async {
    revertToSeedCallCount++;
  }
}

// The `_buildFull()` state now also watches `referencePackScheduleProvider`
// (Plan 09-06's Automatic Refresh SegmentedButton), which reads
// `sharedPreferencesProvider` -- must be overridden or the default throws
// `UnimplementedError` (same requirement as `test/widget_test.dart`'s
// existing `Co2DietApp` smoke test).
Future<Widget> _wrap(_FakeReferencePackNotifier fakeNotifier) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  return ProviderScope(
    overrides: [
      referencePackProvider.overrideWith(() => fakeNotifier),
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
    child: const MaterialApp(home: ReferenceDataScreen()),
  );
}

void main() {
  group('ReferenceDataScreen', () {
    testWidgets(
      'shows a determinate progress bar with percent and byte '
      'counts during an active download',
      (tester) async {
        await tester.pumpWidget(
          await _wrap(
            _FakeReferencePackNotifier(
              const ReferencePackDownloading(
                bytesDownloaded: 340 * 1024 * 1024,
                bytesTotal: 650 * 1024 * 1024,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final progressIndicator = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        );
        expect(progressIndicator.value, closeTo(340 / 650, 0.001));
        expect(find.text('52% — 340/650 MB'), findsOneWidget);
      },
    );

    testWidgets(
      'the Cancel button is visible only during an active download '
      'and calls cancelDownload() when tapped',
      (tester) async {
        final fake = _FakeReferencePackNotifier(
          const ReferencePackDownloading(
            bytesDownloaded: 100 * 1024 * 1024,
            bytesTotal: 200 * 1024 * 1024,
          ),
        );
        await tester.pumpWidget(await _wrap(fake));
        await tester.pumpAndSettle();

        expect(
          find.widgetWithText(OutlinedButton, 'Cancel'),
          findsOneWidget,
        );

        await tester.tap(find.widgetWithText(OutlinedButton, 'Cancel'));
        await tester.pumpAndSettle();

        expect(fake.cancelDownloadCallCount, 1);
      },
    );

    testWidgets(
      'the Cancel button is not visible outside the downloading state',
      (tester) async {
        await tester.pumpWidget(
          await _wrap(_FakeReferencePackNotifier(const ReferencePackSeed())),
        );
        await tester.pumpAndSettle();

        expect(find.widgetWithText(OutlinedButton, 'Cancel'), findsNothing);
      },
    );

    testWidgets(
      'shows the product-count comparison (starter pack vs full '
      'catalog) using concrete numbers, not vague language',
      (tester) async {
        await tester.pumpWidget(
          await _wrap(
            _FakeReferencePackNotifier(const ReferencePackSeed()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('50K products (starter pack)'), findsOneWidget);
        expect(
          find.text('2.5M products (full catalog)'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'tapping Download with insufficient disk space shows the '
      "blocking 'Not enough storage' message and never starts a "
      'download',
      (tester) async {
        final fake = _FakeReferencePackNotifier(
          const ReferencePackSeed(),
          hasEnoughDiskSpaceResult: false,
          freeDiskSpaceBytesResult: 200 * 1024 * 1024,
        );
        await tester.pumpWidget(await _wrap(fake));
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(FilledButton, 'Download'));
        await tester.pumpAndSettle();

        expect(
          find.text('Not enough storage — need ~650MB, only 200MB free'),
          findsOneWidget,
        );
        expect(fake.startFullDownloadCallCount, 0);
      },
    );

    testWidgets(
      'tapping Download while off Wi-Fi shows the "download over '
      'cellular anyway?" prompt before starting, and starting '
      'requires an explicit confirmation',
      (tester) async {
        final fake = _FakeReferencePackNotifier(
          const ReferencePackSeed(),
          isOnWifiResult: false,
        );
        await tester.pumpWidget(await _wrap(fake));
        await tester.pumpAndSettle();

        // Open, then cancel -- no download starts.
        await tester.tap(find.widgetWithText(FilledButton, 'Download'));
        await tester.pumpAndSettle();

        expect(
          find.text('Not on Wi-Fi — download over cellular anyway?'),
          findsOneWidget,
        );
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        expect(fake.startFullDownloadCallCount, 0);

        // Open again, confirm this time.
        await tester.tap(find.widgetWithText(FilledButton, 'Download'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Use cellular data'));
        await tester.pumpAndSettle();

        expect(fake.startFullDownloadCallCount, 1);
        expect(fake.lastAllowCellular, isTrue);
      },
    );

    testWidgets(
      'the Revert action is disabled while a download is actively '
      'in progress',
      (tester) async {
        await tester.pumpWidget(
          await _wrap(
            _FakeReferencePackNotifier(
              const ReferencePackDownloading(
                bytesDownloaded: 100 * 1024 * 1024,
                bytesTotal: 200 * 1024 * 1024,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Revert to starter pack'), findsNothing);
      },
    );

    testWidgets(
      'the Revert action shows a confirmation dialog with the exact '
      'locked copy from CONTEXT.md; confirming calls revertToSeed() '
      'and cancelling does not',
      (tester) async {
        final fake = _FakeReferencePackNotifier(
          ReferencePackFull(
            installedVersion: 'v3',
            productCount: 2500000,
            installedAt: DateTime(2026),
          ),
          installedSizeBytesResult: 650 * 1024 * 1024,
        );
        await tester.pumpWidget(await _wrap(fake));
        await tester.pumpAndSettle();

        // Open, then cancel.
        await tester.tap(find.text('Revert to starter pack'));
        await tester.pumpAndSettle();

        expect(
          find.text(
            'Revert to starter pack? This deletes the full catalog '
            '(650MB) and reduces search coverage back to the starter '
            'set.',
          ),
          findsOneWidget,
        );
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        expect(fake.revertToSeedCallCount, 0);

        // Open again, confirm this time.
        await tester.tap(find.text('Revert to starter pack'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(FilledButton, 'Revert'));
        await tester.pumpAndSettle();

        expect(fake.revertToSeedCallCount, 1);
      },
    );
  });
}
