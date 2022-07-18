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
  final Styles? styles;
  final Map<String, String>? attributes;
  final Map<String, EventCallback>? events;
  final Component? _child;
  final List<Component>? _children;

  List<Component> get children => [if (_child != null) _child!, ..._children ?? []];

  @override
  Element createElement() => DomElement(this);
}

class DomElement extends MultiChildElement with BuildScheduler {
  DomElement(DomComponent component) : super(component);

  @override
  DomComponent get component => super.component as DomComponent;

  dynamic _source;
  dynamic get source => _source;

  @override
  Iterable<Component> build() => component.children;

  @override
  void update(DomComponent newComponent) {
    super.update(newComponent);
    _dirty = true;
    rebuild();
  }

  @override
  void render(DomBuilder b) {
    b.open(
      component.tag,
      // TODO currently this does not really work on first render, find better solution
      key: component.key?.hashCode.toString(),
      id: component.id,
      classes: component.classes,
      styles: component.styles?.styles,
      attributes: component.attributes,
      events: component.events?.map((k, v) => MapEntry(k, (e) => v(e.event))),
    );

    super.render(b);

    _source = b.close(tag: component.tag);
    _view = ComponentsBinding.instance!.registerView(_source, super.render, false);
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

class TextElement extends Element {
  TextElement(Text component) : super(component);

  @override
  Text get _component => super._component as Text;

  @override
  bool get debugDoingBuild => false;

  @override
  void performRebuild() {
    _dirty = false;
  }

  @override
  void visitChildren(ElementVisitor visitor) {}

  @override
  void render(DomBuilder b) {
    if (_component.rawHtml) {
      b.innerHtml(_component.text);
    } else {
      b.text(_component.text);
    }
  }
}
