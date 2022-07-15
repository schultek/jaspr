import 'package:jaspr/ui.dart';
import 'package:jaspr_bootstrap/core.dart';

abstract class BaseComponent extends BaseElement {
  final BackgroundColor? backgroundColor;
  final TextColor? textColor;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Border? border;

  const BaseComponent({
    super.id,
    super.key,
    super.child,
    super.children,
    super.style,
    super.classes,
    super.attributes,
    super.events,
    this.backgroundColor,
    this.textColor,
    this.padding,
    this.margin,
    this.border,
  }) : super(tag: 'div');

  @override
  List<String> getClasses([List<String>? classes]) {
    return [
      if (backgroundColor != null) backgroundColor!.value,
      if (textColor != null) textColor!.value,
      if (padding != null) ...padding!.getClasses('p'),
      if (margin != null) ...margin!.getClasses('m'),
      if (border != null) ...border!.getClasses(),
      if (classes != null) ...classes,
    ];
  }
}
