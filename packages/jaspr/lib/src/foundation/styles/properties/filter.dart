import 'angle.dart';
import 'color.dart';
import 'unit.dart';

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

  const factory Filter.list(List<Filter> filterValues) = _FilterList;
  const factory Filter.blur([Unit length]) = _BlurFilter;
  const factory Filter.brightness([double percentage]) = _BrightnessFilter;
  const factory Filter.contrast([double percentage]) = _ContrastFilter;
  const factory Filter.dropShadow({required Unit offsetX, required Unit offsetY, Unit? spread, Color? color}) =
      _DropShadowFilter;
  const factory Filter.grayscale([double percentage]) = _GrayscaleFilter;
  const factory Filter.hueRotate([Angle angle]) = _HueRotateFilter;
  const factory Filter.invert([double percentage]) = _InvertFilter;
  const factory Filter.opacity([double percentage]) = _OpacityFilter;
  const factory Filter.sepia([double percentage]) = _SepiaFilter;
  const factory Filter.saturate([double percentage]) = _SaturateFilter;
  const factory Filter.url(String url) = _UrlFilter;
}

class _FilterList implements Filter {
  const _FilterList(this._filterValues);

  final List<Filter> _filterValues;

  bool _filtersListable() {
    if (_filterValues.isEmpty) {
      throw 'Filter.list cannot be empty.';
    }

    for (final filter in _filterValues) {
      if (filter is _FilterList) {
        throw 'Cannot nest [Filter.list] inside [Filter.list].';
      }

      if (filter is! _ListableFilter) {
        throw 'Cannot use ${filter.value} as a filter list item, only standalone use supported.';
      }
    }

    return true;
  }

  /// The css value
  @override
  String get value {
    assert(_filtersListable());
    return _filterValues
        .map((filter) {
          return filter.value;
        })
        .join(' ');
  }
}

abstract class _ListableFilter implements Filter {}

abstract class _FilterWithPercentage implements _ListableFilter {
  const _FilterWithPercentage(this._percentage, this._name);

  final double _percentage;
  final String _name;

  /// The css value
  @override
  String get value => "$_name(${_percentage.numstr})";
}

class _BlurFilter implements _ListableFilter {
  const _BlurFilter([this._length = Unit.zero]);

  final Unit _length;

  /// The css value
  @override
  String get value => "blur(${_length.value})";
}

class _BrightnessFilter extends _FilterWithPercentage {
  const _BrightnessFilter([double percentage = 1.0]) : super(percentage, 'brightness');
}

class _ContrastFilter extends _FilterWithPercentage {
  const _ContrastFilter([double percentage = 1.0]) : super(percentage, 'contrast');
}

class _DropShadowFilter implements _ListableFilter {
  const _DropShadowFilter({required Unit offsetX, required Unit offsetY, Unit? spread, Color? color})
    : _offsetX = offsetX,
      _offsetY = offsetX,
      _spread = spread,
      _color = color;

  final Unit _offsetX;
  final Unit _offsetY;
  final Unit? _spread;
  final Color? _color;

  /// The css value
  @override
  String get value {
    String val = '${_offsetX.value} ${_offsetY.value}';
    if (_spread != null) val += ' ${_spread.value}';
    if (_color != null) val += ' ${_color.value}';
    return 'drop-shadow($val)';
  }
}

class _GrayscaleFilter extends _FilterWithPercentage {
  const _GrayscaleFilter([double percentage = 1.0]) : super(percentage, 'grayscale');
}

class _HueRotateFilter implements _ListableFilter {
  const _HueRotateFilter([this._angle = Angle.zero]);

  final Angle _angle;

  /// The css value
  @override
  String get value => "hue-rotate(${_angle.value})";
}

class _InvertFilter extends _FilterWithPercentage {
  const _InvertFilter([double percentage = 1.0]) : super(percentage, 'invert');
}

class _OpacityFilter extends _FilterWithPercentage {
  const _OpacityFilter([double percentage = 1.0]) : super(percentage, 'opacity');
}

class _SepiaFilter extends _FilterWithPercentage {
  const _SepiaFilter([double percentage = 1.0]) : super(percentage, 'sepia');
}

class _SaturateFilter extends _FilterWithPercentage {
  const _SaturateFilter([double percentage = 1.0]) : super(percentage, 'saturate');
}

class _UrlFilter implements _ListableFilter {
  const _UrlFilter(this._url);

  final String _url;

  /// The css value
  @override
  String get value => "url($_url)";
}
