import 'package:jaspr/jaspr.dart';

class MdSubMenu extends StatelessComponent {
  const MdSubMenu({
    this.anchorCorner = "START_END",
    this.menuCorner = "START_START",
    this.hoverOpenDelay = 400,
    this.hoverCloseDelay = 400,
    this.mdSubMenu = true,
    this.id, 
    this.classes, 
    this.styles, 
    this.attributes, 
    this.events, 
    this.children, 
    super.key,
  });

  final Object anchorCorner;
  final Object menuCorner;
  final double hoverOpenDelay;
  final double hoverCloseDelay;
  final bool mdSubMenu;
  final String? id;
  final String? classes;
  final Styles? styles;
  final Map<String, String>? attributes;
  final Map<String, EventCallback>? events;
  final List<Component>? children;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Head(children: [
      script(src: 'packages/jaspr_material/js/md-sub-menu.js', async: true, []),
    ]);
    yield DomComponent(
      tag: 'md-sub-menu',
      id: id,
      styles: styles,
      attributes: {
        ...?attributes,
        'anchor-corner': '$anchorCorner',
        'menu-corner': '$menuCorner',
        'hover-open-delay': '$hoverOpenDelay',
        'hover-close-delay': '$hoverCloseDelay',
        if (mdSubMenu) 'md-sub-menu': '',
      },
      events: events,
      children: children,
    );
  }
}
  