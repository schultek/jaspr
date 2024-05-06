import 'package:jaspr/jaspr.dart';

class MdSwitch extends StatelessComponent {
  const MdSwitch({
    this.selected = false,
    this.icons = false,
    this.showOnlySelectedIcon = false,
    this.required = false,
    this.value = "on",
    required this.name,
    required this.disabled,
    this.id, 
    this.classes, 
    this.styles, 
    this.attributes, 
    this.events, 
    this.children, 
    super.key,
  });

  final bool selected;
  final bool icons;
  final bool showOnlySelectedIcon;
  final bool required;
  final String value;
  final String name;
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
      script(src: 'packages/jaspr_material/js/md-switch.js', async: true, []),
    ]);
    yield DomComponent(
      tag: 'md-switch',
      id: id,
      styles: styles,
      attributes: {
        ...?attributes,
        if (selected) 'selected': '',
        if (icons) 'icons': '',
        if (showOnlySelectedIcon) 'show-only-selected-icon': '',
        if (required) 'required': '',
        'value': value,
        'name': name,
        if (disabled) 'disabled': '',
      },
      events: events,
      children: children,
    );
  }
}
  