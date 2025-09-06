import 'properties/all.dart';

export 'properties/all.dart' hide NumberString;

/// Represents a set of css styles by pairs of property and value.
abstract class Styles with StylesMixin<Styles> {
  const Styles._();

  Map<String, String> get properties;

  /// Constructs an empty [Styles] instance.
  const factory Styles({
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
    Filter? filter,
    Filter? backdropFilter,
    Cursor? cursor,
    UserSelect? userSelect,
    PointerEvents? pointerEvents,
    Transition? transition,
    Transform? transform,
    All? all,
    Appearance? appearance,
    AspectRatio? aspectRatio,
    // Flexbox Styles
    FlexDirection? flexDirection,
    FlexWrap? flexWrap,
    JustifyContent? justifyContent,
    AlignItems? alignItems,
    AlignContent? alignContent,
    // Grid Styles
    GridTemplate? gridTemplate,
    List<TrackSize>? autoRows,
    List<TrackSize>? autoColumns,
    Gap? gap,
    JustifyItems? justifyItems,
    // Item Styles
    Flex? flex,
    int? order,
    AlignSelf? alignSelf,
    JustifySelf? justifySelf,
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
  }) = _Styles;

  /// Constructs a [Styles] instance by combining multiple other [Styles] instances.
  const factory Styles.combine(List<Styles> styles) = _CombinedStyles;

  @override
  Styles combine(Styles styles) => Styles.combine([this, styles]);
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
    Filter? filter,
    Filter? backdropFilter,
    Cursor? cursor,
    UserSelect? userSelect,
    PointerEvents? pointerEvents,
    Transition? transition,
    Transform? transform,
    All? all,
    Appearance? appearance,
    AspectRatio? aspectRatio,
    // Flexbox Styles
    FlexDirection? flexDirection,
    FlexWrap? flexWrap,
    JustifyContent? justifyContent,
    AlignItems? alignItems,
    AlignContent? alignContent,
    // Grid Styles
    GridTemplate? gridTemplate,
    List<TrackSize>? autoRows,
    List<TrackSize>? autoColumns,
    Gap? gap,
    JustifyItems? justifyItems,
    // Item Styles
    Flex? flex,
    int? order,
    AlignSelf? alignSelf,
    JustifySelf? justifySelf,
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
        all: all,
        appearance: appearance,
        aspectRatio: aspectRatio,
        shadow: shadow,
        filter: filter,
        backdropFilter: backdropFilter,
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
        alignContent: alignContent,
        gap: gap,
        justifyItems: justifyItems,
        flex: flex,
        order: order,
        alignSelf: alignSelf,
        justifySelf: justifySelf,
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

  /// Combines the current styles with another [Styles] instances.
  T combine(Styles styles);
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

class _Styles extends Styles {
  // Box Styles
  final String? content;
  final Display? display;
  final Position? position;
  final ZIndex? zIndex;
  final Unit? width;
  final Unit? height;
  final Unit? minWidth;
  final Unit? minHeight;
  final Unit? maxWidth;
  final Unit? maxHeight;
  final Padding? padding;
  final Margin? margin;
  final BoxSizing? boxSizing;
  final Border? border;
  final BorderRadius? radius;
  final Outline? outline;
  final double? opacity;
  final Visibility? visibility;
  final Overflow? overflow;
  final BoxShadow? shadow;
  final Filter? filter;
  final Filter? backdropFilter;
  final Cursor? cursor;
  final UserSelect? userSelect;
  final PointerEvents? pointerEvents;
  final Transition? transition;
  final Transform? transform;
  final All? all;
  final Appearance? appearance;
  final AspectRatio? aspectRatio;
  // Flexbox Style
  final FlexDirection? flexDirection;
  final FlexWrap? flexWrap;
  final JustifyContent? justifyContent;
  final AlignItems? alignItems;
  final AlignContent? alignContent;
  // Grid Style
  final GridTemplate? gridTemplate;
  final List<TrackSize>? autoRows;
  final List<TrackSize>? autoColumns;
  final Gap? gap;
  final JustifyItems? justifyItems;
  // Item Style
  final Flex? flex;
  final int? order;
  final AlignSelf? alignSelf;
  final JustifySelf? justifySelf;
  final GridPlacement? gridPlacement;
  // List Style
  final ListStyle? listStyle;
  final ImageStyle? listImage;
  final ListStylePosition? listPosition;
  // Text Style
  final Color? color;
  final TextAlign? textAlign;
  final FontFamily? fontFamily;
  final Unit? fontSize;
  final FontWeight? fontWeight;
  final FontStyle? fontStyle;
  final TextDecoration? textDecoration;
  final TextTransform? textTransform;
  final Unit? textIndent;
  final Unit? letterSpacing;
  final Unit? wordSpacing;
  final Unit? lineHeight;
  final TextShadow? textShadow;
  final TextOverflow? textOverflow;
  final WhiteSpace? whiteSpace;
  // Background Style
  final Color? backgroundColor;
  final ImageStyle? backgroundImage;
  final BackgroundOrigin? backgroundOrigin;
  final BackgroundPosition? backgroundPosition;
  final BackgroundAttachment? backgroundAttachment;
  final BackgroundRepeat? backgroundRepeat;
  final BackgroundSize? backgroundSize;
  final BackgroundClip? backgroundClip;
  // Raw Styles
  final Map<String, String>? _raw;

