part of core;

class DomComponent implements Component {
  DomComponent({required this.tag, this.id, this.onClick, this.child});

  final String tag;
  final String? id;
  final Component? child;
  final void Function()? onClick;

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
      events: {
        if (_component.onClick != null)
          'click': (e) {
            _component.onClick!();
          },
      },
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
