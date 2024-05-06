import 'package:jaspr/jaspr.dart';

class MdNavigationDrawer extends StatelessComponent {
  const MdNavigationDrawer({
    this.opened = false,
    this.pivot = "end",
    this.id, 
    this.classes, 
    this.styles, 
    this.attributes, 
    this.events, 
    this.children, 
    super.key,
  });

  final bool opened;
  final Object pivot;
  final String? id;
  final String? classes;
  final Styles? styles;
  final Map<String, String>? attributes;
  final Map<String, EventCallback>? events;
  final List<Component>? children;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Head(children: [
      script(src: 'packages/jaspr_material/js/md-navigation-drawer.js', async: true, []),
    ]);
    yield DomComponent(
      tag: 'md-navigation-drawer',
      id: id,
      styles: styles,
      attributes: {
        ...?attributes,
        if (opened) 'opened': '',
        'pivot': '$pivot',
      },
      events: events,
      children: children,
    );
  }
}
  