  const _Styles({
    // Box Styles
    this.content,
    this.display,
    this.position,
    this.zIndex,
    this.width,
    this.height,
    this.minWidth,
    this.minHeight,
    this.maxWidth,
    this.maxHeight,
    this.padding,
    this.margin,
    this.boxSizing,
    this.border,
    this.radius,
    this.outline,
    this.opacity,
    this.visibility,
    this.overflow,
    this.shadow,
    this.filter,
    this.backdropFilter,
    this.cursor,
    this.userSelect,
    this.pointerEvents,
    this.transition,
    this.transform,
    this.all,
    this.appearance,
    this.aspectRatio,
    // Flexbox Styles
    this.flexDirection,
    this.flexWrap,
    this.justifyContent,
    this.alignItems,
    this.alignContent,
    // Grid Styles
    this.gridTemplate,
    this.autoRows,
    this.autoColumns,
    this.gap,
    this.justifyItems,
    // Item Styles
    this.flex,
    this.order,
    this.alignSelf,
    this.justifySelf,
    this.gridPlacement,
    // List Styles
    this.listStyle,
    this.listImage,
    this.listPosition,
    // Text Styles
    this.color,
    this.textAlign,
    this.fontFamily,
    this.fontSize,
    this.fontWeight,
    this.fontStyle,
    this.textDecoration,
    this.textTransform,
    this.textIndent,
    this.letterSpacing,
    this.wordSpacing,
    this.lineHeight,
    this.textShadow,
    this.textOverflow,
    this.whiteSpace,
    // Background Styles
    this.backgroundColor,
    this.backgroundImage,
    this.backgroundOrigin,
    this.backgroundPosition,
    this.backgroundAttachment,
    this.backgroundRepeat,
    this.backgroundSize,
    this.backgroundClip,
    // Raw Styles
    Map<String, String>? raw,
  })  : _raw = raw,
        super._();

