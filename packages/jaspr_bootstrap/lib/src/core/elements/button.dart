import 'package:jaspr/jaspr.dart';
import 'package:jaspr_ui/src/core/elements/base.dart';

class ButtonElement extends BaseElement {
  final String? text;

  const ButtonElement({
    this.text,
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
      tag: 'button',
      id: id,
      styles: styles,
      classes: classes,
      attributes: attributes,
      events: events,
      children: [if (text != null) Text(text!) else ...children],
    );
  }
}
