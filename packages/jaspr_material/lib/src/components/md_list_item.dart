import 'package:jaspr/jaspr.dart';

class MdListItem extends StatelessComponent {
  const MdListItem({
    this.type = "text",
    this.mdListItem = true,
    this.href = "",
    this.target = "",
    this.disabled = false,
    this.id, 
    this.classes, 
    this.styles, 
    this.attributes, 
    this.events, 
    this.children, 
    super.key,
  });

  final Object type;
  final bool mdListItem;
  final String href;
  final Object target;
  final bool disabled;
  final String? id;
  final String? classes;
  final Styles? styles;
  final Map<String, String>? attributes;
  final Map<String, EventCallback>? events;
  final List<Component>? children;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Head(children: [
      script(src: 'packages/jaspr_material/js/md-list-item.js', async: true, []),
    ]);
    yield DomComponent(
      tag: 'md-list-item',
      id: id,
      styles: styles,
      attributes: {
        ...?attributes,
        'type': '$type',
        if (mdListItem) 'md-list-item': '',
        'href': href,
        'target': '$target',
        if (disabled) 'disabled': '',
      },
      events: events,
      children: children,
    );
  }
}
  