import 'angle.dart';
import 'color.dart';
import 'unit.dart';

typedef BackdropFilter = Filter;

class Filter {
  const Filter._(this.value);

  /// The css value
  final String value;

  // Keyword value(s)
  static const Filter none = Filter._('none');

  // Global values
  static const Filter inherit = Filter._('inherit');
  static const Filter initial = Filter._('initial');
  static const Filter revert = Filter._('revert');
  static const Filter revertLayer = Filter._('revert-layer');
  static const Filter unset = Filter._('unset');

  const factory Filter(List<FilterFn> filterValues) = _Filter;
}

class _Filter implements Filter {
  const _Filter(this._filterValues);

  final List<FilterFn> _filterValues;

  /// The css value
  @override
  String get value => _filterValues.map((e) => e.value).join(' ');
}

abstract class FilterFn {
  const factory FilterFn.blur([Unit? length]) = _BlurFilter;
  const factory FilterFn.brightness([double? percentage]) = _BrightnessFilter;
  const factory FilterFn.contrast([double? percentage]) = _ContrastFilter;
  const factory FilterFn.dropShadow({
    required Unit offsetX,
    required Unit offsetY,
    Unit? spread,
    Color? color,
  }) = _DropShadowFilter;
  const factory FilterFn.grayscale([double? percentage]) = _GrayscaleFilter;
  const factory FilterFn.hueRotate([Angle? angle]) = _HueRotateFilter;
  const factory FilterFn.invert([double? percentage]) = _InvertFilter;
  const factory FilterFn.opacity([double? percentage]) = _OpacityFilter;
  const factory FilterFn.sepia([double? percentage]) = _SepiaFilter;
  const factory FilterFn.saturate([double? percentage]) = _SaturateFilter;
  const factory FilterFn.url(String url) = _UrlFilter;
  const factory FilterFn.src(String url) = _SrcFilter;

  /// The css value
  String get value;
}

class _BlurFilter implements FilterFn {
  const _BlurFilter([this._length]);

  final Unit? _length;

  /// The css value
  @override
  String get value => "blur(${_length?.value ?? ''})";
}

class _BrightnessFilter implements FilterFn {
  const _BrightnessFilter([this._percentage]);

  final double? _percentage;

  /// The css value
  @override
  String get value => "brightness(${_percentage?.numstr ?? ''})";
}

class _ContrastFilter implements FilterFn {
  const _ContrastFilter([this._percentage]);

  final double? _percentage;

  @override
  String get value => "contrast(${_percentage?.numstr ?? ''})";
}

class _DropShadowFilter implements FilterFn {
  const _DropShadowFilter({
    required Unit offsetX,
    required Unit offsetY,
    Unit? spread,
    Color? color,
  })  : _offsetX = offsetX,
        _offsetY = offsetX,
        _spread = spread,
        _color = color;

  final Unit _offsetX;
  final Unit _offsetY;
  final Unit? _spread;
  final Color? _color;

  /// The css value
  @override
  String get value =>
      "drop-shadow(${_offsetX.value} ${_offsetY.value} ${_spread?.value ?? ''} ${_color?.value ?? ''})";
}

class _GrayscaleFilter implements FilterFn {
  const _GrayscaleFilter([this._percentage]);

  final double? _percentage;

  /// The css value
  @override
  String get value => "grayscale(${_percentage?.numstr ?? ''})";
}

class _HueRotateFilter implements FilterFn {
  const _HueRotateFilter([this._angle]);

  final Angle? _angle;

  /// The css value
  @override
  String get value => "hue-rotate(${_angle?.value ?? ''})";
}

class _InvertFilter implements FilterFn {
  const _InvertFilter([this._percentage]);

  final double? _percentage;

  /// The css value
  @override
  String get value => "invert(${_percentage?.numstr ?? ''})";
}

class _OpacityFilter implements FilterFn {
  const _OpacityFilter([this._percentage]);

  final double? _percentage;

  /// The css value
  @override
  String get value => "opacity(${_percentage?.numstr ?? ''})";
}

class _SepiaFilter implements FilterFn {
  const _SepiaFilter([this._percentage]);

  final double? _percentage;

  /// The css value
  @override
  String get value => "sepia(${_percentage?.numstr ?? ''})";
}

class _SaturateFilter implements FilterFn {
  const _SaturateFilter([this._percentage]);

  final double? _percentage;

  /// The css value
  @override
  String get value => "saturate(${_percentage?.numstr ?? ''})";
}

class _UrlFilter implements FilterFn {
  const _UrlFilter(this._url);

  final String _url;

  /// The css value
  @override
  String get value => "url($_url)";
}

class _SrcFilter implements FilterFn {
  const _SrcFilter(this._url);

  final String _url;

  /// The css value
  @override
  String get value => "src($_url)";
}
