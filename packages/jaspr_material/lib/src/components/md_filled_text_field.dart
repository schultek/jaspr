import 'package:jaspr/jaspr.dart';

class MdFilledTextField extends StatelessComponent {
  const MdFilledTextField({
    this.error = false,
    this.errorText = "",
    this.label = "",
    this.required = false,
    this.value = "",
    this.prefixText = "",
    this.suffixText = "",
    this.hasLeadingIcon = false,
    this.hasTrailingIcon = false,
    this.supportingText = "",
    this.textDirection = "",
    this.rows = 2,
    this.cols = 20,
    this.inputmode = "",
    this.max = "",
    this.maxlength = -1,
    this.min = "",
    this.minlength = -1,
    this.noSpinner = false,
    this.pattern = "",
    this.placeholder = "",
    this.readonly = false,
    this.multiple = false,
    this.step = "",
    this.type = "text",
    this.autocomplete = "",
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

  final bool error;
  final String errorText;
  final String label;
  final bool required;
  final String value;
  final String prefixText;
  final String suffixText;
  final bool hasLeadingIcon;
  final bool hasTrailingIcon;
  final String supportingText;
  final String textDirection;
  final double rows;
  final double cols;
  final String inputmode;
  final String max;
  final double maxlength;
  final String min;
  final double minlength;
  final bool noSpinner;
  final String pattern;
  final String placeholder;
  final bool readonly;
  final bool multiple;
  final String step;
  final Object type;
  final String autocomplete;
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
      script(src: 'packages/jaspr_material/js/md-filled-text-field.js', async: true, []),
    ]);
    yield DomComponent(
      tag: 'md-filled-text-field',
      id: id,
      styles: styles,
      attributes: {
        ...?attributes,
        if (error) 'error': '',
        'error-text': errorText,
        'label': label,
        if (required) 'required': '',
        'value': value,
        'prefix-text': prefixText,
        'suffix-text': suffixText,
        if (hasLeadingIcon) 'has-leading-icon': '',
        if (hasTrailingIcon) 'has-trailing-icon': '',
        'supporting-text': supportingText,
        'text-direction': textDirection,
        'rows': '$rows',
        'cols': '$cols',
        'inputMode': inputmode,
        'max': max,
        'maxLength': '$maxlength',
        'min': min,
        'minLength': '$minlength',
        if (noSpinner) 'no-spinner': '',
        'pattern': pattern,
        'placeholder': placeholder,
        if (readonly) 'readOnly': '',
        if (multiple) 'multiple': '',
        'step': step,
        'type': '$type',
        'autocomplete': autocomplete,
        'name': name,
        if (disabled) 'disabled': '',
      },
      events: events,
      children: children,
    );
  }
}
  