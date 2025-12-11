import 'package:jaspr/dom.dart';
import 'package:jaspr_content/src/theme/theme.dart';
import 'package:test/test.dart';

void main() {
  group('ThemeColor', () {
    test('value returns light color value', () {
      final themeColor = ThemeColor(Colors.blue, dark: Colors.red);
      expect(themeColor.value, equals(Colors.blue.value));
    });

    test('withHue applies to both light and dark colors', () {
      final themeColor = ThemeColor(Colors.blue, dark: Colors.red);
      final newThemeColor = themeColor.withHue(90);

      expect(newThemeColor.light.value, equals(Colors.blue.withHue(90).value));
      expect(newThemeColor.dark?.value, equals(Colors.red.withHue(90).value));
    });

    test('withLightness applies to both light and dark colors', () {
      final themeColor = ThemeColor(Colors.blue, dark: Colors.red);
      final newThemeColor = themeColor.withLightness(0.5);

      expect(newThemeColor.light.value, equals(Colors.blue.withLightness(0.5).value));
      expect(newThemeColor.dark?.value, equals(Colors.red.withLightness(0.5).value));
    });

    test('withOpacity applies to both light and dark colors', () {
      final themeColor = ThemeColor(Colors.blue, dark: Colors.red);
      final newThemeColor = themeColor.withOpacity(0.5);

      expect(newThemeColor.light.value, equals(Colors.blue.withOpacity(0.5).value));
      expect(newThemeColor.dark?.value, equals(Colors.red.withOpacity(0.5).value));
    });

    test('withValues applies to both light and dark colors', () {
      final themeColor = ThemeColor(Colors.blue, dark: Colors.red);
      final newThemeColor = themeColor.withValues(alpha: 0.5);

      expect(newThemeColor.light.value, equals(Colors.blue.withValues(alpha: 0.5).value));
      expect(newThemeColor.dark?.value, equals(Colors.red.withValues(alpha: 0.5).value));
    });

    test('equality and hashCode', () {
      final themeColor1 = ThemeColor(Colors.blue, dark: Colors.red);
      final themeColor2 = ThemeColor(Colors.blue, dark: Colors.red);
      final themeColor3 = ThemeColor(Colors.green, dark: Colors.red);

      expect(themeColor1, equals(themeColor2));
      expect(themeColor1.hashCode, equals(themeColor2.hashCode));
      expect(themeColor1, isNot(equals(themeColor3)));
      expect(themeColor1.hashCode, isNot(equals(themeColor3.hashCode)));
    });

    test('toString returns correct representation', () {
      final themeColor = ThemeColor(Colors.blue, dark: Colors.red);
      expect(themeColor.toString(), equals('ThemeColor(Color(blue), dark: Color(red))'));
    });

    test('with methods work when dark is null', () {
      final themeColor = ThemeColor(Colors.blue);
      final withOpacity = themeColor.withOpacity(0.5);
      expect(withOpacity.light.value, equals(Colors.blue.withOpacity(0.5).value));
      expect(withOpacity.dark, isNull);

      final withLightness = themeColor.withLightness(0.5);
      expect(withLightness.light.value, equals(Colors.blue.withLightness(0.5).value));
      expect(withLightness.dark, isNull);

      final withHue = themeColor.withHue(90);
      expect(withHue.light.value, equals(Colors.blue.withHue(90).value));
      expect(withHue.dark, isNull);

      final withValues = themeColor.withValues(alpha: 0.5);
      expect(withValues.light.value, equals(Colors.blue.withValues(alpha: 0.5).value));
      expect(withValues.dark, isNull);
    });
  });
}
