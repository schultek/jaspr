library style;

import 'properties/all.dart';

export 'properties/all.dart' hide NumberString;

part 'groups/background.dart';
part 'groups/box.dart';
part 'groups/flexbox.dart';
part 'groups/flexitem.dart';
part 'groups/grid.dart';
part 'groups/grid_item.dart';
part 'groups/list.dart';
part 'groups/text.dart';

/// Represents a set of css styles by pairs of property and value.
abstract class Styles with StylesMixin<Styles> {
  /// Constructs an empty [Styles] instance.
  const factory Styles() = _EmptyStyles;

  const Styles._();

  /// Constructs a [Styles] instance from a [Map] of raw css style properties and values.
  const factory Styles.raw(Map<String, String> styles) = _RawStyles;

  /// Constructs a [Styles] instance by combining multiple other [Styles] instances.
  const factory Styles.combine(List<Styles> styles) = _CombinedStyles;

  /// Constructs a [Styles] instance for common text-related style properties.
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

  /// Constructs a [Styles] instance for common background style properties.
  const factory Styles.background({
    Color? color,
    BackgroundAttachment? attachment,
    BackgroundClip? clip,
    ImageStyle? image,
    BackgroundOrigin? origin,
    BackgroundPosition? position,
    BackgroundRepeat? repeat,
    BackgroundSize? size,
  }) = _BackgroundStyles;

  /// Constructs a [Styles] instance for common box style properties.
  const factory Styles.box({
    EdgeInsets? padding,
    EdgeInsets? margin,
    Display? display,
    BoxSizing? boxSizing,
    Unit? width,
    Unit? height,
    Unit? minWidth,
    Unit? maxWidth,
    Unit? minHeight,
    Unit? maxHeight,
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

  /// Constructs a [Styles] instance for common flexbox style properties.
  const factory Styles.flexbox({
    FlexDirection? direction,
    FlexWrap? wrap,
    JustifyContent? justifyContent,
    AlignItems? alignItems,
  }) = _FlexBoxStyles;

  /// Constructs a [Styles] instance for children of a flex-box parent.
  const factory Styles.flexItem({
    Flex? flex,
    int? order,
    AlignSelf? alignSelf,
  }) = _FlexItemStyles;

  /// Constructs a [Styles] instance for common grid style properties.
  const factory Styles.grid({
    GridTemplate? template,
    GridGap? gap,
    List<TrackSize>? autoRows,
    List<TrackSize>? autoColumns,
  }) = _GridStyles;

  /// Constructs a [Styles] instance for children of a grid parent.
  const factory Styles.gridItem({
    GridPlacement? placement,
  }) = _GridItemStyles;

  /// Constructs a [Styles] instance for a list.
  const factory Styles.list({
    ListStyle? style,
    ImageStyle? image,
    ListStylePosition? position,
  }) = _ListStyles;

  Map<String, String> get styles;

  @override
  Styles combine(Styles styles) => Styles.combine([this, styles]);
}

class _EmptyStyles extends Styles {
  const _EmptyStyles() : super._();

  @override
  Map<String, String> get styles => {};

  @override
  Styles combine(Styles styles) {
    return styles;
  }
}

abstract mixin class StylesMixin<T> {
  /// Combines the current styles with a [Map] of raw css style properties and values.
  T raw(Map<String, String> styles) => combine(Styles.raw(styles));

  /// Combines the current styles with another [Styles] instances.
  T combine(Styles styles);

  /// Combines the current styles with common text-related style properties.
  T text({
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
  }) =>
      combine(Styles.text(
        color: color,
        align: align,
        fontFamily: fontFamily,
        fontStyle: fontStyle,
        fontSize: fontSize,
        fontWeight: fontWeight,
        decoration: decoration,
        transform: transform,
        indent: indent,
        letterSpacing: letterSpacing,
        wordSpacing: wordSpacing,
        lineHeight: lineHeight,
        shadow: shadow,
        overflow: overflow,
        whiteSpace: whiteSpace,
      ));

  /// Combines the current styles with common background style properties.
  T background({
    Color? color,
    BackgroundAttachment? attachment,
    BackgroundClip? clip,
    ImageStyle? image,
    BackgroundOrigin? origin,
    BackgroundPosition? position,
    BackgroundRepeat? repeat,
    BackgroundSize? size,
  }) =>
      combine(Styles.background(
        color: color,
        attachment: attachment,
        clip: clip,
        image: image,
        origin: origin,
        position: position,
        repeat: repeat,
        size: size,
      ));

  /// Combines the current styles with common box style properties.
  T box({
    EdgeInsets? padding,
    EdgeInsets? margin,
    Display? display,
    BoxSizing? boxSizing,
    Unit? width,
    Unit? height,
    Unit? minWidth,
    Unit? maxWidth,
    Unit? minHeight,
    Unit? maxHeight,
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
  }) =>
      combine(Styles.box(
        padding: padding,
        margin: margin,
        display: display,
        boxSizing: boxSizing,
        width: width,
        height: height,
        minWidth: minWidth,
        maxWidth: maxWidth,
        minHeight: minHeight,
        maxHeight: maxHeight,
        border: border,
        radius: radius,
        outline: outline,
        overflow: overflow,
        visibility: visibility,
        position: position,
        opacity: opacity,
        transform: transform,
        shadow: shadow,
        cursor: cursor,
        transition: transition,
      ));

  /// Combines the current styles with common flexbox style properties.
  T flexbox({
    FlexDirection? direction,
    FlexWrap? wrap,
    JustifyContent? justifyContent,
    AlignItems? alignItems,
  }) =>
      combine(Styles.flexbox(
        direction: direction,
        wrap: wrap,
        justifyContent: justifyContent,
        alignItems: alignItems,
      ));

  /// Combines the current styles with common flex child properties.
  T flexItem({
    Flex? flex,
    int? order,
    AlignSelf? alignSelf,
  }) =>
      combine(Styles.flexItem(
        flex: flex,
        order: order,
        alignSelf: alignSelf,
      ));

  /// Combines the current styles with common grid style properties.
  T grid({
    GridTemplate? template,
    GridGap? gap,
    List<TrackSize>? autoRows,
    List<TrackSize>? autoColumns,
  }) =>
      combine(Styles.grid(
        template: template,
        gap: gap,
        autoRows: autoRows,
        autoColumns: autoColumns,
      ));

  /// Combines the current styles with common grid child properties.
  T gridItem({
    GridPlacement? placement,
  }) =>
      combine(Styles.gridItem(
        placement: placement,
      ));

  /// Combines the current styles with common list style properties.
  T list({
    ListStyle? style,
    ImageStyle? image,
    ListStylePosition? position,
  }) =>
      combine(Styles.list(
        style: style,
        image: image,
        position: position,
      ));
}

class _RawStyles extends Styles {
  const _RawStyles(this.styles) : super._();

  @override
  final Map<String, String> styles;

  @override
  Styles raw(Map<String, String> styles) {
    return Styles.raw({...this.styles, ...styles});
  }
}

class _CombinedStyles extends Styles {
  const _CombinedStyles(this._styles) : super._();

  final List<Styles> _styles;

  @override
  Map<String, String> get styles => _styles.fold({}, (v, s) => v..addAll(s.styles));

  @override
  Styles combine(Styles styles) {
    return Styles.combine([..._styles, styles]);
  }
}
