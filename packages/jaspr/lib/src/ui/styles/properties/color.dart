abstract class Color {
  /// Constructs a [Color] from a hex string. Must start with a '#' and contain up to 6 hex characters.
  const factory Color.hex(String hex) = _HexColor;

  /// Constructs a [Color] from an integer value.
  const factory Color.value(int value) = _ValueColor;

  /// Constructs a [Color] from a web color name. Consider using [Colors.<name>] instead.
  const factory Color.named(String name) = _NamedColor;

  /// Constructs a [Color] from red, green and blue values
  const factory Color.rgb(int red, int green, int blue) = _RGBColor;

  /// Constructs a [Color] from red, green, blue and alpha values
  const factory Color.rgba(int red, int green, int blue, double alpha) = _RGBAColor;

  /// Constructs a [Color] from hue, saturation and lightness values
  const factory Color.hsl(int hue, int saturation, int lightness) = _HSLColor;

  /// Constructs a [Color] from hue, saturation, lightness and alpha values
  const factory Color.hsla(int hue, int saturation, int lightness, double alpha) = _HSLAColor;

  static const Color inherit = Color.named('inherit');
  static const Color initial = Color.named('initial');
  static const Color revert = Color.named('revert');
  static const Color revertLayer = Color.named('revert-layer');
  static const Color unset = Color.named('unset');

  /// The color css value
  String get value;
}

class _HexColor implements Color {
  final String hex;

  const _HexColor(this.hex);

  @override
  String get value => hex;
}

class _ValueColor implements Color {
  final int _value;
  const _ValueColor(this._value);

  @override
  String get value => '#${_value.toRadixString(16).padLeft(6, '0')}';
}

class _NamedColor implements Color {
  final String name;
  const _NamedColor(this.name);

