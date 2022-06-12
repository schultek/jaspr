import 'package:jaspr_ui/core.dart';

class ColorStyle extends Style {
  final Color color;

  ColorStyle(this.color) : super('color', color.value);
}

class Color {
  final String _value;

  Color(this._value);

  get value => _value;

  factory Color.fromRGB(int red, int blue, int green) {
    return Color('rgb($red, $blue, $green)');
  }

  factory Color.fromHEX(int value) {
    return Color('#${value.toRadixString(16)}');
  }

  factory Color.fromName(Colors value) {
    return Color(value.name);
  }
}

enum Colors {
  aqua,
  black,
  blue,
  fuchsia,
  gray,
  green,
  lime,
  maroon,
  navy,
  olive,
  purple,
  red,
  silver,
  teal,
  white,
  yellow,
}
