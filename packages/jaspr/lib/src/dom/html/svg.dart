// GENERATED FILE - DO NOT EDIT
// Generated from packages/jaspr/tool/generate_html.dart
//
// dart format off
// ignore_for_file: camel_case_types

part of 'html.dart';

/// {@template jaspr.html.svg}
/// The &lt;svg&gt; element is a container that defines a new coordinate system and viewport. It is used as the outermost element of SVG documents, but it can also be used to embed an SVG fragment inside an SVG or HTML document.
/// {@endtemplate}
final class svg extends StatelessComponent {
  /// {@macro jaspr.html.svg}
  const svg(
    this.children, {
    this.viewBox,
    this.width,
    this.height,
    this.id,
    this.classes,
    this.styles,
    this.attributes,
    this.events,
    super.key,
  });

  /// The SVG viewport coordinates for the current SVG fragment.
  final String? viewBox;

  /// The displayed width of the rectangular viewport. (Not the width of its coordinate system.)
  final Unit? width;

  /// The displayed height of the rectangular viewport. (Not the height of its coordinate system.)
  final Unit? height;

  /// The id of the HTML element. Must be unique within the document.
  final String? id;

  /// The CSS classes to apply to the HTML element, separated by whitespace.
  final String? classes;

  /// The inline styles to apply to the HTML element.
  final Styles? styles;

  /// Additional attributes to apply to the HTML element.
  final Map<String, String>? attributes;

  /// Event listeners to attach to the HTML element.
  final Map<String, EventCallback>? events;

  /// The children of this component.
  final List<Component> children;

  @override
  Component build(BuildContext context) {
    return Component.element(
      tag: 'svg',
      id: id,
      classes: classes,
      styles: styles,
      attributes: {
        ...?attributes,
        'viewBox': ?viewBox,
        'width': ?width?.value,
        'height': ?height?.value,
      },
      events: events,
      children: children,
    );
  }
}

/// {@template jaspr.html.rect}
/// The &lt;rect&gt; element is a basic SVG shape that draws rectangles, defined by their position, width, and height. The rectangles may have their corners rounded.
/// {@endtemplate}
final class rect extends StatelessComponent {
  /// {@macro jaspr.html.rect}
  const rect(
    this.children, {
    this.x,
    this.y,
    this.rx,
    this.ry,
    this.width,
    this.height,
    this.fill,
    this.stroke,
    this.strokeWidth,
    this.id,
    this.classes,
    this.styles,
    this.attributes,
    this.events,
    super.key,
  });

  /// The x coordinate of the rect.
  final String? x;

  /// The y coordinate of the rect.
  final String? y;

  /// The horizontal corner radius of the rect.
  final String? rx;

  /// The vertical corner radius of the rect.
  final String? ry;

  /// The width of the rect.
  final String? width;

  /// The height of the rect.
  final String? height;

  /// The color (or gradient or pattern) used to paint the shape.
  final Color? fill;

  /// The color (or gradient or pattern) used to paint the outline of the shape.
  final Color? stroke;

  /// The width of the stroke to be applied to the shape.
  final String? strokeWidth;

  /// The id of the HTML element. Must be unique within the document.
  final String? id;

  /// The CSS classes to apply to the HTML element, separated by whitespace.
  final String? classes;

  /// The inline styles to apply to the HTML element.
  final Styles? styles;

  /// Additional attributes to apply to the HTML element.
  final Map<String, String>? attributes;

  /// Event listeners to attach to the HTML element.
  final Map<String, EventCallback>? events;

  /// The children of this component.
  final List<Component> children;

  @override
  Component build(BuildContext context) {
    return Component.element(
      tag: 'rect',
      id: id,
      classes: classes,
      styles: styles,
      attributes: {
        ...?attributes,
        'x': ?x,
        'y': ?y,
        'rx': ?rx,
        'ry': ?ry,
        'width': ?width,
        'height': ?height,
        'fill': ?fill?.value,
        'stroke': ?stroke?.value,
        'stroke-width': ?strokeWidth,
      },
      events: events,
      children: children,
    );
  }
}

/// {@template jaspr.html.circle}
/// The &lt;circle&gt; SVG element is an SVG basic shape, used to draw circles based on a center point and a radius.
/// {@endtemplate}
final class circle extends StatelessComponent {
  /// {@macro jaspr.html.circle}
  const circle(
    this.children, {
    this.cx,
    this.cy,
    this.r,
    this.fill,
    this.stroke,
    this.strokeWidth,
    this.id,
    this.classes,
    this.styles,
    this.attributes,
    this.events,
    super.key,
  });

  /// The x-axis coordinate of the center of the circle.
  final String? cx;

  /// The y-axis coordinate of the center of the circle.
  final String? cy;

  /// The radius of the circle.
  final String? r;

  /// The color (or gradient or pattern) used to paint the shape.
  final Color? fill;

  /// The color (or gradient or pattern) used to paint the outline of the shape.
  final Color? stroke;

  /// The width of the stroke to be applied to the shape.
  final String? strokeWidth;

