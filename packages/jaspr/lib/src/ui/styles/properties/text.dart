import 'color.dart';
import 'unit.dart';

enum TextAlign {
  start('start'),
  end('end'),
  left('left'),
  right('right'),
  center('center'),
  justify('justify'),
  justifyAll('justify-all'),
  matchParent('match-parent'),

  inherit('inherit'),
  initial('initial'),
  revert('revert'),
  revertLayer('revert-layer'),
  unset('unset');

  final String value;
  const TextAlign(this.value);
}

class FontFamily {
  /// The css value
  final String value;

  /// Constructs a [FontFamily] from a custom font name
  const FontFamily(String value) : value = '"$value"';

  const FontFamily._generic(this.value);

  /// Constructs a [FontFamily] value from a list of families
  const factory FontFamily.list(List<FontFamily> families) = _ListFontFamily;

  static const FontFamily inherit = FontFamily._generic('inherit');
  static const FontFamily initial = FontFamily._generic('initial');
  static const FontFamily revert = FontFamily._generic('revert');
  static const FontFamily revertLayer = FontFamily._generic('revert-layer');
  static const FontFamily unset = FontFamily._generic('unset');
}

class _ListFontFamily implements FontFamily {
  final List<FontFamily> families;
  const _ListFontFamily(this.families);

  @override
  String get value => families.map((f) => f.value).join(', ');
}

class FontFamilies {
  // generic families
  static const FontFamily serif = FontFamily._generic('serif');
  static const FontFamily sansSerif = FontFamily._generic('sans-serif');
  static const FontFamily monospace = FontFamily._generic('monospace');
  static const FontFamily cursive = FontFamily._generic('cursive');
  static const FontFamily fantasy = FontFamily._generic('fantasy');
  static const FontFamily systemUi = FontFamily._generic('system-ui');
  static const FontFamily uiSerif = FontFamily._generic('ui-serif');
  static const FontFamily uiSansSerif = FontFamily._generic('ui-sans-serif');
  static const FontFamily uiMonospace = FontFamily._generic('ui-monospace');
  static const FontFamily uiRounded = FontFamily._generic('ui-rounded');
  static const FontFamily emoji = FontFamily._generic('emoji');
  static const FontFamily math = FontFamily._generic('math');
  static const FontFamily fangSong = FontFamily._generic('fangsong');

  // common families
  static const FontFamily arial = FontFamily('Arial');
  static const FontFamily helvetica = FontFamily('Helvetica');
  static const FontFamily gillSans = FontFamily('Gill Sans');
  static const FontFamily lucida = FontFamily('Lucida');
  static const FontFamily helveticaNarrow = FontFamily('Helvetica Narrow');
  static const FontFamily times = FontFamily('Times');
  static const FontFamily timesNewRoman = FontFamily('Times New Roman');
  static const FontFamily palatino = FontFamily('Palatino');
  static const FontFamily bookman = FontFamily('Bookman');
  static const FontFamily newCenturySchoolbook = FontFamily('New Century Schoolbook');
  static const FontFamily andaleMono = FontFamily('Andale Mono');
  static const FontFamily courierNew = FontFamily('Courier New');
  static const FontFamily courier = FontFamily('Courier');
  static const FontFamily lucidatypewriter = FontFamily('Lucidatypewriter');
  static const FontFamily comicSans = FontFamily('Comic Sans');
  static const FontFamily zapfChancery = FontFamily('Zapf Chancery');
  static const FontFamily coronetscript = FontFamily('Coronetscript');
  static const FontFamily florence = FontFamily('Florence');
  static const FontFamily parkavenue = FontFamily('Parkavenue');
  static const FontFamily impact = FontFamily('Impact');
  static const FontFamily arnoldboecklin = FontFamily('Arnoldboecklin');
  static const FontFamily oldtown = FontFamily('Oldtown');
  static const FontFamily blippo = FontFamily('Blippo');
  static const FontFamily brushstroke = FontFamily('Brushstroke');
}

class FontStyle {
  /// The css value
  final String value;

  const FontStyle._(this.value);

  static const FontStyle normal = FontStyle._('normal');
  static const FontStyle italic = FontStyle._('italic');
  static const FontStyle oblique = FontStyle._('oblique');

  // TODO Angle class
  const factory FontStyle.obliqueAngle(double degrees) = _ObliqueAngleFontStyle;

