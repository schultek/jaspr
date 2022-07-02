import 'package:jaspr/ui.dart';

class EdgeInsets {
  final Unit? left;
  final Unit? top;
  final Unit? right;
  final Unit? bottom;
  final Unit? horizontal;
  final Unit? vertical;

  EdgeInsets({this.left, this.top, this.right, this.bottom, this.horizontal, this.vertical});

  const EdgeInsets.fromLTRB(this.left, this.top, this.right, this.bottom)
      : horizontal = null,
        vertical = null;

  const EdgeInsets.all(Unit value)
      : left = null,
        top = null,
        right = null,
        bottom = null,
        horizontal = value,
        vertical = value;

  const EdgeInsets.only({this.left, this.top, this.right, this.bottom})
      : horizontal = null,
        vertical = null;

  const EdgeInsets.symmetric({
    this.vertical,
    this.horizontal,
  })  : left = null,
        top = null,
        right = null,
        bottom = null;

  static const EdgeInsets zero = EdgeInsets.only();

  getStyle() {
    if (horizontal != null || vertical != null) {
      return horizontal == vertical
          ? vertical.toString()
          : "${vertical?.toString() ?? '0px'} ${horizontal?.toString() ?? '0px'}";
    } else {
      return "${top?.toString() ?? '0px'} ${right?.toString() ?? '0px'} ${bottom?.toString() ?? '0px'} ${left?.toString() ?? '0px'}";
    }
  }

  EdgeInsets copyWith({
    Unit? left,
    Unit? top,
    Unit? right,
    Unit? bottom,
    Unit? horizontal,
    Unit? vertical,
  }) {
    return EdgeInsets(
      left: left ?? this.left,
      top: top ?? this.top,
      right: right ?? this.right,
      bottom: bottom ?? this.bottom,
      horizontal: horizontal ?? this.horizontal,
      vertical: vertical ?? this.vertical,
    );
  }
}

class Border {
  final BorderStyle? style;
  final Unit? width;
  final Color? color;
  final Unit? radius;

  const Border({
    this.style,
    this.width,
    this.color,
    this.radius,
  });

  List<Style> getStyles() => [
    if (style != null) Style('border-style', style!.name),
    if (width != null) Style('border-width', width.toString()),
    if (color != null) Style('border-color', color!.value),
    if (radius != null) Style('border-radius', radius.toString()),
  ];
}

class Outline {
  final BorderStyle? style;
  final Unit? width;
  final Color? color;

  const Outline({
    this.style,
    this.width,
    this.color,
  });

  List<Style> getStyles() => [
    if (style != null) Style('outline-style', style!.name),
    if (width != null) Style('outline-width', width.toString()),
    if (color != null) Style('outline-color', color!.value),
  ];
}
