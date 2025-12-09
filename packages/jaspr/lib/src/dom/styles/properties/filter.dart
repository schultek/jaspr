import 'angle.dart';
import 'color.dart';
import 'unit.dart';

/// CSS filter effects let you define a way of processing an element's rendering before the element is displayed in the
/// document. Examples of such effects include blurring and changing the intensity of the color of an element.
///
/// Read more: [MDN CSS Filter Effects](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_filter_effects)
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

  /// Combines multiple filter functions into a single filter value.
  const factory Filter.list(List<Filter> filterValues) = _FilterList;

  /// Creates a blur filter function that applies a Gaussian blur to the input image.
  const factory Filter.blur([Unit length]) = _BlurFilter;

  /// Creates a brightness filter function that applies a linear multiplier value on an element or an input image, making the image appear
  /// brighter or darker.
  const factory Filter.brightness([double percentage]) = _BrightnessFilter;

  /// Creates a contrast filter function that adjusts the contrast of the input image.
  const factory Filter.contrast([double percentage]) = _ContrastFilter;

  /// Creates a drop-shadow filter function that applies a drop shadow effect to the input image.
  const factory Filter.dropShadow({required Unit offsetX, required Unit offsetY, Unit? spread, Color? color}) =
      _DropShadowFilter;

  /// Creates a grayscale filter function that converts the input image to grayscale.
  const factory Filter.grayscale([double percentage]) = _GrayscaleFilter;

  /// Creates a hue-rotate filter function that rotates the hue of an element and its contents.
  const factory Filter.hueRotate([Angle angle]) = _HueRotateFilter;

  /// Creates an invert filter function that inverts the colors of the input image.
  const factory Filter.invert([double percentage]) = _InvertFilter;

  /// Creates an opacity filter function that applies transparency to the samples in the input image
  const factory Filter.opacity([double percentage]) = _OpacityFilter;

  /// Creates a sepia filter function that applies a sepia filter to the input image, giving it a warm, brownish tone.
  const factory Filter.sepia([double percentage]) = _SepiaFilter;

  /// Creates a saturate filter function that super-saturates or desaturates the input image.
  const factory Filter.saturate([double percentage]) = _SaturateFilter;

  /// Creates a url filter function that references an SVG filter element.
  const factory Filter.url(String url) = _UrlFilter;
}

abstract class _ListableFilter implements Filter {}

class _FilterList implements _ListableFilter {
  const _FilterList(this._filterValues);

  final List<Filter> _filterValues;

  bool _filtersListable() {
    if (_filterValues.isEmpty) {
      throw 'Filter.list cannot be empty.';
    }

    for (final filter in _filterValues) {
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
    return _filterValues.map((filter) => filter.value).join(' ');
  }
}

abstract class _FilterWithPercentage implements _ListableFilter {
  const _FilterWithPercentage(this._percentage, this._name);

  final double _percentage;
  final String _name;

  /// The css value
  @override
  String get value => '$_name(${_percentage.numstr})';
}

class _BlurFilter implements _ListableFilter {
  const _BlurFilter([this._length = Unit.zero]);

  final Unit _length;

  /// The css value
  @override
  String get value => 'blur(${_length.value})';
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
  String get value => 'hue-rotate(${_angle.value})';
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
  String get value => 'url($_url)';
}
