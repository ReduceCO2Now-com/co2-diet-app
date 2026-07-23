import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'UserFood',
    skip: 'UserFood entity not yet implemented',
    () {
      test(
        'copyWith replaces only specified fields; sentinel pattern '
        'preserves nullable fields',
        () {},
      );

      test(
        'isValid returns false when name is empty or calories is null',
        () {},
      );

      test(
        'perReferenceAmount macros scale correctly when referenceAmountG '
        'differs from 100',
        () {},
      );
    },
  );
}
