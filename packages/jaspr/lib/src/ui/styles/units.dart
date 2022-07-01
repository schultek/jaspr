class Unit {
  final int value;
  final String type;

  const Unit(this.value, {required this.type});

  @override
  String toString() => "$value$type";

  factory Unit.custom(int value, String type) {
    return Unit(value, type: type);
  }
}

class Percent extends Unit {
  const Percent(super.value) : super(type: '%');

  static const Percent zero = Percent(0);
}

class Pixels extends Unit {
  const Pixels(super.value) : super(type: 'px');

  static const Pixels zero = Pixels(0);
}

class Points extends Unit {
  const Points(super.value) : super(type: 'pt');

  static const Points zero = Points(0);
}
