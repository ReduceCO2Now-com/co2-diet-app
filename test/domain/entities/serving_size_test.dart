import 'package:co2diet/domain/entities/serving_size.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ServingSize', () {
    test('toJson/fromJson round-trips a list of {label, grams} pairs', () {
      const sizes = [
        ServingSize(label: 'Slice', grams: 30),
        ServingSize(label: 'Cup', grams: 240),
      ];

      final encoded = ServingSize.encodeList(sizes);
      final decoded = ServingSize.decodeList(encoded);

      expect(decoded, equals(sizes));
    });

    test(
      'fromJsonList returns an empty list for null or malformed JSON '
      '(no crash)',
      () {
        expect(ServingSize.decodeList(null), isEmpty);
        expect(ServingSize.decodeList(''), isEmpty);
        expect(ServingSize.decodeList('not json'), isEmpty);
      },
    );
  });
}
