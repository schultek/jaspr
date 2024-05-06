import 'package:jaspr/jaspr.dart';

class MdPrimaryTab extends StatelessComponent {
  const MdPrimaryTab({
    this.inlineIcon = false,
    this.mdTab = true,
    this.active = false,
    required this.selected,
    this.hasIcon = false,
    this.iconOnly = false,
    required this.tabindex,
    this.id, 
    this.classes, 
    this.styles, 
    this.attributes, 
    this.events, 
    this.children, 
    super.key,
  });

  final bool inlineIcon;
  final bool mdTab;
  final bool active;
  final bool selected;
  final bool hasIcon;
  final bool iconOnly;
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
      script(src: 'packages/jaspr_material/js/md-primary-tab.js', async: true, []),
    ]);
    yield DomComponent(
      tag: 'md-primary-tab',
      id: id,
      styles: styles,
      attributes: {
        ...?attributes,
        if (inlineIcon) 'inline-icon': '',
        if (mdTab) 'md-tab': '',
        if (active) 'active': '',
        if (selected) 'selected': '',
        if (hasIcon) 'has-icon': '',
        if (iconOnly) 'icon-only': '',
        'tabIndex': '$tabindex',
      },
      events: events,
      children: children,
    );
  }
}
  