import 'package:jaspr/jaspr.dart';
// ignore: implementation_imports
import 'package:jaspr/src/foundation/styles/css.dart';

part '_base.dart';
part '_reset.dart';
part 'colors.dart';
part 'typography.dart';

/// A theme for content-driven sites.
///
/// The theme provides colors and typography styles for a page.
/// When no theme is provided, the default [ContentColors.gray] and [ContentTypography.base] are used.
class ContentTheme {
  /// Creates a new theme with the provided colors.
  factory ContentTheme({
    Color? primary,
    Color? background,
    Color? text,
    List<ColorToken> colors = const [],
  }) {
    return ContentTheme.custom(
      colors: ContentColors._base.apply(colors: {
        ...colors,
        if (primary != null) ContentColors.primary.apply(primary),
        if (background != null) ContentColors.background.apply(background),
        if (text != null) ContentColors.text.apply(text),
      }),
    );
  }

  /// Creates a new theme with the provided colors and typography.
  const ContentTheme.custom({this.colors, this.typography});

  final Set<ColorToken>? colors;
  final ContentTypography? typography;

  ContentTheme apply({
    Set<ColorToken>? colors,
    ContentTypography? typography,
  }) {
    return copyWith(colors: colors, typography: typography);
  }

  ContentTheme copyWith({
    Set<ColorToken>? colors,
    ContentTypography? typography,
  }) {
    return ContentTheme.custom(
      colors: colors ?? this.colors,
      typography: typography ?? this.typography,
    );
  }

  List<StyleRule> get styles {
    final colors = this.colors ?? ContentColors._base;
    final typography = this.typography ?? ContentTypography.base;

    return [
      ...colors.build(),
      css('body').styles(
        color: ContentColors.text,
        backgroundColor: ContentColors.background,
      ),
      typography.build(),
    ];
  }
}

/// A set of colors for the page content.
///
/// You can override individual colors, or add new color tokens to the theme.
class ContentColors {
  const ContentColors._();

  static final Set<ColorToken> _base = {
    primary,
    background,
    text,
    headings,
    lead,
    links,
    bold,
    counters,
    bullets,
    hr,
    quotes,
    quoteBorders,
    captions,
    kbd,
    kbdShadows,
    code,
    preCode,
    preBg,
    thBorders,
    tdBorders,
  };

  static final ColorToken primary = ColorToken('primary', ColorTheme.gray.$900, dark: Colors.white);
  static final ColorToken background = ColorToken('background', ColorTheme.gray.$100, dark: ColorTheme.gray.$900);
  static final ColorToken text = ColorToken('text', ColorTheme.gray.$700, dark: ColorTheme.gray.$200);
  static final ColorToken headings = ColorToken('content-headings', ColorTheme.gray.$900, dark: Colors.white);
  static final ColorToken lead = ColorToken('content-lead', ColorTheme.gray.$600, dark: ColorTheme.gray.$400);
  static final ColorToken links = ColorToken('content-links', ColorTheme.gray.$900, dark: Colors.white);
  static final ColorToken bold = ColorToken('content-bold', ColorTheme.gray.$900, dark: Colors.white);
  static final ColorToken counters = ColorToken('content-counters', ColorTheme.gray.$500, dark: ColorTheme.gray.$400);
  static final ColorToken bullets = ColorToken('content-bullets', ColorTheme.gray.$300, dark: ColorTheme.gray.$600);
  static final ColorToken hr = ColorToken('content-hr', ColorTheme.gray.$200, dark: ColorTheme.gray.$700);
  static final ColorToken quotes = ColorToken('content-quotes', ColorTheme.gray.$900, dark: ColorTheme.gray.$100);
  static final ColorToken quoteBorders =
      ColorToken('content-quote-borders', ColorTheme.gray.$200, dark: ColorTheme.gray.$700);
  static final ColorToken captions = ColorToken('content-captions', ColorTheme.gray.$500, dark: ColorTheme.gray.$400);
  static final ColorToken kbd = ColorToken('content-kbd', ColorTheme.gray.$900, dark: Colors.white);
  static final ColorToken kbdShadows = ColorToken('content-kbd-shadows', ColorTheme.gray.$900, dark: Colors.white);
  static final ColorToken code = ColorToken('content-code', ColorTheme.gray.$900, dark: Colors.white);
  static final ColorToken preCode = ColorToken('content-pre-code', ColorTheme.gray.$200, dark: ColorTheme.gray.$300);
  static final ColorToken preBg = ColorToken('content-pre-bg', ColorTheme.gray.$800, dark: Color('rgb(0 0 0 / 50%)'));
  static final ColorToken thBorders =
      ColorToken('content-th-borders', ColorTheme.gray.$300, dark: ColorTheme.gray.$600);
  static final ColorToken tdBorders =
      ColorToken('content-td-borders', ColorTheme.gray.$200, dark: ColorTheme.gray.$700);
}

extension on Set<ColorToken> {
  Set<ColorToken> apply({
    Set<ColorToken>? colors,
    bool mergeColors = true,
  }) {
    return mergeColors && colors != null ? {...this, ...colors} : colors ?? this;
  }

  List<StyleRule> build() {
    final colors = {
      for (final color in this) '--${color.name}': color,
    };

    final light = {for (final entry in colors.entries) entry.key: entry.value.light.value};

    final dark = {
      for (final entry in colors.entries)
        if (entry.value case ThemeColor(:final dark?)) entry.key: dark.value,
    };

    return [
      css(':root').styles(raw: light),
      if (dark.isNotEmpty) css(':root[data-theme="dark"]').styles(raw: dark),
    ];
  }
}
