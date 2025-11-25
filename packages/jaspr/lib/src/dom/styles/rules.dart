import '../../foundation/constants.dart';
import 'selector.dart';
import 'styles.dart';

abstract class StyleRule {
  /// Renders a css rule with the given selector and styles.
  const factory StyleRule({required Selector selector, required Styles styles}) = BlockStyleRule;

  /// Renders a `@import url(...)` css rule.
  ///
  /// The `@import` CSS at-rule is used to import style rules from other valid stylesheets.
  const factory StyleRule.import(String url) = ImportStyleRule;

  /// Renders a `@font-face` css rule.
  ///
  /// The `@font-face` CSS at-rule specifies a custom font with which to display text; the font can be loaded from
  /// either a remote server or a locally-installed font on the user's own computer.
  const factory StyleRule.fontFace({required String family, FontStyle? style, required String url}) = FontFaceStyleRule;

  /// Renders a `@media` css rule.
  ///
  /// The `@media` CSS at-rule can be used to apply part of a style sheet based on the result of one or more media
  /// queries. With it, you specify a media query and a block of CSS to apply to the document if and only if the media
  /// query matches the device on which the content is being used.
  const factory StyleRule.media({required MediaQuery query, required List<StyleRule> styles}) = MediaStyleRule;

  /// Renders a `@layer` css rule.
  ///
  /// The `@layer` CSS at-rule is used to declare a cascade layer and can also be used to define the order of
  /// precedence in case of multiple cascade layers.
  const factory StyleRule.layer({String? name, required List<StyleRule> styles}) = LayerStyleRule;

  /// Renders a `@supports` css rule.
  ///
  /// The `@supports` CSS at-rule lets you specify CSS declarations that depend on a browser's support for CSS
  /// features. Using this at-rule is commonly called a feature query. The rule must be placed at the top level of
  /// your code or nested inside any other conditional group at-rule.
  const factory StyleRule.supports({required String condition, required List<StyleRule> styles}) = SupportsStyleRule;

  /// Renders a `@keyframes` css rule.
  ///
  /// The `@keyframes` CSS at-rule controls the intermediate steps in a CSS animation sequence by defining styles for
  /// keyframes (or waypoints) along the animation sequence. This gives more control over the intermediate steps of
  /// the animation sequence than transitions.
  const factory StyleRule.keyframes({required String name, required Map<String, Styles> styles}) = KeyframesStyleRule;

  /// Returns the rendered css for this rule.
  String toCss([String indent]);
}

const cssBlockInset = kDebugMode || kGenerateMode ? '  ' : '';
const cssPropSpace = kDebugMode || kGenerateMode ? '\n' : ' ';

extension StyleRulesRender on Iterable<StyleRule> {
  /// Renders a list of style rules into raw css.
  ///
  /// @import rules are hoisted to the beginning of the rendered css rules
  /// as only there they are used by the css engine.
  String render() {
    final imports = StringBuffer();
    final rules = StringBuffer();
    for (final rule in this) {
      final output = rule.toCss() + cssPropSpace;
      if (rule is ImportStyleRule) {
        imports.write(output);
      } else {
        rules.write(output);
      }
    }

    return (imports.toString() + rules.toString()).trimRight();
  }
}

class BlockStyleRule implements StyleRule {
  const BlockStyleRule({required this.selector, required this.styles});

  final Selector selector;
  final Styles styles;

  @override
  String toCss([String indent = '']) {
    return '$indent${selector.selector} {$cssPropSpace'
        '${styles.properties.entries.map((e) => '$indent$cssBlockInset${e.key}: ${e.value};$cssPropSpace').join()}'
        '$indent}';
  }
}

class MediaStyleRule implements StyleRule {
  const MediaStyleRule({required this.query, required this.styles});

  final MediaQuery query;
  final List<StyleRule> styles;

  @override
  String toCss([String indent = '']) {
    return '$indent@media ${query._value} {$cssPropSpace'
        '${styles.map((r) => r.toCss('$indent$cssBlockInset') + cssPropSpace).join()}'
        '$indent}';
  }
}

/// Media queries allow you to apply CSS styles depending on a device's media type (such as `print` vs. `screen`) or other
/// features or characteristics such as screen resolution or orientation, aspect ratio, browser viewport width or
/// height, user preferences such as preferring reduced motion, data usage, or transparency.
abstract class MediaQuery {
  String get _value;

