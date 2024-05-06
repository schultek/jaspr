import 'package:jaspr/jaspr.dart';

class MdMenuItem extends StatelessComponent {
  const MdMenuItem({
    this.disabled = false,
    this.type = "menuitem",
    this.href = "",
    this.target = "",
    this.keepOpen = false,
    this.selected = false,
    required this.typeaheadText,
    this.id, 
    this.classes, 
    this.styles, 
    this.attributes, 
    this.events, 
    this.children, 
    super.key,
  });

  final bool disabled;
  final Object type;
  final String href;
  final Object target;
  final bool keepOpen;
  final bool selected;
  final String typeaheadText;
  final String? id;
  final String? classes;
  final Styles? styles;
  final Map<String, String>? attributes;
  final Map<String, EventCallback>? events;
  final List<Component>? children;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Head(children: [
      script(src: 'packages/jaspr_material/js/md-menu-item.js', async: true, []),
    ]);
    yield DomComponent(
      tag: 'md-menu-item',
      id: id,
      styles: styles,
      attributes: {
        ...?attributes,
        if (disabled) 'disabled': '',
        'type': '$type',
        'href': href,
        'target': '$target',
        if (keepOpen) 'keep-open': '',
        if (selected) 'selected': '',
        'typeahead-text': typeaheadText,
      },
      events: events,
      children: children,
    );
  }
}
  