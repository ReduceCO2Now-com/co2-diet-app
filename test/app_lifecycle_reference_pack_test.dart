// Real tests for Plan 09-06's foreground-triggered delta-refresh scheduling
// (replaces Plan 09-01's Wave 0 skip stub).
//
// Three groups:
//  - 'isCheckDue' -- pure unit tests, no widget pump/SharedPreferences setup
//    needed.
//  - 'Co2DietApp lifecycle observer' -- widget tests pumping the real
//    `Co2DietApp`, driving `AppLifecycleState.resumed` via
//    `tester.binding.handleAppLifecycleStateChanged`, and observing whether
//    a `_FakeReferencePackNotifier` override's `checkForUpdateIfDue()` was
//    invoked. Mirrors `test/widget_test.dart`'s established
//    `appDatabaseProvider`/`sharedPreferencesProvider` override convention.
//  - 'checkForUpdateIfDue Wi-Fi behavior' -- exercises the real
//    `ReferencePackNotifier.checkForUpdateIfDue()` against a mocked
//    `IReferencePackRepository` (mocktail) with connectivity_plus's platform
//    channel mocked off-Wi-Fi (Phase 02-07's established connectivity-mock
//    convention, reused from `food_search_notifier_test.dart`).

import 'package:co2diet/app.dart';
import 'package:co2diet/core/di/providers.dart';
import 'package:co2diet/core/di/reference_pack_providers.dart';
import 'package:co2diet/data/local/app_database.dart';
import 'package:co2diet/domain/entities/reference_pack_manifest.dart';
import 'package:co2diet/domain/entities/reference_pack_status.dart';
import 'package:co2diet/domain/repositories/i_reference_pack_repository.dart';
import 'package:co2diet/features/onboarding/providers/onboarding_gate_provider.dart';
import 'package:co2diet/features/reference_data/providers/reference_pack_notifier.dart';
import 'package:co2diet/features/reference_data/providers/reference_pack_schedule_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------

ReferencePackManifest _buildManifest({String currentVersion = 'v4'}) {
  return ReferencePackManifest(
    currentVersion: currentVersion,
    packUrl: 'https://cdn.example.com/off-pack/full_v4.sqlite.gz',
    packSizeBytes: 200 * 1024 * 1024,
    packSha256: 'deadbeef',
    productCount: 2600000,
    deltaFrom: const {},
  );
}

// connectivity_plus channel name used by MethodChannelConnectivity --
// mirrors food_search_notifier_test.dart's established mock (Phase 02-07).
const _connectivityChannel = MethodChannel(
  'dev.fluttercommunity.plus/connectivity',
);

void _mockConnectivity(String result) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_connectivityChannel, (call) async {
        if (call.method == 'check') return [result];
        return null;
      });
}

void _clearConnectivityMock() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_connectivityChannel, null);
}

// ---------------------------------------------------------------------------
// 'isCheckDue' -- pure function tests
// ---------------------------------------------------------------------------

void _testIsCheckDue() {
  group('isCheckDue', () {
    final now = DateTime(2026, 8, 14);

    test('manual schedule is never due', () {
      expect(isCheckDue(ReferencePackSchedule.manual, null, now), isFalse);
      expect(
        isCheckDue(
          ReferencePackSchedule.manual,
          now.subtract(const Duration(days: 365)),
          now,
        ),
        isFalse,
      );
    });

    test('weekly schedule is due when never checked', () {
      expect(isCheckDue(ReferencePackSchedule.weekly, null, now), isTrue);
    });

    test('weekly schedule is due when 7+ days have elapsed', () {
      expect(
        isCheckDue(
          ReferencePackSchedule.weekly,
          now.subtract(const Duration(days: 7)),
          now,
        ),
        isTrue,
      );
      expect(
        isCheckDue(
          ReferencePackSchedule.weekly,
          now.subtract(const Duration(days: 8)),
          now,
        ),
        isTrue,
      );
    });

    test('weekly schedule is not due when fewer than 7 days have elapsed', () {
      expect(
        isCheckDue(
          ReferencePackSchedule.weekly,
          now.subtract(const Duration(days: 1)),
          now,
        ),
        isFalse,
      );
    });

    test('monthly schedule is due when never checked', () {
      expect(isCheckDue(ReferencePackSchedule.monthly, null, now), isTrue);
    });

    test('monthly schedule is due when 30+ days have elapsed', () {
      expect(
        isCheckDue(
          ReferencePackSchedule.monthly,
          now.subtract(const Duration(days: 30)),
          now,
        ),
        isTrue,
      );
      expect(
        isCheckDue(
          ReferencePackSchedule.monthly,
          now.subtract(const Duration(days: 31)),
          now,
        ),
        isTrue,
      );
    });

    test(
      'monthly schedule is not due when fewer than 30 days have elapsed',
      () {
        expect(
          isCheckDue(
            ReferencePackSchedule.monthly,
            now.subtract(const Duration(days: 5)),
            now,
          ),
          isFalse,
        );
      },
    );
  });
}

