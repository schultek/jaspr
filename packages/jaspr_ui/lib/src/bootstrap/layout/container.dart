import 'package:jaspr/jaspr.dart';
import 'package:jaspr_ui/bootstrap.dart';
import 'package:jaspr_ui/src/bootstrap/components/base.dart';
import 'package:jaspr_ui/src/core/elements/div.dart';

class Container extends BaseComponent {
  final Breakpoint breakpoint;

  Container({
    this.breakpoint = Breakpoint.extraSmall,
    super.id,
    super.key,
    super.child,
    super.children,
    super.styles,
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
