part of '../styles.dart';

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
  final Cursor? cursor;
  final UserSelect? userSelect;
  final PointerEvents? pointerEvents;
  final Transition? transition;
  final Transform? transform;
  // Flexbox Style
  final FlexDirection? flexDirection;
  final FlexWrap? flexWrap;
  final JustifyContent? justifyContent;
  final AlignItems? alignItems;
  // Grid Style
  final GridTemplate? gridTemplate;
  final List<TrackSize>? autoRows;
  final List<TrackSize>? autoColumns;
  final Gap? gap;
  // Item Style
  final Flex? flex;
  final int? order;
  final AlignSelf? alignSelf;
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
    this.cursor,
    this.userSelect,
    this.pointerEvents,
    this.transition,
    this.transform,
    // Flexbox Styles
    this.flexDirection,
    this.flexWrap,
    this.justifyContent,
    this.alignItems,
    // Grid Styles
    this.gridTemplate,
    this.autoRows,
    this.autoColumns,
    this.gap,
    // Item Styles
    this.flex,
    this.order,
    this.alignSelf,
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
        if (cursor != null) 'cursor': cursor!.value,
        if (transition != null) 'transition': transition!.value,
        if (userSelect != null) ...{
          'user-select': userSelect!.value,
          '-webkit-user-select': userSelect!.value,
        },
        if (pointerEvents != null) 'pointer-events': pointerEvents!.value,
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
        if (order != null) 'order': order!.toString(),
        if (alignSelf != null) 'align-self': alignSelf!.value,
        // Grid Styles
        ...?gridTemplate?.styles,
        if (autoRows != null) 'grid-auto-rows': autoRows!.map((s) => s.value).join(' '),
        if (autoColumns != null) 'grid-auto-columns': autoColumns!.map((s) => s.value).join(' '),
        ...?gridPlacement?.styles,
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
