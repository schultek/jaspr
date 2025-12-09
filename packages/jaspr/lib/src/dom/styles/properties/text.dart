import 'angle.dart';
import 'color.dart';
import 'unit.dart';

/// The `text-align` CSS property sets the horizontal alignment of the inline-level content
/// inside a block element or table-cell box. This means it works like vertical-align but
/// in the horizontal direction.
///
/// Read more: [MDN `text-align`](https://developer.mozilla.org/en-US/docs/Web/CSS/text-align)
enum TextAlign {
  /// The same as [left] if direction is left-to-right and [right] if direction is right-to-left.
  start('start'),

  /// The same as [right] if direction is left-to-right and [left] if direction is right-to-left.
  end('end'),

  /// The inline contents are aligned to the left edge of the line box.
  left('left'),

  /// The inline contents are aligned to the right edge of the line box.
  right('right'),

  /// The inline contents are centered within the line box.
  center('center'),

  /// The inline contents are justified. Spaces out the content to line up its left and right edges
  /// to the left and right edges of the line box, except for the last line.
  justify('justify'),

  /// Similar to [inherit], but the values [start] and [end] are calculated according to the parent's
  /// direction and are replaced by the appropriate [left] or [right] value.
  matchParent('match-parent'),

  inherit('inherit'),
  initial('initial'),
  revert('revert'),
  revertLayer('revert-layer'),
  unset('unset');

  final String value;
  const TextAlign(this.value);
}

/// The `font-family` CSS property specifies a prioritized list of one or more font family names
/// and/or generic family names for the selected element.
///
/// See also:
///   - [FontFamilies] for generic and common font families.
///
/// Read more: [MDN `font-family`](https://developer.mozilla.org/en-US/docs/Web/CSS/font-family)
class FontFamily {
  /// The css value
  final String value;

  /// Constructs a [FontFamily] from a custom font name.
  const FontFamily(String value) : value = "'$value'";

  const FontFamily._generic(this.value);

  /// Constructs a [FontFamily] value from a list of families.
  const factory FontFamily.list(List<FontFamily> families) = _ListFontFamily;

  /// Constructs a [FontFamily] value from a CSS variable.
  const factory FontFamily.variable(String value) = _VariableFontFamily;

  static const FontFamily inherit = FontFamily._generic('inherit');
  static const FontFamily initial = FontFamily._generic('initial');
  static const FontFamily revert = FontFamily._generic('revert');
  static const FontFamily revertLayer = FontFamily._generic('revert-layer');
  static const FontFamily unset = FontFamily._generic('unset');
}

class _ListFontFamily implements FontFamily {
  final List<FontFamily> families;
  const _ListFontFamily(this.families);

  bool _validateFamilies() {
    if (families.isEmpty) {
      throw 'FontFamily.list cannot be empty';
    }
    return true;
  }

  @override
  String get value {
    assert(_validateFamilies());
    return families.map((f) => f.value).join(', ');
  }
}

class _VariableFontFamily implements FontFamily {
  final String _value;

  const _VariableFontFamily(this._value);

  @override
  String get value => 'var($_value)';
}

/// A collection of generic and common font families.
///
/// - Generic font families are a fallback mechanism, a means of preserving some of the style
/// sheet author's intent when none of the specified fonts are available. A generic font family
/// should be the last item in the list of font family names.
///
/// Read more: [MDN `font-family`](https://developer.mozilla.org/en-US/docs/Web/CSS/font-family)
class FontFamilies {
  /// Generic font family where glyphs have finishing strokes, flared or tapering ends, or have actual serifed endings.
  static const FontFamily serif = FontFamily._generic('serif');

  /// Generic font family where glyphs have stroke endings that are plain.
  static const FontFamily sansSerif = FontFamily._generic('sans-serif');

  /// Generic font family where all glyphs have the same fixed width.
  static const FontFamily monospace = FontFamily._generic('monospace');

