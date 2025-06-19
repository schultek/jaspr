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
/// When no theme is provided, the default [ContentColors] and [ContentTypography] are used.
class ContentTheme {
  /// Creates a new theme with the provided colors, fonts and styles.
  ContentTheme({
    Color? primary,
    Color? background,
    Color? text,
    List<ColorToken> colors = const [],
    FontFamily? font,
    FontFamily? codeFont,
    ContentTypography? typography,
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
       reset = true;

  /// Disables any theming and styles for the page.
  const ContentTheme.none()
    : colors = const [],
      font = null,
      codeFont = null,
      typography = const ContentTypography(styles: Styles(), rules: []),
      reset = false;

  /// A set of color tokens for the site.
  final List<ColorToken> colors;

  /// The font family to use for the page.
  final FontFamily? font;

  /// The font family to use for code blocks and similar elements.
  final FontFamily? codeFont;

  /// The typography styles to use for the content.
  final ContentTypography typography;

  /// Whether to apply a set of CSS reset styles to the page.
  final bool reset;

  /// The default font family to use for the page.
  static final defaultFont = _defaultFont;

  /// The default font family to use for code blocks and similar elements.
  static final defaultCodeFont = _defaultCodeFont;

  ContentTheme apply({
    List<ColorToken>? colors,
    FontFamily? font,
    FontFamily? codeFont,
    ContentTypography? typography,
    bool mergeColors = true,
  }) {
    return copyWith(
      colors: mergeColors && colors != null
          ? this.colors.apply(colors: colors)
          : colors ?? this.colors,
      font: font ?? this.font,
      codeFont: codeFont ?? this.codeFont,
      typography: typography,
    );
  }

  ContentTheme copyWith({
    List<ColorToken>? colors,
    FontFamily? font,
    FontFamily? codeFont,
    ContentTypography? typography,
  }) {
    return ContentTheme(
      colors: colors ?? this.colors,
      font: font ?? this.font,
      codeFont: codeFont ?? this.codeFont,
      typography: typography ?? this.typography,
    );
  }

  List<StyleRule> get styles {
    final colors = this.colors;
    final typography = this.typography;

    final hasTextToken = colors.any(
      (color) => color.name == ContentColors.text.name,
    );
    final hasBackgroundToken = colors.any(
      (color) => color.name == ContentColors.background.name,
    );

    return [
      ...colors.build(),
      if (reset) ..._resetStyles,
      if (font != null)
        css(':host,html').styles(
          fontFamily: font,
        ),
      if (codeFont != null)
        css('code, kbd, pre, samp').styles(
          fontFamily: codeFont,
        ),
      if (hasTextToken || hasBackgroundToken)
        css('body').styles(
          color: hasTextToken ? ContentColors.text : null,
          backgroundColor: hasBackgroundToken ? ContentColors.background : null,
        ),
      typography.build(),
    ];
  }
}
