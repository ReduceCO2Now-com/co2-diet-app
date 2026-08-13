import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'Reference pack scheduled check',
    skip: 'Awaiting Plan 09-06 implementation',
    () {
      // TODO(Plan 09-06): does not check for an update on resume when
      // the schedule is manual.
      test(
        'does not check for an update on resume when the schedule is '
        'manual',
        () {},
      );

      // TODO(Plan 09-06): checks for an update on resume when the
      // schedule is weekly and 7+ days have elapsed since the last
      // check.
      test(
        'checks for an update on resume when the schedule is weekly '
        'and 7+ days have elapsed since the last check',
        () {},
      );

      // TODO(Plan 09-06): does not check on resume when the schedule
      // is weekly and fewer than 7 days have elapsed.
      test(
        'does not check on resume when the schedule is weekly and '
        'fewer than 7 days have elapsed',
        () {},
      );

      // TODO(Plan 09-06): checks for an update on resume when the
      // schedule is monthly and 30+ days have elapsed.
      test(
        'checks for an update on resume when the schedule is monthly '
        'and 30+ days have elapsed',
        () {},
      );

      // TODO(Plan 09-06): a schedule check off Wi-Fi with no
      // allowCellular override only updates the 'connect to Wi-Fi'
      // status and never starts the multi-MB delta download.
      test(
        'a schedule check off Wi-Fi with no allowCellular override '
        "only updates the 'connect to Wi-Fi' status and never starts "
        'the multi-MB delta download',
        () {},
      );
    },
  );
}
