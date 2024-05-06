import 'package:jaspr/jaspr.dart';

class MdFilledField extends StatelessComponent {
  const MdFilledField({
    this.disabled = false,
    this.error = false,
    this.focused = false,
    this.label = "",
    this.populated = false,
    this.required = false,
    this.resizable = false,
    this.supportingText = "",
    this.errorText = "",
    this.count = -1,
    this.max = -1,
    this.hasStart = false,
    this.hasEnd = false,
    this.id, 
    this.classes, 
    this.styles, 
    this.attributes, 
    this.events, 
    this.children, 
    super.key,
  });

  final bool disabled;
  final bool error;
  final bool focused;
  final String label;
  final bool populated;
  final bool required;
  final bool resizable;
  final String supportingText;
  final String errorText;
  final double count;
  final double max;
  final bool hasStart;
  final bool hasEnd;
  final String? id;
  final String? classes;
  final Styles? styles;
  final Map<String, String>? attributes;
  final Map<String, EventCallback>? events;
  final List<Component>? children;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Head(children: [
      script(src: 'packages/jaspr_material/js/md-filled-field.js', async: true, []),
    ]);
    yield DomComponent(
      tag: 'md-filled-field',
      id: id,
      styles: styles,
      attributes: {
        ...?attributes,
        if (disabled) 'disabled': '',
        if (error) 'error': '',
        if (focused) 'focused': '',
        'label': label,
        if (populated) 'populated': '',
        if (required) 'required': '',
        if (resizable) 'resizable': '',
        'supporting-text': supportingText,
        'error-text': errorText,
        'count': '$count',
        'max': '$max',
        if (hasStart) 'has-start': '',
        if (hasEnd) 'has-end': '',
      },
      events: events,
      children: children,
    );
  }
}
  