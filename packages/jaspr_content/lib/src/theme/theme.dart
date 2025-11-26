import 'package:jaspr/dom.dart';
// ignore: implementation_imports
import 'package:jaspr/src/dom/styles/css.dart' show StyleRuleResolve;
// ignore: implementation_imports
import 'package:jaspr/src/dom/styles/rules.dart' show BlockStyleRule;

part '_base.dart';
part '_reset.dart';
part 'colors.dart';
part 'typography.dart';

/// A theme for content-driven sites.
///
/// The theme provides colors and typography styles for a page.
/// When no theme is provided, the default [ContentColors] and [ContentTypography] are used.
class ContentTheme {
  /// Creates a default theme and applies the provided colors, fonts and styles.
  ContentTheme({
    Color? primary,
    Color? background,
    Color? text,
    List<ColorToken> colors = const [],
    FontFamily? font,
    FontFamily? codeFont,
    ContentTypography? typography,
    Iterable<ThemeExtension<Object?>> extensions = const [],
  }) : colors = ContentColors._base.apply(
         colors: [
           ...colors,
           if (primary != null) ContentColors.primary.apply(primary),
           if (background != null) ContentColors.background.apply(background),
           if (text != null) ContentColors.text.apply(text),
         ],
       ),
       font = font ?? defaultFont,
       codeFont = codeFont ?? defaultCodeFont,
       typography = typography ?? ContentTypography.base,
       extensions = Map<Object, ThemeExtension<Object?>>.unmodifiable(<Object, ThemeExtension<Object?>>{
         for (final ThemeExtension<Object?> extension in extensions)
           extension.type: extension as ThemeExtension<ThemeExtension<Object?>>,
       }),
       reset = true;

  /// Creates an empty theme and applies the provided colors, fonts and styles.
  ContentTheme.raw({
    List<ColorToken> colors = const [],
    this.font,
    this.codeFont,
    this.typography = const ContentTypography.none(),
    Iterable<ThemeExtension<Object?>> extensions = const [],
    this.reset = false,
  }) : colors = List<ColorToken>.unmodifiable(colors),
       extensions = Map<Object, ThemeExtension<Object?>>.unmodifiable(<Object, ThemeExtension<Object?>>{
         for (final ThemeExtension<Object?> extension in extensions)
           extension.type: extension as ThemeExtension<ThemeExtension<Object?>>,
       });

  /// Disables any theming and styles for the page.
  const factory ContentTheme.none() = _NoContentTheme;

  /// The current font family, represented by the `--content-font` CSS variable.
  static final FontFamily currentFont = FontFamily.variable('--content-font');

  /// The current code font family, represented by the `--content-code-font` CSS variable.
  static final FontFamily currentCodeFont = FontFamily.variable('--content-code-font');

  /// The default font family to use for the page.
  static final defaultFont = _defaultFont;

  /// The default font family to use for code blocks and similar elements.
  static final defaultCodeFont = _defaultCodeFont;

  /// Whether the theme is enabled. This is false for [ContentTheme.none].
  final bool enabled = true;

  /// A set of color tokens for the site.
  final List<ColorToken> colors;

  /// The font family used for content on the page.
  final FontFamily? font;

  /// The font family used for code blocks and similar elements.
  final FontFamily? codeFont;

  /// The typography styles to use for the content.
  final ContentTypography typography;

  /// Arbitrary additions to this theme.
  ///
  /// To obtain an extension, use [extension].
  final Map<Object, ThemeExtension<Object?>> extensions;

  /// Whether to apply a set of CSS reset styles to the page.
  final bool reset;

  ContentTheme apply({
    List<ColorToken>? colors,
    FontFamily? font,
    FontFamily? codeFont,
    ContentTypography? typography,
    Iterable<ThemeExtension<Object?>>? extensions,
  }) {
    return ContentTheme(
      colors: colors != null ? this.colors.apply(colors: colors) : this.colors,
      font: font ?? this.font,
      codeFont: codeFont ?? this.codeFont,
      typography: typography ?? this.typography,
      extensions: extensions != null ? [...this.extensions.values, ...extensions] : this.extensions.values,
    );
  }

