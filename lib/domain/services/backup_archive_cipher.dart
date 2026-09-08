import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute;
import 'package:pointycastle/export.dart';

/// OWASP Password Storage Cheat Sheet's second Argon2id profile (the
/// stronger of its two recommended profiles) — memory in KiB, iterations,
/// and parallelism ("lanes").
const kArgon2MemoryKiB = 19456;

/// Argon2id iteration count (OWASP second profile).
const kArgon2Iterations = 2;

/// Argon2id parallelism / lane count (OWASP second profile).
const kArgon2Parallelism = 1;

/// Primitives-only arguments for [_deriveKeyIsolate] — the top-level
/// function [compute] runs on a background isolate.
///
/// PointyCastle's [Argon2BytesGenerator] instances cannot cross an isolate
/// boundary, so only plain data crosses here; the generator itself is
/// constructed *inside* the isolate function body (08-01 device-benchmark
/// checkpoint follow-up — see [BackupArchiveCipher.deriveKey]'s doc
/// comment).
typedef _DeriveKeyArgs = ({
  String passphrase,
  Uint8List salt,
  int memoryKiB,
  int iterations,
  int parallelism,
});

/// Runs Argon2id key derivation on whichever isolate [compute] schedules
/// this on. A top-level function (not a method) so it is a valid [compute]
/// callback, mirroring `reference_pack_extractor.dart`'s
/// `_decompressGzipFile` precedent (Phase 9, commit `01ea2c6`): accept a
/// record of primitives in, construct every non-sendable object (here, the
/// [Argon2BytesGenerator]) inside the function body, return only bytes.
Uint8List _deriveKeyIsolate(_DeriveKeyArgs args) {
  final generator = Argon2BytesGenerator()
    ..init(
      Argon2Parameters(
        Argon2Parameters.ARGON2_id,
        args.salt,
        desiredKeyLength: 32,
        iterations: args.iterations,
        memory: args.memoryKiB,
        lanes: args.parallelism,
      ),
    );
  final out = Uint8List(32);
  generator.deriveKey(
    Uint8List.fromList(utf8.encode(args.passphrase)),
    0,
    out,
    0,
  );
  return out;
}

/// Primitives-only arguments for [_gcmProcessIsolate] — see
/// [_DeriveKeyArgs]'s doc comment for why only plain data crosses the
/// isolate boundary here too ([GCMBlockCipher]/[AESEngine] instances
/// cannot).
typedef _GcmArgs = ({
  bool forEncryption,
  Uint8List data,
  Uint8List key,
  Uint8List nonce,
  Uint8List associatedData,
});

/// Runs one AES-256-GCM `process()` call (encrypt or decrypt, per
/// `_GcmArgs.forEncryption`) on whichever isolate [compute] schedules this
/// on. Top-level function for the same [compute]-callback reason as
/// [_deriveKeyIsolate]. Lets [InvalidCipherTextException] propagate
/// uncaught — `compute()`/`Isolate.run` rethrows it in the calling isolate.
Uint8List _gcmProcessIsolate(_GcmArgs args) {
  final cipher = GCMBlockCipher(AESEngine())
    ..init(
      args.forEncryption,
      AEADParameters(
        KeyParameter(args.key),
        128,
        args.nonce,
        args.associatedData,
      ),
    );
  return cipher.process(args.data);
}

