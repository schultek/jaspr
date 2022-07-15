import 'package:jaspr/jaspr.dart';
import 'package:jaspr/components.dart';

enum HeaderSize { h1, h2, h3, h4, h5, h6 }

class Header extends BaseElement {
  final String text;
  final HeaderSize size;

  Header(
    this.text, {
    this.size = HeaderSize.h3,
    super.key,
    super.id,
    super.style,
    super.classes,
    super.attributes,
    super.events,
  }) : super(tag: size.name);

  @override
  List<Component> getChildren() => [Text(text)];
}
