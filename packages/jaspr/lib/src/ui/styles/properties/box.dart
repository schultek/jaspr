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
  Map<String, String> get styles => {
        // TODO
      };
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
