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

abstract class Border {
  const factory Border({BorderStyle? style, Color? color, Unit? width}) = __Border;

  const factory Border.only({BorderSide? left, BorderSide? top, BorderSide? right, BorderSide? bottom}) = _OnlyBorder;
  const factory Border.symmetric({BorderSide? vertical, BorderSide? horizontal}) = _SymmetricBorder;

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

class BorderSide {
  final BorderStyle? style;
  final Color? color;
  final Unit? width;

  const BorderSide({this.style = BorderStyle.solid, this.color, this.width});

  const BorderSide.none() : color = null, width = null, style = BorderStyle.none;
  const BorderSide.solid({this.color, this.width}) : style = BorderStyle.solid;
  const BorderSide.dotted({this.color, this.width}) : style = BorderStyle.dotted;
  const BorderSide.dashed({this.color, this.width}) : style = BorderStyle.dashed;
  const BorderSide.double({this.color, this.width}) : style = BorderStyle.double;
  const BorderSide.groove({this.color, this.width}) : style = BorderStyle.groove;
  const BorderSide.ridge({this.color, this.width}) : style = BorderStyle.ridge;
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
      var values = [topLeft!, topRight!, bottomRight!, bottomLeft!].map((r) => r._values).toList();
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
    'outline-color': ?color?.value,
    'outline-style': ?style?.value,
    'outline-width': ?width?.value,
    'outline-offset': ?offset?.value,
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
  Map<String, String> get styles => {'overflow': _value};
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
      'overflow': '${x!._value} ${y!._value}'
    else ...{
      'overflow-x': ?x?._value,
      'overflow-y': ?y?._value,
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

enum BoxSizing {
  borderBox('border-box'),
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

class BoxShadow {
  const BoxShadow._(this.value);

  final String value;

  // Keyword and global values
  static const BoxShadow none = BoxShadow._('none');
  static const BoxShadow initial = BoxShadow._('initial');
  static const BoxShadow inherit = BoxShadow._('inherit');
  static const BoxShadow revert = BoxShadow._('revert');
  static const BoxShadow revertLayer = BoxShadow._('revert-layer');
  static const BoxShadow unset = BoxShadow._('unset');

  const factory BoxShadow({required Unit offsetX, required Unit offsetY, Unit? blur, Unit? spread, Color? color}) =
      _BoxShadow;

  const factory BoxShadow.inset({
    required Unit offsetX,
    required Unit offsetY,
    Unit? blur,
    Unit? spread,
    Color? color,
  }) = _InsetBoxShadow;

  const factory BoxShadow.combine(List<BoxShadow> shadows) = _CombineBoxShadow;
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

class _CombineBoxShadow implements BoxShadow {
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

class Cursor {
  const Cursor._(this.value);

  final String value;

  static const Cursor auto = Cursor._('auto');
  static const Cursor defaultCursor = Cursor._('default');
  static const Cursor none = Cursor._('none');
  static const Cursor contextMenu = Cursor._('context-menu');
  static const Cursor help = Cursor._('help');
  static const Cursor pointer = Cursor._('pointer');
  static const Cursor progress = Cursor._('progress');
  static const Cursor wait = Cursor._('wait');
  static const Cursor cell = Cursor._('cell');
  static const Cursor crosshair = Cursor._('crosshair');
  static const Cursor text = Cursor._('text');
  static const Cursor verticalText = Cursor._('vertical-text');
  static const Cursor alias = Cursor._('alias');
  static const Cursor copy = Cursor._('copy');
  static const Cursor move = Cursor._('move');
  static const Cursor noDrop = Cursor._('no-drop');
  static const Cursor notAllowed = Cursor._('not-allowed');
  static const Cursor grab = Cursor._('grab');
  static const Cursor grabbing = Cursor._('grabbing');
  static const Cursor allScroll = Cursor._('all-scroll');
  static const Cursor colResize = Cursor._('col-resize');
  static const Cursor rowResize = Cursor._('row-resize');
  static const Cursor nResize = Cursor._('n-resize');
  static const Cursor eResize = Cursor._('e-resize');
  static const Cursor sResize = Cursor._('s-resize');
  static const Cursor wResize = Cursor._('w-resize');
  static const Cursor neResize = Cursor._('ne-resize');
  static const Cursor nwResize = Cursor._('nw-resize');
  static const Cursor seResize = Cursor._('se-resize');
  static const Cursor swResize = Cursor._('sw-resize');
  static const Cursor ewResize = Cursor._('ew-resize');
  static const Cursor nsResize = Cursor._('ns-resize');
  static const Cursor neswResize = Cursor._('nesw-resize');
  static const Cursor nwseResize = Cursor._('nwse-resize');
  static const Cursor zoomIn = Cursor._('zoom-in');
  static const Cursor zoomOut = Cursor._('zoom-out');

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

enum Appearance {
  // Global values
  initial('initial'),
  inherit('inherit'),
  unset('unset'),
  revert('revert'),
  revertLayer('revert-layer'),

  // Basic values
  none('none'),
  auto('auto'),
  base('base'),
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
  menulistButton('menulist-button');

  /// The css value
  final String value;
  const Appearance(this.value);
}

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

  // Basic value(s)
  static const auto = AspectRatio._('auto');

  const factory AspectRatio(int num, [int? denom]) = _AspectRatio;
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