  /// The id of the HTML element. Must be unique within the document.
  final String? id;

  /// The CSS classes to apply to the HTML element, separated by whitespace.
  final String? classes;

  /// The inline styles to apply to the HTML element.
  final Styles? styles;

  /// Additional attributes to apply to the HTML element.
  final Map<String, String>? attributes;

  /// Event listeners to attach to the HTML element.
  final Map<String, EventCallback>? events;

  /// The children of this component.
  final List<Component> children;

  @override
  Component build(BuildContext context) {
    return Component.element(
      tag: 'circle',
      id: id,
      classes: classes,
      styles: styles,
      attributes: {
        ...?attributes,
        'cx': ?cx,
        'cy': ?cy,
        'r': ?r,
        'fill': ?fill?.value,
        'stroke': ?stroke?.value,
        'stroke-width': ?strokeWidth,
      },
      events: events,
      children: children,
    );
  }
}

/// {@template jaspr.html.ellipse}
/// The &lt;ellipse&gt; element is an SVG basic shape, used to create ellipses based on a center coordinate, and both their x and y radius.
/// {@endtemplate}
final class ellipse extends StatelessComponent {
  /// {@macro jaspr.html.ellipse}
  const ellipse(
    this.children, {
    this.cx,
    this.cy,
    this.rx,
    this.ry,
    this.fill,
    this.stroke,
    this.strokeWidth,
    this.id,
    this.classes,
    this.styles,
    this.attributes,
    this.events,
    super.key,
  });

  /// The x-axis coordinate of the center of the ellipse.
  final String? cx;

  /// The y-axis coordinate of the center of the ellipse.
  final String? cy;

  /// The radius of the ellipse on the x axis.
  final String? rx;

  /// The radius of the ellipse on the y axis.
  final String? ry;

  /// The color (or gradient or pattern) used to paint the shape.
  final Color? fill;

  /// The color (or gradient or pattern) used to paint the outline of the shape.
  final Color? stroke;

  /// The width of the stroke to be applied to the shape.
  final String? strokeWidth;

  /// The id of the HTML element. Must be unique within the document.
  final String? id;

  /// The CSS classes to apply to the HTML element, separated by whitespace.
  final String? classes;

  /// The inline styles to apply to the HTML element.
  final Styles? styles;

  /// Additional attributes to apply to the HTML element.
  final Map<String, String>? attributes;

  /// Event listeners to attach to the HTML element.
  final Map<String, EventCallback>? events;

  /// The children of this component.
  final List<Component> children;

  @override
  Component build(BuildContext context) {
    return Component.element(
      tag: 'ellipse',
      id: id,
      classes: classes,
      styles: styles,
      attributes: {
        ...?attributes,
        'cx': ?cx,
        'cy': ?cy,
        'rx': ?rx,
        'ry': ?ry,
        'fill': ?fill?.value,
        'stroke': ?stroke?.value,
        'stroke-width': ?strokeWidth,
      },
      events: events,
      children: children,
    );
  }
}

/// {@template jaspr.html.line}
/// The &lt;line&gt; element is an SVG basic shape used to create a line connecting two points.
/// {@endtemplate}
final class line extends StatelessComponent {
  /// {@macro jaspr.html.line}
  const line(
    this.children, {
    this.x1,
    this.y1,
    this.x2,
    this.y2,
    this.fill,
    this.stroke,
    this.strokeWidth,
    this.id,
    this.classes,
    this.styles,
    this.attributes,
    this.events,
    super.key,
  });

  /// Defines the x-axis coordinate of the line starting point.
  final String? x1;

  /// Defines the y-axis coordinate of the line starting point.
  final String? y1;

  /// Defines the x-axis coordinate of the line ending point.
  final String? x2;

  /// Defines the y-axis coordinate of the line ending point.
  final String? y2;

  /// The color (or gradient or pattern) used to paint the shape.
  final Color? fill;

  /// The color (or gradient or pattern) used to paint the outline of the shape.
  final Color? stroke;

  /// The width of the stroke to be applied to the shape.
  final String? strokeWidth;

  /// The id of the HTML element. Must be unique within the document.
  final String? id;

  /// The CSS classes to apply to the HTML element, separated by whitespace.
  final String? classes;

  /// The inline styles to apply to the HTML element.
  final Styles? styles;

  /// Additional attributes to apply to the HTML element.
  final Map<String, String>? attributes;

  /// Event listeners to attach to the HTML element.
  final Map<String, EventCallback>? events;

  /// The children of this component.
  final List<Component> children;

  @override
  Component build(BuildContext context) {
    return Component.element(
      tag: 'line',
      id: id,
      classes: classes,
      styles: styles,
      attributes: {
        ...?attributes,
        'x1': ?x1,
        'y1': ?y1,
        'x2': ?x2,
        'y2': ?y2,
        'fill': ?fill?.value,
        'stroke': ?stroke?.value,
        'stroke-width': ?strokeWidth,
      },
      events: events,
      children: children,
    );
  }
}

