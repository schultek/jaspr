import 'package:jaspr/jaspr.dart';

class MdRadio extends StatelessComponent {
  const MdRadio({
    required this.checked,
    this.required = false,
    this.value = "on",
    required this.name,
    required this.disabled,
    required this.tabindex,
    this.id, 
    this.classes, 
    this.styles, 
    this.attributes, 
    this.events, 
    this.children, 
    super.key,
  });

  final bool checked;
  final bool required;
  final String value;
  final String name;
  final bool disabled;
  final double tabindex;
  final String? id;
  final String? classes;
  final Styles? styles;
  final Map<String, String>? attributes;
  final Map<String, EventCallback>? events;
  final List<Component>? children;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Head(children: [
      script(src: 'packages/jaspr_material/js/md-radio.js', async: true, []),
    ]);
    yield DomComponent(
      tag: 'md-radio',
      id: id,
      styles: styles,
      attributes: {
        ...?attributes,
        if (checked) 'checked': '',
        if (required) 'required': '',
        'value': value,
        'name': name,
        if (disabled) 'disabled': '',
        'tabIndex': '$tabindex',
      },
      events: events,
      children: children,
    );
  }
}
  