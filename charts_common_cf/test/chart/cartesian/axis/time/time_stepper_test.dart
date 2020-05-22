// Copyright 2018 the Charts project authors. Please see the AUTHORS file
// for details.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:charts_common_cf/src/chart/cartesian/axis/time/date_time_extents.dart';
import 'package:charts_common_cf/src/chart/cartesian/axis/time/day_time_stepper.dart';
import 'package:charts_common_cf/src/chart/cartesian/axis/time/hour_time_stepper.dart';
import 'package:charts_common_cf/src/chart/cartesian/axis/time/minute_time_stepper.dart';
import 'package:charts_common_cf/src/chart/cartesian/axis/time/month_time_stepper.dart';
import 'package:charts_common_cf/src/chart/cartesian/axis/time/year_time_stepper.dart';
import 'package:test/test.dart';
import 'simple_date_time_factory.dart' show SimpleDateTimeFactory;

const EPSILON = 0.001;

void main() {
  const dateTimeFactory = SimpleDateTimeFactory();
  const millisecondsInHour = 3600 * 1000;

  setUp(() {});

  group('Day time stepper', () {
    test('get steps with 1 day increments', () {
      final stepper = DayTimeStepper(dateTimeFactory);
      final extent = DateTimeExtents(
          start: DateTime(2017, 8, 20), end: DateTime(2017, 8, 25));
      final stepIterable = stepper.getSteps(extent)..iterator.reset(1);
      final steps = stepIterable.toList();

      expect(steps.length, equals(6));
      expect(
          steps,
          equals([
            DateTime(2017, 8, 20),
            DateTime(2017, 8, 21),
            DateTime(2017, 8, 22),
            DateTime(2017, 8, 23),
            DateTime(2017, 8, 24),
            DateTime(2017, 8, 25),
          ]));
    });

    test('get steps with 5 day increments', () {
      final stepper = DayTimeStepper(dateTimeFactory);
      final extent = DateTimeExtents(
        start: DateTime(2017, 8, 10),
        end: DateTime(2017, 8, 26),
      );

      final stepIterable = stepper.getSteps(extent)..iterator.reset(5);
      final steps = stepIterable.toList();

      expect(steps.length, equals(4));
      // Note, this is because 5 day increments in a month is 1,6,11,16,21,26,31
      expect(
          steps,
          equals([
            DateTime(2017, 8, 11),
            DateTime(2017, 8, 16),
            DateTime(2017, 8, 21),
            DateTime(2017, 8, 26),
          ]));
    });

    test('step through daylight saving forward change', () {
      final stepper = DayTimeStepper(dateTimeFactory);
      // DST for PST 2017 begin on March 12
      final extent = DateTimeExtents(
        start: DateTime(2017, 3, 11),
        end: DateTime(2017, 3, 13),
      );
      final stepIterable = stepper.getSteps(extent)..iterator.reset(1);
      final steps = stepIterable.toList();

      expect(steps.length, equals(3));
      expect(
          steps,
          equals([
            DateTime(2017, 3, 11),
            DateTime(2017, 3, 12),
            DateTime(2017, 3, 13),
          ]));
    });

    test('step through daylight saving backward change', () {
      final stepper = DayTimeStepper(dateTimeFactory);
      // DST for PST 2017 end on November 5
      final extent = DateTimeExtents(
        start: DateTime(2017, 11, 4),
        end: DateTime(2017, 11, 6),
      );
      final stepIterable = stepper.getSteps(extent)..iterator.reset(1);
      final steps = stepIterable.toList();

      expect(steps.length, equals(3));
      expect(
          steps,
          equals([
            DateTime(2017, 11, 4),
            DateTime(2017, 11, 5),
            DateTime(2017, 11, 6),
          ]));
    });
  });

  group('Hour time stepper', () {
    test('gets steps in 1 hour increments', () {
      final stepper = HourTimeStepper(dateTimeFactory);
      final extent = DateTimeExtents(
        start: DateTime(2017, 8, 20, 10),
        end: DateTime(2017, 8, 20, 15),
      );
      final stepIterable = stepper.getSteps(extent)..iterator.reset(1);
      final steps = stepIterable.toList();

      expect(steps.length, equals(6));
      expect(
          steps,
          equals([
            DateTime(2017, 8, 20, 10),
            DateTime(2017, 8, 20, 11),
            DateTime(2017, 8, 20, 12),
            DateTime(2017, 8, 20, 13),
            DateTime(2017, 8, 20, 14),
            DateTime(2017, 8, 20, 15),
          ]));
    });

    test('gets steps in 4 hour increments', () {
      final stepper = HourTimeStepper(dateTimeFactory);
      final extent = DateTimeExtents(
        start: DateTime(2017, 8, 20, 10),
        end: DateTime(2017, 8, 21, 10),
      );
      final stepIterable = stepper.getSteps(extent)..iterator.reset(4);
      final steps = stepIterable.toList();

      expect(steps.length, equals(6));
      expect(
          steps,
          equals([
            DateTime(2017, 8, 20, 12),
            DateTime(2017, 8, 20, 16),
            DateTime(2017, 8, 20, 20),
            DateTime(2017, 8, 21, 0),
            DateTime(2017, 8, 21, 4),
            DateTime(2017, 8, 21, 8),
          ]));
    });

    test('step through daylight saving forward change in 1 hour increments',
        () {
      final stepper = HourTimeStepper(dateTimeFactory);
      // DST for PST 2017 begin on March 12. At 2am clocks are turned to 3am.
      final extent = DateTimeExtents(
        start: DateTime(2017, 3, 12, 0),
        end: DateTime(2017, 3, 12, 5),
      );
      final stepIterable = stepper.getSteps(extent)..iterator.reset(1);
      final steps = stepIterable.toList();

      expect(steps.length, equals(5));
      expect(
          steps,
          equals([
            DateTime(2017, 3, 12, 0),
            DateTime(2017, 3, 12, 1),
            DateTime(2017, 3, 12, 3),
            DateTime(2017, 3, 12, 4),
            DateTime(2017, 3, 12, 5),
          ]));
    });

    test('step through daylight saving backward change in 1 hour increments',
        () {
      final stepper = HourTimeStepper(dateTimeFactory);
      // DST for PST 2017 end on November 5. At 2am, clocks are turned to 1am.
      final extent = DateTimeExtents(
        start: DateTime(2017, 11, 5, 0),
        end: DateTime(2017, 11, 5, 4),
      );
      final stepIterable = stepper.getSteps(extent)..iterator.reset(1);
      final steps = stepIterable.toList();

      expect(steps.length, equals(6));
      expect(
          steps,
          equals([
            DateTime(2017, 11, 5, 0),
            DateTime(2017, 11, 5, 0)
                .add(Duration(milliseconds: millisecondsInHour)),
            DateTime(2017, 11, 5, 0)
                .add(Duration(milliseconds: millisecondsInHour * 2)),
            DateTime(2017, 11, 5, 2),
            DateTime(2017, 11, 5, 3),
            DateTime(2017, 11, 5, 4),
          ]));
    });

    test('step through daylight saving forward change in 4 hour increments',
        () {
      final stepper = HourTimeStepper(dateTimeFactory);
      // DST for PST 2017 begin on March 12. At 2am clocks are turned to 3am.
      final extent = DateTimeExtents(
        start: DateTime(2017, 3, 12, 0),
        end: DateTime(2017, 3, 13, 0),
      );
      final stepIterable = stepper.getSteps(extent)..iterator.reset(4);
      final steps = stepIterable.toList();

      expect(steps.length, equals(6));
      expect(
          steps,
          equals([
            DateTime(2017, 3, 12, 4),
            DateTime(2017, 3, 12, 8),
            DateTime(2017, 3, 12, 12),
            DateTime(2017, 3, 12, 16),
            DateTime(2017, 3, 12, 20),
            DateTime(2017, 3, 13, 0),
          ]));
    });

    test('step through daylight saving backward change in 4 hour increments',
        () {
      final stepper = HourTimeStepper(dateTimeFactory);
      // DST for PST 2017 end on November 5.
      // At 2am, clocks are turned to 1am.
      final extent = DateTimeExtents(
        start: DateTime(2017, 11, 5, 0),
        end: DateTime(2017, 11, 6, 0),
      );
      final stepIterable = stepper.getSteps(extent)..iterator.reset(4);
      final steps = stepIterable.toList();

      expect(steps.length, equals(7));
      expect(
          steps,
          equals([
            DateTime(2017, 11, 5, 0)
                .add(Duration(milliseconds: millisecondsInHour)),
            DateTime(2017, 11, 5, 4),
            DateTime(2017, 11, 5, 8),
            DateTime(2017, 11, 5, 12),
            DateTime(2017, 11, 5, 16),
            DateTime(2017, 11, 5, 20),
            DateTime(2017, 11, 6, 0),
          ]));
    });
  });

  group('Minute time stepper', () {
    test('gets steps with 5 minute increments', () {
      final stepper = MinuteTimeStepper(dateTimeFactory);
      final extent = DateTimeExtents(
        start: DateTime(2017, 8, 20, 3, 46),
        end: DateTime(2017, 8, 20, 4, 02),
      );
      final stepIterable = stepper.getSteps(extent)..iterator.reset(5);
      final steps = stepIterable.toList();

      expect(steps.length, equals(3));
      expect(
          steps,
          equals([
            DateTime(2017, 8, 20, 3, 50),
            DateTime(2017, 8, 20, 3, 55),
            DateTime(2017, 8, 20, 4),
          ]));
    });

    test('step through daylight saving forward change', () {
      final stepper = MinuteTimeStepper(dateTimeFactory);
      // DST for PST 2017 begin on March 12. At 2am clocks are turned to 3am.
      final extent = DateTimeExtents(
        start: DateTime(2017, 3, 12, 1, 40),
        end: DateTime(2017, 3, 12, 4, 02),
      );
      final stepIterable = stepper.getSteps(extent)..iterator.reset(15);
      final steps = stepIterable.toList();

      expect(steps.length, equals(6));
      expect(
          steps,
          equals([
            DateTime(2017, 3, 12, 1, 45),
            DateTime(2017, 3, 12, 3),
            DateTime(2017, 3, 12, 3, 15),
            DateTime(2017, 3, 12, 3, 30),
            DateTime(2017, 3, 12, 3, 45),
            DateTime(2017, 3, 12, 4),
          ]));
    });

    test('steps correctly after daylight saving forward change', () {
      final stepper = MinuteTimeStepper(dateTimeFactory);
      // DST for PST 2017 begin on March 12. At 2am clocks are turned to 3am.
      final extent = DateTimeExtents(
        start: DateTime(2017, 3, 12, 3, 02),
        end: DateTime(2017, 3, 12, 4, 02),
      );
      final stepIterable = stepper.getSteps(extent)..iterator.reset(30);
      final steps = stepIterable.toList();

      expect(steps.length, equals(2));
      expect(
          steps,
          equals([
            DateTime(2017, 3, 12, 3, 30),
            DateTime(2017, 3, 12, 4),
          ]));
    });

    test('step through daylight saving backward change', () {
      final stepper = MinuteTimeStepper(dateTimeFactory);
      // DST for PST 2017 end on November 5.
      // At 2am, clocks are turned to 1am.
      final extent = DateTimeExtents(
          start: DateTime(2017, 11, 5).add(Duration(hours: 1, minutes: 29)),
          end: DateTime(2017, 11, 5, 3, 02));
      final stepIterable = stepper.getSteps(extent)..iterator.reset(30);
      final steps = stepIterable.toList();

      expect(steps.length, equals(6));
      expect(
          steps,
          equals([
            // The first 1:30am
            DateTime(2017, 11, 5).add(Duration(hours: 1, minutes: 30)),
            // The 2nd 1am.
            DateTime(2017, 11, 5).add(Duration(hours: 2)),
            // The 2nd 1:30am
            DateTime(2017, 11, 5).add(Duration(hours: 2, minutes: 30)),
            // 2am
            DateTime(2017, 11, 5).add(Duration(hours: 3)),
            // 2:30am
            DateTime(2017, 11, 5).add(Duration(hours: 3, minutes: 30)),
            // 3am
            DateTime(2017, 11, 5, 3)
          ]));
    });
  });

  group('Month time stepper', () {
    test('steps crosses the year', () {
      final stepper = MonthTimeStepper(dateTimeFactory);
      final extent = DateTimeExtents(
        start: DateTime(2017, 5),
        end: DateTime(2018, 9),
      );
      final stepIterable = stepper.getSteps(extent)..iterator.reset(4);
      final steps = stepIterable.toList();

      expect(steps.length, equals(4));
      expect(
          steps,
          equals([
            DateTime(2017, 8),
            DateTime(2017, 12),
            DateTime(2018, 4),
            DateTime(2018, 8),
          ]));
    });

    test('steps within one year', () {
      final stepper = MonthTimeStepper(dateTimeFactory);
      final extent = DateTimeExtents(
        start: DateTime(2017, 1),
        end: DateTime(2017, 5),
      );
      final stepIterable = stepper.getSteps(extent)..iterator.reset(2);
      final steps = stepIterable.toList();

      expect(steps.length, equals(2));
      expect(
          steps,
          equals([
            DateTime(2017, 2),
            DateTime(2017, 4),
          ]));
    });

    test('step before would allow ticks to include last month of the year', () {
      final stepper = MonthTimeStepper(dateTimeFactory);
      final time = DateTime(2017, 10);

      expect(stepper.getStepTimeBeforeInclusive(time, 1),
          equals(DateTime(2017, 10)));

      // Months - 3, 6, 9, 12
      expect(stepper.getStepTimeBeforeInclusive(time, 3),
          equals(DateTime(2017, 9)));

      // Months - 6, 12
      expect(stepper.getStepTimeBeforeInclusive(time, 6),
          equals(DateTime(2017, 6)));
    });

    test('step before for January', () {
      final stepper = MonthTimeStepper(dateTimeFactory);
      final time = DateTime(2017, 1);

      expect(stepper.getStepTimeBeforeInclusive(time, 1),
          equals(DateTime(2017, 1)));

      // Months - 3, 6, 9, 12
      expect(stepper.getStepTimeBeforeInclusive(time, 3),
          equals(DateTime(2016, 12)));

      // Months - 6, 12
      expect(stepper.getStepTimeBeforeInclusive(time, 6),
          equals(DateTime(2016, 12)));
    });

    test('step before for December', () {
      final stepper = MonthTimeStepper(dateTimeFactory);
      final time = DateTime(2017, 12);

      expect(stepper.getStepTimeBeforeInclusive(time, 1),
          equals(DateTime(2017, 12)));

      // Months - 3, 6, 9, 12
      expect(stepper.getStepTimeBeforeInclusive(time, 3),
          equals(DateTime(2017, 12)));

      // Months - 6, 12
      expect(stepper.getStepTimeBeforeInclusive(time, 6),
          equals(DateTime(2017, 12)));
    });
  });

  group('Year stepper', () {
    test('steps in 10 year increments', () {
      final stepper = YearTimeStepper(dateTimeFactory);
      final extent = DateTimeExtents(
        start: DateTime(2017),
        end: DateTime(2042),
      );
      final stepIterable = stepper.getSteps(extent)..iterator.reset(10);
      final steps = stepIterable.toList();

      expect(steps.length, equals(3));
      expect(
          steps,
          equals([
            DateTime(2020),
            DateTime(2030),
            DateTime(2040),
          ]));
    });

    test('steps through negative year', () {
      final stepper = YearTimeStepper(dateTimeFactory);
      final extent = DateTimeExtents(
        start: DateTime(-420),
        end: DateTime(240),
      );
      final stepIterable = stepper.getSteps(extent)..iterator.reset(200);
      final steps = stepIterable.toList();

      expect(steps.length, equals(4));
      expect(
          steps,
          equals([
            DateTime(-400),
            DateTime(-200),
            DateTime(0),
            DateTime(200),
          ]));
    });
  });
}