  @override
  String get value => name;
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

class Colors {
  static const Color aliceBlue = Color.named('aliceBlue');
  static const Color antiqueWhite = Color.named('antiqueWhite');
  static const Color aqua = Color.named('aqua');
  static const Color aquamarine = Color.named('aquamarine');
  static const Color azure = Color.named('azure');
  static const Color beige = Color.named('beige');
  static const Color bisque = Color.named('bisque');
  static const Color black = Color.named('black');
  static const Color blanchedAlmond = Color.named('blanchedAlmond');
  static const Color blue = Color.named('blue');
  static const Color blueViolet = Color.named('blueViolet');
  static const Color brown = Color.named('brown');
  static const Color burlyWood = Color.named('burlyWood');
  static const Color cadetBlue = Color.named('cadetBlue');
  static const Color chartreuse = Color.named('chartreuse');
  static const Color chocolate = Color.named('chocolate');
  static const Color coral = Color.named('coral');
  static const Color cornflowerBlue = Color.named('cornflowerBlue');
  static const Color cornsilk = Color.named('cornsilk');
  static const Color crimson = Color.named('crimson');
  static const Color cyan = Color.named('cyan');
  static const Color darkBlue = Color.named('darkBlue');
  static const Color darkCyan = Color.named('darkCyan');
  static const Color darkGoldenRod = Color.named('darkGoldenRod');
  static const Color darkGray = Color.named('darkGray');
  static const Color darkGreen = Color.named('darkGreen');
  static const Color darkKhaki = Color.named('darkKhaki');
  static const Color darkMagenta = Color.named('darkMagenta');
  static const Color darkOliveGreen = Color.named('darkOliveGreen');
  static const Color darkorange = Color.named('darkorange');
  static const Color darkOrchid = Color.named('darkOrchid');
  static const Color darkRed = Color.named('darkRed');
  static const Color darkSalmon = Color.named('darkSalmon');
  static const Color darkSeaGreen = Color.named('darkSeaGreen');
  static const Color darkSlateBlue = Color.named('darkSlateBlue');
  static const Color darkSlateGray = Color.named('darkSlateGray');
  static const Color darkTurquoise = Color.named('darkTurquoise');
  static const Color darkViolet = Color.named('darkViolet');
  static const Color deepPink = Color.named('deepPink');
  static const Color deepSkyBlue = Color.named('deepSkyBlue');
  static const Color dimGray = Color.named('dimGray');
  static const Color dodgerBlue = Color.named('dodgerBlue');
  static const Color fireBrick = Color.named('fireBrick');
  static const Color floralWhite = Color.named('floralWhite');
  static const Color forestGreen = Color.named('forestGreen');
  static const Color fuchsia = Color.named('fuchsia');
  static const Color gainsboro = Color.named('gainsboro');
  static const Color ghostWhite = Color.named('ghostWhite');
  static const Color gold = Color.named('gold');
  static const Color goldenRod = Color.named('goldenRod');
  static const Color gray = Color.named('gray');
  static const Color green = Color.named('green');
  static const Color greenYellow = Color.named('greenYellow');
  static const Color honeyDew = Color.named('honeyDew');
  static const Color hotPink = Color.named('hotPink');
  static const Color indianRed = Color.named('indianRed');
  static const Color indigo = Color.named('indigo');
  static const Color ivory = Color.named('ivory');
  static const Color khaki = Color.named('khaki');
  static const Color lavender = Color.named('lavender');
  static const Color lavenderBlush = Color.named('lavenderBlush');
  static const Color lawnGreen = Color.named('lawnGreen');
  static const Color lemonChiffon = Color.named('lemonChiffon');
  static const Color lightBlue = Color.named('lightBlue');
  static const Color lightCoral = Color.named('lightCoral');
  static const Color lightCyan = Color.named('lightCyan');
  static const Color lightGoldenRodYellow = Color.named('lightGoldenRodYellow');
  static const Color lightGrey = Color.named('lightGrey');
  static const Color lightGreen = Color.named('lightGreen');
  static const Color lightPink = Color.named('lightPink');
  static const Color lightSalmon = Color.named('lightSalmon');
  static const Color lightSeaGreen = Color.named('lightSeaGreen');
  static const Color lightSkyBlue = Color.named('lightSkyBlue');
  static const Color lightSlateGray = Color.named('lightSlateGray');
  static const Color lightSteelBlue = Color.named('lightSteelBlue');
  static const Color lightYellow = Color.named('lightYellow');
  static const Color lime = Color.named('lime');
  static const Color limeGreen = Color.named('limeGreen');
  static const Color linen = Color.named('linen');
  static const Color magenta = Color.named('magenta');
  static const Color maroon = Color.named('maroon');
  static const Color mediumAquaMarine = Color.named('mediumAquaMarine');
  static const Color mediumBlue = Color.named('mediumBlue');
  static const Color mediumOrchid = Color.named('mediumOrchid');
  static const Color mediumPurple = Color.named('mediumPurple');
  static const Color mediumSeaGreen = Color.named('mediumSeaGreen');
  static const Color mediumSlateBlue = Color.named('mediumSlateBlue');
  static const Color mediumSpringGreen = Color.named('mediumSpringGreen');
  static const Color mediumTurquoise = Color.named('mediumTurquoise');
  static const Color mediumVioletRed = Color.named('mediumVioletRed');
  static const Color midnightBlue = Color.named('midnightBlue');
  static const Color mintCream = Color.named('mintCream');
  static const Color mistyRose = Color.named('mistyRose');
  static const Color moccasin = Color.named('moccasin');
  static const Color navajoWhite = Color.named('navajoWhite');
  static const Color navy = Color.named('navy');
  static const Color oldLace = Color.named('oldLace');
  static const Color olive = Color.named('olive');
  static const Color oliveDrab = Color.named('oliveDrab');
  static const Color orange = Color.named('orange');
  static const Color orangeRed = Color.named('orangeRed');
  static const Color orchid = Color.named('orchid');
  static const Color paleGoldenRod = Color.named('paleGoldenRod');
  static const Color paleGreen = Color.named('paleGreen');
  static const Color paleTurquoise = Color.named('paleTurquoise');
  static const Color paleVioletRed = Color.named('paleVioletRed');
  static const Color papayaWhip = Color.named('papayaWhip');
  static const Color peachPuff = Color.named('peachPuff');
  static const Color peru = Color.named('peru');
  static const Color pink = Color.named('pink');
  static const Color plum = Color.named('plum');
  static const Color powderBlue = Color.named('powderBlue');
  static const Color purple = Color.named('purple');
  static const Color red = Color.named('red');
  static const Color rosyBrown = Color.named('rosyBrown');
  static const Color royalBlue = Color.named('royalBlue');
  static const Color saddleBrown = Color.named('saddleBrown');
  static const Color salmon = Color.named('salmon');
  static const Color sandyBrown = Color.named('sandyBrown');
  static const Color seaGreen = Color.named('seaGreen');
  static const Color seaShell = Color.named('seaShell');
  static const Color sienna = Color.named('sienna');
  static const Color silver = Color.named('silver');
  static const Color skyBlue = Color.named('skyBlue');
  static const Color slateBlue = Color.named('slateBlue');
  static const Color slateGray = Color.named('slateGray');
  static const Color snow = Color.named('snow');
  static const Color springGreen = Color.named('springGreen');
  static const Color steelBlue = Color.named('steelBlue');
  static const Color tan = Color.named('tan');
  static const Color teal = Color.named('teal');
  static const Color thistle = Color.named('thistle');
  static const Color tomato = Color.named('tomato');
  static const Color turquoise = Color.named('turquoise');
  static const Color violet = Color.named('violet');
  static const Color wheat = Color.named('wheat');
  static const Color white = Color.named('white');
  static const Color whiteSmoke = Color.named('whiteSmoke');
  static const Color yellow = Color.named('yellow');
  static const Color yellowGreen = Color.named('yellowGreen');
}
