import 'package:jaspr/jaspr.dart';

class MdMenu extends StatelessComponent {
  const MdMenu({
    this.anchor = "",
    this.positioning = "absolute",
    this.quick = false,
    this.hasOverflow = false,
    this.open = false,
    this.xOffset = 0,
    this.yOffset = 0,
    this.typeaheadDelay = 200,
    this.anchorCorner = "END_START",
    this.menuCorner = "START_START",
    this.stayOpenOnOutsideClick = false,
    this.stayOpenOnFocusout = false,
    this.skipRestoreFocus = false,
    this.defaultFocus = "FIRST_ITEM",
    this.noNavigationWrap = false,
    this.id, 
    this.classes, 
    this.styles, 
    this.attributes, 
    this.events, 
    this.children, 
    super.key,
  });

  final String anchor;
  final Object positioning;
  final bool quick;
  final bool hasOverflow;
  final bool open;
  final double xOffset;
  final double yOffset;
  final double typeaheadDelay;
  final Object anchorCorner;
  final Object menuCorner;
  final bool stayOpenOnOutsideClick;
  final bool stayOpenOnFocusout;
  final bool skipRestoreFocus;
  final Object defaultFocus;
  final bool noNavigationWrap;
  final String? id;
  final String? classes;
  final Styles? styles;
  final Map<String, String>? attributes;
  final Map<String, EventCallback>? events;
  final List<Component>? children;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Head(children: [
      script(src: 'packages/jaspr_material/js/md-menu.js', async: true, []),
    ]);
    yield DomComponent(
      tag: 'md-menu',
      id: id,
      styles: styles,
      attributes: {
        ...?attributes,
        'anchor': anchor,
        'positioning': '$positioning',
        if (quick) 'quick': '',
        if (hasOverflow) 'has-overflow': '',
        if (open) 'open': '',
        'x-offset': '$xOffset',
        'y-offset': '$yOffset',
        'typeahead-delay': '$typeaheadDelay',
        'anchor-corner': '$anchorCorner',
        'menu-corner': '$menuCorner',
        if (stayOpenOnOutsideClick) 'stay-open-on-outside-click': '',
        if (stayOpenOnFocusout) 'stay-open-on-focusout': '',
        if (skipRestoreFocus) 'skip-restore-focus': '',
        'default-focus': '$defaultFocus',
        if (noNavigationWrap) 'no-navigation-wrap': '',
      },
      events: events,
      children: children,
    );
  }
}
  