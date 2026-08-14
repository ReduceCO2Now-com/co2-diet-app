// Real widget tests for ReferenceDataRow (replaces Plan 09-01's Wave 0
// skip stub).
//
// referencePackProvider is overridden with a small `_FakeReferencePackNotifier`
// (extends the real `ReferencePackNotifier` and stubs `build()`/
// `installedSizeBytes()`) rather than mocking the repository's OFF/download
// internals directly -- mirrors AccountSection/WeightScreen's established
// widget-test convention of overriding a generated Notifier provider
// wholesale.

import 'package:co2diet/domain/entities/reference_pack_status.dart';
import 'package:co2diet/features/reference_data/providers/reference_pack_notifier.dart';
import 'package:co2diet/features/settings/widgets/reference_data_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// A controllable stand-in for the real `ReferencePackNotifier` -- overrides
/// only `build()` (fixed initial status) and `installedSizeBytes()` (fixed
/// installed size), never the repository-backed mutation internals.
class _FakeReferencePackNotifier extends ReferencePackNotifier {
  _FakeReferencePackNotifier(this._status, {this._installedSizeBytes = 0});

  final ReferencePackStatus _status;
  final int _installedSizeBytes;

  @override
  Future<ReferencePackStatus> build() async => _status;

  @override
  Future<int> installedSizeBytes() async => _installedSizeBytes;
}

Widget _wrap(_FakeReferencePackNotifier fakeNotifier) {
  final router = GoRouter(
    initialLocation: '/settings',
    routes: [
      GoRoute(
        path: '/settings',
        builder: (context, state) =>
            const Scaffold(body: ReferenceDataRow()),
      ),
      GoRoute(
        path: '/reference-data',
        builder: (context, state) =>
            const Scaffold(body: Text('reference-data-screen')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [referencePackProvider.overrideWith(() => fakeNotifier)],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  group('ReferenceDataRow', () {
    testWidgets(
      "shows 'Using starter pack' subtitle in the seed state",
      (tester) async {
        await tester.pumpWidget(
          _wrap(_FakeReferencePackNotifier(const ReferencePackSeed())),
        );
        await tester.pumpAndSettle();

        expect(find.text('Download full food database'), findsOneWidget);
        expect(find.text('Using starter pack'), findsOneWidget);
      },
    );

    testWidgets(
      "shows a 'Downloading… X/Y MB' subtitle with live byte "
      'progress in the downloading state',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            _FakeReferencePackNotifier(
              const ReferencePackDownloading(
                bytesDownloaded: 340 * 1024 * 1024,
                bytesTotal: 650 * 1024 * 1024,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Downloading… 340/650 MB'), findsOneWidget);
      },
    );

    testWidgets(
      "shows a 'Full catalog installed — N MB' subtitle in the full "
      'state',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            _FakeReferencePackNotifier(
              ReferencePackFull(
                installedVersion: 'v3',
                productCount: 2500000,
                installedAt: DateTime(2026),
              ),
              installedSizeBytes: 650 * 1024 * 1024,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Full catalog installed — 650 MB'), findsOneWidget);
      },
    );

    testWidgets(
      "shows an 'Update available — connect to Wi-Fi' subtitle when "
      'an update is known but the device is off Wi-Fi',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            _FakeReferencePackNotifier(
              const ReferencePackUpdateAvailable(
                currentVersion: 'v2',
                newVersion: 'v3',
                waitingForWifi: true,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.text('Update available — connect to Wi-Fi'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'tapping the row navigates to /reference-data',
      (tester) async {
        await tester.pumpWidget(
          _wrap(_FakeReferencePackNotifier(const ReferencePackSeed())),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Download full food database'));
        await tester.pumpAndSettle();

        expect(find.text('reference-data-screen'), findsOneWidget);
      },
    );
  });
}
