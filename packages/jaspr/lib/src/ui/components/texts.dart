import 'package:jaspr/components.dart';
import 'package:jaspr/jaspr.dart';

class RichText extends BaseElement {
  const RichText({
  super.key,
  super.id,
  super.styles,
  super.classes,
  super.attributes,
  super.events,
  super.child,
  super.children,
  }) : super(tag: 'p');
}

class TextSpan extends BaseElement {
  final String text;

  const TextSpan({
  required this.text,
  super.key,
  super.id,
  super.styles,
  super.classes,
  super.attributes,
  super.events,
  }) : super(tag: 'span');

  @override
  List<Component> getChildren() => [Text(text)];
}