part of 'framework.dart';

/// Represents a html element in the DOM
///
/// Must have a [tag] and any number of attributes.
/// Can have a single [child] component or any amount of [children].
class DomComponent extends Component {
  const DomComponent({
    super.key,
    required this.tag,
    this.id,
    this.classes,
    this.styles,
    this.attributes,
    this.events,
    this.children,
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
  final List<Component>? children;

  @override
  Element createElement() => DomElement(this);
}

class DomElement extends MultiChildRenderObjectElement {
  DomElement(DomComponent super.component);

  @override
  DomComponent get component => super.component as DomComponent;

  InheritedElement? _wrappingElement;

  @override
  List<Component> buildChildren() => component.children ?? [];

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
    return renderObject;
  }

  @override
  void updateRenderObject(RenderElement renderObject) {
    if (_wrappingElement != null) {
      var wrappingComponent = dependOnInheritedElement(_wrappingElement!) as _WrappingDomComponent;
      renderObject.update(
        component.id ?? wrappingComponent.id,
        _joinString(wrappingComponent.classes, component.classes),
        _joinMap(wrappingComponent.styles?.properties, component.styles?.properties),
        _joinMap(wrappingComponent.attributes, component.attributes),
        _joinMap(wrappingComponent.events, component.events),
      );

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
  List<Component>? get children => null;

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
