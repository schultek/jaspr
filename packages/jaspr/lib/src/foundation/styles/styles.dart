library style;

import 'properties/all.dart';

export 'properties/all.dart' hide NumberString;

part 'groups/background.dart';
part 'groups/box.dart';
part 'groups/flexbox.dart';
part 'groups/flexitem.dart';
part 'groups/general.dart';
part 'groups/grid.dart';
part 'groups/grid_item.dart';
part 'groups/list.dart';
part 'groups/text.dart';

/// Represents a set of css styles by pairs of property and value.
abstract class Styles with StylesMixin<Styles> {
  const Styles._();

  Map<String, String> get properties;

  /// Constructs an empty [Styles] instance.
  const factory Styles({
    // Box Styles
    Padding? padding,
    Margin? margin,
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
    ZIndex? zIndex,
    double? opacity,
    Transform? transform,
    BoxShadow? shadow,
    Cursor? cursor,
    Transition? transition,
    UserSelect? userSelect,
    PointerEvents? pointerEvents,
    // Text Styles
    Color? color,
    TextAlign? textAlign,
    FontFamily? fontFamily,
    FontStyle? fontStyle,
    Unit? fontSize,
    FontWeight? fontWeight,
    TextDecoration? textDecoration,
    TextTransform? textTransform,
    Unit? textIndent,
    Unit? letterSpacing,
    Unit? wordSpacing,
    Unit? lineHeight,
    TextShadow? textShadow,
    TextOverflow? textOverflow,
    WhiteSpace? whiteSpace,
    // Background Styles
    Color? backgroundColor,
    BackgroundAttachment? backgroundAttachment,
    BackgroundClip? backgroundClip,
    ImageStyle? backgroundImage,
    BackgroundOrigin? backgroundOrigin,
    BackgroundPosition? backgroundPosition,
    BackgroundRepeat? backgroundRepeat,
    BackgroundSize? backgroundSize,
    // Flexbox Styles
    FlexDirection? flexDirection,
    FlexWrap? flexWrap,
    JustifyContent? justifyContent,
    AlignItems? alignItems,
    Gap? gap,
    Flex? flex,
    int? order,
    AlignSelf? alignSelf,
    // Grid Styles
    GridTemplate? gridTemplate,
    List<TrackSize>? autoRows,
    List<TrackSize>? autoColumns,
    GridPlacement? gridPlacement,
    // List Styles
    ListStyle? listStyle,
    ImageStyle? listImage,
    ListStylePosition? listPosition,
    // Other Styles
    String? content,
    // Raw Styles
    Map<String, String>? raw,
  }) = _Styles;

  /// Constructs a [Styles] instance from a [Map] of raw css style properties and values.
  @Deprecated('Will be removed in 0.20.0. Use Styles() instead.')
  const factory Styles.raw(Map<String, String> styles) = _RawStyles;

  /// Constructs a [Styles] instance by combining multiple other [Styles] instances.
  const factory Styles.combine(List<Styles> styles) = _CombinedStyles;

  @override
  Styles combine(Styles styles) => Styles.combine([this, styles]);

  /// Constructs a [Styles] instance for common text-related style properties.
  @Deprecated('Will be removed in 0.20.0. Use Styles() instead.')
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
  @Deprecated('Will be removed in 0.20.0. Use Styles() instead.')
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
  @Deprecated('Will be removed in 0.20.0. Use Styles() instead.')
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
    ZIndex? zIndex,
    double? opacity,
    Transform? transform,
    BoxShadow? shadow,
    Cursor? cursor,
    Transition? transition,
  }) = _BoxStyles;

  /// Constructs a [Styles] instance for common flexbox style properties.
  @Deprecated('Will be removed in 0.20.0. Use Styles() instead.')
  const factory Styles.flexbox({
    FlexDirection? direction,
    FlexWrap? wrap,
    JustifyContent? justifyContent,
    AlignItems? alignItems,
    Gap? gap,
  }) = _FlexBoxStyles;

  /// Constructs a [Styles] instance for children of a flex-box parent.
  @Deprecated('Will be removed in 0.20.0. Use Styles() instead.')
  const factory Styles.flexItem({
    Flex? flex,
    int? order,
    AlignSelf? alignSelf,
  }) = _FlexItemStyles;

  /// Constructs a [Styles] instance for common grid style properties.
  @Deprecated('Will be removed in 0.20.0. Use Styles() instead.')
  const factory Styles.grid({
    GridTemplate? template,
    Gap? gap,
    List<TrackSize>? autoRows,
    List<TrackSize>? autoColumns,
  }) = _GridStyles;

  /// Constructs a [Styles] instance for children of a grid parent.
  @Deprecated('Will be removed in 0.20.0. Use Styles() instead.')
  const factory Styles.gridItem({
    GridPlacement? placement,
  }) = _GridItemStyles;

  /// Constructs a [Styles] instance for a list.
  @Deprecated('Will be removed in 0.20.0. Use Styles() instead.')
  const factory Styles.list({
    ListStyle? style,
    ImageStyle? image,
    ListStylePosition? position,
  }) = _ListStyles;
}

