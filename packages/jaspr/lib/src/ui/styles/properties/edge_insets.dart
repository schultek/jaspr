import 'unit.dart';

class EdgeInsets {
  /// The css value
  final String value;

  const EdgeInsets._(this.value);

  const factory EdgeInsets.fromLTRB(Unit left, Unit top, Unit right, Unit bottom) = _QuadEdgeInsets;

  const factory EdgeInsets.only({Unit? left, Unit? top, Unit? right, Unit? bottom}) = _QuadEdgeInsets.only;

  const factory EdgeInsets.all(Unit value) = _AllEdgeInsets;

  const factory EdgeInsets.symmetric({Unit? vertical, Unit? horizontal}) = _SymmetricEdgeInsets;

  static const EdgeInsets zero = EdgeInsets.all(Unit.zero);

  Unit get left => Unit.zero;
  Unit get right => Unit.zero;
  Unit get top => Unit.zero;
  Unit get bottom => Unit.zero;

  static const EdgeInsets inherit = EdgeInsets._('inherit');
  static const EdgeInsets initial = EdgeInsets._('initial');
  static const EdgeInsets revert = EdgeInsets._('revert');
  static const EdgeInsets revertLayer = EdgeInsets._('revert-layer');
  static const EdgeInsets unset = EdgeInsets._('unset');
}

class _QuadEdgeInsets implements EdgeInsets {
  @override
  final Unit left;
  @override
  final Unit top;
  @override
  final Unit right;
  @override
  final Unit bottom;

  const _QuadEdgeInsets(this.left, this.top, this.right, this.bottom);
  const _QuadEdgeInsets.only({Unit? left, Unit? top, Unit? right, Unit? bottom})
      : left = left ?? Unit.zero,
        top = top ?? Unit.zero,
        right = right ?? Unit.zero,
        bottom = bottom ?? Unit.zero;

  @override
  String get value => '${top.value} ${right.value} ${bottom.value} ${left.value}';
}

class _AllEdgeInsets implements EdgeInsets {
  final Unit _value;

  const _AllEdgeInsets(this._value);
  @override
  String get value => _value.value;

  @override
  Unit get left => _value;
  @override
  Unit get right => _value;
  @override
  Unit get top => _value;
  @override
  Unit get bottom => _value;
}

class _SymmetricEdgeInsets implements EdgeInsets {
  final Unit vertical;
  final Unit horizontal;

  const _SymmetricEdgeInsets({Unit? vertical, Unit? horizontal})
      : vertical = vertical ?? Unit.zero,
        horizontal = horizontal ?? Unit.zero;

  @override
  String get value => '${vertical.value} ${horizontal.value}';

  @override
  Unit get left => horizontal;
  @override
  Unit get right => horizontal;
  @override
  Unit get top => vertical;
  @override
  Unit get bottom => vertical;
}
