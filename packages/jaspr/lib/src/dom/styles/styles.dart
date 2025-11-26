import 'properties/all.dart';

export 'properties/all.dart' hide NumberString;

/// Represents a set of css styles.
abstract class Styles with StylesMixin<Styles> {
  const Styles._();

  Map<String, String> get properties;

  /// Constructs a [Styles] instance with the given css properties.
  const factory Styles({
    All? all,
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
    AspectRatio? aspectRatio,
    Padding? padding,
    Margin? margin,
    BoxSizing? boxSizing,
    Border? border,
    BorderRadius? radius,
    Outline? outline,
    double? opacity,
    Visibility? visibility,
    Overflow? overflow,
    Appearance? appearance,
    BoxShadow? shadow,
    Filter? filter,
    Filter? backdropFilter,
    Cursor? cursor,
    UserSelect? userSelect,
    PointerEvents? pointerEvents,
    Animation? animation,
    Transition? transition,
    Transform? transform,
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
    JustifyItems? justifyItems,
    Gap? gap,
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
    Quotes? quotes,
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
    All? all,
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
    AspectRatio? aspectRatio,
    Padding? padding,
    Margin? margin,
    BoxSizing? boxSizing,
    Border? border,
    BorderRadius? radius,
    Outline? outline,
    double? opacity,
    Visibility? visibility,
    Overflow? overflow,
    Appearance? appearance,
    BoxShadow? shadow,
    Filter? filter,
    Filter? backdropFilter,
    Cursor? cursor,
    UserSelect? userSelect,
    PointerEvents? pointerEvents,
    Animation? animation,
    Transition? transition,
    Transform? transform,
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
    JustifyItems? justifyItems,
    Gap? gap,
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
    Quotes? quotes,
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
  }) => combine(
    Styles(
      all: all,
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
      aspectRatio: aspectRatio,
      border: border,
      radius: radius,
      outline: outline,
      overflow: overflow,
      appearance: appearance,
      visibility: visibility,
      position: position,
      zIndex: zIndex,
      opacity: opacity,
      transform: transform,
      shadow: shadow,
      filter: filter,
      backdropFilter: backdropFilter,
      cursor: cursor,
      animation: animation,
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
      quotes: quotes,
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
      justifyItems: justifyItems,
      gap: gap,
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
    ),
  );

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
  final All? all;
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
  final AspectRatio? aspectRatio;
  final Padding? padding;
  final Margin? margin;
  final BoxSizing? boxSizing;
  final Border? border;
  final BorderRadius? radius;
  final Outline? outline;
  final double? opacity;
  final Visibility? visibility;
  final Overflow? overflow;
  final Appearance? appearance;
  final BoxShadow? shadow;
  final Filter? filter;
  final Filter? backdropFilter;
  final Cursor? cursor;
  final UserSelect? userSelect;
  final PointerEvents? pointerEvents;
  final Animation? animation;
  final Transition? transition;
  final Transform? transform;
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
  final Quotes? quotes;
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
    this.all,
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
    this.aspectRatio,
    this.padding,
    this.margin,
    this.boxSizing,
    this.border,
    this.radius,
    this.outline,
    this.opacity,
    this.visibility,
    this.overflow,
    this.appearance,
    this.shadow,
    this.filter,
    this.backdropFilter,
    this.cursor,
    this.userSelect,
    this.pointerEvents,
    this.animation,
    this.transition,
    this.transform,
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
    this.justifyItems,
    this.gap,
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
    this.quotes,
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
  }) : _raw = raw,
       super._();

  @override
  Map<String, String> get properties => {
    'all': ?all?.value,
    // Box Styles
    if (content != null) 'content': '"$content"',
    'display': ?display?.value,
    ...?position?.styles,
    'z-index': ?zIndex?.value,
    'width': ?width?.value,
    'height': ?height?.value,
    'min-width': ?minWidth?.value,
    'min-height': ?minHeight?.value,
    'max-width': ?maxWidth?.value,
    'max-height': ?maxHeight?.value,
    'aspect-ratio': ?aspectRatio?.value,
    ...?padding?.styles._prefixed('padding'),
    ...?margin?.styles._prefixed('margin'),
    'box-sizing': ?boxSizing?.value,
    ...?border?.styles,
    ...?radius?.styles,
    ...?outline?.styles,
    'opacity': ?opacity?.toString(),
    'visibility': ?visibility?.value,
    ...?overflow?.styles,
    'appearance': ?appearance?.value,
    'box-shadow': ?shadow?.value,
    'filter': ?filter?.value,
    'backdrop-filter': ?backdropFilter?.value,
    'cursor': ?cursor?.value,
    'user-select': ?userSelect?.value,
    '-webkit-user-select': ?userSelect?.value,
    'pointer-events': ?pointerEvents?.value,
    'animation': ?animation?.value,
    'transition': ?transition?.value,
    'transform': ?transform?.value,
    // Flexbox Styles
    'flex-direction': ?flexDirection?.value,
    'flex-wrap': ?flexWrap?.value,
    'justify-content': ?justifyContent?.value,
    'align-items': ?alignItems?.value,
    'align-content': ?alignContent?.value,
    // Grid Styles
    ...?gridTemplate?.styles,
    'grid-auto-rows': ?autoRows?.map((s) => s.value).join(' '),
    'grid-auto-columns': ?autoColumns?.map((s) => s.value).join(' '),
    'justify-items': ?justifyItems?.value,
    ...?gap?.styles,
    // Grid Item Styles
    ...?flex?.styles,
    'order': ?order?.toString(),
    'align-self': ?alignSelf?.value,
    'justify-self': ?justifySelf?.value,
    ...?gridPlacement?.styles,
    // List Styles
    'list-style-type': ?listStyle?.value,
    'list-style-image': ?listImage?.value,
    'list-style-position': ?listPosition?.value,
    // Text Styles
    'color': ?color?.value,
    'text-align': ?textAlign?.value,
    'font-family': ?fontFamily?.value,
    'font-size': ?fontSize?.value,
    'font-weight': ?fontWeight?.value,
    'font-style': ?fontStyle?.value,
    'text-decoration': ?textDecoration?.value,
    'text-transform': ?textTransform?.value,
    'text-indent': ?textIndent?.value,
    'letter-spacing': ?letterSpacing?.value,
    'word-spacing': ?wordSpacing?.value,
    'line-height': ?lineHeight?.value,
    'text-shadow': ?textShadow?.value,
    'text-overflow': ?textOverflow?.value,
    'white-space': ?whiteSpace?.value,
    'quotes': ?quotes?.value,
    // Background Styles
    'background-color': ?backgroundColor?.value,
    'background-image': ?backgroundImage?.value,
    'background-origin': ?backgroundOrigin?.value,
    'background-position': ?backgroundPosition?.value,
    'background-attachment': ?backgroundAttachment?.value,
    'background-repeat': ?backgroundRepeat?.value,
    'background-size': ?backgroundSize?.value,
    'background-clip': ?backgroundClip?.value,
    // Raw Styles
    ...?_raw,
  };
}

extension on Map<String, String> {
  Map<String, String> _prefixed(String prefix) {
    return map((k, v) => MapEntry(prefix + (k.isNotEmpty ? '-$k' : ''), v));
  }
}
