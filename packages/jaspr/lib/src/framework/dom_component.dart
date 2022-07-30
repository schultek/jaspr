part of framework;

typedef EventCallback = void Function(dynamic event);

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

  final String tag;
  final String? id;
  final Iterable<String>? classes;
  final Map<String, String>? styles;
  final Map<String, String>? attributes;
  final Map<String, EventCallback>? events;
  final Component? _child;
  final List<Component>? _children;

  List<Component> get children => [if (_child != null) _child!, ..._children ?? []];

  @override
  Element createElement() => DomElement(this);
}

class DomElement extends MultiChildElement with DomNode {
  DomElement(DomComponent component) : super(component);

  @override
  DomComponent get component => super.component as DomComponent;

  @override
  Iterable<Component> build() => component.children;

  @override
  void _firstBuild() {
    mountNode();
    super._firstBuild();
  }

  @override
  void update(DomComponent newComponent) {
    super.update(newComponent);
    _dirty = true;
    rebuild();
  }

  @override
  void renderNode(DomBuilder builder) {
    builder.renderNode(
      this,
      component.tag,
      {
        if (component.id != null) 'id': component.id!,
        if (component.classes != null) 'class': component.classes!.join(' '),
        if (component.styles != null) 'style': component.styles!.entries.map((e) => '${e.key}: ${e.value}').join('; '),
        if (component.attributes != null) ...component.attributes!,
      },
      component.events ?? {},
    );
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

class TextElement extends Element with DomNode {
  TextElement(Text component) : super(component);

  @override
  Text get component => super.component as Text;

  @override
  bool get debugDoingBuild => false;

  @override
  void mount(Element? parent, Slot? slot) {
    super.mount(parent, slot);
    assert(_lifecycleState == _ElementLifecycle.active);
    _firstBuild();
  }

  @mustCallSuper
  void _firstBuild() {
    mountNode();
    rebuild();
  }

  @override
  void renderNode(DomBuilder builder) {
    // TODO raw html
    builder.renderTextNode(this, component.text);
  }

  @override
  void performRebuild() {
    _dirty = false;
  }

  @override
  void visitChildren(ElementVisitor visitor) {}
}