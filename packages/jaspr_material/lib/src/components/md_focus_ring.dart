import 'package:jaspr/jaspr.dart';

class MdFocusRing extends StatelessComponent {
  const MdFocusRing({
    this.visible = false,
    this.inward = false,
    this.id, 
    this.classes, 
    this.styles, 
    this.attributes, 
    this.events, 
    this.children, 
    super.key,
  });

  final bool visible;
  final bool inward;
  final String? id;
  final String? classes;
  final Styles? styles;
  final Map<String, String>? attributes;
  final Map<String, EventCallback>? events;
  final List<Component>? children;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Head(children: [
      script(src: 'packages/jaspr_material/js/md-focus-ring.js', async: true, []),
    ]);
    yield DomComponent(
      tag: 'md-focus-ring',
      id: id,
      styles: styles,
      attributes: {
        ...?attributes,
        if (visible) 'visible': '',
        if (inward) 'inward': '',
      },
      events: events,
      children: children,
    );
  }
}
  