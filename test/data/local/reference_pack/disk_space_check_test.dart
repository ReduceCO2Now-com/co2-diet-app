import 'package:co2diet/data/local/reference_pack/disk_space_checker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DiskSpaceChecker', () {
    test(
      'hasEnoughSpace returns true when free bytes exceed the '
      'required amount times the safety multiplier',
      () async {
        final checker = DiskSpaceChecker(
          freeBytesQuery: () async => 1000,
        );

        // (300 + 400) * 1.15 = 805 <= 1000 free bytes.
        final result = await checker.hasEnoughSpace(300, 400);

        expect(result, isTrue);
      },
    );

    test(
      'hasEnoughSpace returns false when free bytes are below the '
      'required amount',
      () async {
        final checker = DiskSpaceChecker(
          freeBytesQuery: () async => 100,
        );

        // (300 + 400) * 1.15 = 805 > 100 free bytes.
        final result = await checker.hasEnoughSpace(300, 400);

        expect(result, isFalse);
      },
    );

    test(
      "hasEnoughSpace's required-bytes calculation accounts for "
      'transient 2x disk usage during gzip decompression '
      '(09-RESEARCH.md Pitfall 4), not just the final installed '
      'footprint',
      () async {
        // Only enough free space for the decompressed footprint alone
        // (400 bytes) -- not enough once the compressed download (300
        // bytes) that must coexist on disk during decompression is
        // also accounted for. A checker that (incorrectly) sized only
        // against decompressedFinalBytes would return true here.
        final checker = DiskSpaceChecker(
          freeBytesQuery: () async => 400,
        );

        final result = await checker.hasEnoughSpace(300, 400);

        expect(result, isFalse);
      },
    );
  });
}
