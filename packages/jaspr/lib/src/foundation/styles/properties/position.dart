import 'unit.dart';

/// The `position` CSS property sets how an element is positioned in a document
///
/// See also:
///   - [ZIndex] for controlling the stack order of positioned elements.
///
/// Read more: [MDN `position`](https://developer.mozilla.org/en-US/docs/Web/CSS/position)
abstract class Position {
  /// The element is positioned according to the Normal Flow of the document. This is the default value.
  static const Position static = _Position('static');

  /// The element is removed from the normal document flow, and no space is created for the element in the page layout.
  /// The element is positioned relative to its closest positioned ancestor (if any) or to the initial containing block.
  /// Its final position is determined by the values of [top], [right], [bottom], and [left].
  const factory Position.absolute({Unit? top, Unit? left, Unit? bottom, Unit? right}) = _Positioned.absolute;

  /// The element is positioned according to the normal flow of the document, and then offset relative to itself based
  /// on the values of [top], [right], [bottom], and [left]. The offset does not affect the position of any other
  /// elements; thus, the space given for the element in the page layout is the same as if position were static.
  const factory Position.relative({Unit? top, Unit? left, Unit? bottom, Unit? right}) = _Positioned.relative;

  /// The element is removed from the normal document flow, and no space is created for the element in the page layout.
  /// The element is positioned relative to its initial containing block, which is the viewport in the case of visual
  /// media. Its final position is determined by the values of [top], [right], [bottom], and [left].
  const factory Position.fixed({Unit? top, Unit? left, Unit? bottom, Unit? right}) = _Positioned.fixed;

  /// The element is positioned according to the normal flow of the document, and then offset relative to its nearest
  /// scrolling ancestor and containing block (nearest block-level ancestor), including table-related elements, based
  /// on the values of [top], [right], [bottom], and [left]. The offset does not affect the position of any other elements.
  const factory Position.sticky({Unit? top, Unit? left, Unit? bottom, Unit? right}) = _Positioned.sticky;

  static const Position inherit = _Position('inherit');
  static const Position initial = _Position('initial');
  static const Position revert = _Position('revert');
  static const Position revertLayer = _Position('revert-layer');
  static const Position unset = _Position('unset');

  /// The css styles
  Map<String, String> get styles;
}

class _Position implements Position {
  final String value;

  const _Position(this.value);

  @override
  Map<String, String> get styles => {'position': value};
}

class _Positioned extends _Position {
  final Unit? top;
  final Unit? left;
  final Unit? bottom;
  final Unit? right;

  const _Positioned.absolute({this.top, this.left, this.bottom, this.right}) : super('absolute');
  const _Positioned.relative({this.top, this.left, this.bottom, this.right}) : super('relative');
  const _Positioned.fixed({this.top, this.left, this.bottom, this.right}) : super('fixed');
  const _Positioned.sticky({this.top, this.left, this.bottom, this.right}) : super('sticky');

  @override
  Map<String, String> get styles => {
    ...super.styles,
    'top': ?top?.value,
    'left': ?left?.value,
    'bottom': ?bottom?.value,
    'right': ?right?.value,
  };
}

/// The `z-index` CSS property sets the z-order of a positioned element and its descendants or flex and grid items. Overlapping
/// elements with a larger z-index cover those with a smaller one.
///
/// See also:
///   - [Position] for controlling how an element is positioned in a document.
///
/// Read more: [MDN `z-index`](https://developer.mozilla.org/en-US/docs/Web/CSS/z-index)
class ZIndex {
  /// The box does not establish a new local stacking context. The stack level of the generated box in the current stacking context is 0.
  static const ZIndex auto = ZIndex._('auto');

  /// This [value] is the stack level of the generated box in the current stacking context. The box also establishes a local stacking
  /// context. This means that the z-indexes of descendants are not compared to the z-indexes of elements outside this element.
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
