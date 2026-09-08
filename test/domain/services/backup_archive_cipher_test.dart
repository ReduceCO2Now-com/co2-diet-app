// Tests for BackupArchiveCipher (AUTH-09 / 08-01).
//
// Covers:
// - deriveKey determinism (same passphrase+salt -> identical key) and
//   salt-sensitivity (different salt -> different key).
// - encrypt -> decrypt round trip recovers the original plaintext exactly.
// - encrypt()'s output length is plaintext.length + 16 (the GCM tag is
//   actually appended -- guards PointyCastle's ChaCha20-Poly1305 trap,
//   08-RESEARCH.md Pitfall 2, by asserting on AES-GCM's own output shape).
// - decrypt() throws on a wrong key, a tampered ciphertext byte, a
//   tampered tag byte, or mismatched associated data.
// - randomBytes() is a live CSPRNG, not a fixed/predictable source.
// - Two independent encrypt() calls over identical plaintext, each with
//   fresh salt/nonce, produce different keys, nonces, and ciphertext.
//
// Most tests use a reduced Argon2id profile (memory: 8 KiB, iterations: 1)
// to stay well under the 30s sampling budget (08-VALIDATION.md: "Argon2id
// at 19 MiB is ~150ms/derivation -- keep full-KDF test count small"). One
// test uses the real OWASP profile to catch a parameter-plumbing
// regression without paying the full cost repeatedly.

import 'dart:typed_data';

import 'package:co2diet/domain/services/backup_archive_cipher.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointycastle/export.dart';

