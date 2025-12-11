import 'color.dart';
import 'unit.dart';

/// The `display` CSS property sets whether an element is treated as a block or
/// inline element and the layout used for its children, such as flow layout,
/// grid or flex.
///
/// Read more: [MDN `display`](https://developer.mozilla.org/en-US/docs/Web/CSS/display)
enum Display {
  /// Turns off the display of an element so that it has no effect on layout
  /// (the document is rendered as though the element did not exist). All
  /// descendant elements also have their display turned off. To have an element
  /// take up the space that it would normally take, but without actually rendering
  /// anything, use the [Visibility] property instead.
  none('none'),

  /// The element generates a block box, generating line breaks both before and after
  /// the element when in the normal flow.
  block('block'),

  /// The element generates one or more inline boxes that do not generate line breaks
  /// before or after themselves. In normal flow, the next element will be on the same
  /// line if there is space.
  inline('inline'),

  /// The element generates a block box that will be flowed with surrounding content as
  /// if it were a single inline box (behaving much like a replaced element would).
  inlineBlock('inline-block'),

  /// The element behaves like a block-level element and lays out its content according
  /// to the flexbox model.
  flex('flex'),

  /// The element behaves like an inline-level element and lays out its content according
  /// to the flexbox model.
  inlineFlex('inline-flex'),

  /// The element behaves like a block-level element and lays out its content according
  /// to the grid model.
  grid('grid'),

  /// The element behaves like an inline-level element and lays out its content according
  /// to the grid model.
  inlineGrid('inline-grid'),

  /// The element generates a block box that establishes a new block formatting context,
  /// defining where the formatting root lies.
  flowRoot('flow-root'),

  /// The element doesn't produce a specific box by itself. It is replaced by their
  /// pseudo-box and its child boxes.
  contents('contents'),

  /// The element generates a block box for the content and a separate list-item inline box.
  listItem('list-item'),

  inherit('inherit'),
  initial('initial'),
  revert('revert'),
  revertLayer('revert-layer'),
  unset('unset');

  /// The css value
  final String value;
  const Display(this.value);
}

/// The `border` CSS property sets an element's border.
///
/// Read more: [MDN `border`](https://developer.mozilla.org/en-US/docs/Web/CSS/border)
abstract class Border {
  @Deprecated('Use Border.all() instead.')
  const factory Border({BorderStyle? style, Color? color, Unit? width}) = __Border;

  /// Create a border for all sides.
  const factory Border.all({BorderStyle? style, Color? color, Unit? width}) = __Border;

  /// Create a border with individual sides.
  const factory Border.only({BorderSide? left, BorderSide? top, BorderSide? right, BorderSide? bottom}) = _OnlyBorder;

  /// Create a border with vertical and horizontal sides.
  const factory Border.symmetric({BorderSide? vertical, BorderSide? horizontal}) = _SymmetricBorder;

  /// Display no border.
  static const Border none = _Border('none');

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

class __Border implements Border {
  final BorderStyle? style;
  final Color? color;
  final Unit? width;

  const __Border({this.style = BorderStyle.solid, this.color, this.width})
    : assert(
        style != null || color != null || width != null,
        'At least one of style, color or width must be not null. For no border, use Border.none',
      );

  @override
  Map<String, String> get styles => <String, String>{
    'border': [
      if (style != null) style!.value,
      if (color != null) color!.value,
      if (width != null) width!.value,
    ].join(' '),
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
    'border-left-style': ?left?.style?.value,
    'border-top-style': ?top?.style?.value,
    'border-right-style': ?right?.style?.value,
    'border-bottom-style': ?bottom?.style?.value,
    'border-left-color': ?left?.color?.value,
    'border-top-color': ?top?.color?.value,
    'border-right-color': ?right?.color?.value,
    'border-bottom-color': ?bottom?.color?.value,
    'border-left-width': ?left?.width?.value,
    'border-top-width': ?top?.width?.value,
    'border-right-width': ?right?.width?.value,
    'border-bottom-width': ?bottom?.width?.value,
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
        'border-top-style': ?vertical?.style?.value,
        'border-bottom-style': ?vertical?.style?.value,
        'border-left-style': ?horizontal?.style?.value,
        'border-right-style': ?horizontal?.style?.value,
      },
      if (vertical?.color != null && horizontal?.color != null)
        'border-color': '${vertical!.color!.value} ${horizontal!.color!.value}'
      else ...{
        'border-top-color': ?vertical?.color?.value,
        'border-bottom-color': ?vertical?.color?.value,
        'border-left-color': ?horizontal?.color?.value,
        'border-right-color': ?horizontal?.color?.value,
      },
      if (vertical?.width != null && horizontal?.width != null)
        'border-width': '${vertical!.width!.value} ${horizontal!.width!.value}'
      else ...{
        'border-top-width': ?vertical?.width?.value,
        'border-bottom-width': ?vertical?.width?.value,
        'border-left-width': ?horizontal?.width?.value,
        'border-right-width': ?horizontal?.width?.value,
      },
    };
  }
}

