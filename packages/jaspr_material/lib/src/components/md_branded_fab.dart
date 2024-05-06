import 'package:jaspr/jaspr.dart';

class MdBrandedFab extends StatelessComponent {
  const MdBrandedFab({
    this.variant = "surface",
    this.size = "medium",
    this.label = "",
    this.lowered = false,
    this.id, 
    this.classes, 
    this.styles, 
    this.attributes, 
    this.events, 
    this.children, 
    super.key,
  });

  final Object variant;
  final Object size;
  final String label;
  final bool lowered;
  final String? id;
  final String? classes;
  final Styles? styles;
  final Map<String, String>? attributes;
  final Map<String, EventCallback>? events;
  final List<Component>? children;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Head(children: [
      script(src: 'packages/jaspr_material/js/md-branded-fab.js', async: true, []),
    ]);
    yield DomComponent(
      tag: 'md-branded-fab',
      id: id,
      styles: styles,
      attributes: {
        ...?attributes,
        'variant': '$variant',
        'size': '$size',
        'label': label,
        if (lowered) 'lowered': '',
      },
      events: events,
      children: children,
    );
  }
}
  