@TestOn('vm')
library;

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

      group('relative', () {
        test('withOpacity', () {
          var color = Color('#ff0000');
          var relativeColor = color.withOpacity(0.5);
          expect(relativeColor.value, equals('rgb(from #ff0000 r g b / 0.5)'));
        });

        test('withOpacity relative', () {
          var color = Color('#ff0000');
          var relativeColor = color.withOpacity(-0.2, replace: false);
          expect(relativeColor.value, equals('rgb(from #ff0000 r g b / calc(alpha - 0.2))'));
        });

        test('withOpacity relative chain', () {
          var color = Color('#ff0000');
          var relativeColor = color.withOpacity(-0.2, replace: false).withOpacity(0.4, replace: false);
          expect(relativeColor.value, equals('rgb(from #ff0000 r g b / calc(alpha + 0.2))'));
        });

        test('withLightness', () {
          var color = Color('#ff0000');
          var relativeColor = color.withLightness(0.5);
          expect(relativeColor.value, equals('hsl(from #ff0000 h s 50)'));
        });

        test('withLightness relative', () {
          var color = Color('#ff0000');
          var relativeColor = color.withLightness(0.5, replace: false);
          expect(relativeColor.value, equals('hsl(from #ff0000 h s calc(l + 50))'));
        });

        test('withLightness relative chained', () {
          var color = Color('#ff0000');
          var relativeColor = color
              .withLightness(0.5, replace: false)
              .withLightness(0.2, replace: false)
              .withOpacity(-0.2, replace: false);
          expect(relativeColor.value, equals('hsl(from #ff0000 h s calc(l + 70) / calc(alpha - 0.2))'));
        });

        test('withHue', () {
          var color = Color('#ff0000');
          var relativeColor = color.withHue(50);
          expect(relativeColor.value, equals('oklch(from #ff0000 l c 50)'));
        });

        test('withHue relative', () {
          var color = Color('#ff0000');
          var relativeColor = color.withHue(50, replace: false);
          expect(relativeColor.value, equals('oklch(from #ff0000 l c calc(h + 50))'));
        });

        test('withHue relative chained', () {
          var color = Color('#ff0000');
          var relativeColor =
              color.withHue(50, replace: false).withHue(20, replace: false).withOpacity(-0.2, replace: false);
          expect(relativeColor.value, equals('oklch(from #ff0000 l c calc(h + 70) / calc(alpha - 0.2))'));
        });

        test('withValues', () {
          var color = Color('#ff00ff');
          var relativeColor = color.withValues(red: 0, green: 255);
          expect(relativeColor.value, equals('rgb(from #ff00ff 0 255 b)'));
        });

        test('withValues chain', () {
          var color = Color('#ff00ff');
          var relativeColor = color.withValues(red: 0, green: 255).withValues(red: 100).withOpacity(0.2);
          expect(relativeColor.value, equals('rgb(from #ff00ff 100 255 b / 0.2)'));
        });
      });
    });
  });
}
