import 'package:jaspr/src/ui/components/elements/base.dart';

@Deprecated("Will be removed after create `jaspr/html` library.")
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
