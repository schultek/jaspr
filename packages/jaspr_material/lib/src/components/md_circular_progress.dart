import 'package:jaspr/jaspr.dart';

class MdCircularProgress extends StatelessComponent {
  const MdCircularProgress({
    this.value = 0,
    this.max = 1,
    this.indeterminate = false,
    this.fourColor = false,
    this.id, 
    this.classes, 
    this.styles, 
    this.attributes, 
    this.events, 
    this.children, 
    super.key,
  });

  final double value;
  final double max;
  final bool indeterminate;
  final bool fourColor;
  final String? id;
  final String? classes;
  final Styles? styles;
  final Map<String, String>? attributes;
  final Map<String, EventCallback>? events;
  final List<Component>? children;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Head(children: [
      script(src: 'packages/jaspr_material/js/md-circular-progress.js', async: true, []),
    ]);
    yield DomComponent(
      tag: 'md-circular-progress',
      id: id,
      styles: styles,
      attributes: {
        ...?attributes,
        'value': '$value',
        'max': '$max',
        if (indeterminate) 'indeterminate': '',
        if (fourColor) 'four-color': '',
      },
      events: events,
      children: children,
    );
  }
}
  