/// Represents one side of a CSS [Border].
///
/// Use [BorderSide] to specify the `style`, `color`, and `width` of an
/// individual border edge. Combine [BorderSide] instances with [Border.only]
/// or [Border.symmetric] or use the shorthand [Border] factory for all sides.
class BorderSide {
  final BorderStyle? style;
  final Color? color;
  final Unit? width;

  /// Create a border side with the given `style`, `color`, and `width`.
  const BorderSide({this.style = BorderStyle.solid, this.color, this.width});

  /// Display no border on this side.
  const BorderSide.none() : color = null, width = null, style = BorderStyle.none;

  /// Create a [BorderStyle.solid] border side with the given color and width.
  const BorderSide.solid({this.color, this.width}) : style = BorderStyle.solid;

  /// Create a [BorderStyle.dotted] border side with the given color and width.
  const BorderSide.dotted({this.color, this.width}) : style = BorderStyle.dotted;

  /// Create a [BorderStyle.dashed] border side with the given color and width.
  const BorderSide.dashed({this.color, this.width}) : style = BorderStyle.dashed;

  /// Create a [BorderStyle.double] border side with the given color and width.
  const BorderSide.double({this.color, this.width}) : style = BorderStyle.double;

  /// Create a [BorderStyle.groove] border side with the given color and width.
  const BorderSide.groove({this.color, this.width}) : style = BorderStyle.groove;

  /// Create a [BorderStyle.ridge] border side with the given color and width.
  const BorderSide.ridge({this.color, this.width}) : style = BorderStyle.ridge;
}

/// Keywords for the visual style of borders (e.g. `dotted`, `solid`, `double`).
///
/// Read more: [MDN `border-style`](https://developer.mozilla.org/en-US/docs/Web/CSS/border-style)
enum BorderStyle {
  /// Like the [hidden] keyword, displays no border.
  none('none'),

  /// Like the [none] keyword, displays no border.
  hidden('hidden'),

  /// Displays a series of rounded dots. The spacing of the dots is not defined by the specification and is
  /// implementation-specific. The radius of the dots is half the computed value of the same side's border-width.
  dotted('dotted'),

  /// Displays a series of short square-ended dashes or line segments. The exact size and length of the segments are not
  /// defined by the specification and are implementation-specific.
  dashed('dashed'),

  /// Displays a single, straight, solid line.
  solid('solid'),

  /// Displays two straight lines that add up to the pixel size defined by border-width.
  double('double'),

  /// Displays a border with a carved appearance. It is the opposite of [ridge].
  groove('groove'),

  /// Displays a border with an extruded appearance. It is the opposite of [groove].
  ridge('ridge'),

  /// Displays a border that makes the element appear embedded. It is the opposite of [outset].
  inset('inset'),

  /// Displays a border that makes the element appear embossed. It is the opposite of [inset].
  outset('outset');

  /// The css value
  final String value;
  const BorderStyle(this.value);
}

/// Represents the CSS `border-radius` property.
///
/// Rounds the corners of an element's outer border edge.
///
/// Read more: [MDN `border-radius`](https://developer.mozilla.org/en-US/docs/Web/CSS/border-radius)
abstract class BorderRadius {
  /// Create a border radius with the given radius for all corners.
  const factory BorderRadius.all(Radius radius) = _AllBorderRadius;

  /// Create a border radius with a circular radius of the given value for all corners.
  const factory BorderRadius.circular(Unit radius) = _CircularBorderRadius;

