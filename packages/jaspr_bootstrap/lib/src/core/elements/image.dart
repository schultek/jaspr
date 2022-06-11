import 'package:jaspr/jaspr.dart';
import 'package:jaspr_ui/src/core/elements/base.dart';

class Image extends BaseElement {
  final String source;
  final String alternate;

  const Image({
    required this.source,
    this.alternate = '',
    super.key,
    super.id,
    super.styles,
    super.classes,
    super.attributes,
    super.events,
  });

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
