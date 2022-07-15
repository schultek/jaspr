import 'package:jaspr_bootstrap/src/components/base.dart';

class Row extends BaseComponent {
  const Row({
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
    return ['row', ...super.getClasses(classes)];
  }
}
