import 'package:jaspr/jaspr.dart';

class MdDivider extends StatelessComponent {
  const MdDivider({
    this.inset = false,
    this.insetStart = false,
    this.insetEnd = false,
    this.id, 
    this.classes, 
    this.styles, 
    this.attributes, 
    this.events, 
    this.children, 
    super.key,
  });

  final bool inset;
  final bool insetStart;
  final bool insetEnd;
  final String? id;
  final String? classes;
  final Styles? styles;
  final Map<String, String>? attributes;
  final Map<String, EventCallback>? events;
  final List<Component>? children;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Head(children: [
      script(src: 'packages/jaspr_material/js/md-divider.js', async: true, []),
    ]);
    yield DomComponent(
      tag: 'md-divider',
      id: id,
      styles: styles,
      attributes: {
        ...?attributes,
        if (inset) 'inset': '',
        if (insetStart) 'inset-start': '',
        if (insetEnd) 'inset-end': '',
      },
      events: events,
      children: children,
    );
  }
}
  