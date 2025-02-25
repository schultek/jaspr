@TestOn('vm')

import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/jaspr_test.dart';

void main() {
  group('style', () {
    group('unit', () {
      test('extensions on num', () {
        expect(100.px, equals(Unit.pixels(100)));
        expect(100.pt, equals(Unit.points(100)));
        expect(100.percent, equals(Unit.percent(100)));
        expect(100.em, equals(Unit.em(100)));
        expect(100.rem, equals(Unit.rem(100)));
      });

      test('compares equal', () {
        expect(Unit.zero, equals(0.px));
        expect(0.px, equals(Unit.zero));
        expect(0.px, equals(0.pt));
        expect(0.px, isNot(equals(1.px)));

        expect(Unit.zero.hashCode, equals(0.px.hashCode));
        expect(0.px.hashCode, equals(Unit.zero.hashCode));
        expect(0.px.hashCode, equals(0.pt.hashCode));
        expect(0.px.hashCode, isNot(equals(1.px.hashCode)));
      });
    });

    group('angle', () {
      test('outputs style value', () {
        expect(Angle.zero.value, equals('0'));
        expect(Angle.deg(12).value, equals('12deg'));
        expect(Angle.rad(1.2).value, equals('1.2rad'));
        expect(Angle.turn(3).value, equals('3turn'));
      });

      test('extensions on num', () {
        expect(100.deg, equals(Angle.deg(100)));
        expect(100.rad, equals(Angle.rad(100)));
        expect(100.turn, equals(Angle.turn(100)));
      });

      test('compares equal', () {
        expect(Angle.zero, equals(0.deg));
        expect(0.deg, equals(Angle.zero));
        expect(0.deg, equals(0.rad));
        expect(0.deg, isNot(equals(1.rad)));

        expect(Angle.zero.hashCode, equals(0.deg.hashCode));
        expect(0.deg.hashCode, equals(Angle.zero.hashCode));
        expect(0.deg.hashCode, equals(0.rad.hashCode));
        expect(0.deg.hashCode, isNot(equals(1.rad.hashCode)));
      });
    });

    group('spacing', () {
      test('base', () {
        var insets = Spacing.inherit;

        expect(insets.styles, equals({'': 'inherit'}));

        expect(insets.left, equals(0.px));
        expect(insets.top, equals(0.px));
        expect(insets.right, equals(0.px));
        expect(insets.bottom, equals(0.px));
      });

      test('from ltrm', () {
        var insets = Spacing.fromLTRB(10.px, 20.px, 30.px, 40.px);

        expect(insets.left, equals(10.px));
        expect(insets.top, equals(20.px));
        expect(insets.right, equals(30.px));
        expect(insets.bottom, equals(40.px));

        expect(insets.styles, equals({'': '20px 30px 40px 10px'}));
      });

      test('only', () {
        var insets = Spacing.only(left: 10.px, bottom: 40.px);

        expect(insets.left, equals(10.px));
        expect(insets.top, equals(0.px));
        expect(insets.right, equals(0.px));
        expect(insets.bottom, equals(40.px));

        expect(insets.styles, equals({'left': '10px', 'bottom': '40px'}));
      });

      test('all', () {
        var insets = Spacing.all(10.px);

        expect(insets.left, equals(10.px));
        expect(insets.top, equals(10.px));
        expect(insets.right, equals(10.px));
        expect(insets.bottom, equals(10.px));

        expect(insets.styles, equals({'': '10px'}));
      });

      test('symmetric', () {
        var insets = Spacing.symmetric(vertical: 10.px, horizontal: 20.px);

        expect(insets.left, equals(20.px));
        expect(insets.top, equals(10.px));
        expect(insets.right, equals(20.px));
        expect(insets.bottom, equals(10.px));

        expect(insets.styles, equals({'': '10px 20px'}));

        insets = Spacing.symmetric(vertical: 10.px);

        expect(insets.left, equals(0.px));
        expect(insets.top, equals(10.px));
        expect(insets.right, equals(0.px));
        expect(insets.bottom, equals(10.px));

        expect(insets.styles, equals({'top': '10px', 'bottom': '10px'}));
      });
    });
  });
}
