abstract class Color {
  /// Constructs a [Color] from a css color value.
  ///
  /// [value] must be a valid css color value, e.g. a color name, a hex value etc.
  const factory Color(String value) = _Color;

  /// Constructs a [Color] from an integer value.
  const factory Color.value(int value) = _ValueColor;

  /// Constructs a [Color] from red, green and blue values
  const factory Color.rgb(int red, int green, int blue) = _RGBColor;

  /// Constructs a [Color] from red, green, blue and alpha values
  const factory Color.rgba(int red, int green, int blue, double alpha) = _RGBAColor;

  /// Constructs a [Color] from hue, saturation and lightness values
  const factory Color.hsl(int hue, int saturation, int lightness) = _HSLColor;

  /// Constructs a [Color] from hue, saturation, lightness and alpha values
  const factory Color.hsla(int hue, int saturation, int lightness, double alpha) = _HSLAColor;

  /// Constructs a variable containing color.
  const factory Color.variable(String value) = _VariableColor;

  /// The `currentcolor` keyword represents the value of an element's color property.
  /// This lets you use the color value on properties that do not receive it by default.
  static const Color currentColor = Color('currentcolor');

  static const Color inherit = Color('inherit');
  static const Color initial = Color('initial');
  static const Color revert = Color('revert');
  static const Color revertLayer = Color('revert-layer');
  static const Color unset = Color('unset');

  /// The color css value
  String get value;
}

class _Color implements Color {
  final String _value;

  const _Color(this._value);

  @override
  String get value => _value;

  @override
  String toString() => 'Color($_value)';
}

class _ValueColor implements Color {
  final int _value;
  const _ValueColor(this._value);

  @override
  String get value => '#${_value.toRadixString(16).padLeft(6, '0')}';
}

class _RGBColor implements Color {
  final int red;
  final int green;
  final int blue;

  const _RGBColor(this.red, this.green, this.blue);

  @override
  String get value => 'rgb($red, $green, $blue)';
}

class _RGBAColor extends _RGBColor {
  final double alpha;

  const _RGBAColor(super.red, super.green, super.blue, this.alpha);

  @override
  String get value => 'rgba($red, $green, $blue, $alpha)';
}

class _HSLColor implements Color {
  final int hue;
  final int saturation;
  final int lightness;

  const _HSLColor(this.hue, this.saturation, this.lightness);

  @override
  String get value => 'hsl($hue, $saturation%, $lightness%)';
}

class _HSLAColor extends _HSLColor {
  final double alpha;

  const _HSLAColor(super.hue, super.saturation, super.lightness, this.alpha);

  @override
  String get value => 'hsla($hue, $saturation%, $lightness%, $alpha)';
}

class _VariableColor implements Color {
  final String _value;

  const _VariableColor(this._value);

  @override
  String get value => 'var($_value)';
}

