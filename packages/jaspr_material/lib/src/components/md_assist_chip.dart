import 'package:jaspr/jaspr.dart';

class MdAssistChip extends StatelessComponent {
  const MdAssistChip({
    this.elevated = false,
    this.href = "",
    this.target = "",
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
  final String href;
  final Object target;
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
      script(src: 'packages/jaspr_material/js/md-assist-chip.js', async: true, []),
    ]);
    yield DomComponent(
      tag: 'md-assist-chip',
      id: id,
      styles: styles,
      attributes: {
        ...?attributes,
        if (elevated) 'elevated': '',
        'href': href,
        'target': '$target',
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
  