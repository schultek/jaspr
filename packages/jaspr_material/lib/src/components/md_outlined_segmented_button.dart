import 'package:jaspr/jaspr.dart';

class MdOutlinedSegmentedButton extends StatelessComponent {
  const MdOutlinedSegmentedButton({
    this.disabled = false,
    this.selected = false,
    this.label = "",
    this.noCheckmark = false,
    this.hasIcon = false,
    this.id, 
    this.classes, 
    this.styles, 
    this.attributes, 
    this.events, 
    this.children, 
    super.key,
  });

  final bool disabled;
  final bool selected;
  final String label;
  final bool noCheckmark;
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
      script(src: 'packages/jaspr_material/js/md-outlined-segmented-button.js', async: true, []),
    ]);
    yield DomComponent(
      tag: 'md-outlined-segmented-button',
      id: id,
      styles: styles,
      attributes: {
        ...?attributes,
        if (disabled) 'disabled': '',
        if (selected) 'selected': '',
        'label': label,
        if (noCheckmark) 'no-checkmark': '',
        if (hasIcon) 'has-icon': '',
      },
      events: events,
      children: children,
    );
  }
}
  