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

import 'dart:math';

import 'package:charts_common_cf/src/chart/cartesian/axis/axis.dart';
import 'package:charts_common_cf/src/chart/cartesian/axis/draw_strategy/base_tick_draw_strategy.dart';
import 'package:charts_common_cf/src/common/graphics_factory.dart';
import 'package:charts_common_cf/src/common/line_style.dart';
import 'package:charts_common_cf/src/common/text_style.dart';
import 'package:charts_common_cf/src/common/text_element.dart';
import 'package:charts_common_cf/src/chart/common/chart_canvas.dart';
import 'package:charts_common_cf/src/chart/common/chart_context.dart';
import 'package:charts_common_cf/src/chart/common/unitconverter/unit_converter.dart';
import 'package:charts_common_cf/src/chart/cartesian/axis/collision_report.dart';
import 'package:charts_common_cf/src/chart/cartesian/axis/numeric_scale.dart';
import 'package:charts_common_cf/src/chart/cartesian/axis/tick.dart';
import 'package:charts_common_cf/src/chart/cartesian/axis/tick_formatter.dart';
import 'package:charts_common_cf/src/chart/cartesian/axis/tick_provider.dart';
import 'package:charts_common_cf/src/chart/cartesian/axis/numeric_extents.dart';
import 'package:charts_common_cf/src/chart/cartesian/axis/numeric_tick_provider.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockNumericScale extends Mock implements NumericScale {}

/// A fake draw strategy that reports collision and alternate ticks
///
/// Reports collision when the tick count is greater than or equal to
/// [collidesAfterTickCount].
///
/// Reports alternate rendering after tick count is greater than or equal to
/// [alternateRenderingAfterTickCount].
class FakeDrawStrategy extends BaseTickDrawStrategy<num> {
  final int collidesAfterTickCount;
  final int alternateRenderingAfterTickCount;

  FakeDrawStrategy(
      this.collidesAfterTickCount, this.alternateRenderingAfterTickCount)
      : super(null, FakeGraphicsFactory());

  @override
  CollisionReport collides(List<Tick<num>> ticks, _) {
    final ticksCollide = ticks.length >= collidesAfterTickCount;
    final alternateTicksUsed = ticks.length >= alternateRenderingAfterTickCount;

    return CollisionReport(
        ticksCollide: ticksCollide,
        ticks: ticks,
        alternateTicksUsed: alternateTicksUsed);
  }

  @override
  void draw(ChartCanvas canvas, Tick<num> tick,
      {AxisOrientation orientation,
      Rectangle<int> axisBounds,
      Rectangle<int> drawAreaBounds,
      bool isFirst,
      bool isLast}) {}
}

/// A fake [GraphicsFactory] that returns [MockTextStyle] and [MockTextElement].
class FakeGraphicsFactory extends GraphicsFactory {
  @override
  TextStyle createTextPaint() => MockTextStyle();

  @override
  TextElement createTextElement(String text) => MockTextElement();

  @override
  LineStyle createLinePaint() => MockLinePaint();
}

class MockTextStyle extends Mock implements TextStyle {}

class MockTextElement extends Mock implements TextElement {}

class MockLinePaint extends Mock implements LineStyle {}

class MockChartContext extends Mock implements ChartContext {}

/// A celsius to fahrenheit converter for testing axis with unit converter.
class CelsiusToFahrenheitConverter implements UnitConverter<num, num> {
  const CelsiusToFahrenheitConverter();

  @override
  num convert(num value) => (value * 1.8) + 32.0;

  @override
  num invert(num value) => (value - 32.0) / 1.8;
}

