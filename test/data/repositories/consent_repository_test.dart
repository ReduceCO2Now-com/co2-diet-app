import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'ConsentRepository',
    skip: 'Awaiting Plan 06-04 implementation',
    () {
      // TODO(Plan 06-04): recordConsent writes the correct id/appVersion/
      // policyVersion/consentsGiven JSON array through a mocktail-mocked
      // ConsentRecordsDao (mirror co2_settings_repository_test.dart's
      // mocktail structure).
      test(
        'recordConsent writes id/appVersion/policyVersion/'
        'consentsGiven JSON array through ConsentRecordsDao',
        () {},
      );

      // TODO(Plan 06-04): recordConsent never mutates any other DAO --
      // single-table isolation, mirroring Co2SettingsRepository's
      // verifyNoMoreInteractions pattern.
      test(
        'recordConsent never touches any other DAO (single-table '
        'isolation)',
        () {},
      );

      // TODO(Plan 06-04): watchConsents maps Drift ConsentRecord rows
      // to domain ConsentEvent entities.
      test(
        'watchConsents maps Drift ConsentRecord rows to domain '
        'ConsentEvent entities',
        () {},
      );

      // TODO(Plan 06-04): watchConsents returns an empty stream/list
      // when no consent has ever been recorded.
      test(
        'watchConsents emits an empty list when no consent has ever '
        'been recorded',
        () {},
      );
    },
  );
}