  /// Create a border radius with individual corners.
  const factory BorderRadius.only({Radius? topLeft, Radius? topRight, Radius? bottomLeft, Radius? bottomRight}) =
      _OnlyBorderRadius;

  /// Create a border radius with top and bottom corners.
  const factory BorderRadius.vertical({Radius? top, Radius? bottom}) = _OnlyBorderRadius.vertical;

  /// Create a border radius with left and right corners.
  const factory BorderRadius.horizontal({Radius? left, Radius? right}) = _OnlyBorderRadius.horizontal;

  /// The css styles
  Map<String, String> get styles;
}

class _AllBorderRadius implements BorderRadius {
  final Radius radius;

  const _AllBorderRadius(this.radius);

  @override
  Map<String, String> get styles => {'border-radius': radius._values.join(' / ')};
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
      final values = [topLeft!, topRight!, bottomRight!, bottomLeft!].map((r) => r._values).toList();
      if (values.every((v) => v.length == 1)) {
        return {'border-radius': values.map((v) => v.first).join(' ')};
      } else {
        return {'border-radius': '${values.map((v) => v.first).join(' ')} / ${values.map((v) => v.last).join(' ')}'};
      }
    } else {
      return {
        'border-top-left-radius': ?topLeft?._values.join(' '),
        'border-top-right-radius': ?topRight?._values.join(' '),
        'border-bottom-right-radius': ?bottomRight?._values.join(' '),
        'border-bottom-left-radius': ?bottomLeft?._values.join(' '),
      };
    }
  }
}

/// Represents a corner radius used by [BorderRadius].
///
/// Create circular radii with [Radius.circular] or elliptical radii with
/// [Radius.elliptical].
abstract class Radius {
  /// Create a circular radius with the given value.
  const factory Radius.circular(Unit radius) = _CircularRadius;

  /// Create an elliptical radius with the given x and y values.
  const factory Radius.elliptical(Unit x, Unit y) = _EllipticalRadius;

  /// A radius with zero size.
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

/// Represents the CSS `outline` property.
///
/// Outlines are drawn outside the border edge and do not take up space in the layout.
///
/// Read more: [MDN `outline`](https://developer.mozilla.org/en-US/docs/Web/CSS/outline)
abstract class Outline {
  /// Create an outline with the given color, style, width, and offset.
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
    'outline-color': ?color?.value,
    'outline-style': ?style?.value,
    'outline-width': ?width?.value,
    'outline-offset': ?offset?.value,
  };
}

/// The style of an element's outline. An outline is a line that is drawn
/// around an element, outside the border.
///
/// Read more: [MDN `outline-style`](https://developer.mozilla.org/en-US/docs/Web/CSS/outline-style)
enum OutlineStyle {
  /// Permits the user agent to render a custom outline style.
  auto('auto'),

  /// No outline is used. The outline-width is 0.
  none('none'),

  /// The outline is a series of dots.
  dotted('dotted'),

  /// The outline is a series of short line segments.
  dashed('dashed'),

  /// The outline is a single line.
  solid('solid'),

  /// The outline is two single lines. The outline-width is the sum of the
  /// two lines and the space between them.
  double('double'),

  /// The outline looks as though it were carved into the page.
  groove('groove'),

  /// The opposite of [groove]: the outline looks as though it were extruded from the page.
  ridge('ridge'),

  /// The outline makes the box look as though it were embedded in the page.
  inset('inset'),

  /// The opposite of [inset]: the outline makes the box look as though it were coming out of the page.
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

/// The CSS `outline-width` property sets the thickness of an element's outline.
/// An outline is a line that is drawn around an element, outside the border.
///
/// Read more: [MDN `outline-width`](https://developer.mozilla.org/en-US/docs/Web/CSS/outline-width)
abstract class OutlineWidth {
  /// Create an outline width from the given unit.
  const factory OutlineWidth(Unit unit) = _OutlineWidth;

  /// Depends on the user agent. Typically equivalent to 1px in desktop browsers.
  static const OutlineWidth thin = _KeywordOutlineWidth('thin');

  /// Depends on the user agent. Typically equivalent to 3px in desktop browsers.
  static const OutlineWidth medium = _KeywordOutlineWidth('medium');

