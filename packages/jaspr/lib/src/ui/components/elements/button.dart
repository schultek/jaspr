import 'package:jaspr/jaspr.dart';
import 'package:jaspr/components.dart';

class ButtonElement extends Box {
  final String? text;

  const ButtonElement({
    this.text,
    children,
    super.key,
    super.id,
    super.style,
    super.classes,
    super.attributes,
    super.events,
  }) : super(tag: 'button');

  @override
  getChildren() => [if (text != null) Text(text!) else ...super.getChildren()];
}
