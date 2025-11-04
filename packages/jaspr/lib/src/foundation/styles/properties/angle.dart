import 'unit.dart';

/// Extension helpers to create [Angle] values from numeric literals.
///
/// Example:
///
/// ```dart
///  90.deg
///  1.rad
///  0.25.turn
/// ```
extension AngleExt on num {
  /// Returns an [Angle] expressed in degrees (CSS `deg`).
  Angle get deg => Angle.deg(toDouble());

  /// Returns an [Angle] expressed in radians (CSS `rad`).
  Angle get rad => Angle.rad(toDouble());

  /// Returns an [Angle] expressed in turns (CSS `turn`).
  Angle get turn => Angle.turn(toDouble());
}

/// The `<angle>` CSS data type represents an angle value expressed in
/// degrees, gradians, radians, or turns. It is used by CSS functions like
/// `rotate()` and in gradient angles.
///
/// Positive numbers represent clockwise angles; negative numbers represent
/// counter-clockwise angles. Common units are `deg`, `rad`, and `turn`.
///
/// Examples (CSS): `90deg`, `3.1416rad`, `0.25turn`.
///
/// Read more: [MDN `<angle>`](https://developer.mozilla.org/en-US/docs/Web/CSS/angle)
abstract class Angle {
  /// A zero angle (`0`). Useful when no rotation is required.
  static const Angle zero = _ZeroAngle();

  /// Constructs an [Angle] in degrees (`<number>deg`).
  const factory Angle.deg(double value) = _DegreeAngle;

  /// Constructs an [Angle] in radians (`<number>rad`).
  const factory Angle.rad(double value) = _RadianAngle;

  /// Constructs an [Angle] in turns (`<number>turn`). One full circle is `1turn`.
  const factory Angle.turn(double value) = _TurnAngle;

  /// Constructs an [Angle] from a CSS variable reference: `var(--name)`.
  const factory Angle.variable(String value) = _VariableAngle;

  /// Adds two angles. If both angles use the same unit the result may be
  /// combined; otherwise a CSS `calc()` expression will be produced.
  Angle operator +(Angle other);

  /// The CSS text value for this angle (e.g. `90deg`, `1.5708rad`, `0.25turn`).
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
