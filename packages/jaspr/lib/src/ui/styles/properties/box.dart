import 'color.dart';
import 'unit.dart';

/// The display CSS property sets whether an element is treated as a block or inline element and the layout used for its children, such as flow layout, grid or flex.
enum Display {
  none("none"),
  block("block"),
  inline("inline"),
  inlineBlock("inline-block"),
  flex('flex'),
  inlineFlex('inline-flex'),
  grid('grid'),
  inlineGrid('inline-grid'),
  flowRoot('flow-root'),
  contents('contents'),

  inherit('inherit'),
  initial('initial'),
  revert('revert'),
  revertLayer('revert-layer'),
  unset('unset');

  /// The css value
  final String value;
  const Display(this.value);
}

abstract class Border {
  const factory Border.all(BorderSide side) = _AllBorder;
  const factory Border.only({BorderSide? left, BorderSide? top, BorderSide? right, BorderSide? bottom}) = _OnlyBorder;
  const factory Border.symmetric({BorderSide? vertical, BorderSide? horizontal}) = _SymmetricBorder;

  static const Border inherit = _Border('inherit');
  static const Border initial = _Border('initial');
  static const Border revert = _Border('revert');
  static const Border revertLayer = _Border('revert-layer');
  static const Border unset = _Border('unset');

  /// The css styles
  Map<String, String> get styles;
}

class _Border implements Border {
  /// The css value
  final String value;

  const _Border(this.value);

  @override
  Map<String, String> get styles => {'border': value};
}

class _AllBorder implements Border {
  final BorderSide side;

  const _AllBorder(this.side);

  @override
  Map<String, String> get styles => {
        'border': [
          if (side.style != null) side.style!.value,
          if (side.color != null) side.color!.value,
          if (side.width != null) side.width!.value,
        ].join(' ')
      };
}

class _OnlyBorder implements Border {
  final BorderSide? left;
  final BorderSide? top;
  final BorderSide? right;
  final BorderSide? bottom;

  const _OnlyBorder({this.left, this.top, this.right, this.bottom});

  @override
  Map<String, String> get styles => {
        if (left?.style != null) 'border-left-style': left!.style!.value,
        if (top?.style != null) 'border-top-style': top!.style!.value,
        if (right?.style != null) 'border-right-style': right!.style!.value,
        if (bottom?.style != null) 'border-bottom-style': bottom!.style!.value,
        if (left?.color != null) 'border-left-color': left!.color!.value,
        if (top?.color != null) 'border-top-color': top!.color!.value,
        if (right?.color != null) 'border-right-color': right!.color!.value,
        if (bottom?.color != null) 'border-bottom-color': bottom!.color!.value,
        if (left?.width != null) 'border-left-width': left!.width!.value,
        if (top?.width != null) 'border-top-width': top!.width!.value,
        if (right?.width != null) 'border-right-width': right!.width!.value,
        if (bottom?.width != null) 'border-bottom-width': bottom!.width!.value,
      };
}

class _SymmetricBorder implements Border {
  final BorderSide? vertical;
  final BorderSide? horizontal;

  const _SymmetricBorder({this.vertical, this.horizontal});

  @override
  Map<String, String> get styles {
    return {
      if (vertical?.style != null && horizontal?.style != null)
        'border-style': '${vertical!.style!.value} ${horizontal!.style!.value}'
      else ...{
        if (vertical?.style != null) 'border-top-style': vertical!.style!.value,
        if (vertical?.style != null) 'border-bottom-style': vertical!.style!.value,
        if (horizontal?.style != null) 'border-left-style': horizontal!.style!.value,
        if (horizontal?.style != null) 'border-right-style': horizontal!.style!.value,
      },
      if (vertical?.color != null && horizontal?.color != null)
        'border-color': '${vertical!.color!.value} ${horizontal!.color!.value}'
      else ...{
        if (vertical?.color != null) 'border-top-color': vertical!.color!.value,
        if (vertical?.color != null) 'border-bottom-color': vertical!.color!.value,
        if (horizontal?.color != null) 'border-left-color': horizontal!.color!.value,
        if (horizontal?.color != null) 'border-right-color': horizontal!.color!.value,
      },
      if (vertical?.width != null && horizontal?.width != null)
        'border-width': '${vertical!.width!.value} ${horizontal!.width!.value}'
      else ...{
        if (vertical?.width != null) 'border-top-width': vertical!.width!.value,
        if (vertical?.width != null) 'border-bottom-width': vertical!.width!.value,
        if (horizontal?.width != null) 'border-left-width': horizontal!.width!.value,
        if (horizontal?.width != null) 'border-right-width': horizontal!.width!.value,
      },
    };
  }
}

