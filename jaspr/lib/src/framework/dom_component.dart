part of framework;

typedef EventCallback = void Function();

/// Represents a html element in the DOM
///
/// Must have a [tag] and any number of attributes.
/// Can have a single [child] component or any amount of [children].
class DomComponent extends Component {
  DomComponent({
    Key? key,
    required this.tag,
    this.id,
    this.classes,
    this.styles,
    this.attributes,
    this.events,
    Component? child,
    List<Component>? children,
  })  : children = [if (child != null) child, ...children ?? []],
        super(key: key);

  final String tag;
  final String? id;
  final Iterable<String>? classes;
  final Map<String, String>? styles;
  final Map<String, String>? attributes;
  final Map<String, EventCallback>? events;
  final List<Component>? children;

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
  Iterable<Component> build() => component.children ?? [];

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
      key: component.key?.hashCode.toString(),
      id: component.id,
      classes: component.classes,
      styles: component.styles,
      attributes: component.attributes,
      events: component.events?.map((k, v) => MapEntry(k, (e) => v())),
      onCreate: (event) {
        view = event.view;
        _source = event.source;
      },
      onUpdate: (event) {
        view = event.view;
        _source = event.source;
      },
    );

    super.render(b);

    b.close(tag: component.tag);
  }
}

/// Represents a plain text node with no additional properties.
///
/// Styling is done through the parent element(s) and their styles.
class Text extends Component {
  Text(this.text, {Key? key}) : super(key: key);

  final String text;

  @override
  Element createElement() {
    return TextElement(this);
  }
}

class TextElement extends Element {
  TextElement(Text component) : super(component);

  @override
  Text get _component => super._component as Text;

  @override
  bool get debugDoingBuild => false;

  @override
  void performRebuild() {}

  @override
  void visitChildren(ElementVisitor visitor) {}

  @override
  void render(DomBuilder b) {
    b.text(_component.text);
  }
}
