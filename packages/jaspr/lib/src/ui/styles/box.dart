import 'package:jaspr/ui.dart';

class BoxStyle extends MultipleStyle {
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

  BoxStyle({
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
  });

  @override
  List<Style> getStyles() => [
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
  ];
}