// ---------------------------------------------------------------------------
// 'Co2DietApp lifecycle observer' -- integration-style widget tests
// ---------------------------------------------------------------------------

/// A controllable stand-in for the real `ReferencePackNotifier` -- tracks
/// how many times `checkForUpdateIfDue()` was called, without ever touching
/// the repository/network internals.
class _FakeReferencePackNotifier extends ReferencePackNotifier {
  int checkForUpdateIfDueCallCount = 0;

  @override
  Future<ReferencePackStatus> build() async => ReferencePackFull(
    installedVersion: 'v3',
    productCount: 2500000,
    installedAt: DateTime(2026),
  );

  @override
  Future<void> checkForUpdateIfDue() async {
    checkForUpdateIfDueCallCount++;
  }
}

Future<_FakeReferencePackNotifier> _pumpAppAndResume(
  WidgetTester tester, {
  String? schedule,
  String? lastCheckedAt,
}) async {
  final db = AppDatabase(NativeDatabase.memory());
  addTearDown(db.close);

  SharedPreferences.setMockInitialValues({
    'hasCompletedOnboarding': true,
    'referencePackSchedule': ?schedule,
    'referencePackLastCheckedAt': ?lastCheckedAt,
  });
  final prefs = await SharedPreferences.getInstance();

  final fake = _FakeReferencePackNotifier();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        sharedPreferencesProvider.overrideWithValue(prefs),
        referencePackProvider.overrideWith(() => fake),
      ],
      child: const Co2DietApp(),
    ),
  );
  await tester.pump();

  // Drive the resumed lifecycle event -- mirrors the real platform signal
  // Co2DietApp's WidgetsBindingObserver reacts to.
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  await tester.pump();
  await tester.pump();

  return fake;
}

void _testLifecycleObserver() {
  group('Co2DietApp lifecycle observer', () {
    testWidgets(
      'does not check for an update on resume when the schedule is manual',
      (tester) async {
        final fake = await _pumpAppAndResume(tester, schedule: 'manual');
        expect(fake.checkForUpdateIfDueCallCount, 0);
      },
    );

    testWidgets(
      'checks for an update on resume when the schedule is weekly and 7+ '
      'days have elapsed since the last check',
      (tester) async {
        final eightDaysAgo = DateTime.now()
            .subtract(const Duration(days: 8))
            .toIso8601String();
        final fake = await _pumpAppAndResume(
          tester,
          schedule: 'weekly',
          lastCheckedAt: eightDaysAgo,
        );
        expect(fake.checkForUpdateIfDueCallCount, 1);
      },
    );

    testWidgets(
      'does not check on resume when the schedule is weekly and fewer than '
      '7 days have elapsed',
      (tester) async {
        final oneDayAgo = DateTime.now()
            .subtract(const Duration(days: 1))
            .toIso8601String();
        final fake = await _pumpAppAndResume(
          tester,
          schedule: 'weekly',
          lastCheckedAt: oneDayAgo,
        );
        expect(fake.checkForUpdateIfDueCallCount, 0);
      },
    );

    testWidgets(
      'checks for an update on resume when the schedule is monthly and 30+ '
      'days have elapsed',
      (tester) async {
        final thirtyOneDaysAgo = DateTime.now()
            .subtract(const Duration(days: 31))
            .toIso8601String();
        final fake = await _pumpAppAndResume(
          tester,
          schedule: 'monthly',
          lastCheckedAt: thirtyOneDaysAgo,
        );
        expect(fake.checkForUpdateIfDueCallCount, 1);
      },
    );
  });
}

