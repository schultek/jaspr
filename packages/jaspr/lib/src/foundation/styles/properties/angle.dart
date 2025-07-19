import 'unit.dart';

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

  /// Represents a css variable
  const factory Angle.variable(String value) = _VariableAngle;

  operator +(Angle other);

  /// The css value
  String get value;
}

class _ZeroAngle implements Angle {
  const _ZeroAngle();

  @override
  String get value => '0';

  @override
  Angle operator +(Angle other) => other;

  @override
  bool operator ==(Object other) => identical(this, other) || other is _Angle && other._value == 0;

  @override
  int get hashCode => 0;
}

class _VariableAngle implements Angle {
  final String _value;

  const _VariableAngle(this._value);

  @override
  String get value => 'var($_value)';

  @override
  Angle operator +(Angle other) {
    if (other is _ZeroAngle) return this;
    return _AddAngle(this, other);
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is _VariableAngle && other._value == _value;

  @override
  int get hashCode => _value.hashCode;
}

class _Angle implements Angle {
  final String _unit;
  final double _value;

  const _Angle(this._value, this._unit);

  @override
  String get value => '${_value.numstr}$_unit';

  @override
  Angle operator +(Angle other) {
    if (other is _ZeroAngle) return this;
    if (other is _Angle && other._unit == _unit) {
      return _Angle(_value + other._value, _unit);
    }
    return _AddAngle(this, other);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      _value == 0 && (other is _ZeroAngle || (other is _Angle && other._value == 0)) ||
      other is _Angle && _unit == other._unit && _value == other._value;

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

class _AddAngle implements Angle {
  final Angle _first;
  final Angle _second;

  const _AddAngle(this._first, this._second);

  @override
  String get value => 'calc(${_first.value} + ${_second.value})';

  @override
  Angle operator +(Angle other) {
    return _AddAngle(_first, _second + other);
  }
}