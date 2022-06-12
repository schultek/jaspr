import 'package:jaspr_ui/src/bootstrap/components/base.dart';

class Row extends BaseComponent {
  Row({
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
    return ['row', ...super.getClasses(classes)];
  }
}
