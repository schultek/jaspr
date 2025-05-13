@TestOn('vm')

import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/jaspr_test.dart';

void main() {
  group('style', () {
    group('color', () {
      test('default', () {
        var color = Color('#ffddee');
        expect(color.value, equals('#ffddee'));
      });

      test('value', () {
        var color = Color.value(0xffddee);
        expect(color.value, equals('#ffddee'));
      });

      test('rgb', () {
        var color = Color.rgb(100, 200, 10);
        expect(color.value, equals('rgb(100, 200, 10)'));
      });

      test('rgba', () {
        var color = Color.rgba(100, 200, 10, 0.5);
        expect(color.value, equals('rgba(100, 200, 10, 0.5)'));
      });

      test('hsl', () {
        var color = Color.hsl(100, 10, 20);
        expect(color.value, equals('hsl(100, 10%, 20%)'));
      });

      test('hsla', () {
        var color = Color.hsla(100, 10, 20, 0.5);
        expect(color.value, equals('hsla(100, 10%, 20%, 0.5)'));
      });
    });
  });
}