  /// Depends on the user agent. Typically equivalent to 5px in desktop browsers.
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

/// The `overflow` CSS property sets the desired behavior when content does
/// not fit in the element's padding box (overflows) in the horizontal and/or
/// vertical direction.
///
/// Read more: [MDN `overflow`](https://developer.mozilla.org/en-US/docs/Web/CSS/overflow)
abstract class Overflow {
  /// Overflow content is not clipped and may be visible outside the element's
  /// padding box. The element box is not a scroll container. This is the default
  /// value of the overflow property.
  static const OverflowValue visible = OverflowValue._('visible');

  /// Overflow content is clipped at the element's padding box. There are no scroll
  /// bars, and the clipped content is not visible (i.e., clipped content is hidden),
  /// but the content still exists. User agents do not add scroll bars and also do not
  /// allow users to view the content outside the clipped region by actions such as
  /// dragging on a touch screen or using the scroll wheel on a mouse. The content can
  /// be scrolled programmatically, in which case the element box is a scroll container.
  static const OverflowValue hidden = OverflowValue._('hidden');

  /// Overflow content is clipped at the element's overflow clip edge that is defined
  /// using the `overflow-clip-margin` property. As a result, content overflows the
  /// element's padding box by the `<length>` value of `overflow-clip-margin` or by 0px
  /// if not set. Overflow content outside the clipped region is not visible, user agents
  /// do not add a scroll bar, and programmatic scrolling is also not supported.
  static const OverflowValue clip = OverflowValue._('clip');

  /// Overflow content is clipped at the element's padding box, and overflow content can
  /// be scrolled into view using scroll bars. User agents display scroll bars whether
  /// or not any content is overflowing, so in the horizontal and vertical directions
  /// if the value applies to both directions. The use of this keyword, therefore, can
  /// prevent scroll bars from appearing and disappearing as content changes. Printers
  /// may still print overflow content. The element box is a scroll container.
  static const OverflowValue scroll = OverflowValue._('scroll');

  /// Overflow content is clipped at the element's padding box, and overflow content can
  ///be scrolled into view using scroll bars. Unlike [scroll], user agents display scroll
  ///bars only if the content is overflowing. If content fits inside the element's padding
  ///box, it looks the same as with visible but still establishes a new formatting context.
  ///The element box is a scroll container.
  static const OverflowValue auto = OverflowValue._('auto');

  /// Create an overflow with individual values for horizontal and vertical directions.
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
  Map<String, String> get styles => {'overflow': _value};
}

/// The `overflow` CSS property sets the desired behavior when content does
/// not fit in the element's padding box (overflows) in the horizontal and/or
/// vertical direction.
///
/// See [Overflow] for details.
class OverflowValue extends _Overflow {
  const OverflowValue._(super._value);

  /// Overflow content is not clipped and may be visible outside the element's
  /// padding box. The element box is not a scroll container. This is the default
  /// value of the overflow property.
  static const OverflowValue visible = OverflowValue._('visible');

  /// Overflow content is clipped at the element's padding box. There are no scroll
  /// bars, and the clipped content is not visible (i.e., clipped content is hidden),
  /// but the content still exists. User agents do not add scroll bars and also do not
  /// allow users to view the content outside the clipped region by actions such as
  /// dragging on a touch screen or using the scroll wheel on a mouse. The content can
  /// be scrolled programmatically, in which case the element box is a scroll container.
  static const OverflowValue hidden = OverflowValue._('hidden');

  /// Overflow content is clipped at the element's overflow clip edge that is defined
  /// using the `overflow-clip-margin` property. As a result, content overflows the
  /// element's padding box by the `<length>` value of `overflow-clip-margin` or by 0px
  /// if not set. Overflow content outside the clipped region is not visible, user agents
  /// do not add a scroll bar, and programmatic scrolling is also not supported.
  static const OverflowValue clip = OverflowValue._('clip');

  /// Overflow content is clipped at the element's padding box, and overflow content can
  /// be scrolled into view using scroll bars. User agents display scroll bars whether
  /// or not any content is overflowing, so in the horizontal and vertical directions
  /// if the value applies to both directions. The use of this keyword, therefore, can
  /// prevent scroll bars from appearing and disappearing as content changes. Printers
  /// may still print overflow content. The element box is a scroll container.
  static const OverflowValue scroll = OverflowValue._('scroll');