/// {@template jaspr.html.path}
/// The &lt;path&gt; SVG element is the generic element to define a shape. All the basic shapes can be created with a path element.
/// {@endtemplate}
final class path extends StatelessComponent {
  /// {@macro jaspr.html.path}
  const path(
    this.children, {
    this.d,
    this.fill,
    this.stroke,
    this.strokeWidth,
    this.id,
    this.classes,
    this.styles,
    this.attributes,
    this.events,
    super.key,
  });

  /// This attribute defines the shape of the path.
  final String? d;

  /// The color (or gradient or pattern) used to paint the shape.
  final Color? fill;

  /// The color (or gradient or pattern) used to paint the outline of the shape.
  final Color? stroke;

  /// The width of the stroke to be applied to the shape.
  final String? strokeWidth;

  /// The id of the HTML element. Must be unique within the document.
  final String? id;

  /// The CSS classes to apply to the HTML element, separated by whitespace.
  final String? classes;

  /// The inline styles to apply to the HTML element.
  final Styles? styles;

  /// Additional attributes to apply to the HTML element.
  final Map<String, String>? attributes;

  /// Event listeners to attach to the HTML element.
  final Map<String, EventCallback>? events;

  /// The children of this component.
  final List<Component> children;

  @override
  Component build(BuildContext context) {
    return Component.element(
      tag: 'path',
      id: id,
      classes: classes,
      styles: styles,
      attributes: {
        ...?attributes,
        'd': ?d,
        'fill': ?fill?.value,
        'stroke': ?stroke?.value,
        'stroke-width': ?strokeWidth,
      },
      events: events,
      children: children,
    );
  }
}

/// {@template jaspr.html.polygon}
/// The &lt;polygon&gt; element defines a closed shape consisting of a set of connected straight line segments. The last point is connected to the first point.
/// {@endtemplate}
final class polygon extends StatelessComponent {
  /// {@macro jaspr.html.polygon}
  const polygon(
    this.children, {
    this.points,
    this.fill,
    this.stroke,
    this.strokeWidth,
    this.id,
    this.classes,
    this.styles,
    this.attributes,
    this.events,
    super.key,
  });

  /// This attribute defines the list of points (pairs of x,y absolute coordinates) required to draw the polygon.
  final String? points;

  /// The color (or gradient or pattern) used to paint the shape.
  final Color? fill;

  /// The color (or gradient or pattern) used to paint the outline of the shape.
  final Color? stroke;

  /// The width of the stroke to be applied to the shape.
  final String? strokeWidth;

  /// The id of the HTML element. Must be unique within the document.
  final String? id;

  /// The CSS classes to apply to the HTML element, separated by whitespace.
  final String? classes;

  /// The inline styles to apply to the HTML element.
  final Styles? styles;

  /// Additional attributes to apply to the HTML element.
  final Map<String, String>? attributes;

  /// Event listeners to attach to the HTML element.
  final Map<String, EventCallback>? events;

  /// The children of this component.
  final List<Component> children;

  @override
  Component build(BuildContext context) {
    return Component.element(
      tag: 'polygon',
      id: id,
      classes: classes,
      styles: styles,
      attributes: {
        ...?attributes,
        'points': ?points,
        'fill': ?fill?.value,
        'stroke': ?stroke?.value,
        'stroke-width': ?strokeWidth,
      },
      events: events,
      children: children,
    );
  }
}

/// {@template jaspr.html.polyline}
/// The &lt;polyline&gt; SVG element is an SVG basic shape that creates straight lines connecting several points. Typically a polyline is used to create open shapes as the last point doesn't have to be connected to the first point.
/// {@endtemplate}
final class polyline extends StatelessComponent {
  /// {@macro jaspr.html.polyline}
  const polyline(
    this.children, {
    this.points,
    this.fill,
    this.stroke,
    this.strokeWidth,
    this.id,
    this.classes,
    this.styles,
    this.attributes,
    this.events,
    super.key,
  });

  /// This attribute defines the list of points (pairs of x,y absolute coordinates) required to draw the polyline.
  final String? points;

  /// The color (or gradient or pattern) used to paint the shape.
  final Color? fill;

  /// The color (or gradient or pattern) used to paint the outline of the shape.
  final Color? stroke;

  /// The width of the stroke to be applied to the shape.
  final String? strokeWidth;

  /// The id of the HTML element. Must be unique within the document.
  final String? id;

  /// The CSS classes to apply to the HTML element, separated by whitespace.
  final String? classes;

  /// The inline styles to apply to the HTML element.
  final Styles? styles;

  /// Additional attributes to apply to the HTML element.
  final Map<String, String>? attributes;

  /// Event listeners to attach to the HTML element.
  final Map<String, EventCallback>? events;

  /// The children of this component.
  final List<Component> children;

  @override
  Component build(BuildContext context) {
    return Component.element(
      tag: 'polyline',
      id: id,
      classes: classes,
      styles: styles,
      attributes: {
        ...?attributes,
        'points': ?points,
        'fill': ?fill?.value,
        'stroke': ?stroke?.value,
        'stroke-width': ?strokeWidth,
      },
      events: events,
      children: children,
    );
  }
}
