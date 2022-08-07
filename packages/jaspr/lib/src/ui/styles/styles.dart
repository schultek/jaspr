library style;

import 'properties/background.dart';
import 'properties/box.dart';
import 'properties/color.dart';
import 'properties/edge_insets.dart';
import 'properties/flexbox.dart';
import 'properties/position.dart';
import 'properties/text.dart';
import 'properties/unit.dart';

part 'groups/background.dart';
part 'groups/box.dart';
part 'groups/flexbox.dart';
part 'groups/text.dart';

/// Represents a set of css styles by pairs of property and value
abstract class Styles {
  /// Constructs a [Styles] instance from a [Map] of raw css style properties and values
  const factory Styles.raw(Map<String, String> styles) = _RawStyles;

  /// Constructs a [Styles] instance by combining multiple other [Styles] instances
  const factory Styles.combine(List<Styles> styles) = _CombinedStyles;

  /// Constructs a [Styles] instance for common text-related style properties
  const factory Styles.text({
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
  }) = _TextStyles;

  /// Constructs a [Styles] instance for common background style properties
  const factory Styles.background({
    Color? color,
    BackgroundAttachment attachment,
    BackgroundClip? clip,
    ImageStyle? image,
    BackgroundOrigin? origin,
    BackgroundPosition? position,
    BackgroundRepeat? repeat,
    BackgroundSize? size,
  }) = _BackgroundStyles;

  /// Constructs a [Styles] instance for common box style properties
  const factory Styles.box({
    EdgeInsets? padding,
    EdgeInsets? margin,
    Display? display,
    Unit? width,
    Unit? height,
    Border? border,
    BorderRadius? radius,
    Outline? outline,
    Overflow? overflow,
    Visibility? visibility,
    Position? position,
    double? opacity,
  }) = _BoxStyles;

  /// Constructs a [Styles] instance for common flexbox style properties
  const factory Styles.flexbox({
    FlexDirection? direction,
    FlexWrap? wrap,
    JustifyContent? justifyContent,
    AlignItems? alignItems,
  }) = _FlexBoxStyles;

  Map<String, String> get styles;
}

class _RawStyles implements Styles {
  @override
  final Map<String, String> styles;

  const _RawStyles(this.styles);
}

class _CombinedStyles implements Styles {
  final List<Styles> _styles;

  const _CombinedStyles(this._styles);

  @override
  Map<String, String> get styles => _styles.fold({}, (v, s) => v..addAll(s.styles));
}
