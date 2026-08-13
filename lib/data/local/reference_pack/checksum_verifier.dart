import 'dart:io';

import 'package:crypto/crypto.dart';

/// Verifies a downloaded reference pack file's SHA-256 digest against the
/// value published in `manifest.json` before the file is ever trusted
/// (checksum-before-trust, 09-CONTEXT.md).
///
/// Downloaded pack files are 300-800MB, so [verify] streams the file in
/// chunks via the `crypto` package's [sha256].bind API (09-RESEARCH.md
/// Pattern 2) and never reads the whole file into memory.
class ChecksumVerifier {
  /// Creates a [ChecksumVerifier].
  const ChecksumVerifier();

  /// Returns `true` when [file]'s SHA-256 digest matches [expectedSha256Hex]
  /// (case-insensitive hex comparison).
  ///
  /// Returns `false` — never throws — when [file] does not exist or cannot
  /// be read, so callers can treat "verification failed" uniformly whether
  /// the mismatch is a bad digest or a missing/corrupted file.
  Future<bool> verify(File file, String expectedSha256Hex) async {
    try {
      final digest = await sha256.bind(file.openRead()).first;
      return digest.toString().toLowerCase() ==
          expectedSha256Hex.toLowerCase();
    } on FileSystemException {
      return false;
    }
  }
}
