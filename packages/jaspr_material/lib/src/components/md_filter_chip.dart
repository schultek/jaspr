import 'package:jaspr/jaspr.dart';

class MdFilterChip extends StatelessComponent {
  const MdFilterChip({
    this.elevated = false,
    this.removable = false,
    this.selected = false,
    this.hasSelectedIcon = false,
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

  final bool elevated;
  final bool removable;
  final bool selected;
  final bool hasSelectedIcon;
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
      script(src: 'packages/jaspr_material/js/md-filter-chip.js', async: true, []),
    ]);
    yield DomComponent(
      tag: 'md-filter-chip',
      id: id,
      styles: styles,
      attributes: {
        ...?attributes,
        if (elevated) 'elevated': '',
        if (removable) 'removable': '',
        if (selected) 'selected': '',
        if (hasSelectedIcon) 'has-selected-icon': '',
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
  