  /// Generic font family where glyphs resemble handwriting.
  static const FontFamily cursive = FontFamily._generic('cursive');

  /// Generic font family where glyphs have a playful, decorative design.
  static const FontFamily fantasy = FontFamily._generic('fantasy');

  /// Generic font family that represents the default user interface font on a given platform.
  static const FontFamily systemUi = FontFamily._generic('system-ui');

  /// The default user interface serif font.
  static const FontFamily uiSerif = FontFamily._generic('ui-serif');

  /// The default user interface sans-serif font.
  static const FontFamily uiSansSerif = FontFamily._generic('ui-sans-serif');

  /// The default user interface monospace font.
  static const FontFamily uiMonospace = FontFamily._generic('ui-monospace');

  /// The default user interface font that has rounded features.
  static const FontFamily uiRounded = FontFamily._generic('ui-rounded');
  static const FontFamily emoji = FontFamily._generic('emoji');

  /// This is for the particular stylistic concerns of representing mathematics: superscript and subscript, brackets
  /// that cross several lines, nesting expressions, and double struck glyphs with distinct meanings.
  static const FontFamily math = FontFamily._generic('math');

  /// A particular style of Chinese characters that are between serif-style Song and cursive-style Kai forms. This
  /// style is often used for government documents.
  static const FontFamily fangSong = FontFamily._generic('fangsong');

  // common families
  /// The "Arial" font family.
  static const FontFamily arial = FontFamily('Arial');

  /// The "Helvetica" font family.
  static const FontFamily helvetica = FontFamily('Helvetica');

  /// The "Gill Sans" font family.
  static const FontFamily gillSans = FontFamily('Gill Sans');

  /// The "Lucida" font family.
  static const FontFamily lucida = FontFamily('Lucida');

  /// The "Helvetica Narrow" font family.
  static const FontFamily helveticaNarrow = FontFamily('Helvetica Narrow');

  /// The "Times" font family.
  static const FontFamily times = FontFamily('Times');

  /// The "Times New Roman" font family.
  static const FontFamily timesNewRoman = FontFamily('Times New Roman');

  /// The "Palatino" font family.
  static const FontFamily palatino = FontFamily('Palatino');

  /// The "Bookman" font family.
  static const FontFamily bookman = FontFamily('Bookman');

  /// The "New Century Schoolbook" font family.
  static const FontFamily newCenturySchoolbook = FontFamily('New Century Schoolbook');

  /// The "Andale Mono" font family.
  static const FontFamily andaleMono = FontFamily('Andale Mono');

  /// The "Courier New" font family.
  static const FontFamily courierNew = FontFamily('Courier New');

  /// The "Courier" font family.
  static const FontFamily courier = FontFamily('Courier');

  /// The "Lucidatypewriter" font family.
  static const FontFamily lucidatypewriter = FontFamily('Lucidatypewriter');

  /// The "Comic Sans" font family.
  static const FontFamily comicSans = FontFamily('Comic Sans');

  /// The "Zapf Chancery" font family.
  static const FontFamily zapfChancery = FontFamily('Zapf Chancery');

  /// The "Coronetscript" font family.
  static const FontFamily coronetscript = FontFamily('Coronetscript');

  /// The "Florence" font family.
  static const FontFamily florence = FontFamily('Florence');

  /// The "Parkavenue" font family.
  static const FontFamily parkavenue = FontFamily('Parkavenue');

  /// The "Impact" font family.
  static const FontFamily impact = FontFamily('Impact');

  /// The "Arnoldboecklin" font family.
  static const FontFamily arnoldboecklin = FontFamily('Arnoldboecklin');

  /// The "Oldtown" font family.
  static const FontFamily oldtown = FontFamily('Oldtown');

  /// The "Blippo" font family.
  static const FontFamily blippo = FontFamily('Blippo');

