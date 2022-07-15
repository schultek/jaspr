import 'package:jaspr/components.dart';

class ColorStyle extends Style {
  final Color color;

  ColorStyle(this.color) : super('color', color.value);
}

class Color {
  final String _value;

  const Color(this._value);

  get value => _value;

  factory Color.fromRGB(int red, int blue, int green) {
    return Color('rgb($red, $blue, $green)');
  }

  factory Color.fromRGBA(int red, int blue, int green, double alpha) {
    return Color('rgba($red, $blue, $green, $alpha)');
  }

  factory Color.fromHSL(int red, int blue, int green) {
    return Color('hsl($red, $blue, $green)');
  }

  factory Color.fromHSLA(int red, int blue, int green, double alpha) {
    return Color('hsla($red, $blue, $green, $alpha)');
  }

  factory Color.fromHEX(int value) {
    return Color('#${value.toRadixString(16)}');
  }

  factory Color.fromName(Colors value) {
    return Color(value.name);
  }
}

enum Colors {
  aliceBlue,
  antiqueWhite,
  aqua,
  aquamarine,
  azure,
  beige,
  bisque,
  black,
  blanchedAlmond,
  blue,
  blueViolet,
  brown,
  burlyWood,
  cadetBlue,
  chartreuse,
  chocolate,
  coral,
  cornflowerBlue,
  cornsilk,
  crimson,
  cyan,
  darkBlue,
  darkCyan,
  darkGoldenRod,
  darkGray,
  darkGreen,
  darkKhaki,
  darkMagenta,
  darkOliveGreen,
  darkorange,
  darkOrchid,
  darkRed,
  darkSalmon,
  darkSeaGreen,
  darkSlateBlue,
  darkSlateGray,
  darkTurquoise,
  darkViolet,
  deepPink,
  deepSkyBlue,
  dimGray,
  dodgerBlue,
  fireBrick,
  floralWhite,
  forestGreen,
  fuchsia,
  gainsboro,
  ghostWhite,
  gold,
  goldenRod,
  gray,
  green,
  greenYellow,
  honeyDew,
  hotPink,
  indianRed,
  indigo,
  ivory,
  khaki,
  lavender,
  lavenderBlush,
  lawnGreen,
  lemonChiffon,
  lightBlue,
  lightCoral,
  lightCyan,
  lightGoldenRodYellow,
  lightGrey,
  lightGreen,
  lightPink,
  lightSalmon,
  lightSeaGreen,
  lightSkyBlue,
  lightSlateGray,
  lightSteelBlue,
  lightYellow,
  lime,
  limeGreen,
  linen,
  magenta,
  maroon,
  mediumAquaMarine,
  mediumBlue,
  mediumOrchid,
  mediumPurple,
  mediumSeaGreen,
  mediumSlateBlue,
  mediumSpringGreen,
  mediumTurquoise,
  mediumVioletRed,
  midnightBlue,
  mintCream,
  mistyRose,
  moccasin,
  navajoWhite,
  navy,
  oldLace,
  olive,
  oliveDrab,
  orange,
  orangeRed,
  orchid,
  paleGoldenRod,
  paleGreen,
  paleTurquoise,
  paleVioletRed,
  papayaWhip,
  peachPuff,
  peru,
  pink,
  plum,
  powderBlue,
  purple,
  red,
  rosyBrown,
  royalBlue,
  saddleBrown,
  salmon,
  sandyBrown,
  seaGreen,
  seaShell,
  sienna,
  silver,
  skyBlue,
  slateBlue,
  slateGray,
  snow,
  springGreen,
  steelBlue,
  tan,
  teal,
  thistle,
  tomato,
  turquoise,
  violet,
  wheat,
  white,
  whiteSmoke,
  yellow,
  yellowGreen,
}
