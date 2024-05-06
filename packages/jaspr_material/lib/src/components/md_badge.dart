import 'package:jaspr/jaspr.dart';

class MdBadge extends StatelessComponent {
  const MdBadge({
    this.value = "",
    this.id, 
    this.classes, 
    this.styles, 
    this.attributes, 
    this.events, 
    this.children, 
    super.key,
  });

  final String value;
  final String? id;
  final String? classes;
  final Styles? styles;
  final Map<String, String>? attributes;
  final Map<String, EventCallback>? events;
  final List<Component>? children;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Head(children: [
      script(src: 'packages/jaspr_material/js/md-badge.js', async: true, []),
    ]);
    yield DomComponent(
      tag: 'md-badge',
      id: id,
      styles: styles,
      attributes: {
        ...?attributes,
        'value': value,
      },
      events: events,
      children: children,
    );
  }
}
  