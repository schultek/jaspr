import 'package:jaspr/jaspr.dart';
import 'package:jaspr_ui/src/core/elements/base.dart';

class Image extends BaseElement {
  final String source;
  final String alternate;
  final int width;
  final int height;

  const Image({
    Key? key,
    super.id,
    super.styles,
    super.classes,
    super.attributes,
    super.events,
    required this.source,
    this.width = 100,
    this.height = 100,
    this.alternate = '',
  }) : super(key: key);

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'img',
      id: id,
      styles: styles,
      classes: classes,
      events: events,
      attributes: {
        'src': source,
        'alt': alternate,
        if (attributes != null) ...attributes!,
      },
    );
  }
}
