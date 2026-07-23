import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'ServingSize',
    skip: 'ServingSize entity not yet implemented',
    () {
      test(
        'toJson/fromJson round-trips a list of {label, grams} pairs',
        () {},
      );

      test(
        'fromJsonList returns an empty list for null or malformed JSON '
        '(no crash)',
        () {},
      );
    },
  );
}