/// Pure bytes-in/bytes-out Argon2id key derivation + AES-256-GCM
/// authenticated encryption for the encrypted backup archive
/// (AUTH-09 / 08-01).
///
/// Deliberately has **no** imports of `drift`, `riverpod`, or
/// `flutter/material.dart` — this mirrors `docs/ARCHITECTURE.md` §2's
/// domain-layer rule and is what makes this class trivially unit-testable.
/// `BackupExportService` is the layer that composes this with the existing
/// zip/manifest machinery and maps [InvalidCipherTextException] to a
/// domain-specific exception.
///
/// AES-256-GCM only — deliberately no ChaCha20-Poly1305 path. 08-RESEARCH.md
/// Pitfall 2 verified that PointyCastle 4.0.0's `ChaCha20Poly1305.process()`
/// silently omits the authentication tag in both directions (a correctness
/// trap, not merely a style preference), and this plan has no performance
/// need for it — realistic backup archives are 100 KB-1 MB.
///
/// **Runs on a background isolate.** A real-device benchmark (SM T733,
/// Android 14) measured `deriveKey` + `encrypt` at 916ms and `deriveKey` +
/// `decrypt` at 711ms for a 13.1 KiB archive, ~99% of which is Argon2id
/// key derivation, not the AES-GCM step. That blocks the calling isolate
/// for most of a second — long enough that a `CircularProgressIndicator`
/// on the UI isolate cannot animate, i.e. the "spinner is acceptable UX"
/// assumption does not hold on the isolate that would actually be showing
/// it. [deriveKey], [encrypt] and [decrypt] therefore each run their
/// PointyCastle work inside [compute] (a background isolate), following
/// `lib/data/local/reference_pack/reference_pack_extractor.dart`'s
/// established `compute()` pattern (Phase 9, commit `01ea2c6`, fixed the
/// same class of bug for gzip decompression). Wall-clock time does not
/// necessarily drop — `compute()` moves work off the UI thread, it doesn't
/// make Argon2id faster — but the UI thread is no longer blocked while it
/// runs.
class BackupArchiveCipher {
  /// Creates a [BackupArchiveCipher]. Stateless — safe to use as a `const`.
  const BackupArchiveCipher();

  /// Returns [length] cryptographically secure random bytes, via
  /// `dart:math`'s `Random.secure()` — backed by the platform CSPRNG
  /// (`/dev/urandom`, `arc4random`, `BCryptGenRandom`), never the
  /// predictable `Random()` (08-RESEARCH.md Pitfall 3). Cheap (no KDF/AEAD
  /// work), so this runs on the calling isolate — no [compute] needed.
  Uint8List randomBytes(int length) {
    final rnd = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(length, (_) => rnd.nextInt(256)),
    );
  }

  /// Derives a 32-byte AES-256 key from [passphrase] and [salt] via
  /// Argon2id (OWASP's second recommended profile: `m=19456 KiB, t=2,
  /// p=1`), run on a background isolate via [compute] (see this class's
  /// doc comment). Deterministic for a given (passphrase, salt) pair — the
  /// same inputs always produce the same key, but a different salt (fresh
  /// per archive) always produces a different key even for the same
  /// passphrase.
  Future<Uint8List> deriveKey(
    String passphrase,
    Uint8List salt, {
    int memoryKiB = kArgon2MemoryKiB,
    int iterations = kArgon2Iterations,
    int parallelism = kArgon2Parallelism,
  }) {
    return compute(_deriveKeyIsolate, (
      passphrase: passphrase,
      salt: salt,
      memoryKiB: memoryKiB,
      iterations: iterations,
      parallelism: parallelism,
    ));
  }

  /// Encrypts [plaintext] with AES-256-GCM under [key]/[nonce], binding
  /// [associatedData] (the exact serialized `manifest.json` bytes, per
  /// 08-RESEARCH.md Pattern 2 — never re-serialized) so any edit to the
  /// manifest fails the authentication tag check on decrypt. Run on a
  /// background isolate via [compute] (see this class's doc comment).
  ///
  /// Returns `ciphertext ‖ 16-byte tag` — the returned length is always
  /// `plaintext.length + 16`.
  Future<Uint8List> encrypt({
    required Uint8List plaintext,
    required Uint8List key,
    required Uint8List nonce,
    required Uint8List associatedData,
  }) {
    return compute(_gcmProcessIsolate, (
      forEncryption: true,
      data: plaintext,
      key: key,
      nonce: nonce,
      associatedData: associatedData,
    ));
  }

  /// Decrypts [ciphertext] (as produced by [encrypt]) with AES-256-GCM
  /// under [key]/[nonce]/[associatedData]. Run on a background isolate via
  /// [compute] (see this class's doc comment).
  ///
  /// Throws [InvalidCipherTextException] (from `package:pointycastle/
  /// export.dart`), left to propagate uncaught, on a wrong key, a
  /// tampered ciphertext byte, a tampered tag byte, or [associatedData]
  /// that doesn't match what [encrypt] was called with. `BackupExportService`
  /// (not this class) maps that into a domain-specific
  /// `WrongBackupPassphraseException`.
  Future<Uint8List> decrypt({
    required Uint8List ciphertext,
    required Uint8List key,
    required Uint8List nonce,
    required Uint8List associatedData,
  }) {
    return compute(_gcmProcessIsolate, (
      forEncryption: false,
      data: ciphertext,
      key: key,
      nonce: nonce,
      associatedData: associatedData,
    ));
  }
}
