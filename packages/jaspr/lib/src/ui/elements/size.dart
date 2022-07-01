import 'package:jaspr/src/ui/elements/base.dart';
import 'package:jaspr/src/ui/styles.dart';

class Size extends BaseElement {
  final String width;
  final String height;

  const Size({
    this.width = "0px",
    this.height = "0px",
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
  BaseStyle? getStyles() => MultipleStyle(styles: [Style('width', width), Style('height', height)]);

}
