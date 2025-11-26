@TestOn('vm')
library;

import 'package:jaspr/dom.dart';
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
          var color1 = color.withOpacity(0.5);
          expect(color1.value, equals('rgb(from #ff0000 r g b / 0.5)'));

          var color2 = color.withOpacity(0.5, replace: false);
          expect(color2.value, equals('rgb(from #ff0000 r g b / calc(alpha + 0.5))'));

          var color3 = color.withOpacity(0.2).withOpacity(0.8);
          expect(color3.value, equals('rgb(from #ff0000 r g b / 0.8)'));

          var color4 = color.withOpacity(0.2, replace: false).withOpacity(0.2, replace: false);
          expect(color4.value, equals('rgb(from #ff0000 r g b / calc(alpha + 0.4))'));

          var color5 = color.withOpacity(0.2, replace: false).withOpacity(0.4);
          expect(color5.value, equals('rgb(from #ff0000 r g b / 0.4)'));

          var color6 = color.withOpacity(0.2).withOpacity(0.2, replace: false);
          expect(color6.value, equals('rgb(from #ff0000 r g b / 0.4)'));
        });

        test('withLightness', () {
          var color = Color('#ff0000');
          var color1 = color.withLightness(0.5);
          expect(color1.value, equals('hsl(from #ff0000 h s 50)'));

          var color2 = color.withLightness(0.5, replace: false);
          expect(color2.value, equals('hsl(from #ff0000 h s calc(l + 50))'));

          var color3 = color.withLightness(0.2).withLightness(0.8);
          expect(color3.value, equals('hsl(from #ff0000 h s 80)'));

          var color4 = color.withLightness(0.2, replace: false).withLightness(0.2, replace: false);
          expect(color4.value, equals('hsl(from #ff0000 h s calc(l + 40))'));

          var color5 = color.withLightness(0.2, replace: false).withLightness(0.4);
          expect(color5.value, equals('hsl(from #ff0000 h s 40)'));

          var color6 = color.withLightness(0.2).withLightness(0.2, replace: false);
          expect(color6.value, equals('hsl(from #ff0000 h s 40)'));
        });

        test('withHue', () {
          var color = Color('#ff0000');
          var color1 = color.withHue(50);
          expect(color1.value, equals('oklch(from #ff0000 l c 50)'));

          var color2 = color.withHue(50, replace: false);
          expect(color2.value, equals('oklch(from #ff0000 l c calc(h + 50))'));

          var color3 = color.withHue(20).withHue(30);
          expect(color3.value, equals('oklch(from #ff0000 l c 30)'));

          var color4 = color.withHue(20, replace: false).withHue(20, replace: false);
          expect(color4.value, equals('oklch(from #ff0000 l c calc(h + 40))'));

          var color5 = color.withHue(20, replace: false).withHue(10);
          expect(color5.value, equals('oklch(from #ff0000 l c 10)'));

          var color6 = color.withHue(20).withHue(20, replace: false);
          expect(color6.value, equals('oklch(from #ff0000 l c 40)'));
        });

        test('withValues', () {
          var color = Color('#ff00ff');
          var color1 = color.withValues(red: 0, green: 255);
          expect(color1.value, equals('rgb(from #ff00ff 0 255 b)'));

          var color2 = color.withValues(red: 0, blue: 255).withValues(red: 100).withOpacity(0.2);
          expect(color2.value, equals('rgb(from #ff00ff 100 g 255 / 0.2)'));
        });

        test('mixed', () {
          var color = Color('#ff0000');
          var color1 = color.withLightness(0.5).withOpacity(0.5, replace: false);
          expect(color1.value, equals('hsl(from #ff0000 h s 50 / calc(alpha + 0.5))'));

          var color2 = color.withOpacity(0.5).withLightness(0.5, replace: false);
          expect(color2.value, equals('hsl(from #ff0000 h s calc(l + 50) / 0.5)'));

          var color3 = color.withHue(50).withOpacity(0.5, replace: false);
          expect(color3.value, equals('oklch(from #ff0000 l c 50 / calc(alpha + 0.5))'));

          var color4 = color.withOpacity(0.5).withHue(50, replace: false);
          expect(color4.value, equals('oklch(from #ff0000 l c calc(h + 50) / 0.5)'));

          var color5 = color.withLightness(0.5).withHue(50, replace: false);
          expect(color5.value, equals('oklch(from hsl(from #ff0000 h s 50) l c calc(h + 50))'));

          var color6 = color.withHue(50).withLightness(0.5, replace: false);
          expect(color6.value, equals('hsl(from oklch(from #ff0000 l c 50) h s calc(l + 50))'));

          var color7 = color.withLightness(0.5).withHue(50).withOpacity(0.5, replace: false);
          expect(color7.value, equals('oklch(from hsl(from #ff0000 h s 50) l c 50 / calc(alpha + 0.5))'));

          var color8 = color.withOpacity(0.5).withLightness(0.5).withValues(red: 100);
          expect(color8.value, equals('rgb(from hsl(from #ff0000 h s 50 / 0.5) 100 g b)'));
        });
      });
    });
  });
}