// ---------------------------------------------------------------------------
// 'checkForUpdateIfDue Wi-Fi behavior' -- exercises the real
// ReferencePackNotifier against a mocked repository.
// ---------------------------------------------------------------------------

class _MockReferencePackRepository extends Mock
    implements IReferencePackRepository {}

/// Stubs [mockRepo]'s `watchStatus`/`fetchManifest`/`installedVersion`/
/// `startDeltaDownload` surface for the Wi-Fi-behavior test below.
///
/// A dedicated helper (rather than inline `when()` calls at the test call
/// site) so every `when(() => mockRepo.method())` closure -- required by
/// mocktail's `Mock.noSuchMethod` interception (a bare tearoff never
/// invokes the method, so the stub silently never registers and the real
/// unstubbed call hangs) -- lives in one place.
void _stubMockRepo(
  _MockReferencePackRepository mockRepo, {
  required String installedVersion,
  required String manifestVersion,
}) {
  when(() => mockRepo.watchStatus()).thenAnswer(
    (_) => Stream.value(
      ReferencePackFull(
        installedVersion: installedVersion,
        productCount: 2500000,
        installedAt: DateTime(2026),
      ),
    ),
  );
  when(
    () => mockRepo.fetchManifest(),
  ).thenAnswer((_) async => _buildManifest(currentVersion: manifestVersion));
  when(
    () => mockRepo.installedVersion(),
  ).thenAnswer((_) async => installedVersion);
  when(
    () => mockRepo.startDeltaDownload(
      allowCellular: any(named: 'allowCellular'),
    ),
  ).thenAnswer((_) async {});
}

void _testCheckForUpdateIfDueWifiBehavior() {
  group('checkForUpdateIfDue Wi-Fi behavior', () {
    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      registerFallbackValue(_buildManifest());
    });

    tearDown(_clearConnectivityMock);

    test(
      'a schedule check off Wi-Fi with no allowCellular override only '
      "updates the 'connect to Wi-Fi' status and never starts the "
      'multi-MB delta download',
      () async {
        final mockRepo = _MockReferencePackRepository();
        _stubMockRepo(
          mockRepo,
          installedVersion: 'v3',
          manifestVersion: 'v4',
        );

        _mockConnectivity('none');

        final container = ProviderContainer(
          overrides: [
            referencePackRepositoryProvider.overrideWithValue(mockRepo),
          ],
        );
        addTearDown(container.dispose);

        // Keeps referencePackProvider's non-keepAlive
        // referencePackStatusStreamProvider dependency alive long enough
        // for `Stream.value`'s single event to actually be delivered --
        // a bare `container.read(referencePackProvider.future)` with no
        // active listener races the autoDispose scheduler and can dispose
        // the stream provider before it ever emits (same class of
        // pitfall as [Phase 02-07]'s documented
        // `ProviderContainer.listen`-over-`pumpEventQueue` precedent).
        container.listen(referencePackProvider, (_, _) {});

        // Resolve the initial build (watches the mocked status stream).
        await container.read(referencePackProvider.future);

        final notifier = container.read(referencePackProvider.notifier);
        await notifier.checkForUpdateIfDue();

        final state = container.read(referencePackProvider).value;
        expect(state, isA<ReferencePackUpdateAvailable>());
        expect(
          (state! as ReferencePackUpdateAvailable).waitingForWifi,
          isTrue,
        );

        verifyNever(
          () => mockRepo.startDeltaDownload(
            allowCellular: any(named: 'allowCellular'),
          ),
        );
      },
    );
  });
}

void main() {
  _testIsCheckDue();
  _testLifecycleObserver();
  _testCheckForUpdateIfDueWifiBehavior();
}
