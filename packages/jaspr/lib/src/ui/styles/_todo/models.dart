import 'package:jaspr/ui.dart';

class BoxConstraints {
  final Unit? maxWidth;
  final Unit? maxHeight;
  final Unit? minWidth;
  final Unit? minHeight;

  const BoxConstraints({this.maxWidth, this.maxHeight, this.minWidth, this.minHeight});

  static const BoxConstraints zero = BoxConstraints();
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

class Position {
  final String type;
  final EdgeInsets position;

  Position(this.type, this.position);

  factory Position.absolute(EdgeInsets position) {
    return Position('absolute', position);
  }

  factory Position.relative(EdgeInsets position) {
    return Position('relative', position);
  }

  factory Position.fixed(EdgeInsets position) {
    return Position('fixed', position);
  }

  List<Style> getStyles() => [
        Style('position', type),
        if (position.left != null) Style('left', position.left.toString()),
        if (position.top != null) Style('top', position.top.toString()),
        if (position.right != null) Style('right', position.right.toString()),
        if (position.bottom != null) Style('bottom', position.bottom.toString()),
      ];
}

abstract class Gradient {
  String getStyle() => "";
}

class LinearGradient extends Gradient {
  final bool isRepeating;
  final int angle;
  final Color color1;
  final Color color2;
  final Color? color3;
  final Percent? startColor1;
  final Percent? startColor2;
  final Percent? startColor3;

  LinearGradient({
    this.isRepeating = false,
    this.angle = 90,
    required this.color1,
    required this.color2,
    this.color3,
    this.startColor1,
    this.startColor2,
    this.startColor3,
  });

  @override
  String getStyle() {
    String startFunction = "${isRepeating ? 'repeating-' : ''}linear-gradient(";
    String anglePart = "${angle}deg,";
    String color1Part = "${color1.value} ${startColor1?.toString() ?? ''},";
    String color2Part = "${color2.value} ${startColor2?.toString() ?? ''}";
    String color3Part = color3 != null ? ', ${color3!.value} ${startColor3?.toString() ?? ''}' : '';
    String endFunction = ")";

    return startFunction + anglePart + color1Part + color2Part + color3Part + endFunction;
  }
}

class Circle {
  final Unit? size;
  final PositionEnum? position;

  Circle({this.size, this.position});

  String getStyle() => "circle ${size?.toString() ?? ''} ${position != null ? ' at ' + position!.value : ''},";
}

class RadialGradient extends Gradient {
  final bool isRepeating;
  final Color color1;
  final Color color2;
  final Color? color3;
  final Percent? startColor1;
  final Percent? startColor2;
  final Percent? startColor3;
  final Circle? circle;

  RadialGradient({
    this.isRepeating = false,
    required this.color1,
    required this.color2,
    this.color3,
    this.startColor1,
    this.startColor2,
    this.startColor3,
    this.circle,
  });

  @override
  String getStyle() {
    String startFunction = "${isRepeating ? 'repeating-' : ''}radial-gradient(";
    String setupPart = circle?.getStyle() ?? '';
    String color1Part = "${color1.value} ${startColor1?.toString() ?? ''},";
    String color2Part = "${color2.value} ${startColor2?.toString() ?? ''}";
    String color3Part = color3 != null ? ', ${color3!.value} ${startColor3?.toString() ?? ''}' : '';
    String endFunction = ")";

    return startFunction + setupPart + color1Part + color2Part + color3Part + endFunction;
  }
}
