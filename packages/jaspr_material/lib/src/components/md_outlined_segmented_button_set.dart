import 'package:jaspr/jaspr.dart';

class MdOutlinedSegmentedButtonSet extends StatelessComponent {
  const MdOutlinedSegmentedButtonSet({
    this.multiselect = false,
    this.id, 
    this.classes, 
    this.styles, 
    this.attributes, 
    this.events, 
    this.children, 
    super.key,
  });

  final bool multiselect;
  final String? id;
  final String? classes;
  final Styles? styles;
  final Map<String, String>? attributes;
  final Map<String, EventCallback>? events;
  final List<Component>? children;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Head(children: [
      script(src: 'packages/jaspr_material/js/md-outlined-segmented-button-set.js', async: true, []),
    ]);
    yield DomComponent(
      tag: 'md-outlined-segmented-button-set',
      id: id,
      styles: styles,
      attributes: {
        ...?attributes,
        if (multiselect) 'multiselect': '',
      },
      events: events,
      children: children,
    );
  }
}
  