import 'package:jaspr/jaspr.dart' hide Color;

import 'colors.dart';

/// Bulma Progress Bar Component
/// Supports a limited subset of the available options
/// See https://bulma.io/documentation/elements/progress/ for a detailed description
class ProgressBar extends StatelessComponent {
  const ProgressBar({this.child, this.value, this.max = 100, this.color, super.key});

  final Component? child;
  final double? value;
  final double max;
  final Color? color;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield progress(
      classes: ['progress', if (color != null) 'is-${color!.name}'],
      value: value,
      max: max,
      [if (child != null) child!],
    );
  }
}
