extension AngleExt on num {
  Angle get deg => Angle.deg(toDouble());
  Angle get rad => Angle.rad(toDouble());
  Angle get turn => Angle.turn(toDouble());
}

abstract class Angle {
  static const Angle zero = _ZeroAngle();

  /// Constructs an [Angle] in the form '90deg'
  const factory Angle.deg(double value) = _DegreeAngle;

  /// Constructs an [Angle] in the form '1rad'
  const factory Angle.rad(double value) = _RadianAngle;

  /// Constructs an [Angle] in the form '1turn'
  const factory Angle.turn(double value) = _TurnAngle;

  /// The css value
  String get value;
}

class _ZeroAngle implements Angle {
  const _ZeroAngle();

  @override
  String get value => '0';
}

class _Angle implements Angle {
  final String _unit;
  final double _value;

  const _Angle(this._value, this._unit);

  @override
  String get value => '$_value$_unit';
}

class _DegreeAngle extends _Angle {
  const _DegreeAngle(double value) : super(value, 'deg');
}

class _RadianAngle extends _Angle {
  const _RadianAngle(double value) : super(value, 'rad');
}

class _TurnAngle extends _Angle {
  const _TurnAngle(double value) : super(value, 'turn');
}
