import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  // Working directory for subprocess tests — the script must be resolved
  // relative to the repo root so check_privacy_deps.dart can be found.
  final repoRoot = Directory.current.path;

  group('check_privacy_deps.dart blocklist subprocess', () {
    /// Writes a minimal valid pubspec.lock YAML to a temp file.
    ///
    /// Package name lines use exactly 2 spaces of indentation, which is what
    /// the script's RegExp expects: `^ {2}([a-z][a-z0-9_]*):$`
    File writeLock(String suffix, String content) => File(
          '${Directory.systemTemp.path}/test_pubspec_lock_$suffix.lock',
        )..writeAsStringSync(content);

    const cleanLock = '''
packages:
  drift:
    dependency: "direct main"
    description:
      name: drift
      url: "https://pub.dev"
    source: hosted
    version: "2.34.2"
  flutter_riverpod:
    dependency: "direct main"
    description:
      name: flutter_riverpod
      url: "https://pub.dev"
    source: hosted
    version: "3.3.2"
  go_router:
    dependency: "direct main"
    description:
      name: go_router
      url: "https://pub.dev"
    source: hosted
    version: "17.3.0"
  uuid:
    dependency: "direct main"
    description:
      name: uuid
      url: "https://pub.dev"
    source: hosted
    version: "4.6.0"
  freezed:
    dependency: "dev"
    description:
      name: freezed
      url: "https://pub.dev"
    source: hosted
    version: "3.2.6-dev.1"
sdks:
  dart: ">=3.12.2 <4.0.0"
''';

    const firebaseLock = '''
packages:
  drift:
    dependency: "direct main"
    description:
      name: drift
      url: "https://pub.dev"
    source: hosted
    version: "2.34.2"
  flutter_riverpod:
    dependency: "direct main"
    description:
      name: flutter_riverpod
      url: "https://pub.dev"
    source: hosted
    version: "3.3.2"
  go_router:
    dependency: "direct main"
    description:
      name: go_router
      url: "https://pub.dev"
    source: hosted
    version: "17.3.0"
  uuid:
    dependency: "direct main"
    description:
      name: uuid
      url: "https://pub.dev"
    source: hosted
    version: "4.6.0"
  firebase_core:
    dependency: "transitive"
    description:
      name: firebase_core
      url: "https://pub.dev"
    source: hosted
    version: "2.0.0"
sdks:
  dart: ">=3.12.2 <4.0.0"
''';

    const sentryLock = '''
packages:
  drift:
    dependency: "direct main"
    description:
      name: drift
      url: "https://pub.dev"
    source: hosted
    version: "2.34.2"
  flutter_riverpod:
    dependency: "direct main"
    description:
      name: flutter_riverpod
      url: "https://pub.dev"
    source: hosted
    version: "3.3.2"
  sentry_flutter:
    dependency: "transitive"
    description:
      name: sentry_flutter
      url: "https://pub.dev"
    source: hosted
    version: "7.0.0"
sdks:
  dart: ">=3.12.2 <4.0.0"
''';

    test(
        'Test 1 (exit-0): clean pubspec.lock with no blocked packages exits 0',
        () async {
      final lockFile = writeLock('clean', cleanLock);
      addTearDown(lockFile.deleteSync);

      final result = await Process.run(
        'dart',
        [
          'run',
          'scripts/check_privacy_deps.dart',
          lockFile.path,
          '.privacy-blocklist.yaml',
        ],
        workingDirectory: repoRoot,
      );
      expect(result.exitCode, equals(0),
          reason: 'Expected exit 0 for clean lock. '
              'stdout: ${result.stdout} stderr: ${result.stderr}');
    });

    test(
        'Test 2 (exit-1): pubspec.lock with firebase_core exits 1 '
        'and names the offending package', () async {
      final lockFile = writeLock('firebase', firebaseLock);
      addTearDown(lockFile.deleteSync);

      final result = await Process.run(
        'dart',
        [
          'run',
          'scripts/check_privacy_deps.dart',
          lockFile.path,
          '.privacy-blocklist.yaml',
        ],
        workingDirectory: repoRoot,
      );
      expect(result.exitCode, equals(1),
          reason: 'Expected exit 1 for firebase_core. '
              'stdout: ${result.stdout} stderr: ${result.stderr}');
      expect(result.stdout.toString(), contains('firebase_core'));
    });

    test(
        'Test 3 (exit-1): pubspec.lock with sentry_flutter exits 1 '
        'and names the offending package', () async {
      final lockFile = writeLock('sentry', sentryLock);
      addTearDown(lockFile.deleteSync);

      final result = await Process.run(
        'dart',
        [
          'run',
          'scripts/check_privacy_deps.dart',
          lockFile.path,
          '.privacy-blocklist.yaml',
        ],
        workingDirectory: repoRoot,
      );
      expect(result.exitCode, equals(1),
          reason: 'Expected exit 1 for sentry_flutter. '
              'stdout: ${result.stdout} stderr: ${result.stderr}');
      expect(result.stdout.toString(), contains('sentry_flutter'));
    });
  });
}
