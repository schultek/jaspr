import 'package:jaspr/components.dart';

class BoxConstraints {
  final Unit? maxWidth;
  final Unit? maxHeight;
  final Unit? minWidth;
  final Unit? minHeight;

  const BoxConstraints({this.maxWidth, this.maxHeight, this.minWidth, this.minHeight});

  static const BoxConstraints zero = BoxConstraints();
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
  BaseStyle? getStyles() => MultipleStyle(styles: [
    if (constraints.maxWidth != null) Style('max-width', constraints.maxWidth.toString()),
    if (constraints.maxHeight != null) Style('max-height', constraints.maxHeight.toString()),
    if (constraints.minWidth != null) Style('min-width', constraints.minWidth.toString()),
    if (constraints.minHeight != null) Style('min-height', constraints.minHeight.toString()),
  ]);
}

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
  BaseStyle? getStyles() => MultipleStyle(styles: [
    if (padding != null) Style('padding', padding!.getStyle()),
    if (margin != null) Style('margin', margin!.getStyle()),
    if (border != null) ...border!.getStyles(),
    if (outline != null) ...outline!.getStyles(),
    if (width != null) Style('width', width.toString()),
    if (height != null) Style('height', height.toString()),
    if (overflow != null) Style('overflow', overflow!.name),
    if (display != null) Style('display', display!.value),
    if (visibility != null) Style('visibility', visibility!.name),
    if (position != null) ...position!.getStyles(),
    if (opacity != null) Style('opacity', opacity.toString()),
  ]);
}