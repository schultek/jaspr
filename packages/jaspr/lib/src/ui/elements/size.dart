import 'package:jaspr/src/ui/elements/base.dart';
import 'package:jaspr/src/ui/styles.dart';

class Size extends BaseElement {
  final Unit width;
  final Unit height;

  const Size({
    this.width = Pixels.zero,
    this.height = Pixels.zero,
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
  BaseStyle? getStyles() => MultipleStyle(styles: [Style('width', width.toString()), Style('height', height.toString())]);

}
