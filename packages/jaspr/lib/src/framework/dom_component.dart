part of 'framework.dart';

/// Represents a html element in the DOM
///
/// Must have a [tag] and any number of attributes.
/// Can have a single [child] component or any amount of [children].
class DomComponent extends ProxyComponent {
  const DomComponent({
    super.key,
    required this.tag,
    this.id,
    this.classes,
    this.styles,
    this.attributes,
    this.events,
    super.child,
    super.children,
  });

  const factory DomComponent.wrap({
    Key? key,
    String? id,
    String? classes,
    Styles? styles,
    Map<String, String>? attributes,
    Map<String, EventCallback>? events,
    required Component child,
  }) = _WrappingDomComponent;

  final String tag;
  final String? id;
  final String? classes;
  final Styles? styles;
  final Map<String, String>? attributes;
  final Map<String, EventCallback>? events;

  @override
  ProxyElement createElement() => DomElement(this);
}

class DomElement extends ProxyRenderObjectElement {
  DomElement(DomComponent super.component);

  @override
  DomComponent get component => super.component as DomComponent;

  InheritedElement? _wrappingElement;

  @override
  void _updateInheritance() {
    super._updateInheritance();
    if (_inheritedElements != null && _inheritedElements!.containsKey(_WrappingDomComponent)) {
      _inheritedElements = HashMap<Type, InheritedElement>.from(_inheritedElements!);
    }
    _wrappingElement = _inheritedElements?.remove(_WrappingDomComponent);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    updateRenderObject();
  }

  @override
  bool shouldRerender(DomComponent newComponent) {
    return component.tag != newComponent.tag ||
        component.id != newComponent.id ||
        component.classes != newComponent.classes ||
        component.styles != newComponent.styles ||
        component.attributes != newComponent.attributes ||
        component.events != newComponent.events;
  }

  @override
  void updateRenderObject() {
    if (_wrappingElement != null) {
      var wrappingComponent = dependOnInheritedElement(_wrappingElement!) as _WrappingDomComponent;

      renderObject.updateElement(
        component.tag,
        component.id ?? wrappingComponent.id,
        _join(wrappingComponent.classes, component.classes, (a, b) => '$a $b'),
        _join(wrappingComponent.styles?.properties, component.styles?.properties, (a, b) => {...a, ...b}),
        _join(wrappingComponent.attributes, component.attributes, (a, b) => {...a, ...b}),
        _join(wrappingComponent.events, component.events, (a, b) => {...a, ...b}),
      );

      return;
    }

    renderObject.updateElement(
      component.tag,
      component.id,
      component.classes,
      component.styles?.properties,
      component.attributes,
      component.events,
    );
  }

  T? _join<T>(T? a, T? b, T Function(T a, T b) joiner) {
    return a != null && b != null ? joiner(a, b) : a ?? b;
  }
}

class _WrappingDomComponent extends InheritedComponent implements DomComponent {
  const _WrappingDomComponent({
    super.key,
    this.id,
    this.classes,
    this.styles,
    this.attributes,
    this.events,
    required super.child,
  });

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

  @override
  bool updateShouldNotify(_WrappingDomComponent oldComponent) {
    return oldComponent.id != id ||
        oldComponent.classes != classes ||
        oldComponent.styles != styles ||
        oldComponent.attributes != attributes ||
        oldComponent.events != events;
  }
}

/// Represents a plain text node with no additional properties.
///
/// Styling is done through the parent element(s) and their styles.
class Text extends Component {
  const Text(this.text, {super.key});

  final String text;

  @override
  Element createElement() => TextElement(this);
}

class TextElement extends LeafRenderObjectElement {
  TextElement(Text super.component);

  @override
  bool shouldRerender(Text newComponent) {
    return (component as Text).text != newComponent.text;
  }

  @override
  void updateRenderObject() {
    renderObject.updateText((component as Text).text);
  }
}

class SkipContent extends Component {
  const SkipContent();

  @override
  Element createElement() => SkipContentElement(this);
}

class SkipContentElement extends LeafRenderObjectElement {
  SkipContentElement(SkipContent super.component);

  @override
  void updateRenderObject() {
    renderObject.skipChildren();
  }
}
