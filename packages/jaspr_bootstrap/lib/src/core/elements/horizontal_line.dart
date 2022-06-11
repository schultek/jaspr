import 'package:jaspr/jaspr.dart';
import 'package:jaspr_ui/src/core/elements/base.dart';

class HorizontalLine extends BaseElement {
  HorizontalLine({
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
      tag: 'hr',
      id: id,
      styles: styles,
      classes: classes,
      attributes: attributes,
      events: events,
    );
  }
}
