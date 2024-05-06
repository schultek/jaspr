import 'package:jaspr/jaspr.dart';

class MdNavigationDrawerModal extends StatelessComponent {
  const MdNavigationDrawerModal({
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
      script(src: 'packages/jaspr_material/js/md-navigation-drawer-modal.js', async: true, []),
    ]);
    yield DomComponent(
      tag: 'md-navigation-drawer-modal',
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
  