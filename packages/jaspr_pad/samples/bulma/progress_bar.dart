import 'package:jaspr/jaspr.dart';

import 'colors.dart';

/// Bulma Progress Bar Component
/// Supports a limited subset of the available options
/// See https://bulma.io/documentation/elements/progress/ for a detailed description
class ProgressBar extends StatelessComponent {
  const ProgressBar({this.child, this.value, this.max = 100, this.color, Key? key}) : super(key: key);

  final Component? child;
  final double? value;
  final double max;
  final Color? color;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'progress',
      classes: ['progress', if (color != null) 'is-${color!.name}'],
      attributes: {if (value != null) 'value': value!.toString(), 'max': max.toString()},
      child: child,
    );
  }
}
