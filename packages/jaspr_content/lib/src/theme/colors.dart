part of 'theme.dart';

/// A set of colors for the page content.
///
/// You can override individual colors, or add new color tokens to the theme.
class ContentColors {
  const ContentColors._();

  static final List<ColorToken> _base = [
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
  ];

  static final ColorToken primary = ColorToken('primary', ThemeColors.gray.$900, dark: Colors.white);
  static final ColorToken background = ColorToken('background', ThemeColors.gray.$100, dark: ThemeColors.gray.$950);
  static final ColorToken text = ColorToken('text', ThemeColors.gray.$700, dark: ThemeColors.gray.$200);
  static final ColorToken headings = ColorToken('content-headings', ThemeColors.gray.$900, dark: Colors.white);
  static final ColorToken lead = ColorToken('content-lead', ThemeColors.gray.$600, dark: ThemeColors.gray.$400);
  static final ColorToken links = ColorToken('content-links', ThemeColors.gray.$900, dark: Colors.white);
  static final ColorToken bold = ColorToken('content-bold', ThemeColors.gray.$900, dark: Colors.white);
  static final ColorToken counters = ColorToken('content-counters', ThemeColors.gray.$500, dark: ThemeColors.gray.$400);
  static final ColorToken bullets = ColorToken('content-bullets', ThemeColors.gray.$300, dark: ThemeColors.gray.$600);
  static final ColorToken hr = ColorToken('content-hr', ThemeColors.gray.$200, dark: ThemeColors.gray.$700);
  static final ColorToken quotes = ColorToken('content-quotes', ThemeColors.gray.$900, dark: ThemeColors.gray.$100);
  static final ColorToken quoteBorders =
      ColorToken('content-quote-borders', ThemeColors.gray.$200, dark: ThemeColors.gray.$700);
  static final ColorToken captions = ColorToken('content-captions', ThemeColors.gray.$500, dark: ThemeColors.gray.$400);
  static final ColorToken kbd = ColorToken('content-kbd', ThemeColors.gray.$900, dark: Colors.white);
  static final ColorToken kbdShadows = ColorToken('content-kbd-shadows', ThemeColors.gray.$900, dark: Colors.white);
  static final ColorToken code = ColorToken('content-code', ThemeColors.gray.$900, dark: Colors.white);
  static final ColorToken preCode = ColorToken('content-pre-code', ThemeColors.gray.$200, dark: ThemeColors.gray.$300);
  static final ColorToken preBg = ColorToken('content-pre-bg', ThemeColors.gray.$800, dark: Color('rgb(0 0 0 / 50%)'));
  static final ColorToken thBorders =
      ColorToken('content-th-borders', ThemeColors.gray.$300, dark: ThemeColors.gray.$600);
  static final ColorToken tdBorders =
      ColorToken('content-td-borders', ThemeColors.gray.$200, dark: ThemeColors.gray.$700);
}

/// A color that holds a variant for light and dark themes.
class ThemeColor implements Color {
  const ThemeColor(this.light, {this.dark});

  final Color light;
  final Color? dark;

  @override
  String get value => light.value;

  @override
  ThemeColor withHue(double hue, {bool replace = true}) {
    return ThemeColor(
      light.withHue(hue, replace: replace),
      dark: dark?.withHue(hue, replace: replace),
    );
  }

  @override
  ThemeColor withLightness(double lightness, {bool replace = true}) {
    return ThemeColor(
      light.withLightness(lightness, replace: replace),
      dark: dark?.withLightness(lightness, replace: replace),
    );
  }

  @override
  ThemeColor withOpacity(double opacity, {bool replace = true}) {
    return ThemeColor(
      light.withOpacity(opacity, replace: replace),
      dark: dark?.withOpacity(opacity, replace: replace),
    );
  }

  @override
  ThemeColor withValues({double? red, double? green, double? blue, double? alpha}) {
    return ThemeColor(
      light.withValues(red: red, green: green, blue: blue, alpha: alpha),
      dark: dark?.withValues(red: red, green: green, blue: blue, alpha: alpha),
    );
  }

  @override
  operator ==(Object other) {
    return other is ThemeColor && other.light == light && other.dark == dark;
  }

  @override
  int get hashCode => Object.hash(light, dark);

  @override
  String toString() => 'ThemeColor($light, dark: $dark)';
}

/// A color token that can be used in a theme.
class ColorToken extends ThemeColor {
  const ColorToken(this.name, super.light, {super.dark});

