import '../../jaspr.dart';

class Style extends StatelessComponent {
  final List<StyleRule> styles;

  const Style({required this.styles, super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'style',
      child: Text(styles.map((s) => s.toCss()).join(cssPropSpace), rawHtml: true),
    );
  }
}

const cssBlockInset = kDebugMode ? '  ' : '';
const cssPropSpace = kDebugMode ? '\n' : ' ';

abstract class StyleRule {
  const factory StyleRule({required Selector selector, required Styles styles}) = _BlockStyleRule;

  const factory StyleRule.import(String url) = _ImportStyleRule;
  const factory StyleRule.media({required MediaRuleQuery query, required List<StyleRule> styles}) = _MediaStyleRule;

  String toCss();
}

class _BlockStyleRule implements StyleRule {
  const _BlockStyleRule({required this.selector, required this.styles});

  final Selector selector;
  final Styles styles;

  @override
  String toCss() {
    return '${selector.selector} {$cssPropSpace'
        '${styles.styles.entries.map((e) => '$cssBlockInset${e.key}: ${e.value};').join(cssPropSpace)}'
        '$cssPropSpace}';
  }
}

class _MediaStyleRule implements StyleRule {
  const _MediaStyleRule({required this.query, required this.styles});

  final MediaRuleQuery query;
  final List<StyleRule> styles;

  @override
  String toCss() {
    return '@media ${query.value} {$cssPropSpace'
        '${styles.map((r) => r.toCss()).join(cssPropSpace)}'
        '$cssPropSpace}';
  }
}

enum MediaRuleTarget {
  all,
  screen,
  print;
}

class MediaRuleQuery {
  const MediaRuleQuery._(this.value);

  final String value;

  static const MediaRuleQuery all = MediaRuleQuery();
  static const MediaRuleQuery screen = MediaRuleQuery(target: MediaRuleTarget.screen);
  static const MediaRuleQuery print = MediaRuleQuery(target: MediaRuleTarget.print);

  const factory MediaRuleQuery({
    MediaRuleTarget target,
    Unit? minWidth,
    Unit? maxWidth,
    Unit? minHeight,
    Unit? maxHeight,
    Orientation? orientation,
    bool? canHover,
    String? aspectRatio,
  }) = _MediaRuleQuery;

  const factory MediaRuleQuery.not(MediaRuleQuery query) = _NotMediaRuleQuery;
  const factory MediaRuleQuery.any(List<MediaRuleQuery> queries) = _AnyMediaRuleQuery;
}

enum Orientation { portrait, landscape }

class _MediaRuleQuery implements MediaRuleQuery {
  const _MediaRuleQuery({
    this.target = MediaRuleTarget.all,
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,
    this.orientation,
    this.canHover,
    this.aspectRatio,
  });

  final MediaRuleTarget target;
  final Unit? minWidth;
  final Unit? maxWidth;
  final Unit? minHeight;
  final Unit? maxHeight;
  final Orientation? orientation;
  final bool? canHover;
  final String? aspectRatio;

  @override
  String get value => '${target.name}'
      '${minWidth != null ? ' and (min-width: ${minWidth!.value})' : ''}'
      '${maxWidth != null ? ' and (max-width: ${maxWidth!.value})' : ''}'
      '${minHeight != null ? ' and (min-height: ${minHeight!.value})' : ''}'
      '${maxHeight != null ? ' and (max-height: ${maxHeight!.value})' : ''}'
      '${orientation != null ? ' and (orientation: ${orientation!.name})' : ''}'
      '${canHover != null ? ' and (hover: ${canHover! ? 'hover' : 'none'})' : ''}'
      '${aspectRatio != null ? ' and (aspect-ratio: ${aspectRatio!})' : ''}';
}

class _NotMediaRuleQuery implements MediaRuleQuery {
  const _NotMediaRuleQuery(this.query);

  final MediaRuleQuery query;

  @override
  String get value {
    assert((() {
      if (query is _AnyMediaRuleQuery) {
        throw 'Cannot apply MediaRuleQuery.not() on MediaRuleQuery.any(). Apply on each individual rule instead.';
      }
      if (query is _NotMediaRuleQuery) {
        throw 'Cannot apply MediaRuleQuery.not() twice.';
      }
      return true;
    })());
    return 'not ${query.value}';
  }
}

class _AnyMediaRuleQuery implements MediaRuleQuery {
  const _AnyMediaRuleQuery(this.queries);

