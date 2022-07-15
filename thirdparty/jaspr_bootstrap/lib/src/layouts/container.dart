import 'package:jaspr_bootstrap/core.dart';
import 'package:jaspr_bootstrap/src/components/base.dart';

class Container extends BaseComponent {
  final Breakpoint breakpoint;

  const Container({
    this.breakpoint = Breakpoint.extraSmall,
    super.id,
    super.key,
    super.child,
    super.children,
    super.style,
    super.classes,
    super.attributes,
    super.events,
    super.backgroundColor,
    super.textColor,
    super.padding,
    super.margin,
    super.border,
  });

  @override
  List<String> getClasses([List<String>? classes]) {
    return [
      'container${breakpoint.value}',
      ...super.getClasses(classes),
    ];
  }
}
