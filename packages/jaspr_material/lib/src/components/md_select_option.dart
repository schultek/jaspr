import 'package:jaspr/jaspr.dart';

class MdSelectOption extends StatelessComponent {
  const MdSelectOption({
    this.disabled = false,
    this.mdMenuItem = true,
    this.selected = false,
    this.value = "",
    required this.typeaheadText,
    required this.displayText,
    this.id, 
    this.classes, 
    this.styles, 
    this.attributes, 
    this.events, 
    this.children, 
    super.key,
  });

  final bool disabled;
  final bool mdMenuItem;
  final bool selected;
  final String value;
  final String typeaheadText;
  final String displayText;
  final String? id;
  final String? classes;
  final Styles? styles;
  final Map<String, String>? attributes;
  final Map<String, EventCallback>? events;
  final List<Component>? children;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Head(children: [
      script(src: 'packages/jaspr_material/js/md-select-option.js', async: true, []),
    ]);
    yield DomComponent(
      tag: 'md-select-option',
      id: id,
      styles: styles,
      attributes: {
        ...?attributes,
        if (disabled) 'disabled': '',
        if (mdMenuItem) 'md-menu-item': '',
        if (selected) 'selected': '',
        'value': value,
        'typeahead-text': typeaheadText,
        'display-text': displayText,
      },
      events: events,
      children: children,
    );
  }
}
  