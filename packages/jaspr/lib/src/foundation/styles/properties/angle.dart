import 'unit.dart';

extension AngleExt on num {
  Angle get deg => Angle.deg(toDouble());
  Angle get rad => Angle.rad(toDouble());
  Angle get turn => Angle.turn(toDouble());
}

abstract class Angle {
  /// Constructs an [Angle] in the form '90deg'
  const factory Angle.deg(double value) = _DegreeAngle;

  /// Constructs an [Angle] in the form '1rad'
  const factory Angle.rad(double value) = _RadianAngle;

  /// Constructs an [Angle] in the form '1turn'
  const factory Angle.turn(double value) = _TurnAngle;

  static const Angle zero = _ZeroAngle();

  /// The css value
  String get value;
}

class _ZeroAngle implements Angle {
  const _ZeroAngle();

  @override
  String get value => '0';

  @override
  bool operator ==(Object other) => identical(this, other) || other is _Angle && other._value == 0;

  @override
  int get hashCode => 0;
}

class _Angle implements Angle {
  const _Angle(this._value, this._unit);

  final String _unit;
  final double _value;

  @override
  String get value => '${_value.numstr}$_unit';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      _value == 0 && (other is _ZeroAngle || (other is _Angle && other._value == 0)) ||
      other is _Angle && runtimeType == other.runtimeType && _unit == other._unit && _value == other._value;

  @override
  int get hashCode => _value == 0 ? 0 : _unit.hashCode ^ _value.hashCode;
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