  /// Overflow content is clipped at the element's padding box, and overflow content can
  ///be scrolled into view using scroll bars. Unlike [scroll], user agents display scroll
  ///bars only if the content is overflowing. If content fits inside the element's padding
  ///box, it looks the same as with visible but still establishes a new formatting context.
  ///The element box is a scroll container.
  static const OverflowValue auto = OverflowValue._('auto');

  static const OverflowValue inherit = OverflowValue._('inherit');
  static const OverflowValue initial = OverflowValue._('initial');
  static const OverflowValue revert = OverflowValue._('revert');
  static const OverflowValue revertLayer = OverflowValue._('revert-layer');
  static const OverflowValue unset = OverflowValue._('unset');
}

class _OnlyOverflow implements Overflow {
  final OverflowValue? x;
  final OverflowValue? y;

  const _OnlyOverflow({this.x, this.y});

  @override
  Map<String, String> get styles => {
    if (x != null && y != null)
      'overflow': '${x!._value} ${y!._value}'
    else ...{
      'overflow-x': ?x?._value,
      'overflow-y': ?y?._value,
    },
  };
}

/// The `visibility` CSS property shows or hides an element without changing the
/// layout of a document. The property can also hide rows or columns in a `<table>`.
///
/// Read more: [MDN `visibility`](https://developer.mozilla.org/en-US/docs/Web/CSS/visibility)
enum Visibility {
  /// The element box is visible.
  visible('visible'),

  /// The element box is invisible (not drawn), but still affects layout as normal.
  /// Descendants of the element will be visible if they have visibility set to visible.
  /// The element cannot receive focus.
  hidden('hidden'),

  /// The collapse keyword has different effects for different elements:
  ///
  /// - For `<table>` rows, columns, column groups, and row groups, the row(s) or column(s)
  ///   are hidden and the space they would have occupied is removed. However, the size of
  ///   other rows and columns is still calculated as though the cells in the collapsed
  ///   row(s) or column(s) are present.
  /// - Collapsed flex items and ruby annotations are hidden, and the space they would have
  ///   occupied is removed.
  /// - For other elements, collapse is treated the same as hidden.
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

/// The `box-sizing` CSS property sets how the total width and height of an element is calculated.
///
/// Read more: [MDN `box-sizing`](https://developer.mozilla.org/en-US/docs/Web/CSS/box-sizing)
enum BoxSizing {
  /// This is the initial and default value as specified by the CSS standard. The width and height
  /// properties include the content, but does not include the padding, border, or margin.
  borderBox('border-box'),

  /// The width and height properties include the content, padding, and border, but do not include
  /// the margin. Note that padding and border will be inside of the box.
  contentBox('content-box'),

  inherit('inherit'),
  initial('initial'),
  revert('revert'),
  revertLayer('revert-layer'),
  unset('unset');

  /// The css value
  final String value;
  const BoxSizing(this.value);
}

/// The box-shadow CSS property adds shadow effects around an element's frame. A box shadow is
/// described by X and Y offsets relative to the element, blur and spread radius, and color.
/// You can set multiple effects using [BoxShadow.combine].
///
/// Read more: [MDN `box-shadow`](https://developer.mozilla.org/en-US/docs/Web/CSS/box-shadow)
class BoxShadow {
  const BoxShadow._(this.value);

  final String value;

  /// Create a box shadow with the given offsets, blur, spread, and color.
  const factory BoxShadow({required Unit offsetX, required Unit offsetY, Unit? blur, Unit? spread, Color? color}) =
      _BoxShadow;

  /// Create an inset box shadow with the given offsets, blur, spread, and color.
  const factory BoxShadow.inset({
    required Unit offsetX,
    required Unit offsetY,
    Unit? blur,
    Unit? spread,
    Color? color,
  }) = _InsetBoxShadow;

  /// Combine multiple box shadows into one.
  const factory BoxShadow.combine(List<BoxShadow> shadows) = _CombineBoxShadow;

  // Keyword and global values
  static const BoxShadow none = BoxShadow._('none');
  static const BoxShadow initial = BoxShadow._('initial');
  static const BoxShadow inherit = BoxShadow._('inherit');
  static const BoxShadow revert = BoxShadow._('revert');
  static const BoxShadow revertLayer = BoxShadow._('revert-layer');
  static const BoxShadow unset = BoxShadow._('unset');
}

abstract class _ListableBoxShadow implements BoxShadow {}

class _BoxShadow implements _ListableBoxShadow {
  const _BoxShadow({
    required this.offsetX,
    required this.offsetY,
    this.blur,
    this.spread,
    this.color,
    this.inset = false,
  });

