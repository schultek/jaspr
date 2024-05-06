import 'package:jaspr/jaspr.dart';

class MdLinearProgress extends StatelessComponent {
  const MdLinearProgress({
    this.buffer = 0,
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

  final double buffer;
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
      script(src: 'packages/jaspr_material/js/md-linear-progress.js', async: true, []),
    ]);
    yield DomComponent(
      tag: 'md-linear-progress',
      id: id,
      styles: styles,
      attributes: {
        ...?attributes,
        'buffer': '$buffer',
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
  