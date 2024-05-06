import 'package:jaspr/jaspr.dart';

class MdOutlinedButton extends StatelessComponent {
  const MdOutlinedButton({
    this.disabled = false,
    this.href = "",
    this.target = "",
    this.trailingIcon = false,
    this.hasIcon = false,
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
  final String href;
  final Object target;
  final bool trailingIcon;
  final bool hasIcon;
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
      script(src: 'packages/jaspr_material/js/md-outlined-button.js', async: true, []),
    ]);
    yield DomComponent(
      tag: 'md-outlined-button',
      id: id,
      styles: styles,
      attributes: {
        ...?attributes,
        if (disabled) 'disabled': '',
        'href': href,
        'target': '$target',
        if (trailingIcon) 'trailing-icon': '',
        if (hasIcon) 'has-icon': '',
        'type': '$type',
        'value': value,
      },
      events: events,
      children: children,
    );
  }
}
  