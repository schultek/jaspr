import 'unit.dart';

typedef Padding = Spacing;
typedef Margin = Spacing;

class Spacing {
  /// The css styles
  final Map<String, String> styles;

  const Spacing._(this.styles);

  const factory Spacing.fromLTRB(Unit left, Unit top, Unit right, Unit bottom) = _QuadEdgeInsets;

  const factory Spacing.only({Unit? left, Unit? top, Unit? right, Unit? bottom}) = _QuadEdgeInsets.only;

  const factory Spacing.all(Unit value) = _AllEdgeInsets;

  const factory Spacing.symmetric({Unit? vertical, Unit? horizontal}) = _SymmetricEdgeInsets;

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

class _QuadEdgeInsets implements Spacing {
  final Unit? _left;
  final Unit? _top;
  final Unit? _right;
  final Unit? _bottom;

  const _QuadEdgeInsets(this._left, this._top, this._right, this._bottom);
  const _QuadEdgeInsets.only({Unit? left, Unit? top, Unit? right, Unit? bottom})
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
        if (_top != null) 'top': _top.value,
        if (_left != null) 'left': _left.value,
        if (_right != null) 'right': _right.value,
        if (_bottom != null) 'bottom': _bottom.value,
      };
    }
  }
}

class _AllEdgeInsets implements Spacing {
  final Unit _value;

  const _AllEdgeInsets(this._value);

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

class _SymmetricEdgeInsets implements Spacing {
  final Unit? vertical;
  final Unit? horizontal;

  const _SymmetricEdgeInsets({this.vertical, this.horizontal});

  @override
  Map<String, String> get styles {
    if (vertical != null && horizontal != null) {
      return {'': '${vertical!.value} ${horizontal!.value}'};
    } else {
      return {
        if (vertical != null) 'top': vertical!.value,
        if (vertical != null) 'bottom': vertical!.value,
        if (horizontal != null) 'left': horizontal!.value,
        if (horizontal != null) 'right': horizontal!.value,
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