  @override
  Map<String, String> get properties => {
        // Box Styles
        ...?padding?.styles._prefixed('padding'),
        ...?margin?.styles._prefixed('margin'),
        if (display != null) 'display': display!.value,
        if (boxSizing != null) 'box-sizing': boxSizing!.value,
        if (width != null) 'width': width!.value,
        if (height != null) 'height': height!.value,
        if (minWidth != null) 'min-width': minWidth!.value,
        if (maxWidth != null) 'max-width': maxWidth!.value,
        if (minHeight != null) 'min-height': minHeight!.value,
        if (maxHeight != null) 'max-height': maxHeight!.value,
        ...?border?.styles,
        if (opacity != null) 'opacity': opacity!.toString(),
        ...?outline?.styles,
        ...?radius?.styles,
        ...?overflow?.styles,
        ...?position?.styles,
        if (zIndex != null) 'z-index': zIndex!.value,
        if (visibility != null) 'visibility': visibility!.value,
        if (transform != null) 'transform': transform!.value,
        if (shadow != null) 'box-shadow': shadow!.value,
        if (filter != null) 'filter': filter!.value,
        if (backdropFilter != null) 'backdrop-filter': backdropFilter!.value,
        if (cursor != null) 'cursor': cursor!.value,
        if (transition != null) 'transition': transition!.value,
        if (userSelect != null) ...{
          'user-select': userSelect!.value,
          '-webkit-user-select': userSelect!.value,
        },
        if (pointerEvents != null) 'pointer-events': pointerEvents!.value,
        if (all != null) 'all': all!.value,
        if (appearance != null) 'appearance': appearance!.value,
        if (aspectRatio != null) 'aspect-ratio': aspectRatio!.value,
        // Text Styles
        if (color != null) 'color': color!.value,
        if (fontFamily != null) 'font-family': fontFamily!.value,
        if (fontStyle != null) 'font-style': fontStyle!.value,
        if (fontSize != null) 'font-size': fontSize!.value,
        if (fontWeight != null) 'font-weight': fontWeight!.value,
        if (textAlign != null) 'text-align': textAlign!.value,
        if (textDecoration != null) 'text-decoration': textDecoration!.value,
        if (textTransform != null) 'text-transform': textTransform!.value,
        if (textIndent != null) 'text-indent': textIndent!.value,
        if (letterSpacing != null) 'letter-spacing': letterSpacing!.value,
        if (wordSpacing != null) 'word-spacing': wordSpacing!.value,
        if (lineHeight != null) 'line-height': lineHeight!.value,
        if (textShadow != null) 'text-shadow': textShadow!.value,
        if (textOverflow != null) 'text-overflow': textOverflow!.value,
        if (whiteSpace != null) 'white-space': whiteSpace!.value,
        // Background Styles
        if (backgroundColor != null) 'background-color': backgroundColor!.value,
        if (backgroundAttachment != null) 'background-attachment': backgroundAttachment!.value,
        if (backgroundClip != null) 'background-clip': backgroundClip!.value,
        if (backgroundImage != null) 'background-image': backgroundImage!.value,
        if (backgroundOrigin != null) 'background-origin': backgroundOrigin!.value,
        if (backgroundPosition != null) 'background-position': backgroundPosition!.value,
        if (backgroundRepeat != null) 'background-repeat': backgroundRepeat!.value,
        if (backgroundSize != null) 'background-size': backgroundSize!.value,
        // Flexbox Styles
        if (flexDirection != null) 'flex-direction': flexDirection!.value,
        if (flexWrap != null) 'flex-wrap': flexWrap!.value,
        if (justifyContent != null) 'justify-content': justifyContent!.value,
        if (alignItems != null) 'align-items': alignItems!.value,
        ...?gap?.styles,
        ...?flex?.styles,
        if (alignContent != null) 'align-content': alignContent!.value,
        if (order != null) 'order': order!.toString(),
        if (alignSelf != null) 'align-self': alignSelf!.value,
        // Grid Styles
        ...?gridTemplate?.styles,
        if (autoRows != null) 'grid-auto-rows': autoRows!.map((s) => s.value).join(' '),
        if (autoColumns != null) 'grid-auto-columns': autoColumns!.map((s) => s.value).join(' '),
        ...?gridPlacement?.styles,
        if (justifyItems != null) 'justify-items': justifyItems!.value,
        // Grid Item Styles
        if (justifySelf != null) 'justify-self': justifySelf!.value,
        // List Styles
        if (listStyle != null) 'list-style-type': listStyle!.value,
        if (listPosition != null) 'list-style-position': listPosition!.value,
        if (listImage != null) 'list-style-image': listImage!.value,
        // Other Styles
        if (content != null) 'content': '"$content"',
        // Raw Styles
        ...?_raw,
      };
}

extension on Map<String, String> {
  Map<String, String> _prefixed(String prefix) {
    return map((k, v) => MapEntry(prefix + (k.isNotEmpty ? '-$k' : ''), v));
  }
}
