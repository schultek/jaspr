part of 'framework.dart';

/// Represents a html element in the DOM
///
/// Must have a [tag] and any number of [attributes].
/// Accepts a list of [children].
class DomComponent extends Component {
  const DomComponent._({
    super.key,
    required this.tag,
    this.id,
    this.classes,
    this.styles,
    this.attributes,
    this.events,
    this.children,
  });

  final String tag;
  final String? id;
  final String? classes;
  final Styles? styles;
  final Map<String, String>? attributes;
  final Map<String, EventCallback>? events;
  final List<Component>? children;

  @override
  Element createElement() => DomElement(this);
}

typedef EventCallback = void Function(web.Event event);

class DomElement extends MultiChildRenderObjectElement {
  DomElement(DomComponent super.component);

  @override
  DomComponent get component => super.component as DomComponent;

  InheritedElement? _inheritedDomElement;

  @override
  List<Component> buildChildren() {
    if (_inheritedDomElement case final inheritedDomElement?) {
      final inheritedDomComponent = dependOnInheritedElement(inheritedDomElement) as _InheritedDomComponent;
      return _InheritedDomComponent.consume(
        inheritedDomComponent.paramsBySelector,
        component,
        component.children ?? const [],
      );
    }
    return component.children ?? const [];
  }

  @override
  void _updateInheritance() {
    super._updateInheritance();
    if (_inheritedElements case final originalInheritedElements?
        when originalInheritedElements.containsKey(_InheritedDomComponent)) {
      final updatedInheritedElements = HashMap<Type, InheritedElement>.of(originalInheritedElements);
      _inheritedDomElement = updatedInheritedElements.remove(_InheritedDomComponent);
      _inheritedElements = updatedInheritedElements;
      return;
    }
    _inheritedDomElement = null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    updateRenderObject(renderObject as RenderElement);
  }

  @override
  void update(DomComponent newComponent) {
    assert(component.tag == newComponent.tag, 'Cannot update a DomComponent with a different tag.');
    super.update(newComponent);
  }

  @override
  bool shouldRerender(DomComponent newComponent) {
    return component.id != newComponent.id ||
        component.classes != newComponent.classes ||
        component.styles != newComponent.styles ||
        component.attributes != newComponent.attributes ||
        component.events != newComponent.events;
  }

  @override
  RenderObject createRenderObject() {
    final renderObject = _parentRenderObjectElement!.renderObject.createChildRenderElement(component.tag);
    assert(renderObject.parent == _parentRenderObjectElement!.renderObject);
    updateRenderObject(renderObject);
    return renderObject;
  }

  @override
  void updateRenderObject(RenderElement renderObject) {
    if (_inheritedDomElement != null) {
      final inheritedComponent = dependOnInheritedElement(_inheritedDomElement!) as _InheritedDomComponent;
      final params = _InheritedDomComponent.applyTo(component, inheritedComponent.paramsBySelector);
      if (params != null) {
        renderObject.update(
          component.id ?? params.id,
          _DomParams._joinString(params.classes, component.classes),
          _DomParams._joinMap(params.styles?.properties, component.styles?.properties),
          _DomParams._joinMap(params.attributes, component.attributes),
          _DomParams._joinMap(params.events, component.events),
        );
      }

      return;
    }

    renderObject.update(
      component.id,
      component.classes,
      component.styles?.properties,
      component.attributes,
      component.events,
    );
  }
}

class _WrappingDomComponent extends StatelessComponent implements DomComponent {
  const _WrappingDomComponent({
    super.key,
    this.selector = '> *',
    this.id,
    this.classes,
    this.styles,
    this.attributes,
    this.events,
    required this.child,
  });

  final String selector;

  @override
  final String tag = '';
  @override
  final String? id;
  @override
  final String? classes;
  @override
  final Styles? styles;
  @override
  final Map<String, String>? attributes;
  @override
  final Map<String, EventCallback>? events;

  final Component child;
  @override
  List<Component>? get children => null;

  @override
  Component build(BuildContext context) {
    return _InheritedDomComponent.merge(
      context,
      selector: DomSelector.parse(selector),
      params: _DomParams(
        id: id,
        classes: classes,
        styles: styles,
        attributes: attributes,
        events: events,
      ),
      child: child,
    );
  }
}

class DomSelector {
  const DomSelector(this.parts);

  final List<DomSelectorPart> parts;

