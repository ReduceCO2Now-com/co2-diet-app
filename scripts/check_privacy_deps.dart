// ignore_for_file: avoid_print
import 'dart:io';

/// Audits pubspec.lock against a privacy SDK blocklist.
///
/// Usage:
///   dart run scripts/check_privacy_deps.dart <pubspec.lock> <blocklist.yaml>
///
/// Exit codes:
///   0 — no blocked packages found
///   1 — one or more blocked packages detected (prints BLOCKED: lines)
void main(List<String> args) {
  if (args.length < 2) {
    print('Usage: dart run scripts/check_privacy_deps.dart <pubspec.lock> <blocklist.yaml>');
    exit(2);
  }

  final lockfilePath = args[0];
  final blocklistPath = args[1];

  // Read files
  final lockFile = File(lockfilePath);
  if (!lockFile.existsSync()) {
    print('ERROR: pubspec.lock not found at: $lockfilePath');
    exit(2);
  }

  final blocklistFile = File(blocklistPath);
  if (!blocklistFile.existsSync()) {
    print('ERROR: blocklist not found at: $blocklistPath');
    exit(2);
  }

  final lockContent = lockFile.readAsStringSync();
  final blocklistContent = blocklistFile.readAsStringSync();

  // Parse package names from pubspec.lock.
  // pubspec.lock format has packages indented at two spaces:
  //   packages:
  //     package_name:
  //       dependency: ...
  // We look for lines with exactly two-space indent followed by a package name and colon.
  final packageNames = <String>[];
  bool inPackagesSection = false;

  for (final line in lockContent.split('\n')) {
    if (line.trim() == 'packages:') {
      inPackagesSection = true;
      continue;
    }
    if (inPackagesSection) {
      // Stop if we hit a top-level key (no leading spaces) that isn't 'packages'
      if (line.isNotEmpty && !line.startsWith(' ') && !line.startsWith('\t')) {
        inPackagesSection = false;
        continue;
      }
      // Match exactly two-space indented package name lines: "  package_name:"
      final match = RegExp(r'^ {2}([a-z][a-z0-9_]*):$').firstMatch(line);
      if (match != null) {
        packageNames.add(match.group(1)!);
      }
    }
  }

  // Parse blocked_prefixes from blocklist yaml.
  // Format:
  //   blocked_prefixes:
  //     - firebase_
  //     - sentry_
  final blockedPrefixes = <String>[];
  bool inBlockedPrefixes = false;

  for (final line in blocklistContent.split('\n')) {
    if (line.trim() == 'blocked_prefixes:') {
      inBlockedPrefixes = true;
      continue;
    }
    if (inBlockedPrefixes) {
      // Lines with a list item: "  - prefix_"
      final match = RegExp(r'^ {2}- (.+)$').firstMatch(line);
      if (match != null) {
        blockedPrefixes.add(match.group(1)!.trim());
      } else if (line.isNotEmpty && !line.startsWith(' ') && !line.startsWith('#')) {
        // Hit a new top-level key — stop
        inBlockedPrefixes = false;
      }
    }
  }

  // Check each package against blocked prefixes
  final violations = <String>[];
  for (final pkg in packageNames) {
    for (final prefix in blockedPrefixes) {
      if (pkg.startsWith(prefix)) {
        violations.add('BLOCKED: $pkg (matches prefix "$prefix")');
        break;
      }
    }
  }

  if (violations.isEmpty) {
    print('OK: ${packageNames.length} packages checked, 0 violations');
    exit(0);
  } else {
    for (final violation in violations) {
      print(violation);
    }
    exit(1);
  }
}