abstract mixin class StylesMixin<T> {
  T styles({
    // Box Styles
    String? content,
    Display? display,
    Position? position,
    ZIndex? zIndex,
    Unit? width,
    Unit? height,
    Unit? minWidth,
    Unit? minHeight,
    Unit? maxWidth,
    Unit? maxHeight,
    Padding? padding,
    Margin? margin,
    BoxSizing? boxSizing,
    Border? border,
    BorderRadius? radius,
    Outline? outline,
    double? opacity,
    Visibility? visibility,
    Overflow? overflow,
    BoxShadow? shadow,
    Cursor? cursor,
    UserSelect? userSelect,
    PointerEvents? pointerEvents,
    Transition? transition,
    Transform? transform,
    // Flexbox Styles
    FlexDirection? flexDirection,
    FlexWrap? flexWrap,
    JustifyContent? justifyContent,
    AlignItems? alignItems,
    // Grid Styles
    GridTemplate? gridTemplate,
    List<TrackSize>? autoRows,
    List<TrackSize>? autoColumns,
    Gap? gap,
    // Item Styles
    Flex? flex,
    int? order,
    AlignSelf? alignSelf,
    GridPlacement? gridPlacement,
    // List Styles
    ListStyle? listStyle,
    ImageStyle? listImage,
    ListStylePosition? listPosition,
    // Text Styles
    Color? color,
    TextAlign? textAlign,
    FontFamily? fontFamily,
    Unit? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    TextDecoration? textDecoration,
    TextTransform? textTransform,
    Unit? textIndent,
    Unit? letterSpacing,
    Unit? wordSpacing,
    Unit? lineHeight,
    TextShadow? textShadow,
    TextOverflow? textOverflow,
    WhiteSpace? whiteSpace,
    // Background Styles
    Color? backgroundColor,
    ImageStyle? backgroundImage,
    BackgroundOrigin? backgroundOrigin,
    BackgroundPosition? backgroundPosition,
    BackgroundAttachment? backgroundAttachment,
    BackgroundRepeat? backgroundRepeat,
    BackgroundSize? backgroundSize,
    BackgroundClip? backgroundClip,
    // Raw Styles
    Map<String, String>? raw,
  }) =>
      combine(Styles(
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
        zIndex: zIndex,
        opacity: opacity,
        transform: transform,
        shadow: shadow,
        cursor: cursor,
        transition: transition,
        userSelect: userSelect,
        pointerEvents: pointerEvents,
        color: color,
        textAlign: textAlign,
        fontFamily: fontFamily,
        fontStyle: fontStyle,
        fontSize: fontSize,
        fontWeight: fontWeight,
        textDecoration: textDecoration,
        textTransform: textTransform,
        textIndent: textIndent,
        letterSpacing: letterSpacing,
        wordSpacing: wordSpacing,
        lineHeight: lineHeight,
        textShadow: textShadow,
        textOverflow: textOverflow,
        whiteSpace: whiteSpace,
        backgroundColor: backgroundColor,
        backgroundAttachment: backgroundAttachment,
        backgroundClip: backgroundClip,
        backgroundImage: backgroundImage,
        backgroundOrigin: backgroundOrigin,
        backgroundPosition: backgroundPosition,
        backgroundRepeat: backgroundRepeat,
        backgroundSize: backgroundSize,
        flexDirection: flexDirection,
        flexWrap: flexWrap,
        justifyContent: justifyContent,
        alignItems: alignItems,
        gap: gap,
        flex: flex,
        order: order,
        alignSelf: alignSelf,
        gridTemplate: gridTemplate,
        autoRows: autoRows,
        autoColumns: autoColumns,
        gridPlacement: gridPlacement,
        listStyle: listStyle,
        listImage: listImage,
        listPosition: listPosition,
        content: content,
        raw: raw,
      ));

  /// Combines the current styles with a [Map] of raw css style properties and values.
  @Deprecated('Will be removed in 0.20.0. Use .styles() instead.')
  T raw(Map<String, String> styles) => combine(Styles.raw(styles));

  /// Combines the current styles with another [Styles] instances.
  T combine(Styles styles);

  /// Combines the current styles with common text-related style properties.
  @Deprecated('Will be removed in 0.20.0. Use .styles() instead.')
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
  @Deprecated('Will be removed in 0.20.0. Use .styles() instead.')
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
  @Deprecated('Will be removed in 0.20.0. Use .styles() instead.')
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
  @Deprecated('Will be removed in 0.20.0. Use .styles() instead.')
  T flexbox({
    FlexDirection? direction,
    FlexWrap? wrap,
    JustifyContent? justifyContent,
    AlignItems? alignItems,
    Gap? gap,
  }) =>
      combine(Styles.flexbox(
        direction: direction,
        wrap: wrap,
        justifyContent: justifyContent,
        alignItems: alignItems,
        gap: gap,
      ));

  /// Combines the current styles with common flex child properties.
  @Deprecated('Will be removed in 0.20.0. Use .styles() instead.')
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
  @Deprecated('Will be removed in 0.20.0. Use .styles() instead.')
  T grid({
    GridTemplate? template,
    Gap? gap,
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
  @Deprecated('Will be removed in 0.20.0. Use .styles() instead.')
  T gridItem({
    GridPlacement? placement,
  }) =>
      combine(Styles.gridItem(
        placement: placement,
      ));

  /// Combines the current styles with common list style properties.
  @Deprecated('Will be removed in 0.20.0. Use .styles() instead.')
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
  @override
  final Map<String, String> properties;

  const _RawStyles(this.properties) : super._();

  @override
  Styles raw(Map<String, String> styles) {
    return Styles(raw: {...properties, ...styles});
  }
}

class _CombinedStyles extends Styles {
  final List<Styles> _styles;

  const _CombinedStyles(this._styles) : super._();

  @override
  Map<String, String> get properties => _styles.fold({}, (v, s) => v..addAll(s.properties));

  @override
  Styles combine(Styles styles) {
    return Styles.combine([..._styles, styles]);
  }
}
