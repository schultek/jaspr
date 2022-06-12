import 'package:jaspr/jaspr.dart';

import 'base.dart';

class ButtonElement extends BaseElement {
  final String? text;

  ButtonElement({
    this.text,
    children,
    super.key,
    super.id,
    super.styles,
    super.classes,
    super.attributes,
    super.events,
  }) : super(tag: 'button');

  @override
  getChildren() => [if (text != null) Text(text!) else ...super.getChildren()];
}
