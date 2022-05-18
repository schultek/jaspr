
import 'package:jaspr/jaspr.dart';

class Hidden extends StatelessComponent {
  const Hidden({required this.hidden, required this.child, this.visibilityMode = false, Key? key}) : super(key: key);

  final bool hidden;
  final Component child;
  final bool visibilityMode;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield child;
  }

  @override
  Element createElement() => HiddenElement(this);
}

class HiddenElement extends StatelessElement {
  HiddenElement(Hidden component) : super(component);

  @override
  Hidden get component => super.component as Hidden;

  @override
  void render(DomBuilder b) {
    super.render(HiddenBuilder(component.hidden, component.visibilityMode, b));
  }
}

class HiddenBuilder extends WrappedDomBuilder {
  HiddenBuilder(this.hidden, this.visibilityMode, DomBuilder builder) : super(builder);

  final bool hidden;
  final bool visibilityMode;

  bool isFirst = true;

  @override
  void open(
      String tag, {
        String? key,
        String? id,
        Iterable<String>? classes,
        Map<String, String>? styles,
        Map<String, String>? attributes,
        Map<String, DomEventFn>? events,
        DomLifecycleEventFn? onCreate,
        DomLifecycleEventFn? onUpdate,
        DomLifecycleEventFn? onRemove,
      }) {
    var hide = isFirst && hidden;
    isFirst = false;
    super.open(
      tag,
      key: key,
      id: id,
      classes: classes,
      styles: {...styles ?? {}, if (hide && visibilityMode) 'visibility': 'hidden'},
      attributes: {...attributes ?? {}, if (hide && !visibilityMode) 'hidden': ''},
      events: events,
      onCreate: onCreate,
      onUpdate: onUpdate,
      onRemove: onRemove,
    );
  }
}