  /// The "Brushstroke" font family.
  static const FontFamily brushstroke = FontFamily('Brushstroke');
}

/// The `font-style` CSS property sets whether a font should be styled with a normal, italic, or oblique
/// face from its font-family.
///
/// Read more: [MDN `font-style`](https://developer.mozilla.org/en-US/docs/Web/CSS/font-style)
class FontStyle {
  /// The css value
  final String value;

  const FontStyle._(this.value);

  /// Selects a font that is classified as normal within a font-family.
  static const FontStyle normal = FontStyle._('normal');

  /// Selects a font that is classified as italic.
  ///
  /// If no italic version of the face is available, one classified as oblique is used instead. If neither
  /// is available, the style is artificially simulated.
  static const FontStyle italic = FontStyle._('italic');

  /// Selects a font that is classified as oblique.
  ///
  /// If no oblique version of the face is available, one classified as italic is used instead. If neither
  /// is available, the style is artificially simulated.
  static const FontStyle oblique = FontStyle._('oblique');

  /// Selects a font classified as oblique, and additionally specifies an angle for the slant of the text.
  ///
  /// If one or more oblique faces are available in the chosen font family, the one that most closely matches
  /// the specified angle is chosen. If no oblique faces are available, the browser will synthesize an oblique
  /// version of the font by slanting a normal face by the specified amount. Valid values are degree values of
  /// -90deg to 90deg inclusive. If an angle is not specified, an angle of 14 degrees is used. Positive values
  /// are slanted to the end of the line, while negative values are slanted towards the beginning.
  const factory FontStyle.obliqueAngle(Angle angle) = _ObliqueAngleFontStyle;

  static const FontStyle inherit = FontStyle._('inherit');
  static const FontStyle initial = FontStyle._('initial');
  static const FontStyle revert = FontStyle._('revert');
  static const FontStyle revertLayer = FontStyle._('revert-layer');
  static const FontStyle unset = FontStyle._('unset');
}

class _ObliqueAngleFontStyle implements FontStyle {
  final Angle angle;

  const _ObliqueAngleFontStyle(this.angle);

  @override
  String get value => 'oblique ${angle.value}';
}

/// The `text-transform` CSS property specifies how to capitalize an element's text. It can be used to make text
/// appear in all-uppercase or all-lowercase, or with each word capitalized. It also can help improve legibility for ruby.
///
/// Read more: [MDN `text-transform`](https://developer.mozilla.org/en-US/docs/Web/CSS/text-transform)
enum TextTransform {
  /// Prevents the case of all characters from being changed.
  none('none'),

  /// Converts the first letter of each word to uppercase. Other characters remain unchanged (they retain
  /// their original case as written in the element's text). A letter is defined as a character that is part of Unicode's
  /// Letter or Number general categories; thus, any punctuation marks or symbols at the beginning of a word are ignored.
  capitalize('capitalize'),

  /// Converts all characters to uppercase.
  upperCase('uppercase'),

  /// Converts all characters to lowercase.
  lowerCase('lowercase'),

  /// Forces the writing of a character — mainly ideograms and Latin scripts — inside a square, allowing them to be aligned
  /// in the usual East Asian scripts (like Chinese or Japanese).
  fullWidth('full-width'),

  /// Generally used for `<ruby>` annotation text, the keyword converts all small Kana characters to the equivalent full-size
  /// Kana, to compensate for legibility issues at the small font sizes typically used in ruby.
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

/// The `font-weight` CSS property sets the weight (or boldness) of the font. The weights available depend on the font-family
/// that is currently set.
///
/// Read more: [MDN `font-weight`](https://developer.mozilla.org/en-US/docs/Web/CSS/font-weight)
enum FontWeight {
  /// Normal font weight. Same as 400.
  normal('normal'),

  /// Bold font weight. Same as 700.
  bold('bold'),

  /// One relative font weight heavier than the parent element.
  ///
  /// Note that only four font weights are considered for relative weight calculation.
  bolder('bolder'),

