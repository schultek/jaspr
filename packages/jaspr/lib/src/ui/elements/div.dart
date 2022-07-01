import 'package:jaspr/src/ui/elements/base.dart';

class DivElement extends BaseElement {
  const DivElement({
    super.key,
    super.id,
    super.style,
    super.classes,
    super.attributes,
    super.events,
    super.child,
    super.children,
  }) : super(tag: 'div');
}
