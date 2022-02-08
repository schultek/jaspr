part of core;

typedef EventCallback = void Function();

class DomComponent implements Component {
  DomComponent(
      {required this.tag,
      this.id,
      this.classes,
      this.styles,
      this.attributes,
      this.events,
      this.child});

  final String tag;
  final String? id;
  final Iterable<String>? classes;
  final Map<String, String>? styles;
  final Map<String, String>? attributes;
  final Map<String, EventCallback>? events;
  final Component? child;

  @override
  Element createElement() {
    return DomElement(this);
  }
}

class DomElement extends Element {
  DomElement(DomComponent component) : super(component);

  @override
  DomComponent get _component => super._component as DomComponent;

  DomView? view;
  Element? child;

  Future? _invalidate;

  @override
  void markNeedsBuild() {
    _invalidate ??= Future.microtask(() async {
      try {
        await rebuild();
        await view?.invalidate();
      } finally {
        _invalidate = null;
      }
    });
  }

  @override
  Future<void> rebuild() async {
    child = await updateChild(child, _component.child);
    await child?.rebuild();
  }

  @override
  void render(DomBuilder b) {
    b.open(
      _component.tag,
      id: _component.id,
      classes: _component.classes,
      styles: _component.styles,
      attributes: _component.attributes,
      events: _component.events != null
          ? {
              for (var entry in _component.events!.entries)
                entry.key: (e) => entry.value(),
            }
          : null,
      onCreate: (event) {
        view = event.view;
      },
    );

    child?.render(b);

    b.close(tag: _component.tag);
  }
}

class Text implements Component {
  Text(this.text);

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
  Future<void> rebuild() async {}

  @override
  void render(DomBuilder b) {
    b.text(_component.text);
  }

  @override
  void markNeedsBuild() {}
}
