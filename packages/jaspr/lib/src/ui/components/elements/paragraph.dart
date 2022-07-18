import 'package:jaspr/jaspr.dart';
import 'package:jaspr/components.dart';

class PreformattedText extends Box {
  final String text;

  const PreformattedText(
    this.text, {
    super.key,
    super.id,
    super.style,
    super.classes,
    super.attributes,
    super.events,
  }) : super(tag: 'pre');

  @override
  List<Component> getChildren() {
    return [Text(text)];
  }
}

class Paragraph extends Box {
  const Paragraph({
  super.key,
  super.id,
  super.style,
  super.classes,
  super.attributes,
  super.events,
  super.child,
  super.children,
  }) : super(tag: 'p');
}

class TextSpan extends Box {
  const TextSpan({
  super.key,
  super.id,
  super.style,
  super.classes,
  super.attributes,
  super.events,
  super.child,
  super.children,
  }) : super(tag: 'span');
}
