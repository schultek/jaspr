import 'package:jaspr/jaspr.dart';

class MdFilledSelect extends StatelessComponent {
  const MdFilledSelect({
    this.quick = false,
    this.required = false,
    this.errorText = "",
    this.label = "",
    this.supportingText = "",
    this.error = false,
    this.menuPositioning = "popover",
    this.clampMenuWidth = false,
    this.typeaheadDelay = 200,
    this.hasLeadingIcon = false,
    this.displayText = "",
    this.menuAlign = "start",
    required this.value,
    required this.selectedIndex,
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

  final bool quick;
  final bool required;
  final String errorText;
  final String label;
  final String supportingText;
  final bool error;
  final Object menuPositioning;
  final bool clampMenuWidth;
  final double typeaheadDelay;
  final bool hasLeadingIcon;
  final String displayText;
  final Object menuAlign;
  final String value;
  final double selectedIndex;
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
      script(src: 'packages/jaspr_material/js/md-filled-select.js', async: true, []),
    ]);
    yield DomComponent(
      tag: 'md-filled-select',
      id: id,
      styles: styles,
      attributes: {
        ...?attributes,
        if (quick) 'quick': '',
        if (required) 'required': '',
        'error-text': errorText,
        'label': label,
        'supporting-text': supportingText,
        if (error) 'error': '',
        'menu-positioning': '$menuPositioning',
        if (clampMenuWidth) 'clamp-menu-width': '',
        'typeahead-delay': '$typeaheadDelay',
        if (hasLeadingIcon) 'has-leading-icon': '',
        'display-text': displayText,
        'menu-align': '$menuAlign',
        'value': value,
        'selected-index': '$selectedIndex',
        'name': name,
        if (disabled) 'disabled': '',
      },
      events: events,
      children: children,
    );
  }
}
  