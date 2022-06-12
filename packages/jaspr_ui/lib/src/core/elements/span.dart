import 'package:jaspr/jaspr.dart';
import 'package:jaspr_ui/src/core/elements/base.dart';

class SpanElement extends BaseElement {
  SpanElement({
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
      tag: 'span',
      id: id,
      styles: styles,
      classes: classes,
      attributes: attributes,
      events: events,
      children: children
    );
  }
}
