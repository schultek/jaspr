library style;

import 'properties/all.dart';

export 'properties/all.dart' hide NumberString;

part 'groups/background.dart';
part 'groups/box.dart';
part 'groups/flexbox.dart';
part 'groups/flexitem.dart';
part 'groups/grid.dart';
part 'groups/grid_item.dart';
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
    TextShadow? shadow,
    TextOverflow? overflow,
    WhiteSpace? whiteSpace,
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
    BoxSizing? boxSizing,
    Unit? width,
    Unit? height,
    BoxConstraints? constraints,
    Border? border,
    BorderRadius? radius,
    Outline? outline,
    Overflow? overflow,
    Visibility? visibility,
    Position? position,
    double? opacity,
    Transform? transform,
    BoxShadow? shadow,
    Cursor? cursor,
    Transition? transition,
  }) = _BoxStyles;

  /// Constructs a [Styles] instance for common flexbox style properties
  const factory Styles.flexbox({
    FlexDirection? direction,
    FlexWrap? wrap,
    JustifyContent? justifyContent,
    AlignItems? alignItems,
  }) = _FlexBoxStyles;

  /// Constructs a [Styles] instance for children of a flex-box parent
  const factory Styles.flexItem({
    Flex? flex,
    int? order,
    AlignSelf? alignSelf,
  }) = _FlexItemStyles;

  const factory Styles.grid({
    GridTemplate? template,
    GridGap? gap,
    List<TrackSize>? autoRows,
    List<TrackSize>? autoColumns,
  }) = _GridStyles;

  const factory Styles.gridItem({
    GridPlacement? placement,
  }) = _GridItemStyles;

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