  final String name;

  @override
  String get value => 'var(--$name)';

  /// Recreates this color token with the new color.
  ///
  /// If [color] is a [ThemeColor], it will apply both the light and dark colors.
  /// Else only the light color will be applied.
  ColorToken apply(Color color) {
    return ColorToken(name, color, dark: color is ThemeColor ? color.dark : null);
  }

  @override
  operator ==(Object other) {
    return other is ColorToken && other.name == name && other.light == light && other.dark == dark;
  }

  @override
  int get hashCode => Object.hash(name, light, dark);

  @override
  String toString() => 'ColorToken($name, light: $light, dark: $dark)';
}

extension on List<ColorToken> {
  List<ColorToken> apply({
    List<ColorToken>? colors,
    bool mergeColors = true,
  }) {
    if (mergeColors && colors != null) {
      final map = {for (final color in this) color.name: color, for (final color in colors) color.name: color};
      return map.values.toList();
    } else {
      return colors ?? this;
    }
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

/// A vast and beautiful color theme.
///
/// This color palette is based on the [Tailwind Colors](https://tailwindcss.com/docs/colors).
class ThemeColors {
  static const ColorSwatch slate = ColorSwatch(
    $50: Color('oklch(0.984 0.003 247.858)'),
    $100: Color('oklch(0.968 0.007 247.896)'),
    $200: Color('oklch(0.929 0.013 255.508)'),
    $300: Color('oklch(0.869 0.022 252.894)'),
    $400: Color('oklch(0.704 0.04 256.788)'),
    $500: Color('oklch(0.554 0.046 257.417)'),
    $600: Color('oklch(0.446 0.043 257.281)'),
    $700: Color('oklch(0.372 0.044 257.287)'),
    $800: Color('oklch(0.279 0.041 260.031)'),
    $900: Color('oklch(0.208 0.042 265.755)'),
    $950: Color('oklch(0.129 0.042 264.695)'),
  );
  static const ColorSwatch gray = ColorSwatch(
    $50: Color('oklch(0.985 0.002 247.839)'),
    $100: Color('oklch(0.967 0.003 264.542)'),
    $200: Color('oklch(0.928 0.006 264.531)'),
    $300: Color('oklch(0.872 0.01 258.338)'),
    $400: Color('oklch(0.707 0.022 261.325)'),
    $500: Color('oklch(0.551 0.027 264.364)'),
    $600: Color('oklch(0.446 0.03 256.802)'),
    $700: Color('oklch(0.373 0.034 259.733)'),
    $800: Color('oklch(0.278 0.033 256.848)'),
    $900: Color('oklch(0.21 0.034 264.665)'),
    $950: Color('oklch(0.13 0.028 261.692)'),
  );
  static const ColorSwatch zinc = ColorSwatch(
    $50: Color('oklch(0.985 0 0)'),
    $100: Color('oklch(0.967 0.001 286.375)'),
    $200: Color('oklch(0.92 0.004 286.32)'),
    $300: Color('oklch(0.871 0.006 286.286)'),
    $400: Color('oklch(0.705 0.015 286.067)'),
    $500: Color('oklch(0.552 0.016 285.938)'),
    $600: Color('oklch(0.442 0.017 285.786)'),
    $700: Color('oklch(0.37 0.013 285.805)'),
    $800: Color('oklch(0.274 0.006 286.033)'),
    $900: Color('oklch(0.21 0.006 285.885)'),
    $950: Color('oklch(0.141 0.005 285.823)'),
  );
  static const ColorSwatch neutral = ColorSwatch(
    $50: Color('oklch(0.985 0 0)'),
    $100: Color('oklch(0.97 0 0)'),
    $200: Color('oklch(0.922 0 0)'),
    $300: Color('oklch(0.87 0 0)'),
    $400: Color('oklch(0.708 0 0)'),
    $500: Color('oklch(0.556 0 0)'),
    $600: Color('oklch(0.439 0 0)'),
    $700: Color('oklch(0.371 0 0)'),
    $800: Color('oklch(0.269 0 0)'),
    $900: Color('oklch(0.205 0 0)'),
    $950: Color('oklch(0.145 0 0)'),
  );
  static const ColorSwatch stone = ColorSwatch(
    $50: Color('oklch(0.985 0.001 106.423)'),
    $100: Color('oklch(0.97 0.001 106.424)'),
    $200: Color('oklch(0.923 0.003 48.717)'),
    $300: Color('oklch(0.869 0.005 56.366)'),
    $400: Color('oklch(0.709 0.01 56.259)'),
    $500: Color('oklch(0.553 0.013 58.071)'),
    $600: Color('oklch(0.444 0.011 73.639)'),
    $700: Color('oklch(0.374 0.01 67.558)'),
    $800: Color('oklch(0.268 0.007 34.298)'),
    $900: Color('oklch(0.216 0.006 56.043)'),
    $950: Color('oklch(0.147 0.004 49.25)'),
  );
  static const ColorSwatch red = ColorSwatch(
    $50: Color('oklch(0.971 0.013 17.38)'),
    $100: Color('oklch(0.936 0.032 17.717)'),
    $200: Color('oklch(0.885 0.062 18.334)'),
    $300: Color('oklch(0.808 0.114 19.571)'),
    $400: Color('oklch(0.704 0.191 22.216)'),
    $500: Color('oklch(0.637 0.237 25.331)'),
    $600: Color('oklch(0.577 0.245 27.325)'),
    $700: Color('oklch(0.505 0.213 27.518)'),
    $800: Color('oklch(0.444 0.177 26.899)'),
    $900: Color('oklch(0.396 0.141 25.723)'),
    $950: Color('oklch(0.258 0.092 26.042)'),
  );
  static const ColorSwatch orange = ColorSwatch(
    $50: Color('oklch(0.98 0.016 73.684)'),
    $100: Color('oklch(0.954 0.038 75.164)'),
    $200: Color('oklch(0.901 0.076 70.697)'),
    $300: Color('oklch(0.837 0.128 66.29)'),
    $400: Color('oklch(0.75 0.183 55.934)'),
    $500: Color('oklch(0.705 0.213 47.604)'),
    $600: Color('oklch(0.646 0.222 41.116)'),
    $700: Color('oklch(0.553 0.195 38.402)'),
    $800: Color('oklch(0.47 0.157 37.304)'),
    $900: Color('oklch(0.408 0.123 38.172)'),
    $950: Color('oklch(0.266 0.079 36.259)'),
  );
  static const ColorSwatch amber = ColorSwatch(
    $50: Color('oklch(0.987 0.022 95.277)'),
    $100: Color('oklch(0.962 0.059 95.617)'),
    $200: Color('oklch(0.924 0.12 95.746)'),
    $300: Color('oklch(0.879 0.169 91.605)'),
    $400: Color('oklch(0.828 0.189 84.429)'),
    $500: Color('oklch(0.769 0.188 70.08)'),
    $600: Color('oklch(0.666 0.179 58.318)'),
    $700: Color('oklch(0.555 0.163 48.998)'),
    $800: Color('oklch(0.473 0.137 46.201)'),
    $900: Color('oklch(0.414 0.112 45.904)'),
    $950: Color('oklch(0.279 0.077 45.635)'),
  );
  static const ColorSwatch yellow = ColorSwatch(
    $50: Color('oklch(0.987 0.026 102.212)'),
    $100: Color('oklch(0.973 0.071 103.193)'),
    $200: Color('oklch(0.945 0.129 101.54)'),
    $300: Color('oklch(0.905 0.182 98.111)'),
    $400: Color('oklch(0.852 0.199 91.936)'),
    $500: Color('oklch(0.795 0.184 86.047)'),
    $600: Color('oklch(0.681 0.162 75.834)'),
    $700: Color('oklch(0.554 0.135 66.442)'),
    $800: Color('oklch(0.476 0.114 61.907)'),
    $900: Color('oklch(0.421 0.095 57.708)'),
    $950: Color('oklch(0.286 0.066 53.813)'),
  );
  static const ColorSwatch lime = ColorSwatch(
    $50: Color('oklch(0.986 0.031 120.757)'),
    $100: Color('oklch(0.967 0.067 122.328)'),
    $200: Color('oklch(0.938 0.127 124.321)'),
    $300: Color('oklch(0.897 0.196 126.665)'),
    $400: Color('oklch(0.841 0.238 128.85)'),
    $500: Color('oklch(0.768 0.233 130.85)'),
    $600: Color('oklch(0.648 0.2 131.684)'),
    $700: Color('oklch(0.532 0.157 131.589)'),
    $800: Color('oklch(0.453 0.124 130.933)'),
    $900: Color('oklch(0.405 0.101 131.063)'),
    $950: Color('oklch(0.274 0.072 132.109)'),
  );
  static const ColorSwatch green = ColorSwatch(
    $50: Color('oklch(0.982 0.018 155.826)'),
    $100: Color('oklch(0.962 0.044 156.743)'),
    $200: Color('oklch(0.925 0.084 155.995)'),
    $300: Color('oklch(0.871 0.15 154.449)'),
    $400: Color('oklch(0.792 0.209 151.711)'),
    $500: Color('oklch(0.723 0.219 149.579)'),
    $600: Color('oklch(0.627 0.194 149.214)'),
    $700: Color('oklch(0.527 0.154 150.069)'),
    $800: Color('oklch(0.448 0.119 151.328)'),
    $900: Color('oklch(0.393 0.095 152.535)'),
    $950: Color('oklch(0.266 0.065 152.934)'),
  );
  static const ColorSwatch emerald = ColorSwatch(
    $50: Color('oklch(0.979 0.021 166.113)'),
    $100: Color('oklch(0.95 0.052 163.051)'),
    $200: Color('oklch(0.905 0.093 164.15)'),
    $300: Color('oklch(0.845 0.143 164.978)'),
    $400: Color('oklch(0.765 0.177 163.223)'),
    $500: Color('oklch(0.696 0.17 162.48)'),
    $600: Color('oklch(0.596 0.145 163.225)'),
    $700: Color('oklch(0.508 0.118 165.612)'),
    $800: Color('oklch(0.432 0.095 166.913)'),
    $900: Color('oklch(0.378 0.077 168.94)'),
    $950: Color('oklch(0.262 0.051 172.552)'),
  );
  static const ColorSwatch teal = ColorSwatch(
    $50: Color('oklch(0.984 0.014 180.72)'),
    $100: Color('oklch(0.953 0.051 180.801)'),
    $200: Color('oklch(0.91 0.096 180.426)'),
    $300: Color('oklch(0.855 0.138 181.071)'),
    $400: Color('oklch(0.777 0.152 181.912)'),
    $500: Color('oklch(0.704 0.14 182.503)'),
    $600: Color('oklch(0.6 0.118 184.704)'),
    $700: Color('oklch(0.511 0.096 186.391)'),
    $800: Color('oklch(0.437 0.078 188.216)'),
    $900: Color('oklch(0.386 0.063 188.416)'),
    $950: Color('oklch(0.277 0.046 192.524)'),
  );
  static const ColorSwatch cyan = ColorSwatch(
    $50: Color('oklch(0.984 0.019 200.873)'),
    $100: Color('oklch(0.956 0.045 203.388)'),
    $200: Color('oklch(0.917 0.08 205.041)'),
    $300: Color('oklch(0.865 0.127 207.078)'),
    $400: Color('oklch(0.789 0.154 211.53)'),
    $500: Color('oklch(0.715 0.143 215.221)'),
    $600: Color('oklch(0.609 0.126 221.723)'),
    $700: Color('oklch(0.52 0.105 223.128)'),
    $800: Color('oklch(0.45 0.085 224.283)'),
    $900: Color('oklch(0.398 0.07 227.392)'),
    $950: Color('oklch(0.302 0.056 229.695)'),
  );
  static const ColorSwatch sky = ColorSwatch(
    $50: Color('oklch(0.977 0.013 236.62)'),
    $100: Color('oklch(0.951 0.026 236.824)'),
    $200: Color('oklch(0.901 0.058 230.902)'),
    $300: Color('oklch(0.828 0.111 230.318)'),
    $400: Color('oklch(0.746 0.16 232.661)'),
    $500: Color('oklch(0.685 0.169 237.323)'),
    $600: Color('oklch(0.588 0.158 241.966)'),
    $700: Color('oklch(0.5 0.134 242.749)'),
    $800: Color('oklch(0.443 0.11 240.79)'),
    $900: Color('oklch(0.391 0.09 240.876)'),
    $950: Color('oklch(0.293 0.066 243.157)'),
  );
  static const ColorSwatch blue = ColorSwatch(
    $50: Color('oklch(0.97 0.014 254.604)'),
    $100: Color('oklch(0.932 0.032 255.585)'),
    $200: Color('oklch(0.882 0.059 254.128)'),
    $300: Color('oklch(0.809 0.105 251.813)'),
    $400: Color('oklch(0.707 0.165 254.624)'),
    $500: Color('oklch(0.623 0.214 259.815)'),
    $600: Color('oklch(0.546 0.245 262.881)'),
    $700: Color('oklch(0.488 0.243 264.376)'),
    $800: Color('oklch(0.424 0.199 265.638)'),
    $900: Color('oklch(0.379 0.146 265.522)'),
    $950: Color('oklch(0.282 0.091 267.935)'),
  );
  static const ColorSwatch indigo = ColorSwatch(
    $50: Color('oklch(0.962 0.018 272.314)'),
    $100: Color('oklch(0.93 0.034 272.788)'),
    $200: Color('oklch(0.87 0.065 274.039)'),
    $300: Color('oklch(0.785 0.115 274.713)'),
    $400: Color('oklch(0.673 0.182 276.935)'),
    $500: Color('oklch(0.585 0.233 277.117)'),
    $600: Color('oklch(0.511 0.262 276.966)'),
    $700: Color('oklch(0.457 0.24 277.023)'),
    $800: Color('oklch(0.398 0.195 277.366)'),
    $900: Color('oklch(0.359 0.144 278.697)'),
    $950: Color('oklch(0.257 0.09 281.288)'),
  );
  static const ColorSwatch violet = ColorSwatch(
    $50: Color('oklch(0.969 0.016 293.756)'),
    $100: Color('oklch(0.943 0.029 294.588)'),
    $200: Color('oklch(0.894 0.057 293.283)'),
    $300: Color('oklch(0.811 0.111 293.571)'),
    $400: Color('oklch(0.702 0.183 293.541)'),
    $500: Color('oklch(0.606 0.25 292.717)'),
    $600: Color('oklch(0.541 0.281 293.009)'),
    $700: Color('oklch(0.491 0.27 292.581)'),
    $800: Color('oklch(0.432 0.232 292.759)'),
    $900: Color('oklch(0.38 0.189 293.745)'),
    $950: Color('oklch(0.283 0.141 291.089)'),
  );
  static const ColorSwatch purple = ColorSwatch(
    $50: Color('oklch(0.977 0.014 308.299)'),
    $100: Color('oklch(0.946 0.033 307.174)'),
    $200: Color('oklch(0.902 0.063 306.703)'),
    $300: Color('oklch(0.827 0.119 306.383)'),
    $400: Color('oklch(0.714 0.203 305.504)'),
    $500: Color('oklch(0.627 0.265 303.9)'),
    $600: Color('oklch(0.558 0.288 302.321)'),
    $700: Color('oklch(0.496 0.265 301.924)'),
    $800: Color('oklch(0.438 0.218 303.724)'),
    $900: Color('oklch(0.381 0.176 304.987)'),
    $950: Color('oklch(0.291 0.149 302.717)'),
  );
  static const ColorSwatch fuchsia = ColorSwatch(
    $50: Color('oklch(0.977 0.017 320.058)'),
    $100: Color('oklch(0.952 0.037 318.852)'),
    $200: Color('oklch(0.903 0.076 319.62)'),
    $300: Color('oklch(0.833 0.145 321.434)'),
    $400: Color('oklch(0.74 0.238 322.16)'),
    $500: Color('oklch(0.667 0.295 322.15)'),
    $600: Color('oklch(0.591 0.293 322.896)'),
    $700: Color('oklch(0.518 0.253 323.949)'),
    $800: Color('oklch(0.452 0.211 324.591)'),
    $900: Color('oklch(0.401 0.17 325.612)'),
    $950: Color('oklch(0.293 0.136 325.661)'),
  );
  static const ColorSwatch pink = ColorSwatch(
    $50: Color('oklch(0.971 0.014 343.198)'),
    $100: Color('oklch(0.948 0.028 342.258)'),
    $200: Color('oklch(0.899 0.061 343.231)'),
    $300: Color('oklch(0.823 0.12 346.018)'),
    $400: Color('oklch(0.718 0.202 349.761)'),
    $500: Color('oklch(0.656 0.241 354.308)'),
    $600: Color('oklch(0.592 0.249 0.584)'),
    $700: Color('oklch(0.525 0.223 3.958)'),
    $800: Color('oklch(0.459 0.187 3.815)'),
    $900: Color('oklch(0.408 0.153 2.432)'),
    $950: Color('oklch(0.284 0.109 3.907)'),
  );
  static const ColorSwatch rose = ColorSwatch(
    $50: Color('oklch(0.969 0.015 12.422)'),
    $100: Color('oklch(0.941 0.03 12.58)'),
    $200: Color('oklch(0.892 0.058 10.001)'),
    $300: Color('oklch(0.81 0.117 11.638)'),
    $400: Color('oklch(0.712 0.194 13.428)'),
    $500: Color('oklch(0.645 0.246 16.439)'),
    $600: Color('oklch(0.586 0.253 17.585)'),
    $700: Color('oklch(0.514 0.222 16.935)'),
    $800: Color('oklch(0.455 0.188 13.697)'),
    $900: Color('oklch(0.41 0.159 10.272)'),
    $950: Color('oklch(0.271 0.105 12.094)'),
  );
}

class ColorSwatch implements Color {
  const ColorSwatch({
    required this.$50,
    required this.$100,
    required this.$200,
    required this.$300,
    required this.$400,
    required this.$500,
    required this.$600,
    required this.$700,
    required this.$800,
    required this.$900,
    required this.$950,
  });

  final Color $50;
  final Color $100;
  final Color $200;
  final Color $300;
  final Color $400;
  final Color $500;
  final Color $600;
  final Color $700;
  final Color $800;
  final Color $900;
  final Color $950;

  @override
  String get value => $500.value;

  @override
  Color withHue(double hue, {bool replace = true}) {
    return ColorSwatch(
      $50: $50.withHue(hue, replace: replace),
      $100: $100.withHue(hue, replace: replace),
      $200: $200.withHue(hue, replace: replace),
      $300: $300.withHue(hue, replace: replace),
      $400: $400.withHue(hue, replace: replace),
      $500: $500.withHue(hue, replace: replace),
      $600: $600.withHue(hue, replace: replace),
      $700: $700.withHue(hue, replace: replace),
      $800: $800.withHue(hue, replace: replace),
      $900: $900.withHue(hue, replace: replace),
      $950: $950.withHue(hue, replace: replace),
    );
  }

  @override
  Color withLightness(double lightness, {bool replace = true}) {
    return ColorSwatch(
      $50: $50.withLightness(lightness, replace: replace),
      $100: $100.withLightness(lightness, replace: replace),
      $200: $200.withLightness(lightness, replace: replace),
      $300: $300.withLightness(lightness, replace: replace),
      $400: $400.withLightness(lightness, replace: replace),
      $500: $500.withLightness(lightness, replace: replace),
      $600: $600.withLightness(lightness, replace: replace),
      $700: $700.withLightness(lightness, replace: replace),
      $800: $800.withLightness(lightness, replace: replace),
      $900: $900.withLightness(lightness, replace: replace),
      $950: $950.withLightness(lightness, replace: replace),
    );
  }

  @override
  Color withOpacity(double opacity, {bool replace = true}) {
    return ColorSwatch(
      $50: $50.withOpacity(opacity, replace: replace),
      $100: $100.withOpacity(opacity, replace: replace),
      $200: $200.withOpacity(opacity, replace: replace),
      $300: $300.withOpacity(opacity, replace: replace),
      $400: $400.withOpacity(opacity, replace: replace),
      $500: $500.withOpacity(opacity, replace: replace),
      $600: $600.withOpacity(opacity, replace: replace),
      $700: $700.withOpacity(opacity, replace: replace),
      $800: $800.withOpacity(opacity, replace: replace),
      $900: $900.withOpacity(opacity, replace: replace),
      $950: $950.withOpacity(opacity, replace: replace),
    );
  }

  @override
  Color withValues({double? red, double? green, double? blue, double? alpha}) {
    return ColorSwatch(
      $50: $50.withValues(red: red, green: green, blue: blue, alpha: alpha),
      $100: $100.withValues(red: red, green: green, blue: blue, alpha: alpha),
      $200: $200.withValues(red: red, green: green, blue: blue, alpha: alpha),
      $300: $300.withValues(red: red, green: green, blue: blue, alpha: alpha),
      $400: $400.withValues(red: red, green: green, blue: blue, alpha: alpha),
      $500: $500.withValues(red: red, green: green, blue: blue, alpha: alpha),
      $600: $600.withValues(red: red, green: green, blue: blue, alpha: alpha),
      $700: $700.withValues(red: red, green: green, blue: blue, alpha: alpha),
      $800: $800.withValues(red: red, green: green, blue: blue, alpha: alpha),
      $900: $900.withValues(red: red, green: green, blue: blue, alpha: alpha),
      $950: $950.withValues(red: red, green: green, blue: blue, alpha: alpha),
    );
  }
}
