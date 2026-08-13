import 'dart:convert';
import 'dart:io';

import 'package:co2diet/data/local/reference_pack/checksum_verifier.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChecksumVerifier', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('checksum_verifier_');
    });

    tearDown(() async {
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test(
      "verify returns true when the file's SHA-256 matches the "
      'expected hex digest',
      () async {
        final file = File('${tempDir.path}/pack.bin')
          ..writeAsBytesSync(utf8.encode('reference pack contents'));
        final expected = sha256.convert(await file.readAsBytes()).toString();

        final result = await const ChecksumVerifier().verify(file, expected);

        expect(result, isTrue);
      },
    );

    test(
      "verify returns false when the file's SHA-256 does not match",
      () async {
        final file = File('${tempDir.path}/pack.bin')
          ..writeAsBytesSync(utf8.encode('reference pack contents'));

        final result = await const ChecksumVerifier().verify(
          file,
          '0' * 64,
        );

        expect(result, isFalse);
      },
    );

    test(
      'verify returns false (does not throw) when the target file '
      'does not exist',
      () async {
        final file = File('${tempDir.path}/does_not_exist.bin');

        final result = await const ChecksumVerifier().verify(
          file,
          '0' * 64,
        );

        expect(result, isFalse);
      },
    );
  });
}