  /// One relative font weight lighter than the parent element.
  ///
  /// Note that only four font weights are considered for relative weight calculation.
  lighter('lighter'),

  w100('100'),
  w200('200'),
  w300('300'),
  w400('400'),
  w500('500'),
  w600('600'),
  w700('700'),
  w800('800'),
  w900('900'),

  inherit('inherit'),
  initial('initial'),
  revert('revert'),
  revertLayer('revert-layer'),
  unset('unset');

  final String value;
  const FontWeight(this.value);
}

/// The `text-decoration-line` CSS property sets the kind of decoration that is used on text in an element, such as an
/// underline or overline.
///
/// Read more: [MDN `text-decoration-line`](https://developer.mozilla.org/en-US/docs/Web/CSS/text-decoration-line)
class TextDecorationLine {
  /// The css value
  final String value;

  const TextDecorationLine._(this.value);

  /// Produces no text decoration.
  static const TextDecorationLine none = TextDecorationLine._('none');

  /// Each line of text has a decorative line beneath it.
  static const TextDecorationLineKeyword underline = TextDecorationLineKeyword.underline;

  /// Each line of text has a decorative line above it.
  static const TextDecorationLineKeyword overline = TextDecorationLineKeyword.overline;

  /// Each line of text has a decorative line going through its middle.
  static const TextDecorationLineKeyword lineThrough = TextDecorationLineKeyword.lineThrough;

  /// Combines multiple text decoration lines.
  const factory TextDecorationLine.multi(List<TextDecorationLineKeyword> lines) = _MultiTextDecorationLine;

  static const TextDecorationLine inherit = TextDecorationLine._('inherit');
  static const TextDecorationLine initial = TextDecorationLine._('initial');
  static const TextDecorationLine revert = TextDecorationLine._('revert');
  static const TextDecorationLine revertLayer = TextDecorationLine._('revert-layer');
  static const TextDecorationLine unset = TextDecorationLine._('unset');
}

enum TextDecorationLineKeyword implements TextDecorationLine {
  /// Each line of text has a decorative line beneath it.
  underline('underline'),

  /// Each line of text has a decorative line above it.
  overline('overline'),

  /// Each line of text has a decorative line going through its middle.
  lineThrough('line-through');

  @override
  final String value;
  const TextDecorationLineKeyword(this.value);
}

class _MultiTextDecorationLine implements TextDecorationLine {
  final List<TextDecorationLineKeyword> lines;

  const _MultiTextDecorationLine(this.lines);

  bool _validateLines() {
    if (lines.isEmpty) {
      throw 'TextDecorationLine.multi cannot be empty';
    }
    return true;
  }

  @override
  String get value {
    assert(_validateLines());
    return lines.map((l) => l.value).join(' ');
  }
}

/// The `text-decoration-style` CSS property sets the style of the lines specified by [TextDecorationLine].
///
/// Read more: [MDN `text-decoration-style`](https://developer.mozilla.org/en-US/docs/Web/CSS/text-decoration-style)
enum TextDecorationStyle {
  /// Draws a single line.
  solid('solid'),

  /// Draws a double line.
  double('double'),

  /// Draws a dotted line.
  dotted('dotted'),

  /// Draws a dashed line.
  dashed('dashed'),

  /// Draws a wavy line.
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

/// The `text-decoration-thickness` CSS property sets the stroke thickness of the decoration line that is used on text in an element,
/// such as a line-through, underline, or overline.
///
/// Read more: [MDN `text-decoration-thickness`](https://developer.mozilla.org/en-US/docs/Web/CSS/text-decoration-thickness)
class TextDecorationThickness {
  /// The css value
  final String value;

  const TextDecorationThickness._(this.value);

  /// The browser chooses an appropriate width for the text decoration line.
  static const TextDecorationThickness auto = TextDecorationThickness._('auto');

