import 'package:jaspr/jaspr.dart';

class MdInputChip extends StatelessComponent {
  const MdInputChip({
    this.avatar = false,
    this.href = "",
    this.target = "",
    this.removeOnly = false,
    this.selected = false,
    this.disabled = false,
    this.alwaysFocusable = false,
    this.label = "",
    this.hasIcon = false,
    this.id, 
    this.classes, 
    this.styles, 
    this.attributes, 
    this.events, 
    this.children, 
    super.key,
  });

  final bool avatar;
  final String href;
  final Object target;
  final bool removeOnly;
  final bool selected;
  final bool disabled;
  final bool alwaysFocusable;
  final String label;
  final bool hasIcon;
  final String? id;
  final String? classes;
  final Styles? styles;
  final Map<String, String>? attributes;
  final Map<String, EventCallback>? events;
  final List<Component>? children;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Head(children: [
      script(src: 'packages/jaspr_material/js/md-input-chip.js', async: true, []),
    ]);
    yield DomComponent(
      tag: 'md-input-chip',
      id: id,
      styles: styles,
      attributes: {
        ...?attributes,
        if (avatar) 'avatar': '',
        'href': href,
        'target': '$target',
        if (removeOnly) 'remove-only': '',
        if (selected) 'selected': '',
        if (disabled) 'disabled': '',
        if (alwaysFocusable) 'always-focusable': '',
        'label': label,
        if (hasIcon) 'has-icon': '',
      },
      events: events,
      children: children,
    );
  }
}
  