  final List<MediaRuleQuery> queries;

  @override
  String get value => queries.join(', ');
}

class _ImportStyleRule implements StyleRule {
  final String url;
  const _ImportStyleRule(this.url);

  @override
  String toCss() {
    return '@import url($url);';
  }
}

bool unallowedList(Selector selector) {
  if (selector is _ListSelector) {
    throw 'Cannot further chain selector list, only single selector supported.';
  }
  return true;
}

extension SelectorMixin on Selector {
  Selector tag(String tag) {
    assert(unallowedList(this));
    return Selector.chain([this, Selector.tag(tag)]);
  }

  Selector id(String id) {
    assert(unallowedList(this));
    return Selector.chain([this, Selector.id(id)]);
  }

  Selector dot(String className) {
    assert(unallowedList(this));
    return Selector.chain([this, Selector.dot(className)]);
  }

  Selector descendant(Selector next) {
    assert(unallowedList(this));
    return Selector.combine([this, next], combinator: Combinator.descendant);
  }

  Selector child(Selector next) {
    assert(unallowedList(this));
    return Selector.combine([this, next], combinator: Combinator.child);
  }

  Selector sibling(Selector next) {
    assert(unallowedList(this));
    return Selector.combine([this, next], combinator: Combinator.sibling);
  }

  Selector adjacentSibling(Selector next) {
    assert(unallowedList(this));
    return Selector.combine([this, next], combinator: Combinator.adjacentSibling);
  }
}

class Selector {
  /// The css selector
  final String selector;

  const Selector(this.selector);

  static const Selector all = Selector('*');

  const Selector.tag(String tag) : selector = tag;
  const Selector.id(String id) : selector = '#$id';
  const Selector.dot(String className) : selector = '.$className';
  const factory Selector.attr(String attr, {AttrCheck check}) = _AttrSelector;

  const Selector.pseudoClass(String name) : selector = ':$name';
  const Selector.pseudoElem(String name) : selector = '::$name';

  const factory Selector.chain(List<Selector> selectors) = _ChainSelector;

  const factory Selector.combine(List<Selector> selectors, {Combinator combinator}) = _CombineSelector;

  const factory Selector.list(List<Selector> selectors) = _ListSelector;
}

class _AttrSelector implements Selector {
  final String attr;
  final AttrCheck check;

  const _AttrSelector(this.attr, {this.check = const AttrCheck.exists()});

  @override
  String get selector => '[$attr${check.value}${!check.caseSensitive ? ' i' : ''}]';
}

class AttrCheck {
  final String value;
  final bool caseSensitive;

  const AttrCheck.exists()
      : value = '',
        caseSensitive = true;
  const AttrCheck.exactly(String value, {this.caseSensitive = true}) : value = '="$value"';
  const AttrCheck.containsWord(String value, {this.caseSensitive = true}) : value = '~="$value"';
  const AttrCheck.startsWith(String prefix, {this.caseSensitive = true}) : value = '^="$prefix"';
  const AttrCheck.endsWith(String suffix, {this.caseSensitive = true}) : value = '\$="$suffix"';
  const AttrCheck.dashPrefixed(String prefix, {this.caseSensitive = true}) : value = '|="$prefix"';
  const AttrCheck.contains(String prefix, {this.caseSensitive = true}) : value = '*="$prefix"';
}

class _ChainSelector implements Selector {
  final List<Selector> selectors;

  const _ChainSelector(this.selectors);

  @override
  String get selector {
    assert((() {
      if (selectors.any((s) => s is _ListSelector)) {
        throw 'Cannot further chain selector list, only single selectors supported.';
      }
      return true;
    })());
    return selectors.map((s) => s.selector).join('');
  }
}

enum Combinator {
  descendant(' '),
  child(' > '),
  sibling(' ~ '),
  adjacentSibling(' + ');

  final String separator;
  const Combinator(this.separator);
}

class _CombineSelector implements Selector {
  final List<Selector> selectors;
  final Combinator combinator;

  const _CombineSelector(this.selectors, {this.combinator = Combinator.descendant});

  @override
  String get selector => selectors.map((s) => s.selector).join(combinator.separator);
}

class _ListSelector implements Selector {
  final List<Selector> selectors;

  const _ListSelector(this.selectors);

  @override
  String get selector => selectors.map((s) => s.selector).join(', ');
}
