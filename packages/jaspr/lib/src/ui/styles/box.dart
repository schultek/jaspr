import 'package:jaspr/ui.dart';

class BoxStyle extends MultipleStyle {
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Border? border;
  final Outline? outline;
  final Unit? width;
  final Unit? height;

  BoxStyle({
    this.padding,
    this.margin,
    this.border,
    this.outline,
    this.width,
    this.height,
  });

  @override
  List<Style> getStyles() => [
    if (padding != null) Style('padding', padding!.getStyle()),
    if (margin != null) Style('margin', margin!.getStyle()),
    if (border != null) ...border!.getStyles(),
    if (outline != null) ...outline!.getStyles(),
    if (width != null) Style('width', width.toString()),
    if (height != null) Style('height', height.toString()),
  ];
}
