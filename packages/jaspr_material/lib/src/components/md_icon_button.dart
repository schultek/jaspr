import 'package:jaspr/jaspr.dart';

class MdIconButton extends StatelessComponent {
  const MdIconButton({
    this.disabled = false,
    this.flipIconInRtl = false,
    this.href = "",
    this.target = "",
    this.ariaLabelSelected = "",
    this.toggle = false,
    this.selected = false,
    this.type = "submit",
    this.value = "",
    this.id, 
    this.classes, 
    this.styles, 
    this.attributes, 
    this.events, 
    this.children, 
    super.key,
  });

  final bool disabled;
  final bool flipIconInRtl;
  final String href;
  final Object target;
  final String ariaLabelSelected;
  final bool toggle;
  final bool selected;
  final Object type;
  final String value;
  final String? id;
  final String? classes;
  final Styles? styles;
  final Map<String, String>? attributes;
  final Map<String, EventCallback>? events;
  final List<Component>? children;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Head(children: [
      script(src: 'packages/jaspr_material/js/md-icon-button.js', async: true, []),
    ]);
    yield DomComponent(
      tag: 'md-icon-button',
      id: id,
      styles: styles,
      attributes: {
        ...?attributes,
        if (disabled) 'disabled': '',
        if (flipIconInRtl) 'flip-icon-in-rtl': '',
        'href': href,
        'target': '$target',
        'aria-label-selected': ariaLabelSelected,
        if (toggle) 'toggle': '',
        if (selected) 'selected': '',
        'type': '$type',
        'value': value,
      },
      events: events,
      children: children,
    );
  }
}
  