class BorderSide {
  final BorderStyle? style;
  final Color? color;
  final Unit? width;

  const BorderSide({this.style, this.color, this.width});
}

enum BorderStyle {
  none('none'),
  hidden('hidden'),
  dotted('dotted'),
  dashed('dashed'),
  solid('solid'),
  double('double'),
  groove('groove'),
  ridge('ridge'),
  inset('inset'),
  outset('outset');

  /// The css value
  final String value;
  const BorderStyle(this.value);
}

abstract class BorderRadius {
  const factory BorderRadius.all(Radius radius) = _AllBorderRadius;
  const factory BorderRadius.circular(Unit radius) = _CircularBorderRadius;
  const factory BorderRadius.only({Radius? topLeft, Radius? topRight, Radius? bottomLeft, Radius? bottomRight}) =
      _OnlyBorderRadius;

  const factory BorderRadius.vertical({Radius? top, Radius? bottom}) = _OnlyBorderRadius.vertical;

  const factory BorderRadius.horizontal({Radius? left, Radius? right}) = _OnlyBorderRadius.horizontal;

  /// The css styles
  Map<String, String> get styles;
}

class _AllBorderRadius implements BorderRadius {
  final Radius radius;

  const _AllBorderRadius(this.radius);

  @override
  Map<String, String> get styles => {
        'border-radius': radius._values.join(' / '),
      };
}

class _CircularBorderRadius implements BorderRadius {
  final Unit radius;

  const _CircularBorderRadius(this.radius);

  @override
  Map<String, String> get styles => {'border-radius': radius.value};
}

class _OnlyBorderRadius implements BorderRadius {
  final Radius? topLeft;
  final Radius? topRight;
  final Radius? bottomLeft;
  final Radius? bottomRight;

  const _OnlyBorderRadius({this.topLeft, this.topRight, this.bottomLeft, this.bottomRight});
  const _OnlyBorderRadius.vertical({Radius? top, Radius? bottom})
      : topLeft = top,
        topRight = top,
        bottomLeft = bottom,
        bottomRight = bottom;
  const _OnlyBorderRadius.horizontal({Radius? left, Radius? right})
      : topLeft = left,
        topRight = right,
        bottomLeft = left,
        bottomRight = right;

  @override
  Map<String, String> get styles {
    if (topLeft != null && topRight != null && bottomRight != null && bottomLeft != null) {
      var values = [topLeft!, topRight!, bottomRight!, bottomLeft!].map((r) => r._values).toList();
      if (values.every((v) => v.length == 1)) {
        return {'border-radius': values.map((v) => v.first).join(' ')};
      } else {
        return {'border-radius': '${values.map((v) => v.first).join(' ')} / ${values.map((v) => v.last).join(' ')}'};
      }
    } else {
      return {
        if (topLeft != null) 'border-top-left-radius': topLeft!._values.join(' '),
        if (topRight != null) 'border-top-right-radius': topRight!._values.join(' '),
        if (bottomRight != null) 'border-bottom-right-radius': bottomRight!._values.join(' '),
        if (bottomLeft != null) 'border-bottom-left-radius': bottomLeft!._values.join(' '),
      };
    }
  }
}

abstract class Radius {
  const factory Radius.circular(Unit radius) = _CircularRadius;
  const factory Radius.elliptical(Unit x, Unit y) = _EllipticalRadius;

  static const Radius zero = Radius.circular(Unit.zero);

  List<String> get _values;
}

class _CircularRadius implements Radius {
  final Unit radius;

  const _CircularRadius(this.radius);

  @override
  List<String> get _values {
    return [radius.value];
  }
}

class _EllipticalRadius implements Radius {
  final Unit x;
  final Unit y;

  const _EllipticalRadius(this.x, this.y);

  @override
  List<String> get _values {
    return [x.value, y.value];
  }
}

abstract class Outline {
  const factory Outline({Color? color, OutlineStyle? style, OutlineWidth? width, Unit? offset}) = _Outline;

