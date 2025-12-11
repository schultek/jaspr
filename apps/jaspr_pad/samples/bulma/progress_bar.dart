import 'package:jaspr/dom.dart' hide Color;
import 'package:jaspr/jaspr.dart';

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
  Component build(BuildContext context) {
    return progress(classes: 'progress ${color != null ? ' is-${color!.name}' : ''}', value: value, max: max, [
      if (child != null) child!,
    ]);
  }
}