  ContentTheme copyWith({
    List<ColorToken>? colors,
    FontFamily? font,
    FontFamily? codeFont,
    ContentTypography? typography,
    Iterable<ThemeExtension<Object?>>? extensions,
  }) {
    return ContentTheme(
      colors: colors ?? this.colors,
      font: font ?? this.font,
      codeFont: codeFont ?? this.codeFont,
      typography: typography ?? this.typography,
      extensions: extensions ?? this.extensions.values,
    );
  }

  /// Used to obtain a particular [ThemeExtension] from [extensions].
  ///
  /// Obtain with `Content.themeOf(context).extension<MyThemeExtension>()`.
  T? extension<T>() => extensions[T] as T?;

  List<StyleRule> get styles {
    final colors = this.colors;
    final typography = this.typography;

    final hasTextToken = colors.any((color) => color.name == ContentColors.text.name);
    final hasBackgroundToken = colors.any((color) => color.name == ContentColors.background.name);

    final variables = <String, String>{
      if (font case final font?) '--content-font': font.value,
      if (codeFont case final codeFont?) '--content-code-font': codeFont.value,
    };

    for (final extension in extensions.values) {
      final vars = extension.buildVariables(this);
      for (final MapEntry(:key, :value) in vars.entries) {
        assert(key.startsWith('--'), 'CSS variable names must start with "--": $key');
        if (value is ColorToken && colors.any((c) => c.name == value.name)) {
          // Refer to global colors that are already defined in the theme.
          variables[key] = 'var(--${value.name})';
        } else if (value is ThemeColor) {
          colors.add(ColorToken(key.substring(2), value.light, dark: value.dark));
        } else if (value is Color) {
          colors.add(ColorToken(key.substring(2), value));
        } else if (value is Unit) {
          variables[key] = value.value;
        } else {
          variables[key] = value.toString();
        }
      }
    }

    return [
      ...colors.build(),
      if (reset) ..._resetStyles,
      if (variables.isNotEmpty)
        css(':root').styles(
          raw: {
            for (final MapEntry(:key, :value) in variables.entries) key: value,
          },
        ),
      if (font != null) css(':host,html').styles(fontFamily: currentFont),
      if (codeFont != null) css('code, kbd, pre, samp').styles(fontFamily: currentCodeFont),
      if (hasTextToken || hasBackgroundToken)
        css('body').styles(
          color: hasTextToken ? ContentColors.text : null,
          backgroundColor: hasBackgroundToken ? ContentColors.background : null,
        ),
      typography.build(),
      for (final extension in extensions.values) ...extension.buildStyles(this),
    ];
  }
}

class _NoContentTheme implements ContentTheme {
  const _NoContentTheme();

  @override
  bool get enabled => false;

  @override
  List<ColorToken> get colors => [];

  @override
  FontFamily? get font => null;

  @override
  FontFamily? get codeFont => null;

  @override
  ContentTypography get typography => const ContentTypography.none();

  @override
  Map<Object, ThemeExtension<Object?>> get extensions => {};

  @override
  bool get reset => false;

  @override
  List<StyleRule> get styles => [];

  @override
  ContentTheme apply({
    List<ColorToken>? colors,
    FontFamily? font,
    FontFamily? codeFont,
    ContentTypography? typography,
    Iterable<ThemeExtension<Object?>>? extensions,
  }) => this;

  @override
  ContentTheme copyWith({
    List<ColorToken>? colors,
    FontFamily? font,
    FontFamily? codeFont,
    ContentTypography? typography,
    Iterable<ThemeExtension<Object?>>? extensions,
  }) => this;

  @override
  T? extension<T>() => null;
}

/// An interface that defines custom additions to a [ContentTheme] object.
abstract class ThemeExtension<T extends ThemeExtension<T>> {
  const ThemeExtension();

  /// The extension's type.
  Object get type => T;

  /// Creates a copy of this theme extension with the given fields
  /// replaced by the non-null parameter values.
  ThemeExtension<T> copyWith();

  /// Builds CSS variables for this extension.
  Map<String, Object> buildVariables(ContentTheme theme) => {};

  /// Builds additional styles for this extension.
  List<StyleRule> buildStyles(ContentTheme theme) => [];
}
