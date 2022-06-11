import 'package:jaspr/jaspr.dart';
import 'package:jaspr_ui/src/bootstrap/components/base.dart';

class Row extends BaseComponent {
  Row({
    super.id,
    super.key,
    super.child,
    super.children,
    super.styles,
    super.classes,
    super.attributes,
    super.events,
    super.backgroundColor,
    super.textColor,
    super.padding,
    super.margin,
    super.border,
  });

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'div',
      id: id,
      styles: styles,
      attributes: attributes,
      events: events,
      classes: ['row', ...getClasses(classes)],
      children: children,
    );
  }
}
