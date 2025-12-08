import 'unit.dart';

/// The `padding` CSS property sets the inner spacing of an element.
///
/// Read more: [MDN `padding`](https://developer.mozilla.org/en-US/docs/Web/CSS/padding)
typedef Padding = Spacing;

/// The `margin` CSS property sets the outer spacing of an element.
///
/// Read more: [MDN `margin`](https://developer.mozilla.org/en-US/docs/Web/CSS/margin)
typedef Margin = Spacing;

/// Represents spacing properties such as padding and margin in CSS.
///
/// Prefer using [Padding] and [Margin] type aliases for better readability.
class Spacing {
  // TODO: Support block and inline spacings.

  /// The css styles
  final Map<String, String> styles;

  const Spacing._(this.styles);

  /// Creates spacing with individual values for left, top, right, and bottom.
  const factory Spacing.fromLTRB(Unit left, Unit top, Unit right, Unit bottom) = _QuadSpacing;

  /// Creates spacing with optional values for left, top, right, and bottom.
  const factory Spacing.only({Unit? left, Unit? top, Unit? right, Unit? bottom}) = _QuadSpacing.only;

  /// Creates spacing with the same value for all directions.
  const factory Spacing.all(Unit value) = _AllSpacing;

  /// Creates symmetric spacing with optional vertical and horizontal values.
  const factory Spacing.symmetric({Unit? vertical, Unit? horizontal}) = _SymmetricSpacing;

  /// Creates spacing with zero value for all directions.
  static const Spacing zero = Spacing.all(Unit.zero);

  Unit get left => Unit.zero;
  Unit get right => Unit.zero;
  Unit get top => Unit.zero;
  Unit get bottom => Unit.zero;

  static const Spacing inherit = Spacing._({'': 'inherit'});
  static const Spacing initial = Spacing._({'': 'initial'});
  static const Spacing revert = Spacing._({'': 'revert'});
  static const Spacing revertLayer = Spacing._({'': 'revert-layer'});
  static const Spacing unset = Spacing._({'': 'unset'});
}

class _QuadSpacing implements Spacing {
  final Unit? _left;
  final Unit? _top;
  final Unit? _right;
  final Unit? _bottom;

  const _QuadSpacing(this._left, this._top, this._right, this._bottom);
  const _QuadSpacing.only({Unit? left, Unit? top, Unit? right, Unit? bottom})
    : _left = left,
      _top = top,
      _right = right,
      _bottom = bottom;

  @override
  Unit get left => _left ?? Unit.zero;
  @override
  Unit get right => _right ?? Unit.zero;
  @override
  Unit get top => _top ?? Unit.zero;
  @override
  Unit get bottom => _bottom ?? Unit.zero;

  @override
  Map<String, String> get styles {
    if (_top != null && _right != null && _bottom != null && _left != null) {
      return {'': '${_top.value} ${_right.value} ${_bottom.value} ${_left.value}'};
    } else {
      return {
        'top': ?_top?.value,
        'left': ?_left?.value,
        'right': ?_right?.value,
        'bottom': ?_bottom?.value,
      };
    }
  }
}

class _AllSpacing implements Spacing {
  final Unit _value;

  const _AllSpacing(this._value);

  @override
  Unit get left => _value;
  @override
  Unit get right => _value;
  @override
  Unit get top => _value;
  @override
  Unit get bottom => _value;

  @override
  Map<String, String> get styles => {'': _value.value};
}

class _SymmetricSpacing implements Spacing {
  final Unit? vertical;
  final Unit? horizontal;

  const _SymmetricSpacing({this.vertical, this.horizontal});

  @override
  Map<String, String> get styles {
    if (vertical != null && horizontal != null) {
      return {'': '${vertical!.value} ${horizontal!.value}'};
    } else {
      return {
        'top': ?vertical?.value,
        'bottom': ?vertical?.value,
        'left': ?horizontal?.value,
        'right': ?horizontal?.value,
      };
    }
  }

  @override
  Unit get left => horizontal ?? Unit.zero;
  @override
  Unit get right => horizontal ?? Unit.zero;
  @override
  Unit get top => vertical ?? Unit.zero;
  @override
  Unit get bottom => vertical ?? Unit.zero;
}
