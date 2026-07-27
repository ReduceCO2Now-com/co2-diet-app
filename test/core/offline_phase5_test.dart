import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'Phase 5 offline proof',
    skip: 'Phase 5 code paths not yet implemented',
    () {
      test(
        'DailyTotalsCalculator, PersonalCo2MultiplierCalculator, '
        'NotificationService, BackupExportService never call '
        'OffApiClient or Connectivity',
        () {},
      );
    },
  );
}
