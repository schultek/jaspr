class Unit {
  final double value;
  final String type;

  const Unit(this.value, {required this.type});

  @override
  String toString() => "$value$type";

  factory Unit.custom(double value, String type) {
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

class Em extends Unit {
  const Em(super.value) : super(type: 'em');

  static const Em zero = Em(0);
}

class Rem extends Unit {
  const Rem(super.value) : super(type: 'rem');

  static const Rem zero = Rem(0);
}

class Number extends Unit {
  const Number(super.value) : super(type: '');

  static const Number zero = Number(0);
}
