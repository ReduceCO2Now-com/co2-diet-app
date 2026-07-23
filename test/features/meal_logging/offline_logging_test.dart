import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'Offline core logging',
    skip: 'offline logging path not yet verifiable',
    () {
      test(
        'logFood, editEntry, deleteEntry, duplicateEntry never call '
        'OffApiClient or Connectivity check',
        () {},
      );
    },
  );
}
