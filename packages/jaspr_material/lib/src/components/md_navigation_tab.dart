import 'package:jaspr/jaspr.dart';

class MdNavigationTab extends StatelessComponent {
  const MdNavigationTab({
    this.disabled = false,
    required this.label,
    this.badgeValue = "",
    this.showBadge = false,
    this.active = false,
    this.hideInactiveLabel = false,
    this.id, 
    this.classes, 
    this.styles, 
    this.attributes, 
    this.events, 
    this.children, 
    super.key,
  });

  final bool disabled;
  final Object label;
  final String badgeValue;
  final bool showBadge;
  final bool active;
  final bool hideInactiveLabel;
  final String? id;
  final String? classes;
  final Styles? styles;
  final Map<String, String>? attributes;
  final Map<String, EventCallback>? events;
  final List<Component>? children;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Head(children: [
      script(src: 'packages/jaspr_material/js/md-navigation-tab.js', async: true, []),
    ]);
    yield DomComponent(
      tag: 'md-navigation-tab',
      id: id,
      styles: styles,
      attributes: {
        ...?attributes,
        if (disabled) 'disabled': '',
        'label': '$label',
        'badge-value': badgeValue,
        if (showBadge) 'show-badge': '',
        if (active) 'active': '',
        if (hideInactiveLabel) 'hide-inactive-label': '',
      },
      events: events,
      children: children,
    );
  }
}
  