  /// If the font file includes information about a preferred thickness, use that value. If the font file doesn't include this information,
  /// behave as if auto was set, with the browser choosing an appropriate thickness.
  static const TextDecorationThickness fromFont = TextDecorationThickness._('from-font');

  /// Specifies the thickness of the text decoration line, overriding the font file suggestion or the browser default.
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

/// The `text-decoration` CSS property sets the appearance of decorative lines on text.
///
/// Read more: [MDN `text-decoration`](https://developer.mozilla.org/en-US/docs/Web/CSS/text-decoration)
class TextDecoration {
  /// The css value
  final String value;

  const TextDecoration._(this.value);

  /// Creates a text decoration with the specified properties.
  const factory TextDecoration({
    TextDecorationLine? line,
    Color? color,
    TextDecorationStyle? style,
    TextDecorationThickness? thickness,
  }) = _TextDecoration;

  static const TextDecoration none = TextDecoration._('none');
  static const TextDecoration inherit = TextDecoration._('inherit');
  static const TextDecoration initial = TextDecoration._('initial');
  static const TextDecoration revert = TextDecoration._('revert');
  static const TextDecoration revertLayer = TextDecoration._('revert-layer');
  static const TextDecoration unset = TextDecoration._('unset');
}

class _TextDecoration implements TextDecoration {
  final TextDecorationLine? line;
  final Color? color;
  final TextDecorationStyle? style;
  final TextDecorationThickness? thickness;

  const _TextDecoration({this.line, this.color, this.style, this.thickness})
    : assert(
        line != null || style != null || color != null || thickness != null,
        'At least one of line, style or color must not be null. For no text decoration, use TextDecoration.none',
      );

  @override
  String get value => [
    if (line != null) line!.value,
    if (style != null) style!.value,
    if (color != null) color!.value,
    if (thickness != null) thickness!.value,
  ].join(' ');
}

/// The `text-shadow` CSS property adds shadows to text.
///
/// It creates one or multiple shadows to be applied to the text and any of its decorations. Each shadow is described by
/// some combination of X and Y offsets from the element, blur radius, and color.
///
/// Read more: [MDN `text-shadow`](https://developer.mozilla.org/en-US/docs/Web/CSS/text-shadow)
class TextShadow {
  const TextShadow._(this.value);

  static const none = TextShadow._('none');
  static const initial = TextShadow._('initial');
  static const inherit = TextShadow._('inherit');
  static const revert = TextShadow._('revert');
  static const revertLayer = TextShadow._('revert-layer');
  static const unset = TextShadow._('unset');

  /// Creates a text shadow with the specified properties.
  const factory TextShadow({required Unit offsetX, required Unit offsetY, Unit? blur, Color? color}) = _TextShadow;

  /// Combines multiple text shadows into one.
  const factory TextShadow.combine(List<TextShadow> shadows) = _CombineTextShadow;

  /// The css value
  final String value;
}

abstract class _ListableTextShadow implements TextShadow {}

class _TextShadow implements _ListableTextShadow {
  const _TextShadow({required this.offsetX, required this.offsetY, this.blur, this.color});

  final Unit offsetX;
  final Unit offsetY;
  final Unit? blur;
  final Color? color;

  @override
  String get value => [
    offsetX.value,
    offsetY.value,
    if (blur != null) blur!.value,
    if (color != null) color!.value,
  ].join(' ');
}

class _CombineTextShadow implements _ListableTextShadow {
  const _CombineTextShadow(this.shadows);

  final List<TextShadow> shadows;

  bool _validateShadows() {
    if (shadows.isEmpty) {
      throw 'TextShadow.combine cannot be empty. For no text shadow, use TextShadow.none';
    }

    for (final shadow in shadows) {
      if (shadow is! _ListableTextShadow) {
        throw 'Cannot use ${shadow.value} as a text shadow list item, only standalone use supported';
      }
    }

    return true;
  }

