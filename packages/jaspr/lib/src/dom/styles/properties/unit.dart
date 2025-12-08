extension UnitExt on num {
  /// Refers to the CSS % (percent) unit.
  ///
  /// This is used to specify a percentage of the parent's width or height.
  Unit get percent => Unit.percent(toDouble());

  /// Refers to the CSS px (pixel) unit.
  ///
  /// This is used to specify a length in pixels.
  Unit get px => Unit.pixels(toDouble());

  /// Refers to the CSS pt (point) unit.
  ///
  /// This is used to specify a font size in certain contexts.
  /// Using pixel size may be preferred.
  Unit get pt => Unit.points(toDouble());

  /// Refers to the CSS em (font size) unit.
  ///
  /// This is used to specify a length relative to the font size of the parent.
  /// For example, '2.em' is equal to twice the font size of the parent.
  Unit get em => Unit.em(toDouble());

  /// Refers to the CSS rem (root em) unit.
  ///
  /// This is used to specify a length relative to the font size of the
  /// root element (usually the `<html>` element). For example, '2.rem' is equal
  /// to twice the font size of the root element. If all child elements use
  /// rem units, then simply changing the value of the root element will
  /// proportionally adjust the values of the children.
  Unit get rem => Unit.rem(toDouble());

  /// Refers to the CSS vw (viewport width) unit.
  ///
  /// This is used to specify a percentage of the viewport width.
  /// For example, 50.vw means 50% of the viewport (browser window) width.
  /// This is useful for creating responsive layouts.
  Unit get vw => Unit.vw(toDouble());

  /// Refers to the CSS vh (viewport height) unit.
  ///
  /// This is used to specify a percentage of the viewport height.
  /// For example, 50.vh means 50% of the viewport (browser window) height.
  /// This is useful for creating responsive layouts.
  Unit get vh => Unit.vh(toDouble());
}

/// Represents a CSS unit value.
///
/// This can be used to specify lengths, sizes, and other measurements in CSS.
///
/// Read more: [MDN CSS Values and Units](https://developer.mozilla.org/en-US/docs/Learn/CSS/Building_blocks/Values_and_units)
abstract class Unit {
  static const Unit zero = _ExpUnit('0');

  /// The style attribute unit 'auto'
  static const Unit auto = _ExpUnit('auto');

  /// The max-content sizing keyword represents the maximum intrinsic size of the content. For text content this means
  /// that the content will not wrap at all even if it causes overflows.
  static const Unit maxContent = _ExpUnit('max-content');

  /// The min-content sizing keyword represents the minimum intrinsic size of the content. For text content this means
  /// that the content will take all soft-wrapping opportunities, becoming as small as the longest word.
  static const Unit minContent = _ExpUnit('min-content');

  /// The fit-content keyword means that the box will use the available space, but never more than max-content.
  static const Unit fitContent = _ExpUnit('fit-content');

  /// Represents a css variable
  const factory Unit.variable(String value) = _VariableUnit;

  /// Constructs a [Unit] in the form '100%'
  const factory Unit.percent(double value) = _PercentUnit;

  /// Constructs a [Unit] in the form '100px'
  const factory Unit.pixels(double value) = _PixelsUnit;

  /// Constructs a [Unit] in the form '100pt'
  const factory Unit.points(double value) = _PointsUnit;

  /// Constructs a [Unit] in the form '100em'
  const factory Unit.em(double value) = _EmUnit;

  /// Constructs a [Unit] in the form '100rem'
  const factory Unit.rem(double value) = _RemUnit;

  /// Constructs a [Unit] in the form '100vw'
  const factory Unit.vw(double value) = _VwUnit;

  /// Constructs a [Unit] in the form '100vh'
  const factory Unit.vh(double value) = _VhUnit;

  /// Constructs a [Unit] from a custom css expression.
  ///
  /// This allows to use css functions like `calc()`, `min()`, etc.
  const factory Unit.expression(String expression) = _ExpUnit;

  /// The css value
  String get value;

  static const Unit inherit = _ExpUnit('inherit');
  static const Unit initial = _ExpUnit('initial');
  static const Unit revert = _ExpUnit('revert');
  static const Unit revertLayer = _ExpUnit('revert-layer');
  static const Unit unset = _ExpUnit('unset');
}

class _ExpUnit implements Unit {
  const _ExpUnit(this.value);

  @override
  final String value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ExpUnit && other.value == value ||
      value == '0' && other is _Unit && other._value == 0;

  @override
  int get hashCode => value == '0' ? 0 : Object.hash(_ExpUnit, value);
}

class _VariableUnit implements Unit {
  final String _value;

  const _VariableUnit(this._value);

  @override
  String get value => 'var($_value)';

  @override
  bool operator ==(Object other) => identical(this, other) || other is _VariableUnit && other._value == _value;

  @override
  int get hashCode => Object.hash(_VariableUnit, _value);
}

class _Unit implements Unit {
  final String _unit;
  final double _value;

  const _Unit(this._value, this._unit);

  @override
  String get value => '${_value.numstr}$_unit';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      _value == 0 && ((other is _ExpUnit && other.value == '0') || (other is _Unit && other._value == 0)) ||
      other is _Unit && runtimeType == other.runtimeType && _unit == other._unit && _value == other._value;

  @override
  int get hashCode => _value == 0 ? 0 : Object.hash(_unit, _value);
}

class _PercentUnit extends _Unit {
  const _PercentUnit(double value) : super(value, '%');
}

class _PixelsUnit extends _Unit {
  const _PixelsUnit(double value) : super(value, 'px');
}

class _PointsUnit extends _Unit {
  const _PointsUnit(double value) : super(value, 'pt');
}

class _EmUnit extends _Unit {
  const _EmUnit(double value) : super(value, 'em');
}

class _RemUnit extends _Unit {
  const _RemUnit(double value) : super(value, 'rem');
}

class _VwUnit extends _Unit {
  const _VwUnit(double value) : super(value, 'vw');
}

class _VhUnit extends _Unit {
  const _VhUnit(double value) : super(value, 'vh');
}

extension NumberString on double {
  String get numstr {
    if (isInfinite) return toString().toLowerCase();
    return roundToDouble() == this ? round().toString() : toString();
  }
}

extension DurationExt on int {
  /// Shorthand for `Duration(milliseconds: this)`
  Duration get ms => Duration(milliseconds: this);

  /// Shorthand for `Duration(seconds: this)`
  Duration get seconds => Duration(seconds: this);
}