  static final _specifierRegex = RegExp(r'\*|[#.]?[^\s#.*]+');

  static List<DomSelector> parse(String query) {
    final selectors = <DomSelector>[];
    final list = query.split(',');
    for (final s in list) {
      final parts = <({_Combinator combinator, String? tag, String? id, List<String>? classes})>[];

      final selectorParts = s.trim().split(RegExp(r'\s+'));
      _Combinator? combinator;
      for (final part in selectorParts) {
        if (part == '>') {
          if (combinator != null) {
            throw FormatException('Invalid selector: $s');
          }
          combinator = _Combinator.child;
          continue;
        }

        combinator ??= _Combinator.descendant;

        String? tag;
        String? id;
        List<String>? classes;

        final matches = _specifierRegex.allMatches(part);
        if (matches.isEmpty) {
          throw FormatException('Invalid selector: $s');
        }
        for (final match in matches) {
          final specifier = match.group(0)!;
          if (specifier == '*') {
            if (tag != null) {
              throw FormatException('Invalid selector: $s');
            }
            tag = '*';
          } else if (specifier.startsWith('#')) {
            if (id != null) {
              throw FormatException('Invalid selector: $s');
            }
            id = specifier.substring(1);
          } else if (specifier.startsWith('.')) {
            classes ??= [];
            classes.add(specifier.substring(1));
          } else {
            if (tag != null || id != null || classes != null) {
              throw FormatException('Invalid selector: $s');
            }
            tag = specifier;
          }
        }
        if (tag == '*') {
          tag = null;
        }

        parts.add((combinator: combinator, tag: tag, id: id, classes: classes));
        combinator = null;
      }

      if (parts.isEmpty) {
        throw FormatException('Invalid selector: $s');
      }

      selectors.add(DomSelector(parts));
    }
    return selectors;
  }

  bool matches({required String tag, String? id, String? classes}) {
    if (parts.length != 1) return false;
    return parts.first.matches(tag: tag, id: id, classes: classes);
  }

  (List<DomSelector>, bool) consume({required String tag, String? id, String? classes}) {
    final first = parts.first;
    final matches = first.matches(tag: tag, id: id, classes: classes);

    if (first.combinator == _Combinator.child) {
      // The first part doesn't match, so the selector chain is terminated.
      if (!matches) {
        return ([], true);
      }
    } else {
      // The first part matches, so we can include the rest of the selector chain as a new selector.
      if (matches) {
        return ([DomSelector(parts.skip(1).toList()), this], true);
      }
    }

    return ([this], false);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DomSelector &&
        parts.length == other.parts.length &&
        parts.every((p) => p == other.parts[parts.indexOf(p)]);
  }

  @override
  int get hashCode => Object.hashAll(parts);
}

typedef DomSelectorPart = ({_Combinator combinator, String? tag, String? id, List<String>? classes});

extension on DomSelectorPart {
  bool matches({required String tag, String? id, String? classes}) {
    late final classesSet = classes?.split(' ').toSet() ?? const <String>{};

    if (this.tag case final expectedTag? when expectedTag != tag) return false;
    if (this.id case final expectedId? when expectedId != id) return false;
    if (this.classes case final expectedClasses? when !expectedClasses.every((c) => classesSet.contains(c))) {
      return false;
    }

    return true;
  }
}

enum _Combinator { descendant, child }

class _DomParams {
  const _DomParams({
    this.id,
    this.classes,
    this.styles,
    this.attributes,
    this.events,
  });

  final String? id;
  final String? classes;
  final Styles? styles;
  final Map<String, String>? attributes;
  final Map<String, EventCallback>? events;

  _DomParams merge(_DomParams other) {
    return _DomParams(
      id: other.id ?? id,
      classes: _joinString(classes, other.classes),
      styles: switch ((styles, other.styles)) {
        (null, final s) || (final s, null) => s,
        (final sa?, final sb?) => sa.combine(sb),
      },
      attributes: _joinMap(attributes, other.attributes),
      events: _joinMap(events, other.events),
    );
  }

  static String? _joinString(String? a, String? b) {
    if (a == null) return b;
    if (b == null) return a;
    return '$a $b';
  }

  static Map<K, V>? _joinMap<K, V>(Map<K, V>? a, Map<K, V>? b) {
    if (a == null || a.isEmpty) return b;
    if (b == null || b.isEmpty) return a;
    return {...a, ...b};
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _DomParams &&
        other.id == id &&
        other.classes == classes &&
        other.styles == styles &&
        other.attributes == attributes &&
        other.events == events;
  }

