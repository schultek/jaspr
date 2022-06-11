import 'package:jaspr/jaspr.dart';
import 'package:jaspr_ui/bootstrap.dart';
import 'package:jaspr_ui/src/bootstrap/components/base.dart';

class Container extends BaseComponent {
  final Breakpoint breakpoint;

  Container({
    this.breakpoint = Breakpoint.extraSmall,
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
      classes: [
        'container${breakpoint.value}',
        ...getClasses(classes),
      ],
      children: children,
    );
  }
}
