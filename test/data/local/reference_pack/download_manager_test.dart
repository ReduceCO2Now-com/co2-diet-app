// Unit tests for DownloadManager's pure, directly-callable helpers only
// (replaces Plan 09-01's Wave 0 stub) -- sanitizedFilename(),
// statusFromTaskStatus(), estimateBytesDownloaded(). Deliberately does NOT
// exercise enqueueFullPack/enqueueDelta/cancel/pause/resume/hasActiveTask,
// since those call through FileDownloader()'s real platform channel
// (09-RESEARCH.md's Validation Architecture flags that class of behavior as
// manual/real-device-only, Plan 09-08).

import 'package:background_downloader/background_downloader.dart';
import 'package:co2diet/data/local/reference_pack/download_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DownloadManager.sanitizedFilename', () {
    const manager = DownloadManager();

    test('builds a full-pack filename from a plain version string', () {
      final filename = manager.sanitizedFilename(
        '2026-09-off-pack-v3',
        isDelta: false,
      );

      expect(filename, 'full_2026-09-off-pack-v3.sqlite.gz');
    });

    test('builds a delta filename from a plain version string', () {
      final filename = manager.sanitizedFilename(
        'v2_to_v3',
        isDelta: true,
      );

      expect(filename, 'delta_v2_to_v3.sqlite');
    });

    test(
      'strips path separators from the version string for a full-pack '
      'filename, never echoing the raw untrusted string verbatim',
      () {
        final filename = manager.sanitizedFilename(
          '../../etc/passwd',
          isDelta: false,
        );

        // '.' is an allowed filename character (kept as-is); only the path
        // separator itself must never survive into the constructed name.
        expect(filename, isNot(contains('/')));
        expect(filename, 'full_.._.._etc_passwd.sqlite.gz');
      },
    );

    test(
      'strips path separators from the version string for a delta '
      'filename, never echoing the raw untrusted string verbatim',
      () {
        final filename = manager.sanitizedFilename(
          '..\\windows\\system32',
          isDelta: true,
        );

        expect(filename, isNot(contains(r'\')));
        expect(filename, 'delta_.._windows_system32.sqlite');
      },
    );

    test(
      'strips unexpected characters (spaces, quotes, semicolons) from the '
      'version string',
      () {
        final filename = manager.sanitizedFilename(
          "v1; DROP TABLE off_ref.products; --",
          isDelta: false,
        );

        expect(filename, isNot(contains(' ')));
        expect(filename, isNot(contains(';')));
        expect(filename, isNot(contains("'")));
      },
    );
  });

  group('DownloadManager.statusFromTaskStatus', () {
    test('maps every TaskStatus value to the expected status with no '
        'fallthrough to a default/unknown state', () {
      final expected = {
        TaskStatus.enqueued: ReferencePackDownloadStatus.enqueued,
        TaskStatus.running: ReferencePackDownloadStatus.running,
        TaskStatus.paused: ReferencePackDownloadStatus.paused,
        TaskStatus.complete: ReferencePackDownloadStatus.complete,
        TaskStatus.notFound: ReferencePackDownloadStatus.notFound,
        TaskStatus.failed: ReferencePackDownloadStatus.failed,
        TaskStatus.canceled: ReferencePackDownloadStatus.canceled,
        TaskStatus.waitingToRetry: ReferencePackDownloadStatus.waitingToRetry,
      };

      // Every TaskStatus.values entry must have an explicit expectation --
      // this assertion itself would fail if a future package upgrade added
      // a new TaskStatus value this test doesn't yet know about.
      expect(expected.keys.toSet(), TaskStatus.values.toSet());

      for (final entry in expected.entries) {
        expect(
          statusFromTaskStatus(entry.key),
          entry.value,
          reason: 'TaskStatus.${entry.key.name} mapped incorrectly',
        );
      }
    });
  });

  group('DownloadManager.estimateBytesDownloaded', () {
    test('returns 0 at the 0.0 progress boundary', () {
      expect(estimateBytesDownloaded(0, 681574912), 0);
    });

    test('returns the full expected size at the 1.0 progress boundary', () {
      expect(estimateBytesDownloaded(1, 681574912), 681574912);
    });

    test('returns the proportional byte count for a mid-progress fraction', () {
      expect(estimateBytesDownloaded(0.5, 1000), 500);
    });

    test('rounds to the nearest whole byte for a non-exact fraction', () {
      expect(estimateBytesDownloaded(0.333, 1000), 333);
    });
  });
}
