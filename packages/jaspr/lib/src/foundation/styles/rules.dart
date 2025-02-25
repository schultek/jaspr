import '../constants.dart';
import 'selector.dart';
import 'styles.dart';

abstract class StyleRule {
  /// Renders a css rule with the given selector and styles.
  const factory StyleRule({
    required Selector selector,
    required Styles styles,
  }) = BlockStyleRule;

  /// Renders a `@import url(...)` css rule.
  const factory StyleRule.import(String url) = ImportStyleRule;

  /// Renders a `@font-face` css rule.
  const factory StyleRule.fontFace({
    required String family,
    FontStyle? style,
    required String url,
  }) = FontFaceStyleRule;

  /// Renders a `@media` css rule.
  const factory StyleRule.media({
    required MediaQuery query,
    required List<StyleRule> styles,
  }) = MediaStyleRule;

  /// Renders a `@layer` css rule.
  const factory StyleRule.layer({
    String? name,
    required List<StyleRule> styles,
  }) = LayerStyleRule;

  /// Renders a `@supports` css rule.
  const factory StyleRule.supports({
    required String condition,
    required List<StyleRule> styles,
  }) = SupportsStyleRule;

  /// Renders a `@keyframes` css rule.
  const factory StyleRule.keyframes({
    required String name,
    required Map<String, Styles> styles,
  }) = KeyframesStyleRule;

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

abstract class MediaQuery {
  String get _value;

  const factory MediaQuery.all({
    Unit? minWidth,
    Unit? maxWidth,
    Unit? minHeight,
    Unit? maxHeight,
    Orientation? orientation,
    bool? canHover,
    String? aspectRatio,
    ColorScheme? prefersColorScheme,
  }) = _MediaRuleQuery.all;

  const factory MediaQuery.screen({
    Unit? minWidth,
    Unit? maxWidth,
    Unit? minHeight,
    Unit? maxHeight,
    Orientation? orientation,
    bool? canHover,
    String? aspectRatio,
    ColorScheme? prefersColorScheme,
  }) = _MediaRuleQuery.screen;

  const factory MediaQuery.print({
    Unit? minWidth,
    Unit? maxWidth,
    Unit? minHeight,
    Unit? maxHeight,
    Orientation? orientation,
    bool? canHover,
    String? aspectRatio,
    ColorScheme? prefersColorScheme,
  }) = _MediaRuleQuery.print;

  const factory MediaQuery.not(MediaQuery query) = _NotMediaRuleQuery;
  const factory MediaQuery.any(List<MediaQuery> queries) = _AnyMediaRuleQuery;
}

enum Orientation { portrait, landscape }

enum ColorScheme { light, dark }

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

  @override
  String get _value => '$target'
      '${minWidth != null ? ' and (min-width: ${minWidth!.value})' : ''}'
      '${maxWidth != null ? ' and (max-width: ${maxWidth!.value})' : ''}'
      '${minHeight != null ? ' and (min-height: ${minHeight!.value})' : ''}'
      '${maxHeight != null ? ' and (max-height: ${maxHeight!.value})' : ''}'
      '${orientation != null ? ' and (orientation: ${orientation!.name})' : ''}'
      '${canHover != null ? ' and (hover: ${canHover! ? 'hover' : 'none'})' : ''}'
      '${prefersColorScheme != null ? ' and (prefers-color-scheme: ${prefersColorScheme!.name})' : ''}'
      '${aspectRatio != null ? ' and (aspect-ratio: ${aspectRatio!})' : ''}';
}

class _NotMediaRuleQuery implements MediaQuery {
  const _NotMediaRuleQuery(this.query);

  final MediaQuery query;

  @override
  String get _value {
    assert((() {
      if (query is _AnyMediaRuleQuery) {
        throw 'Cannot apply MediaRuleQuery.not() on MediaRuleQuery.any(). Apply on each individual rule instead.';
      }
      if (query is _NotMediaRuleQuery) {
        throw 'Cannot apply MediaRuleQuery.not() twice.';
      }
      return true;
    })());
    return 'not ${query._value}';
  }
}

class _AnyMediaRuleQuery implements MediaQuery {
  const _AnyMediaRuleQuery(this.queries);

  final List<MediaQuery> queries;

  @override
  String get _value => queries.map((q) => q._value).join(', ');
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
  const FontFaceStyleRule({
    required this.family,
    this.style,
    required this.url,
  });

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
