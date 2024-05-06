import 'package:jaspr/jaspr.dart';

class MdCheckbox extends StatelessComponent {
  const MdCheckbox({
    this.checked = false,
    this.indeterminate = false,
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

  final bool checked;
  final bool indeterminate;
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
      script(src: 'packages/jaspr_material/js/md-checkbox.js', async: true, []),
    ]);
    yield DomComponent(
      tag: 'md-checkbox',
      id: id,
      styles: styles,
      attributes: {
        ...?attributes,
        if (checked) 'checked': '',
        if (indeterminate) 'indeterminate': '',
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
  