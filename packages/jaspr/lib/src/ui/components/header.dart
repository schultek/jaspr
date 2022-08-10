import 'package:jaspr/components.dart';
import 'package:jaspr/jaspr.dart';

enum HeaderSize { h1, h2, h3, h4, h5, h6 }

class Header extends BaseElement {
  final String text;
  final HeaderSize size;

  Header({
    required this.text,
    this.size = HeaderSize.h3,
    super.key,
    super.id,
    super.styles,
    super.classes,
    super.attributes,
    super.events,
  }) : super(tag: size.name);

  @override
  List<Component> getChildren() => [Text(text)];
}
