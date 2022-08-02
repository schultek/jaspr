import 'package:jaspr/ui.dart';

class BoxConstraints {
  final Unit? maxWidth;
  final Unit? maxHeight;
  final Unit? minWidth;
  final Unit? minHeight;

  const BoxConstraints({this.maxWidth, this.maxHeight, this.minWidth, this.minHeight});

  static const BoxConstraints zero = BoxConstraints();
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