void main() {
  FakeGraphicsFactory graphicsFactory;
  MockNumericScale scale;
  NumericTickProvider tickProvider;
  TickFormatter<num> formatter;
  ChartContext context;

  setUp(() {
    graphicsFactory = FakeGraphicsFactory();
    scale = MockNumericScale();
    tickProvider = NumericTickProvider();
    formatter = NumericTickFormatter();
    context = MockChartContext();
  });

  test('singleTickCount_choosesTicksWithSmallestStepCoveringDomain', () {
    tickProvider
      ..zeroBound = false
      ..dataIsInWholeNumbers = false
      ..setFixedTickCount(4)
      ..allowedSteps = [1.0, 2.5, 5.0];
    final drawStrategy = FakeDrawStrategy(10, 10);
    when(scale.viewportDomain).thenReturn(NumericExtents(10.0, 70.0));
    when(scale.rangeWidth).thenReturn(1000);

    final ticks = tickProvider.getTicks(
        context: context,
        graphicsFactory: graphicsFactory,
        scale: scale,
        formatter: formatter,
        formatterValueCache: <num, String>{},
        tickDrawStrategy: drawStrategy,
        orientation: null);

    expect(ticks, hasLength(4));
    expect(ticks[0].value, equals(0));
    expect(ticks[1].value, equals(25));
    expect(ticks[2].value, equals(50));
    expect(ticks[3].value, equals(75));
  });

  test(
      'tickCountRangeChoosesTicksWithMostTicksAndSmallestIntervalCoveringDomain',
      () {
    tickProvider
      ..zeroBound = false
      ..dataIsInWholeNumbers = false
      ..setTickCount(5, 3)
      ..allowedSteps = [1.0, 2.5, 5.0];
    final drawStrategy = FakeDrawStrategy(10, 10);
    when(scale.viewportDomain).thenReturn(NumericExtents(10.0, 80.0));
    when(scale.rangeWidth).thenReturn(1000);

    final ticks = tickProvider.getTicks(
        context: context,
        graphicsFactory: graphicsFactory,
        scale: scale,
        formatter: formatter,
        formatterValueCache: <num, String>{},
        tickDrawStrategy: drawStrategy,
        orientation: null);

    expect(ticks, hasLength(5));
    expect(ticks[0].value, equals(0));
    expect(ticks[1].value, equals(25));
    expect(ticks[2].value, equals(50));
    expect(ticks[3].value, equals(75));
    expect(ticks[4].value, equals(100));
  });

  test('choosesNonAlternateRenderingTicksEvenIfIntervalIsLarger', () {
    tickProvider
      ..zeroBound = false
      ..dataIsInWholeNumbers = false
      ..setTickCount(5, 3)
      ..allowedSteps = [1.0, 2.5, 6.0];
    final drawStrategy = FakeDrawStrategy(10, 5);
    when(scale.viewportDomain).thenReturn(NumericExtents(10.0, 80.0));
    when(scale.rangeWidth).thenReturn(1000);

    final ticks = tickProvider.getTicks(
        context: context,
        graphicsFactory: graphicsFactory,
        scale: scale,
        formatter: formatter,
        formatterValueCache: <num, String>{},
        tickDrawStrategy: drawStrategy,
        orientation: null);

    expect(ticks, hasLength(3));
    expect(ticks[0].value, equals(0));
    expect(ticks[1].value, equals(60));
    expect(ticks[2].value, equals(120));
  });

  test('choosesNonCollidingTicksEvenIfIntervalIsLarger', () {
    tickProvider
      ..zeroBound = false
      ..dataIsInWholeNumbers = false
      ..setTickCount(5, 3)
      ..allowedSteps = [1.0, 2.5, 6.0];
    final drawStrategy = FakeDrawStrategy(5, 5);
    when(scale.viewportDomain).thenReturn(NumericExtents(10.0, 80.0));
    when(scale.rangeWidth).thenReturn(1000);

    final ticks = tickProvider.getTicks(
        context: context,
        graphicsFactory: graphicsFactory,
        scale: scale,
        formatter: formatter,
        formatterValueCache: <num, String>{},
        tickDrawStrategy: drawStrategy,
        orientation: null);

    expect(ticks, hasLength(3));
    expect(ticks[0].value, equals(0));
    expect(ticks[1].value, equals(60));
    expect(ticks[2].value, equals(120));
  });

  test('zeroBound_alwaysReturnsZeroTick', () {
    tickProvider
      ..zeroBound = true
      ..dataIsInWholeNumbers = false
      ..setFixedTickCount(3)
      ..allowedSteps = [1.0, 2.5, 5.0];
    final drawStrategy = FakeDrawStrategy(10, 10);
    when(scale.viewportDomain).thenReturn(NumericExtents(55.0, 135.0));
    when(scale.rangeWidth).thenReturn(1000);

    final ticks = tickProvider.getTicks(
        context: context,
        graphicsFactory: graphicsFactory,
        scale: scale,
        formatter: formatter,
        formatterValueCache: <num, String>{},
        tickDrawStrategy: drawStrategy,
        orientation: null);

    final tickValues = ticks.map((tick) => tick.value).toList();

    expect(tickValues, contains(0.0));
  });

  test('boundsCrossOrigin_alwaysReturnsZeroTick', () {
    tickProvider
      ..zeroBound = false
      ..dataIsInWholeNumbers = false
      ..setFixedTickCount(3)
      ..allowedSteps = [1.0, 2.5, 5.0];
    final drawStrategy = FakeDrawStrategy(10, 10);
    when(scale.viewportDomain).thenReturn(NumericExtents(-55.0, 135.0));
    when(scale.rangeWidth).thenReturn(1000);

    final ticks = tickProvider.getTicks(
        context: context,
        graphicsFactory: graphicsFactory,
        scale: scale,
        formatter: formatter,
        formatterValueCache: <num, String>{},
        tickDrawStrategy: drawStrategy,
        orientation: null);

    final tickValues = ticks.map((tick) => tick.value).toList();

    expect(tickValues, contains(0.0));
  });

  test('boundsCrossOrigin_returnsValidTickRange', () {
    final drawStrategy = FakeDrawStrategy(10, 10);
    when(scale.viewportDomain).thenReturn(NumericExtents(-55.0, 135.0));
    when(scale.rangeWidth).thenReturn(1000);

    final ticks = tickProvider.getTicks(
        context: context,
        graphicsFactory: graphicsFactory,
        scale: scale,
        formatter: formatter,
        formatterValueCache: <num, String>{},
        tickDrawStrategy: drawStrategy,
        orientation: null);

    final tickValues = ticks.map((tick) => tick.value).toList();

    // We expect to see a range of ticks that crosses zero.
    expect(tickValues,
        equals([-60.0, -30.0, 0.0, 30.0, 60.0, 90.0, 120.0, 150.0]));
  });

  test('dataIsWholeNumbers_returnsWholeNumberTicks', () {
    tickProvider
      ..zeroBound = false
      ..dataIsInWholeNumbers = true
      ..setFixedTickCount(3)
      ..allowedSteps = [1.0, 2.5, 5.0];
    final drawStrategy = FakeDrawStrategy(10, 10);

    when(scale.viewportDomain).thenReturn(NumericExtents(0.25, 0.75));
    when(scale.rangeWidth).thenReturn(1000);

    final ticks = tickProvider.getTicks(
        context: context,
        graphicsFactory: graphicsFactory,
        scale: scale,
        formatter: formatter,
        formatterValueCache: <num, String>{},
        tickDrawStrategy: drawStrategy,
        orientation: null);

    expect(ticks[0].value, equals(0));
    expect(ticks[1].value, equals(1));
    expect(ticks[2].value, equals(2));
  });

  test('choosesTicksBasedOnPreferredAxisUnits', () {
    tickProvider
      ..zeroBound = true
      ..dataIsInWholeNumbers = false
      ..setFixedTickCount(3)
      ..allowedSteps = [5.0]
      ..dataToAxisUnitConverter = const CelsiusToFahrenheitConverter();

    final drawStrategy = FakeDrawStrategy(10, 10);

    when(scale.viewportDomain).thenReturn(NumericExtents(0.0, 20.0));
    when(scale.rangeWidth).thenReturn(1000);

    final ticks = tickProvider.getTicks(
        context: context,
        graphicsFactory: graphicsFactory,
        scale: scale,
        formatter: formatter,
        formatterValueCache: <num, String>{},
        tickDrawStrategy: drawStrategy,
        orientation: null);

    expect(ticks[0].value, closeTo(-17.8, 0.1)); // 0 in axis units
    expect(ticks[1].value, closeTo(10, 0.1)); // 50 in axis units
    expect(ticks[2].value, closeTo(37.8, 0.1)); // 100 in axis units
  });

  test('handlesVerySmallMeasures', () {
    tickProvider
      ..zeroBound = true
      ..dataIsInWholeNumbers = false
      ..setFixedTickCount(5);

    final drawStrategy = FakeDrawStrategy(10, 10);

    when(scale.viewportDomain).thenReturn(NumericExtents(0.000001, 0.000002));
    when(scale.rangeWidth).thenReturn(1000);

    final ticks = tickProvider.getTicks(
        context: context,
        graphicsFactory: graphicsFactory,
        scale: scale,
        formatter: formatter,
        formatterValueCache: <num, String>{},
        tickDrawStrategy: drawStrategy,
        orientation: null);

    expect(ticks.length, equals(5));
    expect(ticks[0].value, equals(0));
    expect(ticks[1].value, equals(0.0000005));
    expect(ticks[2].value, equals(0.0000010));
    expect(ticks[3].value, equals(0.0000015));
    expect(ticks[4].value, equals(0.000002));
  });

  test('handlesVerySmallMeasuresForWholeNumbers', () {
    tickProvider
      ..zeroBound = true
      ..dataIsInWholeNumbers = true
      ..setFixedTickCount(5);

    final drawStrategy = FakeDrawStrategy(10, 10);

    when(scale.viewportDomain).thenReturn(NumericExtents(0.000001, 0.000002));
    when(scale.rangeWidth).thenReturn(1000);

    final ticks = tickProvider.getTicks(
        context: context,
        graphicsFactory: graphicsFactory,
        scale: scale,
        formatter: formatter,
        formatterValueCache: <num, String>{},
        tickDrawStrategy: drawStrategy,
        orientation: null);

    expect(ticks.length, equals(5));
    expect(ticks[0].value, equals(0));
    expect(ticks[1].value, equals(1));
    expect(ticks[2].value, equals(2));
    expect(ticks[3].value, equals(3));
    expect(ticks[4].value, equals(4));
  });

  test('handlesVerySmallMeasuresForWholeNumbersWithoutZero', () {
    tickProvider
      ..zeroBound = false
      ..dataIsInWholeNumbers = true
      ..setFixedTickCount(5);

    final drawStrategy = FakeDrawStrategy(10, 10);

    when(scale.viewportDomain)
        .thenReturn(NumericExtents(101.000001, 101.000002));
    when(scale.rangeWidth).thenReturn(1000);

    final ticks = tickProvider.getTicks(
        context: context,
        graphicsFactory: graphicsFactory,
        scale: scale,
        formatter: formatter,
        formatterValueCache: <num, String>{},
        tickDrawStrategy: drawStrategy,
        orientation: null);

    expect(ticks.length, equals(5));
    expect(ticks[0].value, equals(101));
    expect(ticks[1].value, equals(102));
    expect(ticks[2].value, equals(103));
    expect(ticks[3].value, equals(104));
    expect(ticks[4].value, equals(105));
  });

  test('handles tick hint for non zero ticks', () {
    final drawStrategy = FakeDrawStrategy(10, 10);
    when(scale.viewportDomain).thenReturn(NumericExtents(20.0, 35.0));
    when(scale.rangeWidth).thenReturn(1000);

    // Step Size: 3,
    // Previous start tick: 10
    // Previous window: 10 - 25
    // Previous ticks: 10, 13, 16, 19, 22, 25
    final tickHint = TickHint(10, 25, tickCount: 6);

    final ticks = tickProvider.getTicks(
      context: context,
      graphicsFactory: graphicsFactory,
      scale: scale,
      formatter: formatter,
      formatterValueCache: <num, String>{},
      tickDrawStrategy: drawStrategy,
      orientation: null,
      tickHint: tickHint,
    );

    // adjusted ticks for window 20 - 35
    // Should have ticks 22, 25, 28, 31, 34, 37
    expect(ticks, hasLength(6));
    expect(ticks[0].value, equals(22));
    expect(ticks[1].value, equals(25));
    expect(ticks[2].value, equals(28));
    expect(ticks[3].value, equals(31));
    expect(ticks[4].value, equals(34));
    expect(ticks[5].value, equals(37));
  });

  test('handles tick hint for negative starting ticks', () {
    final drawStrategy = FakeDrawStrategy(10, 10);
    when(scale.viewportDomain).thenReturn(NumericExtents(-35.0, -20.0));
    when(scale.rangeWidth).thenReturn(1000);

    // Step Size: 3,
    // Previous start tick: -25
    // Previous window: -25 to -10
    // Previous ticks: -25, -22, -19, -16, -13, -10
    final tickHint = TickHint(-25, -10, tickCount: 6);

    final ticks = tickProvider.getTicks(
      context: context,
      graphicsFactory: graphicsFactory,
      scale: scale,
      formatter: formatter,
      formatterValueCache: <num, String>{},
      tickDrawStrategy: drawStrategy,
      orientation: null,
      tickHint: tickHint,
    );

    // adjusted ticks for window -35 to -20
    // Should have ticks -34, -31, -28, -25, -22, -19
    expect(ticks, hasLength(6));
    expect(ticks[0].value, equals(-34));
    expect(ticks[1].value, equals(-31));
    expect(ticks[2].value, equals(-28));
    expect(ticks[3].value, equals(-25));
    expect(ticks[4].value, equals(-22));
    expect(ticks[5].value, equals(-19));
  });

  test('handles NaN to NaN', () {
    tickProvider
      ..zeroBound = false
      ..dataIsInWholeNumbers = true
      ..setFixedTickCount(5);

    final drawStrategy = FakeDrawStrategy(10, 10);

    when(scale.viewportDomain)
        .thenReturn(NumericExtents(1.0, double.nan));
    when(scale.rangeWidth).thenReturn(1000);

    final ticks = tickProvider.getTicks(
        context: context,
        graphicsFactory: graphicsFactory,
        scale: scale,
        formatter: formatter,
        formatterValueCache: <num, String>{},
        tickDrawStrategy: drawStrategy,
        orientation: null);

    final tickValues = ticks.map((tick) => tick.value).toList();

    //print('tickValues=$tickValues');
    expect(tickValues, equals([1.0, 2.0, 3.0, 4.0, 5.0]));
  });

  test('handles 1.0 to NaN', () {
    tickProvider
      ..zeroBound = false
      ..dataIsInWholeNumbers = true
      ..setFixedTickCount(5);

    final drawStrategy = FakeDrawStrategy(10, 10);

    when(scale.viewportDomain)
        .thenReturn(NumericExtents(1.0, double.nan));
    when(scale.rangeWidth).thenReturn(1000);

    final ticks = tickProvider.getTicks(
        context: context,
        graphicsFactory: graphicsFactory,
        scale: scale,
        formatter: formatter,
        formatterValueCache: <num, String>{},
        tickDrawStrategy: drawStrategy,
        orientation: null);

    final tickValues = ticks.map((tick) => tick.value).toList();

    //print('ticks=$ticks');
    expect(tickValues, equals([1.0, 2.0, 3.0, 4.0, 5.0]));
  });

  test('handles -NaN to -1', () {
    tickProvider
      ..zeroBound = false
      ..dataIsInWholeNumbers = true
      ..setFixedTickCount(5);

    final drawStrategy = FakeDrawStrategy(10, 10);

    when(scale.viewportDomain)
        .thenReturn(NumericExtents(-double.nan, 1.0));
    when(scale.rangeWidth).thenReturn(1000);

    final ticks = tickProvider.getTicks(
        context: context,
        graphicsFactory: graphicsFactory,
        scale: scale,
        formatter: formatter,
        formatterValueCache: <num, String>{},
        tickDrawStrategy: drawStrategy,
        orientation: null);

    final tickValues = ticks.map((tick) => tick.value).toList();

    // TODO(wink): -Nan to -1 looks wrong?
    //print('tickValues=$tickValues');
    expect(tickValues, equals([0.0, 1.0, 2.0, 3.0, 4.0]));
  });


  test('handles -100.0 to -1.0', () {
    tickProvider
      ..zeroBound = false
      ..dataIsInWholeNumbers = false
      ..setFixedTickCount(5);

    final drawStrategy = FakeDrawStrategy(10, 10);

    when(scale.viewportDomain)
        .thenReturn(NumericExtents(-100.0, -1.0));
    when(scale.rangeWidth).thenReturn(1000);

    final ticks = tickProvider.getTicks(
        context: context,
        graphicsFactory: graphicsFactory,
        scale: scale,
        formatter: formatter,
        formatterValueCache: <num, String>{},
        tickDrawStrategy: drawStrategy,
        orientation: null);

    final tickValues = ticks.map((tick) => tick.value).toList();

    //print('tickValues=$tickValues');
    expect(tickValues, equals([-100.0, -75.0, -50.0, -25.0, 0.0]));
  });

  test('handles -1e18 to 0.0', () {
    tickProvider
      ..zeroBound = false
      ..dataIsInWholeNumbers = false
      ..setFixedTickCount(5);

    final drawStrategy = FakeDrawStrategy(10, 10);
    when(scale.viewportDomain).thenReturn(NumericExtents(-1e18, 0.0));
    when(scale.rangeWidth).thenReturn(1000);

    final ticks = tickProvider.getTicks(
        context: context,
        graphicsFactory: graphicsFactory,
        scale: scale,
        formatter: formatter,
        formatterValueCache: <num, String>{},
        tickDrawStrategy: drawStrategy,
        orientation: null);

    final tickValues = ticks.map((tick) => tick.value).toList();

    expect(tickValues,
        equals([
              -1000000000000000000.0,
              -750000000000000000.0,
              -500000000000000000.0,
              -250000000000000000.0,
              0.0  ]));
  });

  test('handles -1e19 to 0.0', () {
    tickProvider
      ..zeroBound = false
      ..dataIsInWholeNumbers = false
      ..setFixedTickCount(5);

    final drawStrategy = FakeDrawStrategy(10, 10);
    when(scale.viewportDomain).thenReturn(NumericExtents(-1e19, 0));
    when(scale.rangeWidth).thenReturn(1000);

    final ticks = tickProvider.getTicks(
        context: context,
        graphicsFactory: graphicsFactory,
        scale: scale,
        formatter: formatter,
        formatterValueCache: <num, String>{},
        tickDrawStrategy: drawStrategy,
        orientation: null);

    final tickValues = ticks.map((tick) => tick.value).toList();

    // TODO(wink): -1e19 to 0.0 looks wrong?
    //print('tickValues=$tickValues');
    expect(tickValues,
        equals([-10136092888451461000.0,
              -7602069666338596000.0,
              -5068046444225731000.0,
              -2534023222112865300.0,
              0.0]));
  });

  test('handles -1e300 to 0.0', () {
    tickProvider
      ..zeroBound = false
      ..dataIsInWholeNumbers = false
      ..setFixedTickCount(5);

    final drawStrategy = FakeDrawStrategy(10, 10);
    when(scale.viewportDomain).thenReturn(NumericExtents(-1e300, 0));
    when(scale.rangeWidth).thenReturn(1000);

    final ticks = tickProvider.getTicks(
        context: context,
        graphicsFactory: graphicsFactory,
        scale: scale,
        formatter: formatter,
        formatterValueCache: <num, String>{},
        tickDrawStrategy: drawStrategy,
        orientation: null);

    final tickValues = ticks.map((tick) => tick.value).toList();

    // TODO(wink): -1e300 to 0.0 looks wrong?
    //print('tickValues=$tickValues');
    expect(tickValues,
        equals([double.negativeInfinity,
            double.negativeInfinity,
            double.negativeInfinity,
            double.negativeInfinity,
            double.negativeInfinity]));
  });

  test('handles -maxFinite to 0.0', () {
    tickProvider
      ..zeroBound = false
      ..dataIsInWholeNumbers = false
      ..setFixedTickCount(5);

    final drawStrategy = FakeDrawStrategy(10, 10);
    when(scale.viewportDomain).thenReturn(NumericExtents(-double.maxFinite, 0.0));
    when(scale.rangeWidth).thenReturn(1000);

    final ticks = tickProvider.getTicks(
        context: context,
        graphicsFactory: graphicsFactory,
        scale: scale,
        formatter: formatter,
        formatterValueCache: <num, String>{},
        tickDrawStrategy: drawStrategy,
        orientation: null);

    final tickValues = ticks.map((tick) => tick.value).toList();

    // TODO(wink): -maxFinite to 0.0 looks wrong?
    //print('tickValues=$tickValues');
    expect(tickValues,
        equals([double.negativeInfinity,
            double.negativeInfinity,
            double.negativeInfinity,
            double.negativeInfinity,
            double.negativeInfinity]));
  });

  test('handles negativeInfinity to 0.0', () {
    tickProvider
      ..zeroBound = false
      ..dataIsInWholeNumbers = false
      ..setFixedTickCount(5);

    final drawStrategy = FakeDrawStrategy(10, 10);
    when(scale.viewportDomain).thenReturn(NumericExtents(double.negativeInfinity, 0.0));
    when(scale.rangeWidth).thenReturn(1000);

    final ticks = tickProvider.getTicks(
        context: context,
        graphicsFactory: graphicsFactory,
        scale: scale,
        formatter: formatter,
        formatterValueCache: <num, String>{},
        tickDrawStrategy: drawStrategy,
        orientation: null);

    final tickValues = ticks.map((tick) => tick.value).toList();

    // TODO(wink): negativeInfinity to 0.0 looks wrong?
    //print('tickValues=$tickValues');
    expect(tickValues,
        equals([double.negativeInfinity,
            double.negativeInfinity,
            double.negativeInfinity,
            double.negativeInfinity,
            double.negativeInfinity]));
  });

  test('handles 0.0 to 1e18', () {
    tickProvider
      ..zeroBound = false
      ..dataIsInWholeNumbers = false
      ..setFixedTickCount(5);

    final drawStrategy = FakeDrawStrategy(10, 10);
    when(scale.viewportDomain).thenReturn(NumericExtents(0.0, 1e18));
    when(scale.rangeWidth).thenReturn(1000);

    final ticks = tickProvider.getTicks(
        context: context,
        graphicsFactory: graphicsFactory,
        scale: scale,
        formatter: formatter,
        formatterValueCache: <num, String>{},
        tickDrawStrategy: drawStrategy,
        orientation: null);

    final tickValues = ticks.map((tick) => tick.value).toList();

    expect(tickValues,
        equals([0.0,
              250000000000000000.0,
              500000000000000000.0,
              750000000000000000.0,
              1000000000000000000.0]));
  });

  test('handles 0.0 to 1e19', () {
    tickProvider
      ..zeroBound = false
      ..dataIsInWholeNumbers = false
      ..setFixedTickCount(5);

    final drawStrategy = FakeDrawStrategy(10, 10);
    when(scale.viewportDomain).thenReturn(NumericExtents(-1e19, 0));
    when(scale.rangeWidth).thenReturn(1000);

    final ticks = tickProvider.getTicks(
        context: context,
        graphicsFactory: graphicsFactory,
        scale: scale,
        formatter: formatter,
        formatterValueCache: <num, String>{},
        tickDrawStrategy: drawStrategy,
        orientation: null);

    final tickValues = ticks.map((tick) => tick.value).toList();

    // TODO(wink): 0.0 to 1e19 looks wrong?
    //print('tickValues=$tickValues');
    expect(tickValues,
        equals([-10136092888451461000.0,
              -7602069666338596000.0,
              -5068046444225731000.0,
              -2534023222112865300.0,
              0.0]));
  });

  test('handles 0.0 to 1e300', () {
    tickProvider
      ..zeroBound = false
      ..dataIsInWholeNumbers = false
      ..setFixedTickCount(5);

    final drawStrategy = FakeDrawStrategy(10, 10);
    when(scale.viewportDomain).thenReturn(NumericExtents(0.0, 1e300));
    when(scale.rangeWidth).thenReturn(1000);

    final ticks = tickProvider.getTicks(
        context: context,
        graphicsFactory: graphicsFactory,
        scale: scale,
        formatter: formatter,
        formatterValueCache: <num, String>{},
        tickDrawStrategy: drawStrategy,
        orientation: null);

    final tickValues = ticks.map((tick) => tick.value).toList();

    // TODO(wink): 0.0 to 1e300 looks wrong?
    //print('tickValues=$tickValues');
    expect(tickValues,
        equals([0.0, 1.0, 2.0, 3.0, 4.0]));
  });


  test('handles 0.0 to maxFinite', () {
    tickProvider
      ..zeroBound = false
      ..dataIsInWholeNumbers = false
      ..setFixedTickCount(5);

    final drawStrategy = FakeDrawStrategy(10, 10);
    when(scale.viewportDomain).thenReturn(NumericExtents(0.0, double.maxFinite));
    when(scale.rangeWidth).thenReturn(1000);

    final ticks = tickProvider.getTicks(
        context: context,
        graphicsFactory: graphicsFactory,
        scale: scale,
        formatter: formatter,
        formatterValueCache: <num, String>{},
        tickDrawStrategy: drawStrategy,
        orientation: null);

    final tickValues = ticks.map((tick) => tick.value).toList();

    // TODO(wink): 0.0 to infinity, looks wrong?
    //print('tickValues=$tickValues');
    expect(tickValues,
        equals([0.0, 1.0, 2.0, 3.0, 4.0]));
  });

  test('handles 0.0 to infinity', () {
    tickProvider
      ..zeroBound = false
      ..dataIsInWholeNumbers = false
      ..setFixedTickCount(5);

    final drawStrategy = FakeDrawStrategy(10, 10);
    when(scale.viewportDomain).thenReturn(NumericExtents(0, double.infinity));
    when(scale.rangeWidth).thenReturn(1000);

    final ticks = tickProvider.getTicks(
        context: context,
        graphicsFactory: graphicsFactory,
        scale: scale,
        formatter: formatter,
        formatterValueCache: <num, String>{},
        tickDrawStrategy: drawStrategy,
        orientation: null);

    final tickValues = ticks.map((tick) => tick.value).toList();

    // TODO(wink): 0.0 to infinity, looks wrong?
    //print('tickValues=$tickValues');
    expect(tickValues,
        equals([0.0, 1.0, 2.0, 3.0, 4.0]));
  });

  test('handles -infinity to infinity', () {
    tickProvider
      ..zeroBound = false
      ..dataIsInWholeNumbers = false
      ..setFixedTickCount(5);

    final drawStrategy = FakeDrawStrategy(10, 10);
    when(scale.viewportDomain).thenReturn(NumericExtents(double.negativeInfinity, double.infinity));
    when(scale.rangeWidth).thenReturn(1000);

    final ticks = tickProvider.getTicks(
        context: context,
        graphicsFactory: graphicsFactory,
        scale: scale,
        formatter: formatter,
        formatterValueCache: <num, String>{},
        tickDrawStrategy: drawStrategy,
        orientation: null);

    final tickValues = ticks.map((tick) => tick.value).toList();

    // TODO(wink): -infinity to +infinity looks wrong?
    //print('tickValues=$tickValues');
    expect(tickValues,
        equals([double.negativeInfinity,
            double.negativeInfinity,
            double.negativeInfinity,
            double.negativeInfinity,
            double.negativeInfinity]));
  });
}
