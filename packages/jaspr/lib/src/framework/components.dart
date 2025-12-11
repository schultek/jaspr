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

  InheritedElement? _wrappingElement;

  @override
  List<Component> buildChildren() => component.children ?? [];

  @override
  void _updateInheritance() {
    super._updateInheritance();
    if (_inheritedElements case final originalInheritedElements?
        when originalInheritedElements.containsKey(_WrappingDomComponent)) {
      final updatedInheritedElements = HashMap<Type, InheritedElement>.of(originalInheritedElements);
      _wrappingElement = updatedInheritedElements.remove(_WrappingDomComponent);
      _inheritedElements = updatedInheritedElements;
      return;
    }
    _wrappingElement = null;
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
    if (_wrappingElement != null) {
      final wrappingComponent = dependOnInheritedElement(_wrappingElement!) as _WrappingDomComponent;
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
