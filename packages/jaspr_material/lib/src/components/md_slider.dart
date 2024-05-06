import 'package:jaspr/jaspr.dart';

class MdSlider extends StatelessComponent {
  const MdSlider({
    this.min = 0,
    this.max = 100,
    required this.value,
    required this.valueStart,
    required this.valueEnd,
    this.valueLabel = "",
    this.valueLabelStart = "",
    this.valueLabelEnd = "",
    this.ariaLabelStart = "",
    this.ariaValuetextStart = "",
    this.ariaLabelEnd = "",
    this.ariaValuetextEnd = "",
    this.step = 1,
    this.ticks = false,
    this.labeled = false,
    this.range = false,
    required this.name,
    required this.disabled,
    this.id, 
    this.classes, 
    this.styles, 
    this.attributes, 
    this.events, 
    this.children, 
    super.key,
  });

  final double min;
  final double max;
  final Object value;
  final Object valueStart;
  final Object valueEnd;
  final String valueLabel;
  final String valueLabelStart;
  final String valueLabelEnd;
  final String ariaLabelStart;
  final String ariaValuetextStart;
  final String ariaLabelEnd;
  final String ariaValuetextEnd;
  final double step;
  final bool ticks;
  final bool labeled;
  final bool range;
  final String name;
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
      script(src: 'packages/jaspr_material/js/md-slider.js', async: true, []),
    ]);
    yield DomComponent(
      tag: 'md-slider',
      id: id,
      styles: styles,
      attributes: {
        ...?attributes,
        'min': '$min',
        'max': '$max',
        'value': '$value',
        'value-start': '$valueStart',
        'value-end': '$valueEnd',
        'value-label': valueLabel,
        'value-label-start': valueLabelStart,
        'value-label-end': valueLabelEnd,
        'aria-label-start': ariaLabelStart,
        'aria-valuetext-start': ariaValuetextStart,
        'aria-label-end': ariaLabelEnd,
        'aria-valuetext-end': ariaValuetextEnd,
        'step': '$step',
        if (ticks) 'ticks': '',
        if (labeled) 'labeled': '',
        if (range) 'range': '',
        'name': name,
        if (disabled) 'disabled': '',
      },
      events: events,
      children: children,
    );
  }
}
  