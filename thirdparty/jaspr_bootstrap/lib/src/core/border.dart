import 'package:jaspr_bootstrap/core.dart';

class BorderEdge {
  final bool left;
  final bool top;
  final bool right;
  final bool bottom;

  const BorderEdge.all({bool visible = true})
      : left = visible,
        top = visible,
        right = visible,
        bottom = visible;

  const BorderEdge.only({
    this.left = false,
    this.top = false,
    this.right = false,
    this.bottom = false,
  });

  const BorderEdge.symmetric({bool vertical = false, bool horizontal = false})
      : left = horizontal,
        top = vertical,
        right = horizontal,
        bottom = vertical;

  Iterable<String> getClasses() {
    if (left && top && right && bottom) {
      return ['border'];
    } else {
      return [
        if (left == true) 'border-start',
        if (top == true) 'border-top',
        if (right == true) 'border-end',
        if (bottom == true) 'border-bottom',
      ];
    }
  }
}

class Border {
  final BorderEdge? edge;
  final BorderColor? color;
  final BorderRound? round;
  final BorderRadius? radius;
  final BorderOpacity? opacity;
  final BorderWidth? width;

  Border({
    this.edge,
    this.color,
    this.round,
    this.radius,
    this.opacity,
    this.width,
  });

  Iterable<String> getClasses() {
    return [
      if (edge != null) ...edge!.getClasses(),
      if (color != null) color!.value,
      if (round != null) round!.value,
      if (radius != null) radius!.value,
      if (opacity != null) opacity!.value,
      if (width != null) width!.value,
    ];
  }
}
