library style;

import 'properties/color.dart';
import 'properties/text.dart';
import 'properties/unit.dart';

part 'text.dart';

/// Represents a set of css styles by pairs of property and value
abstract class Style {
  /// Constructs a [Style] instance from a [Map] of raw css style properties and values
  const factory Style.raw(Map<String, String> styles) = _RawStyle;

  /// Constructs a [Style] instance by combining multiple other [Style] instances
  const factory Style.combine(List<Style> styles) = _CombinedStyle;

  /// Constructs a [Style] instance for common text-related style properties
  const factory Style.text({
    Color? color,
    TextAlign? align,
    FontFamily? fontFamily,
    FontStyle? fontStyle,
    Unit? fontSize,
    FontWeight? fontWeight,
    TextDecoration? decoration,
    TextTransform? transform,
    Unit? indent,
    Unit? letterSpacing,
    Unit? wordSpacing,
    Unit? lineHeight,
  }) = _TextStyle;

  Map<String, String> get styles;
}

class _RawStyle implements Style {
  @override
  final Map<String, String> styles;

  const _RawStyle(this.styles);
}

class _CombinedStyle implements Style {
  final List<Style> _styles;

  const _CombinedStyle(this._styles);

  @override
  Map<String, String> get styles => _styles.fold({}, (v, s) => v..addAll(s.styles));
}
