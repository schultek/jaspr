import 'package:jaspr/jaspr.dart';
import 'package:jaspr_ui/src/core/elements/base.dart';

class ButtonElement extends BaseElement {
  final String text;

  const ButtonElement({
    required this.text,
    Key? key,
    super.id,
    super.styles,
    super.classes,
    super.attributes,
    super.events,
  }) : super(key: key);

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'button',
      id: id,
      styles: styles,
      classes: classes,
      attributes: attributes,
      events: events,
      child: Text(text),
    );
  }
}