  @override
  String get value {
    assert(_validateShadows());
    return shadows.map((s) => s.value).join(', ');
  }
}

/// The `text-overflow` CSS property sets how hidden overflow content is signaled to users. It can be clipped, display
/// an ellipsis (…), or display a custom string.
///
/// Read more: [MDN `text-overflow`](https://developer.mozilla.org/en-US/docs/Web/CSS/text-overflow)
enum TextOverflow {
  /// The default for this property. This keyword value will truncate the text at the limit of the content area, therefore the
  /// truncation can happen in the middle of a character.
  clip('clip'),

  /// This keyword value will display an ellipsis ('…') to represent clipped text.
  ///
  /// The ellipsis is displayed inside the content area, decreasing the amount of text displayed. If there is not enough space
  /// to display the ellipsis, it is clipped.
  ellipsis('ellipsis'),

  inherit('inherit'),
  initial('initial'),
  revert('revert'),
  revertLayer('revert-layer'),
  unset('unset');

  /// The css value
  final String value;
  const TextOverflow(this.value);
}

/// The `white-space` CSS property sets how white space inside an element is handled.
///
/// Read more: [MDN `white-space`](https://developer.mozilla.org/en-US/docs/Web/CSS/white-space)
enum WhiteSpace {
  /// Sequences of whitespace are collapsed. Newline characters in the source are handled as other
  /// whitespace. Text will wrap when necessary to fill line boxes.
  normal('normal'),

  /// Text does not wrap across lines. It will overflow its containing element rather than breaking onto a new line.
  noWrap('nowrap'),

  /// Sequences of white space are preserved. Lines are only broken at newline characters in the source and at `<br>` elements.
  pre('pre'),

  /// Sequences of white space are preserved. Lines are broken at newline characters, at `<br>`, and as necessary to fill line boxes.
  preWrap('pre-wrap'),

  /// Sequences of white space are collapsed. Lines are broken at newline characters, at `<br>`, and as necessary to fill line boxes.
  preLine('pre-line'),
  breakSpaces('break-spaces'),

  inherit('inherit'),
  initial('initial'),
  revert('revert'),
  revertLayer('revert-layer'),
  unset('unset');

  /// The css value
  final String value;
  const WhiteSpace(this.value);
}

/// The CSS `quotes` property sets how the browser should render quotation marks that are automatically added to the HTML `<q>` element
/// or added using the open-quotes or close-quotes (or omitted using the no-open-quote and no-close-quote) values of the of the CSS content property.
class Quotes {
  const Quotes._(this.value);

  /// The `open-quote` and `close-quote` values of the content property produce no quotation marks, as if `no-open-quote` and `no-close-quote` were set, respectively.
  static const none = Quotes._('none');

  /// Quotation marks that are typographically appropriate for the inherited language (i.e., via the `lang` attribute set on the parent or other ancestor).
  static const auto = Quotes._('auto');
  static const matchParent = Quotes._('match-parent');

  /// Creates a [Quotes] with the specified primary and optional secondary quotation mark pairs.
  const factory Quotes(
    (String, String) primary, [
    (String, String)? secondary,
  ]) = _Quotes;

  static const inherit = Quotes._('inherit');
  static const initial = Quotes._('initial');
  static const revert = Quotes._('revert');
  static const revertLayer = Quotes._('revert-layer');
  static const unset = Quotes._('unset');

  /// The css value
  final String value;
}

class _Quotes implements Quotes {
  const _Quotes(
    this.primary, [
    this.secondary,
  ]);

  final (String, String) primary;
  final (String, String)? secondary;

  @override
  String get value {
    var quotes = '"${primary.$1}" "${primary.$2}"';
    if (secondary case final secondary?) {
      quotes += ' "${secondary.$1}" "${secondary.$2}"';
    }
    return quotes;
  }
}