  static const Outline inherit = _KeywordOutline('inherit');
  static const Outline initial = _KeywordOutline('initial');
  static const Outline revert = _KeywordOutline('revert');
  static const Outline revertLayer = _KeywordOutline('revert-layer');
  static const Outline unset = _KeywordOutline('unset');

  /// The css styles
  Map<String, String> get styles;
}

class _KeywordOutline implements Outline {
  /// The css value
  final String value;

  const _KeywordOutline(this.value);

  @override
  Map<String, String> get styles => {'outline': value};
}

class _Outline implements Outline {
  final Color? color;
  final OutlineStyle? style;
  final OutlineWidth? width;
  final Unit? offset;

  const _Outline({this.color, this.style, this.width, this.offset});

  @override
  Map<String, String> get styles => {
        if (color != null) 'outline-color': color!.value,
        if (style != null) 'outline-style': style!.value,
        if (width != null) 'outline-width': width!.value,
        if (offset != null) 'outline-offset': offset!.value,
      };
}

enum OutlineStyle {
  auto('auto'),
  none('none'),
  dotted('dotted'),
  dashed('dashed'),
  solid('solid'),
  double('double'),
  groove('groove'),
  ridge('ridge'),
  inset('inset'),
  outset('outset'),

  inherit('inherit'),
  initial('initial'),
  revert('revert'),
  revertLayer('revert-layer'),
  unset('unset');

  /// The css value
  final String value;
  const OutlineStyle(this.value);
}

abstract class OutlineWidth {
  const factory OutlineWidth(Unit unit) = _OutlineWidth;

  static const OutlineWidth thin = _KeywordOutlineWidth('thin');
  static const OutlineWidth medium = _KeywordOutlineWidth('medium');
  static const OutlineWidth thick = _KeywordOutlineWidth('thick');

  static const OutlineWidth inherit = _KeywordOutlineWidth('inherit');
  static const OutlineWidth initial = _KeywordOutlineWidth('initial');
  static const OutlineWidth revert = _KeywordOutlineWidth('revert');
  static const OutlineWidth revertLayer = _KeywordOutlineWidth('revert-layer');
  static const OutlineWidth unset = _KeywordOutlineWidth('unset');

  /// The css value
  String get value;
}

class _KeywordOutlineWidth implements OutlineWidth {
  @override
  final String value;

  const _KeywordOutlineWidth(this.value);
}

class _OutlineWidth implements OutlineWidth {
  final Unit unit;

  const _OutlineWidth(this.unit);

  @override
  String get value => unit.value;
}

abstract class Overflow {
  static const OverflowValue visible = OverflowValue._('visible');
  static const OverflowValue hidden = OverflowValue._('hidden');
  static const OverflowValue clip = OverflowValue._('clip');
  static const OverflowValue scroll = OverflowValue._('scroll');
  static const OverflowValue auto = OverflowValue._('auto');

  const factory Overflow.only({OverflowValue? x, OverflowValue? y}) = _OnlyOverflow;

  static const Overflow inherit = _Overflow('inherit');
  static const Overflow initial = _Overflow('initial');
  static const Overflow revert = _Overflow('revert');
  static const Overflow revertLayer = _Overflow('revert-layer');
  static const Overflow unset = _Overflow('unset');

  /// The css styles
  Map<String, String> get styles;
}

class _Overflow implements Overflow {
  final String _value;

  const _Overflow(this._value);

  @override
  Map<String, String> get styles => {
        'overflow': _value,
      };
}

class OverflowValue extends _Overflow {
  const OverflowValue._(super._value);
}

class _OnlyOverflow implements Overflow {
  final OverflowValue? x;
  final OverflowValue? y;

  const _OnlyOverflow({this.x, this.y});

  @override
  Map<String, String> get styles => {
        if (x != null && y != null)
          'overflow': '$x $y'
        else ...{
          if (x != null) 'overflow-x': x!._value,
          if (y != null) 'overflow-y': y!._value,
        },
      };
}

enum Visibility {
  visible('visible'),
  hidden('hidden'),
  collapse('collapse'),

  inherit('inherit'),
  initial('initial'),
  revert('revert'),
  revertLayer('revert-layer'),
  unset('unset');

  /// The css value
  final String value;
  const Visibility(this.value);
}
