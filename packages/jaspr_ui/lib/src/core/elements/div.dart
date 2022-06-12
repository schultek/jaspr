import 'package:jaspr/jaspr.dart';
import 'package:jaspr_ui/src/core/elements/base.dart';

class DivElement extends BaseElement {
  DivElement({
    super.key,
    super.id,
    super.styles,
    super.classes,
    super.attributes,
    super.events,
    super.child,
    super.children,
  });

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'div',
      id: id,
      styles: styles,
      classes: classes,
      attributes: attributes,
      events: events,
      children: children
    );
  }
}