class Colors {
  static const Color aliceBlue = Color('aliceBlue');
  static const Color antiqueWhite = Color('antiqueWhite');
  static const Color aqua = Color('aqua');
  static const Color aquamarine = Color('aquamarine');
  static const Color azure = Color('azure');
  static const Color beige = Color('beige');
  static const Color bisque = Color('bisque');
  static const Color black = Color('black');
  static const Color blanchedAlmond = Color('blanchedAlmond');
  static const Color blue = Color('blue');
  static const Color blueViolet = Color('blueViolet');
  static const Color brown = Color('brown');
  static const Color burlyWood = Color('burlyWood');
  static const Color cadetBlue = Color('cadetBlue');
  static const Color chartreuse = Color('chartreuse');
  static const Color chocolate = Color('chocolate');
  static const Color coral = Color('coral');
  static const Color cornflowerBlue = Color('cornflowerBlue');
  static const Color cornsilk = Color('cornsilk');
  static const Color crimson = Color('crimson');
  static const Color cyan = Color('cyan');
  static const Color darkBlue = Color('darkBlue');
  static const Color darkCyan = Color('darkCyan');
  static const Color darkGoldenRod = Color('darkGoldenRod');
  static const Color darkGray = Color('darkGray');
  static const Color darkGreen = Color('darkGreen');
  static const Color darkKhaki = Color('darkKhaki');
  static const Color darkMagenta = Color('darkMagenta');
  static const Color darkOliveGreen = Color('darkOliveGreen');
  static const Color darkorange = Color('darkorange');
  static const Color darkOrchid = Color('darkOrchid');
  static const Color darkRed = Color('darkRed');
  static const Color darkSalmon = Color('darkSalmon');
  static const Color darkSeaGreen = Color('darkSeaGreen');
  static const Color darkSlateBlue = Color('darkSlateBlue');
  static const Color darkSlateGray = Color('darkSlateGray');
  static const Color darkTurquoise = Color('darkTurquoise');
  static const Color darkViolet = Color('darkViolet');
  static const Color deepPink = Color('deepPink');
  static const Color deepSkyBlue = Color('deepSkyBlue');
  static const Color dimGray = Color('dimGray');
  static const Color dodgerBlue = Color('dodgerBlue');
  static const Color fireBrick = Color('fireBrick');
  static const Color floralWhite = Color('floralWhite');
  static const Color forestGreen = Color('forestGreen');
  static const Color fuchsia = Color('fuchsia');
  static const Color gainsboro = Color('gainsboro');
  static const Color ghostWhite = Color('ghostWhite');
  static const Color gold = Color('gold');
  static const Color goldenRod = Color('goldenRod');
  static const Color gray = Color('gray');
  static const Color green = Color('green');
  static const Color greenYellow = Color('greenYellow');
  static const Color honeyDew = Color('honeyDew');
  static const Color hotPink = Color('hotPink');
  static const Color indianRed = Color('indianRed');
  static const Color indigo = Color('indigo');
  static const Color ivory = Color('ivory');
  static const Color khaki = Color('khaki');
  static const Color lavender = Color('lavender');
  static const Color lavenderBlush = Color('lavenderBlush');
  static const Color lawnGreen = Color('lawnGreen');
  static const Color lemonChiffon = Color('lemonChiffon');
  static const Color lightBlue = Color('lightBlue');
  static const Color lightCoral = Color('lightCoral');
  static const Color lightCyan = Color('lightCyan');
  static const Color lightGoldenRodYellow = Color('lightGoldenRodYellow');
  static const Color lightGrey = Color('lightGrey');
  static const Color lightGreen = Color('lightGreen');
  static const Color lightPink = Color('lightPink');
  static const Color lightSalmon = Color('lightSalmon');
  static const Color lightSeaGreen = Color('lightSeaGreen');
  static const Color lightSkyBlue = Color('lightSkyBlue');
  static const Color lightSlateGray = Color('lightSlateGray');
  static const Color lightSteelBlue = Color('lightSteelBlue');
  static const Color lightYellow = Color('lightYellow');
  static const Color lime = Color('lime');
  static const Color limeGreen = Color('limeGreen');
  static const Color linen = Color('linen');
  static const Color magenta = Color('magenta');
  static const Color maroon = Color('maroon');
  static const Color mediumAquaMarine = Color('mediumAquaMarine');
  static const Color mediumBlue = Color('mediumBlue');
  static const Color mediumOrchid = Color('mediumOrchid');
  static const Color mediumPurple = Color('mediumPurple');
  static const Color mediumSeaGreen = Color('mediumSeaGreen');
  static const Color mediumSlateBlue = Color('mediumSlateBlue');
  static const Color mediumSpringGreen = Color('mediumSpringGreen');
  static const Color mediumTurquoise = Color('mediumTurquoise');
  static const Color mediumVioletRed = Color('mediumVioletRed');
  static const Color midnightBlue = Color('midnightBlue');
  static const Color mintCream = Color('mintCream');
  static const Color mistyRose = Color('mistyRose');
  static const Color moccasin = Color('moccasin');
  static const Color navajoWhite = Color('navajoWhite');
  static const Color navy = Color('navy');
  static const Color oldLace = Color('oldLace');
  static const Color olive = Color('olive');
  static const Color oliveDrab = Color('oliveDrab');
  static const Color orange = Color('orange');
  static const Color orangeRed = Color('orangeRed');
  static const Color orchid = Color('orchid');
  static const Color paleGoldenRod = Color('paleGoldenRod');
  static const Color paleGreen = Color('paleGreen');
  static const Color paleTurquoise = Color('paleTurquoise');
  static const Color paleVioletRed = Color('paleVioletRed');
  static const Color papayaWhip = Color('papayaWhip');
  static const Color peachPuff = Color('peachPuff');
  static const Color peru = Color('peru');
  static const Color pink = Color('pink');
  static const Color plum = Color('plum');
  static const Color powderBlue = Color('powderBlue');
  static const Color purple = Color('purple');
  static const Color red = Color('red');
  static const Color rosyBrown = Color('rosyBrown');
  static const Color royalBlue = Color('royalBlue');
  static const Color saddleBrown = Color('saddleBrown');
  static const Color salmon = Color('salmon');
  static const Color sandyBrown = Color('sandyBrown');
  static const Color seaGreen = Color('seaGreen');
  static const Color seaShell = Color('seaShell');
  static const Color sienna = Color('sienna');
  static const Color silver = Color('silver');
  static const Color skyBlue = Color('skyBlue');
  static const Color slateBlue = Color('slateBlue');
  static const Color slateGray = Color('slateGray');
  static const Color snow = Color('snow');
  static const Color springGreen = Color('springGreen');
  static const Color steelBlue = Color('steelBlue');
  static const Color tan = Color('tan');
  static const Color teal = Color('teal');
  static const Color thistle = Color('thistle');
  static const Color tomato = Color('tomato');
  static const Color turquoise = Color('turquoise');
  static const Color violet = Color('violet');
  static const Color wheat = Color('wheat');
  static const Color white = Color('white');
  static const Color whiteSmoke = Color('whiteSmoke');
  static const Color yellow = Color('yellow');
  static const Color yellowGreen = Color('yellowGreen');
  static const Color transparent = Color('transparent');
}
