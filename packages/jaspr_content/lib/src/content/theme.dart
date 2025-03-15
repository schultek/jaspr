part of 'content.dart';

class ThemeColor implements Color {
  const ThemeColor(this.light, {this.dark});

  final Color light;
  final Color? dark;

  @override
  String get value => light.value;
}

class ColorToken extends ThemeColor {
  const ColorToken(this.name, super.light, {super.dark});

  final String name;

  @override
  String get value => 'var(--theme-token-$name)';

  @override
  operator ==(Object other) {
    return other is ColorToken && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'ColorToken($name)';
}

class ContentTheme {
  factory ContentTheme({
    Color? primary,
    Color? background,
    ContentColors? base,
    List<ColorToken> tokens = const [],
  }) {
    return ContentTheme.custom(
      colors: (base ?? ContentColors.gray).copyWith(
        primary: primary,
        background: background,
        tokens: tokens.toSet(),
      ),
    );
  }

  const ContentTheme.custom({this.colors, this.layout});

  static const Color primary = Color.variable('--theme-primary');
  static const Color background = Color.variable('--theme-background');
  static const Color text = Color.variable('--theme-text');

  final ContentColors? colors;
  final ContentLayout? layout;

  ContentTheme copyWith({
    ContentColors? colors,
    ContentLayout? layout,
  }) {
    return ContentTheme.custom(
      colors: colors ?? this.colors,
      layout: layout ?? this.layout,
    );
  }

  List<StyleRule> get styles {
    final colors = this.colors ?? ContentColors.gray;
    final layout = this.layout ?? ContentLayout.base;

    return [
      ...colors.build(),
      layout.build(),
    ];
  }
}

class ContentColors {
  const ContentColors({
    required this.primary,
    required this.background,
    required this.text,
    required this.headings,
    required this.lead,
    required this.links,
    required this.bold,
    required this.counters,
    required this.bullets,
    required this.hr,
    required this.quotes,
    required this.quoteBorders,
    required this.captions,
    required this.kbd,
    required this.kbdShadows,
    required this.code,
    required this.preCode,
    required this.preBg,
    required this.thBorders,
    required this.tdBorders,
    this.tokens = const {},
  });

  static final ContentColors gray = ContentColors(
    primary: ThemeColor(colors.gray.$900, dark: Colors.white),
    background: ThemeColor(colors.gray.$100, dark: colors.gray.$900),
    text: ThemeColor(colors.gray.$700, dark: colors.gray.$200),
    headings: ThemeColor(colors.gray.$900, dark: Colors.white),
    lead: ThemeColor(colors.gray.$600, dark: colors.gray.$400),
    links: ThemeColor(colors.gray.$900, dark: Colors.white),
    bold: ThemeColor(colors.gray.$900, dark: Colors.white),
    counters: ThemeColor(colors.gray.$500, dark: colors.gray.$400),
    bullets: ThemeColor(colors.gray.$300, dark: colors.gray.$600),
    hr: ThemeColor(colors.gray.$200, dark: colors.gray.$700),
    quotes: ThemeColor(colors.gray.$900, dark: colors.gray.$100),
    quoteBorders: ThemeColor(colors.gray.$200, dark: colors.gray.$700),
    captions: ThemeColor(colors.gray.$500, dark: colors.gray.$400),
    kbd: ThemeColor(colors.gray.$900, dark: Colors.white),
    kbdShadows: ThemeColor(colors.gray.$900, dark: Colors.white),
    code: ThemeColor(colors.gray.$900, dark: Colors.white),
    preCode: ThemeColor(colors.gray.$200, dark: colors.gray.$300),
    preBg: ThemeColor(colors.gray.$800, dark: Color('rgb(0 0 0 / 50%)')),
    thBorders: ThemeColor(colors.gray.$300, dark: colors.gray.$600),
    tdBorders: ThemeColor(colors.gray.$200, dark: colors.gray.$700),
  );

  final Color primary;
  final Color background;
  final Color text;
  final Color headings;
  final Color lead;
  final Color links;
  final Color bold;
  final Color counters;
  final Color bullets;
  final Color hr;
  final Color quotes;
  final Color quoteBorders;
  final Color captions;
  final Color kbd;
  final Color kbdShadows;
  final Color code;
  final Color preCode;
  final Color preBg;
  final Color thBorders;
  final Color tdBorders;
  final Set<ColorToken> tokens;

  ContentColors copyWith({
    Color? primary,
    Color? background,
    Color? text,
    Color? headings,
    Color? lead,
    Color? links,
    Color? bold,
    Color? counters,
    Color? bullets,
    Color? hr,
    Color? quotes,
    Color? quoteBorders,
    Color? captions,
    Color? kbd,
    Color? kbdShadows,
    Color? code,
    Color? preCode,
    Color? preBg,
    Color? thBorders,
    Color? tdBorders,
    Set<ColorToken>? tokens,
    bool mergeTokens = true,
  }) {
    return ContentColors(
      primary: primary ?? this.primary,
      background: background ?? this.background,
      text: text ?? this.text,
      headings: headings ?? this.headings,
      lead: lead ?? this.lead,
      links: links ?? this.links,
      bold: bold ?? this.bold,
      counters: counters ?? this.counters,
      bullets: bullets ?? this.bullets,
      hr: hr ?? this.hr,
      quotes: quotes ?? this.quotes,
      quoteBorders: quoteBorders ?? this.quoteBorders,
      captions: captions ?? this.captions,
      kbd: kbd ?? this.kbd,
      kbdShadows: kbdShadows ?? this.kbdShadows,
      code: code ?? this.code,
      preCode: preCode ?? this.preCode,
      preBg: preBg ?? this.preBg,
      thBorders: thBorders ?? this.thBorders,
      tdBorders: tdBorders ?? this.tdBorders,
      tokens: mergeTokens && tokens != null ? {...this.tokens, ...tokens} : tokens ?? this.tokens,
    );
  }
}

extension on ContentColors {
  List<StyleRule> build() {
    final colors = {
      '--theme-primary': primary,
      '--theme-background': background,
      '--theme-text': this.text,
      '--content-headings': headings,
      '--content-lead': lead,
      '--content-links': links,
      '--content-bold': bold,
      '--content-counters': counters,
      '--content-bullets': bullets,
      '--content-hr': this.hr,
      '--content-quotes': quotes,
      '--content-quote-borders': quoteBorders,
      '--content-captions': captions,
      '--content-kbd': kbd,
      '--content-kbd-shadows': kbdShadows,
      '--content-code': this.code,
      '--content-pre-code': preCode,
      '--content-pre-bg': preBg,
      '--content-th-borders': thBorders,
      '--content-td-borders': tdBorders,
      for (final token in tokens) '--theme-token-${token.name}': token,
    };

    final light = {
      for (final entry in colors.entries)
        if (entry.value case ThemeColor(:final light))
          entry.key: light.value //
        else
          entry.key: entry.value.value,
    };

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
