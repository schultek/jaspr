@TestOn('vm')
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr_test/jaspr_test.dart';

void main() {
  group('style', () {
    group('transform', () {
      group('combine', () {
        test('basic', () {
          final transform = Transform.combine([Transform.scale(2), Transform.translate(x: 100.px)]);
          expect(transform.value, equals('scale(2) translateX(100px)'));
        });

        test('empty list not allowed', () {
          expect(
            () => Transform.combine([]).value,
            throwsA(predicate((e) => e == '[Transform.combine] cannot be empty.')),
          );
        });

        test('named not allowed in combine', () {
          expect(
            () => Transform.combine([Transform.none]).value,
            throwsA(predicate((e) => e == 'Cannot use none as a filter list item, only standalone use supported.')),
          );
        });
      });

      test('rotate', () {
        final transform = Transform.rotate(10.deg);
        expect(transform.value, equals('rotate(10deg)'));
      });

      test('rotate_axis', () {
        final transform = Transform.rotateAxis(x: 10.deg, z: 2.turn);
        expect(transform.value, equals('rotateX(10deg) rotateZ(2turn)'));
      });

      test('translate', () {
        var transform = Transform.translate(x: 10.px, y: 20.px);
        expect(transform.value, equals('translate(10px, 20px)'));

        transform = Transform.translate(x: 10.px, y: 10.px);
        expect(transform.value, equals('translate(10px, 10px)'));

        transform = Transform.translate(x: 10.px);
        expect(transform.value, equals('translateX(10px)'));
      });

      test('scale', () {
        final transform = Transform.scale(2);
        expect(transform.value, equals('scale(2)'));
      });

      test('skew', () {
        var transform = Transform.skew(x: 10.deg, y: 20.deg);
        expect(transform.value, equals('skew(10deg, 20deg)'));

        transform = Transform.skew(x: 10.deg, y: 10.deg);
        expect(transform.value, equals('skew(10deg, 10deg)'));

        transform = Transform.skew(x: 10.deg);
        expect(transform.value, equals('skewX(10deg)'));
      });

      test('matrix', () {
        final transform = Transform.matrix(1, 2, 3, 4, 5, 6);
        expect(transform.value, equals('matrix(1, 2, 3, 4, 5, 6)'));
      });

      test('perspective', () {
        final transform = Transform.perspective(100.px);
        expect(transform.value, equals('perspective(100px)'));
      });
    });
  });
}
