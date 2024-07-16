part of '../styles.dart';

class _BoxStyles extends Styles {
  const _BoxStyles({
    this.padding,
    this.margin,
    this.display,
    this.boxSizing,
    this.width,
    this.height,
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,
    this.border,
    this.radius,
    this.outline,
    this.overflow,
    this.visibility,
    this.position,
    this.opacity,
    this.transform,
    this.shadow,
    this.cursor,
    this.transition,
  }) : super._();

  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Display? display;
  final BoxSizing? boxSizing;
  final Unit? width;
  final Unit? height;
  final Unit? maxWidth;
  final Unit? maxHeight;
  final Unit? minWidth;
  final Unit? minHeight;
  final Border? border;
  final BorderRadius? radius;
  final Outline? outline;
  final Overflow? overflow;
  final Visibility? visibility;
  final Position? position;
  final double? opacity;
  final Transform? transform;
  final BoxShadow? shadow;
  final Cursor? cursor;
  final Transition? transition;

  @override
  Map<String, String> get styles => {
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
        if (visibility != null) 'visibility': visibility!.value,
        if (transform != null) 'transform': transform!.value,
        if (shadow != null) 'box-shadow': shadow!.value,
        if (cursor != null) 'cursor': cursor!.value,
        if (transition != null) 'transition': transition!.value,
      };
}

extension on Map<String, String> {
  Map<String, String> _prefixed(String prefix) {
    return map((k, v) => MapEntry(prefix + (k.isNotEmpty ? '-$k' : ''), v));
  }
}
