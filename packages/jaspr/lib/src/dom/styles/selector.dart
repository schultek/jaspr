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

  Selector className(String className) {
    assert(unallowedList(this));
    return Selector.chain([this, Selector.className(className)]);
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
  const Selector.className(String className) : selector = '.$className';
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

  const AttrCheck.exists() : value = '', caseSensitive = true;
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
    assert(
      (() {
        if (selectors.any((s) => s is _ListSelector)) {
          throw 'Cannot further chain selector list, only single selectors supported.';
        }
        return true;
      })(),
    );
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
