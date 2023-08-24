import 'unit.dart';

abstract class Position {
  static const Position static = _Position('static');

  const factory Position.absolute({Unit? top, Unit? left, Unit? bottom, Unit? right, ZIndex? zIndex}) =
      _Positioned.absolute;
  const factory Position.relative({Unit? top, Unit? left, Unit? bottom, Unit? right, ZIndex? zIndex}) =
      _Positioned.relative;
  const factory Position.fixed({Unit? top, Unit? left, Unit? bottom, Unit? right, ZIndex? zIndex}) = _Positioned.fixed;
  const factory Position.sticky({Unit? top, Unit? left, Unit? bottom, Unit? right, ZIndex? zIndex}) =
      _Positioned.sticky;

  static const Position inherit = _Position('inherit');
  static const Position initial = _Position('initial');
  static const Position revert = _Position('revert');
  static const Position revertLayer = _Position('revert-layer');
  static const Position unset = _Position('unset');

  Map<String, String> get styles;
}

class _Position implements Position {
  final String value;

  const _Position(this.value);

  @override
  Map<String, String> get styles => {
        'position': value,
      };
}

class _Positioned extends _Position {
  final Unit? top;
  final Unit? left;
  final Unit? bottom;
  final Unit? right;
  final ZIndex? zIndex;

  const _Positioned.absolute({this.top, this.left, this.bottom, this.right, this.zIndex}) : super('absolute');
  const _Positioned.relative({this.top, this.left, this.bottom, this.right, this.zIndex}) : super('relative');
  const _Positioned.fixed({this.top, this.left, this.bottom, this.right, this.zIndex}) : super('fixed');
  const _Positioned.sticky({this.top, this.left, this.bottom, this.right, this.zIndex}) : super('sticky');

  @override
  Map<String, String> get styles => {
        ...super.styles,
        if (top != null) 'top': top!.value,
        if (left != null) 'left': left!.value,
        if (bottom != null) 'bottom': bottom!.value,
        if (right != null) 'right': right!.value,
        if (zIndex != null) 'z-index': zIndex!.value,
      };
}

class ZIndex {
  static const ZIndex auto = ZIndex._('auto');

  const factory ZIndex(int value) = _ZIndex;

  static const ZIndex inherit = ZIndex._('inherit');
  static const ZIndex initial = ZIndex._('initial');
  static const ZIndex revert = ZIndex._('revert');
  static const ZIndex revertLayer = ZIndex._('revert-layer');
  static const ZIndex unset = ZIndex._('unset');

  final String value;
  const ZIndex._(this.value);
}

class _ZIndex extends ZIndex {
  const _ZIndex(int value) : super._('$value');
}