void main() {
  late BackupArchiveCipher cipher;

  setUp(() {
    cipher = const BackupArchiveCipher();
  });

  group('deriveKey', () {
    test(
      'is deterministic: same passphrase+salt produces an identical '
      '32-byte key across two calls',
      () {
        final salt = Uint8List.fromList(List.generate(16, (i) => i));

        final key1 = cipher.deriveKey(
          'correct horse battery staple',
          salt,
          memoryKiB: 8,
          iterations: 1,
        );
        final key2 = cipher.deriveKey(
          'correct horse battery staple',
          salt,
          memoryKiB: 8,
          iterations: 1,
        );

        expect(key1, hasLength(32));
        expect(key1, equals(key2));
      },
    );

    test(
      'the same passphrase with a different salt produces a different key',
      () {
        final saltA = Uint8List.fromList(List.generate(16, (i) => i));
        final saltB = Uint8List.fromList(List.generate(16, (i) => i + 1));

        final keyA = cipher.deriveKey(
          'same passphrase',
          saltA,
          memoryKiB: 8,
          iterations: 1,
        );
        final keyB = cipher.deriveKey(
          'same passphrase',
          saltB,
          memoryKiB: 8,
          iterations: 1,
        );

        expect(keyA, isNot(equals(keyB)));
      },
    );

    test(
      'at the real OWASP profile (19456 KiB / t=2 / p=1) still derives a '
      'valid 32-byte key -- catches a parameter-plumbing regression '
      'without paying the full KDF cost in every other test',
      () {
        final salt = Uint8List.fromList(List.generate(16, (i) => i));
        final key = cipher.deriveKey('a real passphrase, at cost', salt);
        expect(key, hasLength(32));
      },
    );
  });

  group('encrypt / decrypt', () {
    late Uint8List key;
    late Uint8List nonce;
    late Uint8List associatedData;

    setUp(() {
      key = cipher.deriveKey(
        'test passphrase',
        Uint8List.fromList(List.generate(16, (i) => i)),
        memoryKiB: 8,
        iterations: 1,
      );
      nonce = Uint8List.fromList(List.generate(12, (i) => i + 100));
      associatedData = Uint8List.fromList('manifest-bytes'.codeUnits);
    });

    test(
      'encrypt() then decrypt() with the same key/nonce/associatedData '
      'recovers the original plaintext bytes exactly',
      () {
        final plaintext = Uint8List.fromList(
          List.generate(500, (i) => i % 256),
        );

        final ciphertext = cipher.encrypt(
          plaintext: plaintext,
          key: key,
          nonce: nonce,
          associatedData: associatedData,
        );
        final decrypted = cipher.decrypt(
          ciphertext: ciphertext,
          key: key,
          nonce: nonce,
          associatedData: associatedData,
        );

        expect(decrypted, equals(plaintext));
      },
    );

    test(
      "encrypt()'s output length equals plaintext.length + 16 -- the GCM "
      'tag is actually appended, guarding the exact PointyCastle '
      'ChaCha20-Poly1305 trap (08-RESEARCH.md Pitfall 2) by asserting on '
      "AES-GCM's own output shape",
      () {
        final plaintext = Uint8List.fromList(List.generate(42, (i) => i));

        final ciphertext = cipher.encrypt(
          plaintext: plaintext,
          key: key,
          nonce: nonce,
          associatedData: associatedData,
        );

        expect(ciphertext.length, plaintext.length + 16);
      },
    );

    test('decrypt() with a wrong key throws InvalidCipherTextException', () {
      final plaintext = Uint8List.fromList(List.generate(50, (i) => i));
      final ciphertext = cipher.encrypt(
        plaintext: plaintext,
        key: key,
        nonce: nonce,
        associatedData: associatedData,
      );

      final wrongKey = cipher.deriveKey(
        'a different passphrase entirely',
        Uint8List.fromList(List.generate(16, (i) => i)),
        memoryKiB: 8,
        iterations: 1,
      );

      expect(
        () => cipher.decrypt(
          ciphertext: ciphertext,
          key: wrongKey,
          nonce: nonce,
          associatedData: associatedData,
        ),
        throwsA(isA<InvalidCipherTextException>()),
      );
    });

    test(
      'decrypt() with a tampered ciphertext byte throws '
      'InvalidCipherTextException',
      () {
        final plaintext = Uint8List.fromList(List.generate(50, (i) => i));
        final ciphertext = cipher.encrypt(
          plaintext: plaintext,
          key: key,
          nonce: nonce,
          associatedData: associatedData,
        );

        final tampered = Uint8List.fromList(ciphertext);
        tampered[0] = tampered[0] ^ 0xFF;

        expect(
          () => cipher.decrypt(
            ciphertext: tampered,
            key: key,
            nonce: nonce,
            associatedData: associatedData,
          ),
          throwsA(isA<InvalidCipherTextException>()),
        );
      },
    );

    test(
      'decrypt() with a tampered final tag byte throws '
      'InvalidCipherTextException',
      () {
        final plaintext = Uint8List.fromList(List.generate(50, (i) => i));
        final ciphertext = cipher.encrypt(
          plaintext: plaintext,
          key: key,
          nonce: nonce,
          associatedData: associatedData,
        );

        final tampered = Uint8List.fromList(ciphertext);
        tampered[tampered.length - 1] = tampered[tampered.length - 1] ^ 0xFF;

        expect(
          () => cipher.decrypt(
            ciphertext: tampered,
            key: key,
            nonce: nonce,
            associatedData: associatedData,
          ),
          throwsA(isA<InvalidCipherTextException>()),
        );
      },
    );

    test(
      'decrypt() with different associatedData than was used to encrypt '
      'throws InvalidCipherTextException -- proves the manifest is bound, '
      'not just the payload',
      () {
        final plaintext = Uint8List.fromList(List.generate(50, (i) => i));
        final ciphertext = cipher.encrypt(
          plaintext: plaintext,
          key: key,
          nonce: nonce,
          associatedData: associatedData,
        );

        final differentAad = Uint8List.fromList(
          'a-different-manifest'.codeUnits,
        );

        expect(
          () => cipher.decrypt(
            ciphertext: ciphertext,
            key: key,
            nonce: nonce,
            associatedData: differentAad,
          ),
          throwsA(isA<InvalidCipherTextException>()),
        );
      },
    );
  });

  group('randomBytes', () {
    test(
      'two successive randomBytes(16) calls return different byte '
      'sequences -- Random.secure() is live, not a fixed/predictable '
      'source',
      () {
        final a = cipher.randomBytes(16);
        final b = cipher.randomBytes(16);

        expect(a, hasLength(16));
        expect(b, hasLength(16));
        expect(a, isNot(equals(b)));
      },
    );
  });

  group('two independent encrypt() calls over identical plaintext', () {
    test(
      'each with its own freshly-generated salt/nonce, produce different '
      'derived keys, different nonces, and different ciphertext',
      () {
        final plaintext = Uint8List.fromList(
          List.generate(200, (i) => i % 256),
        );
        const passphrase = 'same passphrase, two archives';

        final saltA = cipher.randomBytes(16);
        final nonceA = cipher.randomBytes(12);
        final keyA = cipher.deriveKey(
          passphrase,
          saltA,
          memoryKiB: 8,
          iterations: 1,
        );
        final aadA = Uint8List.fromList('manifest-A'.codeUnits);
        final ciphertextA = cipher.encrypt(
          plaintext: plaintext,
          key: keyA,
          nonce: nonceA,
          associatedData: aadA,
        );

        final saltB = cipher.randomBytes(16);
        final nonceB = cipher.randomBytes(12);
        final keyB = cipher.deriveKey(
          passphrase,
          saltB,
          memoryKiB: 8,
          iterations: 1,
        );
        final aadB = Uint8List.fromList('manifest-B'.codeUnits);
        final ciphertextB = cipher.encrypt(
          plaintext: plaintext,
          key: keyB,
          nonce: nonceB,
          associatedData: aadB,
        );

        expect(saltA, isNot(equals(saltB)));
        expect(nonceA, isNot(equals(nonceB)));
        expect(keyA, isNot(equals(keyB)));
        expect(ciphertextA, isNot(equals(ciphertextB)));
      },
    );
  });
}
