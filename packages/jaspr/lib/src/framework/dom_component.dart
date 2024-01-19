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
    Component? child,
    List<Component>? children,
  })  : _child = child,
        _children = children;

  const factory DomComponent.wrap({
    Key? key,
    String? id,
    List<String>? classes,
    Styles? styles,
    Map<String, String>? attributes,
    Map<String, EventCallback>? events,
    required Component child,
  }) = _WrappingDomComponent;

  final String tag;
  final String? id;
  final List<String>? classes;
  final Styles? styles;
  final Map<String, String>? attributes;
  final Map<String, EventCallback>? events;
  final Component? _child;
  final List<Component>? _children;

  List<Component> get children => [if (_child != null) _child!, ..._children ?? []];

  @override
  Element createElement() => DomElement(this);
}

class DomElement extends MultiChildElement with RenderObjectElement {
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
  Iterable<Component> build() => component.children;

  @override
  void update(DomComponent newComponent) {
    super.update(newComponent);
    _dirty = true;
    rebuild();
  }

  @override
  void updateRenderObject() {
    DomComponent? wrappingComponent;
    if (_wrappingElement != null) {
      wrappingComponent = dependOnInheritedElement(_wrappingElement!) as _WrappingDomComponent;
    }

    renderObject.updateElement(
      component.tag,
      component.id ?? wrappingComponent?.id,
      [...wrappingComponent?.classes ?? [], ...component.classes ?? []],
      {...wrappingComponent?.styles?.styles ?? {}, ...component.styles?.styles ?? {}},
      {...wrappingComponent?.attributes ?? {}, ...component.attributes ?? {}},
      {...wrappingComponent?.events ?? {}, ...component.events ?? {}},
    );
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
  final List<String>? classes;
  @override
  final Styles? styles;
  @override
  final Map<String, String>? attributes;
  @override
  final Map<String, EventCallback>? events;
  @override
  final Component? _child = null;
  @override
  final List<Component> _children = const [];

  @override
  List<Component> get children => [child];

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
  const Text(this.text, {this.rawHtml = false, super.key});

  final String text;
  final bool rawHtml;

  @override
  Element createElement() => TextElement(this);
}

abstract class NoChildElement extends Element {
  NoChildElement(super.component);

  @override
  bool get debugDoingBuild => false;

  @override
  void mount(Element? parent, Element? prevSibling) {
    super.mount(parent, prevSibling);
    assert(_lifecycleState == _ElementLifecycle.active);
    _firstBuild();
  }

  @override
  void _firstBuild([VoidCallback? onBuilt]) {
    super._firstBuild(onBuilt);
    rebuild(onBuilt);
  }

  @override
  void performRebuild() {
    _dirty = false;
  }

  @override
  void visitChildren(ElementVisitor visitor) {}
}

class TextElement extends NoChildElement with RenderObjectElement {
  TextElement(Text super.component);

  @override
  Text get component => super.component as Text;

  @override
  void updateRenderObject() {
    renderObject.updateText(component.text, component.rawHtml);
  }
}

class SkipContent extends Component {
  const SkipContent();

  @override
  Element createElement() => SkipContentElement(this);
}

class SkipContentElement extends NoChildElement with RenderObjectElement {
  SkipContentElement(SkipContent super.component);

  @override
  SkipContent get component => super.component as SkipContent;

  @override
  void updateRenderObject() {
    renderObject.skipChildren();
  }
}
