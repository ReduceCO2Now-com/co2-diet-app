import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

/// OWASP Password Storage Cheat Sheet's second Argon2id profile (the
/// stronger of its two recommended profiles) — memory in KiB, iterations,
/// and parallelism ("lanes").
const kArgon2MemoryKiB = 19456;

/// Argon2id iteration count (OWASP second profile).
const kArgon2Iterations = 2;

/// Argon2id parallelism / lane count (OWASP second profile).
const kArgon2Parallelism = 1;

/// Pure bytes-in/bytes-out Argon2id key derivation + AES-256-GCM
/// authenticated encryption for the encrypted backup archive
/// (AUTH-09 / 08-01).
///
/// Deliberately has **no** imports of `drift`, `riverpod`, or
/// `flutter/material.dart` — this mirrors `docs/ARCHITECTURE.md` §2's
/// domain-layer rule and is what makes this class trivially unit-testable.
/// [BackupExportService] is the layer that composes this with the existing
/// zip/manifest machinery and maps [InvalidCipherTextException] to a
/// domain-specific exception.
///
/// AES-256-GCM only — deliberately no ChaCha20-Poly1305 path. 08-RESEARCH.md
/// Pitfall 2 verified that PointyCastle 4.0.0's `ChaCha20Poly1305.process()`
/// silently omits the authentication tag in both directions (a correctness
/// trap, not merely a style preference), and this plan has no performance
/// need for it — realistic backup archives are 100 KB-1 MB.
class BackupArchiveCipher {
  /// Creates a [BackupArchiveCipher]. Stateless — safe to use as a `const`.
  const BackupArchiveCipher();

  /// Returns [length] cryptographically secure random bytes, via
  /// `dart:math`'s `Random.secure()` — backed by the platform CSPRNG
  /// (`/dev/urandom`, `arc4random`, `BCryptGenRandom`), never the
  /// predictable `Random()` (08-RESEARCH.md Pitfall 3).
  Uint8List randomBytes(int length) {
    final rnd = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(length, (_) => rnd.nextInt(256)),
    );
  }

  /// Derives a 32-byte AES-256 key from [passphrase] and [salt] via
  /// Argon2id (OWASP's second recommended profile: `m=19456 KiB, t=2,
  /// p=1`). Deterministic for a given (passphrase, salt) pair — the same
  /// inputs always produce the same key, but a different salt (fresh per
  /// archive) always produces a different key even for the same
  /// passphrase.
  Uint8List deriveKey(
    String passphrase,
    Uint8List salt, {
    int memoryKiB = kArgon2MemoryKiB,
    int iterations = kArgon2Iterations,
    int parallelism = kArgon2Parallelism,
  }) {
    final generator = Argon2BytesGenerator()
      ..init(
        Argon2Parameters(
          Argon2Parameters.ARGON2_id,
          salt,
          desiredKeyLength: 32,
          iterations: iterations,
          memory: memoryKiB,
          lanes: parallelism,
          version: Argon2Parameters.ARGON2_VERSION_13,
        ),
      );
    final out = Uint8List(32);
    generator.deriveKey(Uint8List.fromList(utf8.encode(passphrase)), 0, out, 0);
    return out;
  }

  /// Encrypts [plaintext] with AES-256-GCM under [key]/[nonce], binding
  /// [associatedData] (the exact serialized `manifest.json` bytes, per
  /// 08-RESEARCH.md Pattern 2 — never re-serialized) so any edit to the
  /// manifest fails the authentication tag check on decrypt.
  ///
  /// Returns `ciphertext ‖ 16-byte tag` — the returned length is always
  /// `plaintext.length + 16`.
  Uint8List encrypt({
    required Uint8List plaintext,
    required Uint8List key,
    required Uint8List nonce,
    required Uint8List associatedData,
  }) {
    return _gcm(
      forEncryption: true,
      key: key,
      nonce: nonce,
      associatedData: associatedData,
    ).process(plaintext);
  }

  /// Decrypts [ciphertext] (as produced by [encrypt]) with AES-256-GCM
  /// under [key]/[nonce]/[associatedData].
  ///
  /// Throws [InvalidCipherTextException] (from `package:pointycastle/
  /// export.dart`), left to propagate uncaught, on a wrong key, a
  /// tampered ciphertext byte, a tampered tag byte, or [associatedData]
  /// that doesn't match what [encrypt] was called with. [BackupExportService]
  /// (not this class) maps that into a domain-specific
  /// `WrongBackupPassphraseException`.
  Uint8List decrypt({
    required Uint8List ciphertext,
    required Uint8List key,
    required Uint8List nonce,
    required Uint8List associatedData,
  }) {
    return _gcm(
      forEncryption: false,
      key: key,
      nonce: nonce,
      associatedData: associatedData,
    ).process(ciphertext);
  }

  GCMBlockCipher _gcm({
    required bool forEncryption,
    required Uint8List key,
    required Uint8List nonce,
    required Uint8List associatedData,
  }) {
    return GCMBlockCipher(AESEngine())
      ..init(
        forEncryption,
        AEADParameters(KeyParameter(key), 128, nonce, associatedData),
      );
  }
}
