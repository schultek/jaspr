import 'package:jaspr/components.dart';

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
  BaseStyle? getStyles() => MultipleStyle(styles: [
    Style('display', 'flex'),
    Style('justify-content', 'center'),
    Style('align-items', 'center'),
    if (style != null) style!,
  ]);
}