  /// Creates a media query that matches all media types.
  const factory MediaQuery.all({
    Unit? minWidth,
    Unit? maxWidth,
    Unit? minHeight,
    Unit? maxHeight,
    Orientation? orientation,
    bool? canHover,
    String? aspectRatio,
    ColorScheme? prefersColorScheme,
    Contrast? prefersContrast,
  }) = _MediaRuleQuery.all;

  /// Creates a media query that matches screen media types.
  const factory MediaQuery.screen({
    Unit? minWidth,
    Unit? maxWidth,
    Unit? minHeight,
    Unit? maxHeight,
    Orientation? orientation,
    bool? canHover,
    String? aspectRatio,
    ColorScheme? prefersColorScheme,
    Contrast? prefersContrast,
  }) = _MediaRuleQuery.screen;

  /// Creates a media query that matches print media types.
  ///
  /// This is intended for paged material and documents viewed on a screen in print preview mode.
  const factory MediaQuery.print({
    Unit? minWidth,
    Unit? maxWidth,
    Unit? minHeight,
    Unit? maxHeight,
    Orientation? orientation,
    bool? canHover,
    String? aspectRatio,
    ColorScheme? prefersColorScheme,
    Contrast? prefersContrast,
  }) = _MediaRuleQuery.print;

  /// Creates a media query that negates the given query, returning `true` if the query would otherwise return `false`.
  const factory MediaQuery.not(MediaQuery query) = _NotMediaRuleQuery;

  /// Combines multiple media queries into a single rule.
  ///
  /// Each query in a comma-separated list is treated separately from the others. Thus, if any of the queries in a list
  /// is `true`, the entire media statement returns `true`. In other words, lists behave like a logical `or` operator.
  const factory MediaQuery.any(List<MediaQuery> queries) = _AnyMediaRuleQuery;

  /// Creates a media query from a custom string.
  const factory MediaQuery.raw(String query) = _RawMediaQuery;
}

/// The `orientation` CSS media feature can be used to test the orientation of the viewport
/// (or the page box, for paged media).
enum Orientation {
  /// The viewport is in a portrait orientation, i.e., the height is greater than or equal to the width.
  portrait,

  /// The viewport is in a landscape orientation, i.e., the width is greater than the height.
  landscape,
}

/// The `prefers-color-scheme` CSS media feature is used to detect if a user has requested light or dark color themes.
/// A user indicates their preference through an operating system setting (e.g., light or dark mode) or
/// a user agent setting.
enum ColorScheme {
  /// Indicates that user has notified that they prefer an interface that has a light theme, or has not expressed an
  /// active preference.
  light,

  /// Indicates that user has notified that they prefer an interface that has a dark theme.
  dark,
}

/// The `prefers-contrast` CSS media feature is used to detect whether the user has requested the web content to be
/// presented with a lower or higher contrast.
enum Contrast {
  /// Indicates that user has notified the system that they prefer an interface that has a higher level of contrast.
  more('more'),

  /// Indicates that user has notified the system that they prefer an interface that has a lower level of contrast.
  less('less'),

  /// Indicates that the user has made no preference known to the system. This keyword value evaluates as false in the Boolean context.
  noPreference('no-preference'),

  /// Indicates that user has notified the system for using a specific set of colors, and the contrast implied by these colors matches neither more nor less.
  /// This value will match the color palette specified by users of `forced-colors: active
  custom('custom');

  const Contrast(this.value);

  final String value;
}

class _MediaRuleQuery implements MediaQuery {
  const _MediaRuleQuery.all({
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,
    this.orientation,
    this.canHover,
    this.aspectRatio,
    this.prefersColorScheme,
    this.prefersContrast,
  }) : target = 'all';

  const _MediaRuleQuery.screen({
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,
    this.orientation,
    this.canHover,
    this.aspectRatio,
    this.prefersColorScheme,
    this.prefersContrast,
  }) : target = 'screen';

  const _MediaRuleQuery.print({
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,
    this.orientation,
    this.canHover,
    this.aspectRatio,
    this.prefersColorScheme,
    this.prefersContrast,
  }) : target = 'print';

  final String target;
  final Unit? minWidth;
  final Unit? maxWidth;
  final Unit? minHeight;
  final Unit? maxHeight;
  final Orientation? orientation;
  final bool? canHover;
  final String? aspectRatio;
  final ColorScheme? prefersColorScheme;
  final Contrast? prefersContrast;

