import 'package:jaspr/jaspr.dart';

class MdDialog extends StatelessComponent {
  const MdDialog({
    required this.open,
    this.quick = false,
    required this.type,
    this.noFocusTrap = false,
    this.id, 
    this.classes, 
    this.styles, 
    this.attributes, 
    this.events, 
    this.children, 
    super.key,
  });

  final bool open;
  final bool quick;
  final Object type;
  final bool noFocusTrap;
  final String? id;
  final String? classes;
  final Styles? styles;
  final Map<String, String>? attributes;
  final Map<String, EventCallback>? events;
  final List<Component>? children;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Head(children: [
      script(src: 'packages/jaspr_material/js/md-dialog.js', async: true, []),
    ]);
    yield DomComponent(
      tag: 'md-dialog',
      id: id,
      styles: styles,
      attributes: {
        ...?attributes,
        if (open) 'open': '',
        if (quick) 'quick': '',
        'type': '$type',
        if (noFocusTrap) 'no-focus-trap': '',
      },
      events: events,
      children: children,
    );
  }
}
  