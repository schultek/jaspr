import 'package:jaspr/jaspr.dart';

class MdItem extends StatelessComponent {
  const MdItem({
    this.multiline = false,
    this.id, 
    this.classes, 
    this.styles, 
    this.attributes, 
    this.events, 
    this.children, 
    super.key,
  });

  final bool multiline;
  final String? id;
  final String? classes;
  final Styles? styles;
  final Map<String, String>? attributes;
  final Map<String, EventCallback>? events;
  final List<Component>? children;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Head(children: [
      script(src: 'packages/jaspr_material/js/md-item.js', async: true, []),
    ]);
    yield DomComponent(
      tag: 'md-item',
      id: id,
      styles: styles,
      attributes: {
        ...?attributes,
        if (multiline) 'multiline': '',
      },
      events: events,
      children: children,
    );
  }
}
  