  final Unit offsetX;
  final Unit offsetY;
  final Unit? blur;
  final Unit? spread;
  final Color? color;
  final bool inset;

  @override
  String get value => [
    if (inset) 'inset',
    offsetX.value,
    offsetY.value,
    if (blur != null || spread != null) blur?.value ?? '0',
    if (spread != null) spread!.value,
    if (color != null) color!.value,
  ].join(' ');
}

class _InsetBoxShadow extends _BoxShadow {
  const _InsetBoxShadow({required super.offsetX, required super.offsetY, super.blur, super.spread, super.color})
    : super(inset: true);
}

class _CombineBoxShadow implements _ListableBoxShadow {
  const _CombineBoxShadow(this.shadows);

  final List<BoxShadow> shadows;

  bool _shadowsListable() {
    if (shadows.isEmpty) {
      throw '[BoxShadow.combine] cannot be empty.';
    }

    for (final shadow in shadows) {
      if (shadow is! _ListableBoxShadow) {
        throw 'Cannot use ${shadow.value} as a list item, only standalone use supported.';
      }
    }

    return true;
  }

  @override
  String get value {
    assert(_shadowsListable());
    return shadows.map((s) => s.value).join(', ');
  }
}

/// The `cursor` CSS property sets the mouse cursor, if any, to show when the mouse pointer
/// is over an element.
///
/// Read more: [MDN `cursor`](https://developer.mozilla.org/en-US/docs/Web/CSS/cursor)
class Cursor {
  const Cursor._(this.value);

  /// The css value
  final String value;

  /// The user agent will determine the cursor to display based on the current context.
  static const Cursor auto = Cursor._('auto');

  /// The platform-dependent default cursor. Typically an arrow.
  ///
  /// ![default](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/cursor/default.gif)
  static const Cursor defaultCursor = Cursor._('default');

  /// No cursor is rendered.
  static const Cursor none = Cursor._('none');

  /// A context menu is available.
  ///
  /// ![context-menu](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/cursor/context-menu.png)
  static const Cursor contextMenu = Cursor._('context-menu');

  /// Help information is available.
  ///
  /// ![help](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/cursor/help.gif)
  static const Cursor help = Cursor._('help');

  /// The cursor is a pointer that indicates a link. Typically an image of a pointing hand.
  ///
  /// ![pointer](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/cursor/pointer.gif)
  static const Cursor pointer = Cursor._('pointer');

  /// The program is busy in the background, but the user can still interact with the interface
  /// (in contrast to [wait]).
  ///
  /// ![progress](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/cursor/progress.gif)
  static const Cursor progress = Cursor._('progress');

  /// The program is busy, and the user can't interact with the interface (in contrast to [progress]).
  /// Sometimes an image of an hourglass or a watch.
  ///
  /// ![wait](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/cursor/wait.gif)
  static const Cursor wait = Cursor._('wait');

  /// The table cell or set of cells can be selected.
  ///
  /// ![cell](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/cursor/cell.gif)
  static const Cursor cell = Cursor._('cell');

  /// Cross cursor, often used to indicate selection in a bitmap.
  ///
  /// ![crosshair](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/cursor/crosshair.gif)
  static const Cursor crosshair = Cursor._('crosshair');

  /// The text can be selected. Typically the shape of an I-beam.
  ///
  /// ![text](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/cursor/text.gif)
  static const Cursor text = Cursor._('text');

  /// The vertical text can be selected. Typically the shape of a sideways I-beam.
  ///
  /// ![vertical-text](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/cursor/vertical-text.gif)
  static const Cursor verticalText = Cursor._('vertical-text');

  /// An alias or shortcut is to be created.
  ///
  /// ![alias](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/cursor/alias.gif)
  static const Cursor alias = Cursor._('alias');

  /// Something is to be copied.
  ///
  /// ![copy](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/cursor/copy.gif)
  static const Cursor copy = Cursor._('copy');

  /// Something is to be moved.
  ///
  /// ![move](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/cursor/move.gif)
  static const Cursor move = Cursor._('move');

