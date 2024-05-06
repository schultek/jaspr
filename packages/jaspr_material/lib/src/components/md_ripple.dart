import 'package:jaspr/jaspr.dart';

class MdRipple extends StatelessComponent {
  const MdRipple({
    this.disabled = false,
    this.id, 
    this.classes, 
    this.styles, 
    this.attributes, 
    this.events, 
    this.children, 
    super.key,
  });

  final bool disabled;
  final String? id;
  final String? classes;
  final Styles? styles;
  final Map<String, String>? attributes;
  final Map<String, EventCallback>? events;
  final List<Component>? children;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Head(children: [
      script(src: 'packages/jaspr_material/js/md-ripple.js', async: true, []),
    ]);
    yield DomComponent(
      tag: 'md-ripple',
      id: id,
      styles: styles,
      attributes: {
        ...?attributes,
        if (disabled) 'disabled': '',
      },
      events: events,
      children: children,
    );
  }
}
  