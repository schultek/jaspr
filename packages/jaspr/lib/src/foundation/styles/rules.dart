import '../constants.dart';
import 'selector.dart';
import 'styles.dart';

abstract class StyleRule {
  const factory StyleRule({required Selector selector, required Styles styles}) = BlockStyleRule;

  const factory StyleRule.import(String url) = ImportStyleRule;
  const factory StyleRule.fontFace({required String fontFamily, FontStyle? fontStyle, required String url}) =
      FontFaceStyleRule;
  const factory StyleRule.media({required MediaQuery query, required List<StyleRule> styles}) = MediaStyleRule;

  String toCss([String indent]);
}

const cssBlockInset = kDebugMode || kGenerateMode ? '  ' : '';
const cssPropSpace = kDebugMode || kGenerateMode ? '\n' : ' ';

extension StyleRulesRender on Iterable<StyleRule> {
  String render() {
    return map((s) => s.toCss()).join(cssPropSpace);
  }
}

class BlockStyleRule implements StyleRule {
  const BlockStyleRule({required this.selector, required this.styles});

  final Selector selector;
  final Styles styles;

  @override
  String toCss([String indent = '']) {
    return '$indent${selector.selector} {$cssPropSpace'
        '${styles.styles.entries.map((e) => '$indent$cssBlockInset${e.key}: ${e.value};$cssPropSpace').join()}'
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
        '${styles.map((r) => r.toCss(kDebugMode ? '$indent  ' : '') + cssPropSpace).join()}'
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
  }) = _MediaRuleQuery.all;

  const factory MediaQuery.screen({
    Unit? minWidth,
    Unit? maxWidth,
    Unit? minHeight,
    Unit? maxHeight,
    Orientation? orientation,
    bool? canHover,
    String? aspectRatio,
  }) = _MediaRuleQuery.screen;

  const factory MediaQuery.print({
    Unit? minWidth,
    Unit? maxWidth,
    Unit? minHeight,
    Unit? maxHeight,
    Orientation? orientation,
    bool? canHover,
    String? aspectRatio,
  }) = _MediaRuleQuery.print;

  const factory MediaQuery.not(MediaQuery query) = _NotMediaRuleQuery;
  const factory MediaQuery.any(List<MediaQuery> queries) = _AnyMediaRuleQuery;
}

enum Orientation { portrait, landscape }

class _MediaRuleQuery implements MediaQuery {
  const _MediaRuleQuery.all({
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,
    this.orientation,
    this.canHover,
    this.aspectRatio,
  }) : target = 'all';
  const _MediaRuleQuery.screen({
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,
    this.orientation,
    this.canHover,
    this.aspectRatio,
  }) : target = 'screen';
  const _MediaRuleQuery.print({
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,
    this.orientation,
    this.canHover,
    this.aspectRatio,
  }) : target = 'print';

  final String target;
  final Unit? minWidth;
  final Unit? maxWidth;
  final Unit? minHeight;
  final Unit? maxHeight;
  final Orientation? orientation;
  final bool? canHover;
  final String? aspectRatio;

  @override
  String get _value => '$target'
      '${minWidth != null ? ' and (min-width: ${minWidth!.value})' : ''}'
      '${maxWidth != null ? ' and (max-width: ${maxWidth!.value})' : ''}'
      '${minHeight != null ? ' and (min-height: ${minHeight!.value})' : ''}'
      '${maxHeight != null ? ' and (max-height: ${maxHeight!.value})' : ''}'
      '${orientation != null ? ' and (orientation: ${orientation!.name})' : ''}'
      '${canHover != null ? ' and (hover: ${canHover! ? 'hover' : 'none'})' : ''}'
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
  String get _value => queries.join(', ');
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
  const FontFaceStyleRule({required this.fontFamily, this.fontStyle, required this.url});

  final String fontFamily;
  final FontStyle? fontStyle;
  final String url;

  @override
  String toCss([String indent = '']) {
    return '$indent@font-face {$cssPropSpace'
        '$indent${cssBlockInset}font-family: "$fontFamily";$cssPropSpace'
        '${fontStyle != null ? '$indent${cssBlockInset}font-style: ${fontStyle!.value};$cssPropSpace' : ''}'
        '$indent${cssBlockInset}src: url($url);$cssPropSpace'
        '$indent}';
  }
}
