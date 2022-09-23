import 'package:jaspr/components.dart';
import 'package:jaspr/styles.dart';

class Center extends BaseElement {
  const Center({
    super.key,
    super.id,
    super.style,
    super.classes,
    super.attributes,
    super.events,
    super.child,
    super.children,
  }) : super(tag: 'div');

  @override
  Styles getStyles() =>
      Styles.combine([super.getStyles(), Styles.flexbox(alignItems: AlignItems.center, justifyContent: JustifyContent.center)]);
}
