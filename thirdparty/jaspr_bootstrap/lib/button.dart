import 'package:jaspr/components.dart';

class Button extends BaseComponent {
  const Button({
    super.key,
    super.id,
    super.styles,
    super.classes,
    super.attributes,
    super.events,
    super.child,
    super.children,
  }) : super(tag: 'button');

  @override
  List<String> getClasses() => ['btn', 'btn-primary'];
}