  @override
  String get _value =>
      '$target'
      '${minWidth != null ? ' and (min-width: ${minWidth!.value})' : ''}'
      '${maxWidth != null ? ' and (max-width: ${maxWidth!.value})' : ''}'
      '${minHeight != null ? ' and (min-height: ${minHeight!.value})' : ''}'
      '${maxHeight != null ? ' and (max-height: ${maxHeight!.value})' : ''}'
      '${orientation != null ? ' and (orientation: ${orientation!.name})' : ''}'
      '${canHover != null ? ' and (hover: ${canHover! ? 'hover' : 'none'})' : ''}'
      '${prefersColorScheme != null ? ' and (prefers-color-scheme: ${prefersColorScheme!.name})' : ''}'
      '${prefersContrast != null ? ' and (prefers-contrast: ${prefersContrast!.name})' : ''}'
      '${aspectRatio != null ? ' and (aspect-ratio: ${aspectRatio!})' : ''}';
}

class _NotMediaRuleQuery implements MediaQuery {
  const _NotMediaRuleQuery(this.query);

  final MediaQuery query;

  @override
  String get _value {
    assert(
      (() {
        if (query is _AnyMediaRuleQuery) {
          throw 'Cannot apply MediaRuleQuery.not() on MediaRuleQuery.any(). Apply on each individual rule instead.';
        }
        if (query is _NotMediaRuleQuery) {
          throw 'Cannot apply MediaRuleQuery.not() twice.';
        }
        return true;
      })(),
    );
    return 'not ${query._value}';
  }
}

class _AnyMediaRuleQuery implements MediaQuery {
  const _AnyMediaRuleQuery(this.queries);

  final List<MediaQuery> queries;

  @override
  String get _value => queries.map((q) => q._value).join(', ');
}

class _RawMediaQuery implements MediaQuery {
  const _RawMediaQuery(this.query);

  final String query;

  @override
  String get _value => query;
}

class ImportStyleRule implements StyleRule {
  final String url;
  const ImportStyleRule(this.url);

  @override
  String toCss([String indent = '']) {
    return '$indent@import url($url);';
  }
}

class FontFaceStyleRule implements StyleRule {
  const FontFaceStyleRule({required this.family, this.style, required this.url});

  final String family;
  final FontStyle? style;
  final String url;

  @override
  String toCss([String indent = '']) {
    return '$indent@font-face {$cssPropSpace'
        '$indent${cssBlockInset}font-family: "$family";$cssPropSpace'
        '${style != null ? '$indent${cssBlockInset}font-style: ${style!.value};$cssPropSpace' : ''}'
        '$indent${cssBlockInset}src: url($url);$cssPropSpace'
        '$indent}';
  }
}

class LayerStyleRule implements StyleRule {
  const LayerStyleRule({this.name, required this.styles});

  final String? name;
  final List<StyleRule> styles;

  @override
  String toCss([String indent = '']) {
    return '$indent@layer${name != null ? ' $name' : ''} {$cssPropSpace'
        '${styles.map((r) => r.toCss('$indent$cssBlockInset') + cssPropSpace).join()}'
        '$indent}';
  }
}

class SupportsStyleRule implements StyleRule {
  const SupportsStyleRule({required this.condition, required this.styles});

  final String condition;
  final List<StyleRule> styles;

  @override
  String toCss([String indent = '']) {
    return '$indent@supports $condition {$cssPropSpace'
        '${styles.map((r) => r.toCss('$indent$cssBlockInset') + cssPropSpace).join()}'
        '$indent}';
  }
}

class KeyframesStyleRule implements StyleRule {
  const KeyframesStyleRule({required this.name, required this.styles});

  final String name;
  final Map<String, Styles> styles;

  @override
  String toCss([String indent = '']) {
    return '$indent@keyframes $name {$cssPropSpace'
        '${styles.entries.map((e) => '$indent$cssBlockInset${e.key} {$cssPropSpace'
            '${e.value.properties.entries.map((e) => '$indent$cssBlockInset$cssBlockInset${e.key}: ${e.value};$cssPropSpace').join()}'
            '$indent$cssBlockInset}$cssPropSpace').join()}'
        '$indent}';
  }
}
