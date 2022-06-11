import 'package:jaspr/jaspr.dart';
import 'package:jaspr_ui/src/core/elements/base.dart';

enum HeaderSize { h1, h2, h3, h4, h5, h6 }

class Header extends BaseElement {
  final String text;
  final HeaderSize size;

  Header(
    this.text, {
    Key? key,
    super.id,
    super.styles,
    super.classes,
    super.attributes,
    super.events,
    this.size = HeaderSize.h3,
  }) : super(key: key);

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      id: id,
      styles: styles,
      classes: classes,
      attributes: attributes,
      events: events,
      tag: size.name,
      child: Text(text),
    );
  }
}
