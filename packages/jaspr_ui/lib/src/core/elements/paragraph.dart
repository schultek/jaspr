import 'package:jaspr/jaspr.dart';
import 'package:jaspr_ui/src/core/elements/base.dart';

class Paragraph extends BaseElement {
  final String text;

  Paragraph(
    this.text, {
    super.key,
    super.id,
    super.style,
    super.classes,
    super.attributes,
    super.events,
  }) : super(tag: 'p');

  @override
  List<Component> getChildren() {
    return [Text(text)];
  }
}
