import 'package:jaspr/components.dart';
import 'package:jaspr/styles.dart';

class Box extends BaseElement {
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Border? border;
  final Outline? outline;
  final Unit? width;
  final Unit? height;
  final Overflow? overflow;
  final Display? display;
  final Visibility? visibility;
  final Position? position;
  final double? opacity;

  const Box({
    this.padding,
    this.margin,
    this.border,
    this.outline,
    this.width,
    this.height,
    this.overflow,
    this.display,
    this.visibility,
    this.position,
    this.opacity,
    super.key,
    super.id,
    super.style,
    super.classes,
    super.attributes,
    super.events,
    super.child,
    super.children,
    super.tag = 'div',
  });

  @override
  Styles getStyles() => Styles.combine([
        super.getStyles(),
        Styles.box(
          padding: padding,
          margin: margin,
          border: border,
          outline: outline,
          width: width,
          height: height,
          overflow: overflow,
          display: display,
          visibility: visibility,
          position: position,
          opacity: opacity,
        )
      ]);
}

class ConstrainedBox extends Box {
  final BoxConstraints constraints;

  const ConstrainedBox({
    required this.constraints,
    super.padding,
    super.margin,
    super.key,
    super.id,
    super.style,
    super.classes,
    super.attributes,
    super.events,
    super.child,
    super.children,
  });

  @override
  Styles getStyles() => Styles.combine([super.getStyles(), Styles.box(constraints: constraints)]);
}