  @override
  int get hashCode => Object.hash(id, classes, styles, attributes, events);
}

class _InheritedDomComponent extends InheritedComponent {
  const _InheritedDomComponent({required this.paramsBySelector, required super.child, super.key});

  factory _InheritedDomComponent.merge(
    BuildContext context, {
    required List<DomSelector> selector,
    required _DomParams params,
    required Component child,
  }) {
    final current = context.dependOnInheritedComponentOfExactType<_InheritedDomComponent>();
    if (current == null) {
      return _InheritedDomComponent(paramsBySelector: {for (final s in selector) s: params}, child: child);
    }
    final paramsBySelector = Map<DomSelector, _DomParams>.from(current.paramsBySelector);
    for (final s in selector) {
      if (paramsBySelector[s] case final existing?) {
        paramsBySelector[s] = existing.merge(params);
      } else {
        paramsBySelector[s] = params;
      }
    }
    return _InheritedDomComponent(paramsBySelector: paramsBySelector, child: child);
  }

  static List<Component> consume(
    Map<DomSelector, _DomParams> paramsBySelector,
    DomComponent component,
    List<Component> children,
  ) {
    bool didConsume = false;
    final Map<DomSelector, _DomParams> newParamsBySelector = {};

    for (final MapEntry(key: selector, value: params) in paramsBySelector.entries) {
      final (newSelectors, didConsumeSelector) = selector.consume(
        tag: component.tag,
        id: component.id,
        classes: component.classes,
      );

      didConsume |= didConsumeSelector;
      for (final newSelector in newSelectors) {
        newParamsBySelector[newSelector] = params;
      }
    }

    if (!didConsume) {
      return children;
    }

    return [
      _InheritedDomComponent(
        paramsBySelector: newParamsBySelector,
        child: Component.fragment(children),
      ),
    ];
  }

  static _DomParams? applyTo(DomComponent component, Map<DomSelector, _DomParams> paramsBySelector) {
    _DomParams? params;

    for (final selector in paramsBySelector.keys) {
      if (selector.matches(tag: component.tag, id: component.id, classes: component.classes)) {
        params = params?.merge(paramsBySelector[selector]!) ?? paramsBySelector[selector];
      }
    }

    return params;
  }

  final Map<DomSelector, _DomParams> paramsBySelector;

  @override
  bool updateShouldNotify(_InheritedDomComponent oldComponent) {
    if (oldComponent.paramsBySelector.length != paramsBySelector.length) return true;
    return oldComponent.paramsBySelector.entries.any(
      (e) => paramsBySelector[e.key] != e.value,
    );
  }
}

/// Represents a plain text node with no additional properties.
///
/// Styling is done through the parent element(s) and their styles.
class Text extends Component {
  const Text._(this.text, {super.key});

  final String text;

  @override
  Element createElement() => TextElement(this);
}

class TextElement extends LeafRenderObjectElement {
  TextElement(Text super.component);

  @override
  Text get component => super.component as Text;

  @override
  bool shouldRerender(Text newComponent) {
    return component.text != newComponent.text;
  }

  @override
  RenderObject createRenderObject() {
    final renderObject = _parentRenderObjectElement!.renderObject.createChildRenderText(component.text);
    assert(renderObject.parent == _parentRenderObjectElement!.renderObject);
    return renderObject;
  }

  @override
  void updateRenderObject(RenderText text) {
    text.update(component.text);
  }
}

/// A utility component that renders its [children] without any wrapper element.
///
/// This is meant to be used in places where you want to render multiple components,
/// but only a single component is allowed by the API.
class Fragment extends Component {
  const Fragment._(this.children, {super.key});

  const Fragment._empty({super.key}) : children = const [];

  final List<Component> children;

  @override
  Element createElement() => _FragmentElement(this);
}

class _FragmentElement extends MultiChildRenderObjectElement {
  _FragmentElement(Fragment super.component);

  @override
  List<Component> buildChildren() => (component as Fragment).children;

  @override
  RenderObject createRenderObject() {
    final renderObject = _parentRenderObjectElement!.renderObject.createChildRenderFragment();
    assert(renderObject.parent == _parentRenderObjectElement!.renderObject);
    return renderObject;
  }

  @override
  void updateRenderObject(RenderFragment fragment) {}
}
