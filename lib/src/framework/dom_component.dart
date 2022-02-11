part of framework;

typedef EventCallback = void Function();

class DomComponent extends Component {
  DomComponent({
    Key? key,
    required this.tag,
    this.id,
    this.classes,
    this.styles,
    this.attributes,
    this.events,
    this.child,
  }) : super(key: key);

  final String tag;
  final String? id;
  final Iterable<String>? classes;
  final Map<String, String>? styles;
  final Map<String, String>? attributes;
  final Map<String, EventCallback>? events;
  final Component? child;

  @override
  Element createElement() => DomElement(this);
}

class DomElement extends SingleChildElement with BuildScheduler {
  DomElement(DomComponent component) : super(component);

  @override
  DomComponent get component => super.component as DomComponent;

  @override
  Component? build() => component.child;

  @override
  void update(DomComponent newComponent) {
    super.update(newComponent);
    _dirty = true;
    root.performRebuildOn(this);
  }

  @override
  void render(DomBuilder b) {
    b.open(
      component.tag,
      id: component.id,
      classes: component.classes,
      styles: component.styles,
      attributes: component.attributes,
      events: component.events != null
          ? {
              for (var entry in component.events!.entries) entry.key: (e) => entry.value(),
            }
          : null,
      onCreate: (event) {
        view = event.view;
      },
    );

    super.render(b);

    b.close(tag: component.tag);
  }
}

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
  void render(DomBuilder b) {
    b.text(_component.text);
  }

  @override
  void rebuild() {}
}