  static const FontStyle inherit = FontStyle._('inherit');
  static const FontStyle initial = FontStyle._('initial');
  static const FontStyle revert = FontStyle._('revert');
  static const FontStyle revertLayer = FontStyle._('revert-layer');
  static const FontStyle unset = FontStyle._('unset');
}

class _ObliqueAngleFontStyle implements FontStyle {
  final double angle;

  const _ObliqueAngleFontStyle(this.angle);

  @override
  String get value => 'oblique ${angle}deg';
}

enum TextTransform {
  none('none'),
  capitalize('capitalize'),
  upperCase('uppercase'),
  lowerCase('lowercase'),
  fullWidth('full-width'),
  fullSizeKana('full-size-kana'),

  inherit('inherit'),
  initial('initial'),
  revert('revert'),
  revertLayer('revert-layer'),
  unset('unset');

  /// The css value
  final String value;
  const TextTransform(this.value);
}

enum FontWeight {
  normal("normal"),
  bold("bold"),
  bolder("bolder"),
  lighter("lighter"),

  w100("100"),
  w200("200"),
  w300("300"),
  w400("400"),
  w500("500"),
  w600("600"),
  w700("700"),
  w800("800"),
  w900("900"),

  inherit('inherit'),
  initial('initial'),
  revert('revert'),
  revertLayer('revert-layer'),
  unset('unset');

  final String value;
  const FontWeight(this.value);
}

class TextDecorationLine {
  /// The css value
  final String value;

  const TextDecorationLine._(this.value);

  static const TextDecorationLine none = TextDecorationLine._('none');

  static const TextDecorationLineKeyword underline = TextDecorationLineKeyword.underline;
  static const TextDecorationLineKeyword overline = TextDecorationLineKeyword.overline;
  static const TextDecorationLineKeyword lineThrough = TextDecorationLineKeyword.lineThrough;

  const factory TextDecorationLine.multi(List<TextDecorationLineKeyword> lines) = _MultiTextDecorationLine;

  static const TextDecorationLine inherit = TextDecorationLine._('inherit');
  static const TextDecorationLine initial = TextDecorationLine._('initial');
  static const TextDecorationLine revert = TextDecorationLine._('revert');
  static const TextDecorationLine revertLayer = TextDecorationLine._('revert-layer');
  static const TextDecorationLine unset = TextDecorationLine._('unset');
}

enum TextDecorationLineKeyword implements TextDecorationLine {
  underline('underline'),
  overline('overline'),
  lineThrough('line-through');

  @override
  final String value;
  const TextDecorationLineKeyword(this.value);
}

class _MultiTextDecorationLine implements TextDecorationLine {
  final List<TextDecorationLineKeyword> lines;

  const _MultiTextDecorationLine(this.lines);

  @override
  String get value => lines.map((l) => l.value).join(' ');
}

enum TextDecorationStyle {
  solid('solid'),
  double('double'),
  dotted('dotted'),
  dashed('dashed'),
  wavy('wavy'),

  inherit('inherit'),
  initial('initial'),
  revert('revert'),
  revertLayer('revert-layer'),
  unset('unset');

  /// The css value
  final String value;
  const TextDecorationStyle(this.value);
}

class TextDecorationThickness {
  /// The css value
  final String value;

  const TextDecorationThickness._(this.value);

  static const TextDecorationThickness auto = TextDecorationThickness._('auto');
  static const TextDecorationThickness fromFont = TextDecorationThickness._('from-font');

  const factory TextDecorationThickness.value(Unit value) = _ValueTextDecorationThickness;

  static const TextDecorationThickness inherit = TextDecorationThickness._('inherit');
  static const TextDecorationThickness initial = TextDecorationThickness._('initial');
  static const TextDecorationThickness revert = TextDecorationThickness._('revert');
  static const TextDecorationThickness revertLayer = TextDecorationThickness._('revert-layer');
  static const TextDecorationThickness unset = TextDecorationThickness._('unset');
}

class _ValueTextDecorationThickness implements TextDecorationThickness {
  final Unit _value;
  const _ValueTextDecorationThickness(this._value);

  @override
  String get value => _value.value;
}

class TextDecoration {
  final TextDecorationLine? line;
  final Color? color;
  final TextDecorationStyle? style;
  final TextDecorationThickness? thickness;

  const TextDecoration({this.line, this.color, this.style, this.thickness});

  String get value => [
        if (line != null) line!.value,
        if (style != null) style!.value,
        if (color != null) color!.value,
        if (thickness != null) thickness!.value,
      ].join(' ');
}
