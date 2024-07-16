@TestOn('vm')
library;

import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/jaspr_test.dart';

void main() {
  group('style', () {
    group('color', () {
      test('hex', () {
        const color = Color.hex('#ffddee');
        expect(color.value, equals('#ffddee'));
      });

      test('value', () {
        const color = Color.value(0xffddee);
        expect(color.value, equals('#ffddee'));
      });

      test('named', () {
        const color = Color.named('red');
        expect(color.value, equals('red'));
      });

      test('rgb', () {
        const color = Color.rgb(100, 200, 10);
        expect(color.value, equals('rgb(100, 200, 10)'));
      });

      test('rgba', () {
        const color = Color.rgba(100, 200, 10, 0.5);
        expect(color.value, equals('rgba(100, 200, 10, 0.5)'));
      });

      test('hsl', () {
        const color = Color.hsl(100, 10, 20);
        expect(color.value, equals('hsl(100, 10%, 20%)'));
      });

      test('hsla', () {
        const color = Color.hsla(100, 10, 20, 0.5);
        expect(color.value, equals('hsla(100, 10%, 20%, 0.5)'));
      });
    });
  });
}