  /// An item may not be dropped at the current location.
  ///
  /// ![no-drop](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/cursor/no-drop.gif)
  static const Cursor noDrop = Cursor._('no-drop');

  /// The requested action will not be carried out.
  ///
  /// ![not-allowed](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/cursor/not-allowed.gif)
  static const Cursor notAllowed = Cursor._('not-allowed');

  /// Something can be grabbed (dragged to be moved).
  ///
  /// ![grab](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/cursor/grab.gif)
  static const Cursor grab = Cursor._('grab');

  /// Something is being grabbed (dragged to be moved).
  ///
  /// ![grabbing](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/cursor/grabbing.gif)
  static const Cursor grabbing = Cursor._('grabbing');

  /// Something can be scrolled in any direction (panned).
  ///
  /// ![all-scroll](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/cursor/all-scroll.gif)
  static const Cursor allScroll = Cursor._('all-scroll');

  /// The item/column can be resized horizontally. Often rendered as arrows pointing left
  /// and right with a vertical bar separating them.
  ///
  /// ![col-resize](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/cursor/col-resize.gif)
  static const Cursor colResize = Cursor._('col-resize');

  /// The item/row can be resized vertically. Often rendered as arrows pointing up and down
  /// with a horizontal bar separating them.
  ///
  /// ![row-resize](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/cursor/row-resize.gif)
  static const Cursor rowResize = Cursor._('row-resize');

  /// The edge of the item can be moved up.
  ///
  /// ![n-resize](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/cursor/n-resize.gif)
  static const Cursor nResize = Cursor._('n-resize');

  /// The edge of the item can be moved right.
  ///
  /// ![e-resize](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/cursor/e-resize.gif)
  static const Cursor eResize = Cursor._('e-resize');

  /// The edge of the item can be moved down.
  ///
  /// ![s-resize](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/cursor/s-resize.gif)
  static const Cursor sResize = Cursor._('s-resize');

  /// The edge of the item can be moved left.
  ///
  /// ![w-resize](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/cursor/w-resize.gif)
  static const Cursor wResize = Cursor._('w-resize');

  /// The edge of the item can be moved diagonally (north-east).
  ///
  /// ![ne-resize](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/cursor/ne-resize.gif)
  static const Cursor neResize = Cursor._('ne-resize');

  /// The edge of the item can be moved diagonally (north-west).
  ///
  /// ![nw-resize](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/cursor/nw-resize.gif)
  static const Cursor nwResize = Cursor._('nw-resize');

  /// The edge of the item can be moved diagonally (south-east).
  ///
  /// ![se-resize](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/cursor/se-resize.gif)
  static const Cursor seResize = Cursor._('se-resize');

  /// The edge of the item can be moved diagonally (south-west).
  ///
  /// ![sw-resize](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/cursor/sw-resize.gif)
  static const Cursor swResize = Cursor._('sw-resize');

  /// The edge of the item can be moved horizontally (east-west).
  ///
  /// ![ew-resize](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/cursor/3-resize.gif)
  static const Cursor ewResize = Cursor._('ew-resize');

  /// The edge of the item can be moved vertically (north-south).
  ///
  /// ![ns-resize](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/cursor/6-resize.gif)
  static const Cursor nsResize = Cursor._('ns-resize');

  /// The edge of the item can be moved diagonally (north-east south-west).
  ///
  /// ![nesw-resize](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/cursor/1-resize.gif)
  static const Cursor neswResize = Cursor._('nesw-resize');

  /// The edge of the item can be moved diagonally (north-west south-east).
  ///
  /// ![nwse-resize](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/cursor/4-resize.gif)
  static const Cursor nwseResize = Cursor._('nwse-resize');

  /// Something can be zoomed in.
  ///
  /// ![zoom-in](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/cursor/zoom-in.gif)
  static const Cursor zoomIn = Cursor._('zoom-in');

  /// Something can be zoomed out.
  ///
  /// ![zoom-out](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/cursor/zoom-out.gif)
  static const Cursor zoomOut = Cursor._('zoom-out');

  /// Create a custom cursor from a URL, with optional hotspot coordinates and a fallback cursor.
  const factory Cursor.url(String url, {double? x, double? y, required Cursor fallback}) = _UrlCursor;
}

class _UrlCursor implements Cursor {
  const _UrlCursor(this.url, {this.x, this.y, required this.fallback});

  final String url;
  final double? x;
  final double? y;
  final Cursor fallback;

  @override
  String get value => 'url($url)${x != null || y != null ? ' ${x ?? 0} ${y ?? 0}' : ''}, ${fallback.value}';
}

/// The `all` CSS property resets all of an element's properties. It can set properties to their
/// initial or inherited values, or to the values specified in another cascade layer or stylesheet origin.
///
/// Read more: [MDN `all`](https://developer.mozilla.org/en-US/docs/Web/CSS/all)
enum All {
  initial('initial'),
  inherit('inherit'),
  unset('unset'),
  revert('revert'),
  revertLayer('revert-layer');

  /// The css value
  final String value;
  const All(this.value);
}

/// The `appearance` CSS property specifies the rendered appearance of replaced UI widget elements
/// such as form controls. Most commonly, such elements are given native, platform-specific styling
/// based on the operating system's theme, or a primitive appearance with styles that can be overridden
/// using CSS.
///
/// Read more: [MDN `appearance`](https://developer.mozilla.org/en-US/docs/Web/CSS/appearance)
enum Appearance {
  /// Gives the widget a primitive appearance, making it stylable via CSS, while maintaining the widget's
  /// native functionality. This value does not affect non-widgets.
  none('none'),

  /// Sets interactive widgets to render with their OS-native appearance. Behaves as none on elements with
  /// no OS-native styling.
  auto('auto'),
  base('base'),

  /// Only relevant to the `<select>` element and `::picker(select)` pseudo-element, allowing them to be styled.
  baseSelect('base-select'),
  searchfield('searchfield'),
  textArea('textarea'),
  checkbox('checkbox'),
  radio('radio'),
  menulist('menulist'),
  listbox('listbox'),
  meter('meter'),
  progressBar('progress-bar'),
  button('button'),
  textfield('textfield'),
  menulistButton('menulist-button'),

  initial('initial'),
  inherit('inherit'),
  unset('unset'),
  revert('revert'),
  revertLayer('revert-layer');

  /// The css value
  final String value;
  const Appearance(this.value);
}

/// The `aspect-ratio` CSS property allows you to define the desired width-to-height ratio of an element's
/// box. This means that even if the parent container or viewport size changes, the browser will adjust the
/// element's dimensions to maintain the specified width-to-height ratio.
///
/// Read more: [MDN `aspect-ratio`](https://developer.mozilla.org/en-US/docs/Web/CSS/aspect-ratio)
class AspectRatio {
  const AspectRatio._(this.value);

  /// The css value
  final String value;

  // Global values
  static const initial = AspectRatio._('initial');
  static const inherit = AspectRatio._('inherit');
  static const unset = AspectRatio._('unset');
  static const revert = AspectRatio._('revert');
  static const revertLayer = AspectRatio._('revert-layer');

  /// Replaced elements with an intrinsic aspect ratio use that aspect ratio, otherwise the box has no
  /// preferred aspect ratio. Size calculations involving intrinsic aspect ratio always work with the
  /// content box dimensions.
  static const auto = AspectRatio._('auto');

  /// Create an aspect ratio from the given numerator and optional denominator. The property is defined
  /// as `num / denom`. If `denom` is omitted, it is assumed to be 1.
  const factory AspectRatio(int num, [int? denom]) = _AspectRatio;

  /// Create an aspect ratio where `auto` auto is used if the element is a replaced element with a natural
  /// aspect ratio, like an <img> element. Otherwise, the specified ratio of num / denom is used as the
  /// preferred aspect ratio.
  const factory AspectRatio.autoOrRatio(int num, [int? denom]) = _AspectAutoOrRatio;
}

class _AspectRatio implements AspectRatio {
  const _AspectRatio(this.num, [this.denom]);

  final int num;
  final int? denom;

  /// The css value
  @override
  String get value => "$num${denom != null ? '/$denom' : ''}";
}

class _AspectAutoOrRatio implements AspectRatio {
  const _AspectAutoOrRatio(this.num, [this.denom]);

  final int num;
  final int? denom;

  /// The css value
  @override
  String get value => "auto $num${denom != null ? '/$denom' : ''}";
}
