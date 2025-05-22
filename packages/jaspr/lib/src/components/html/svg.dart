part of 'html.dart';

/// The &lt;svg&gt; element is a container that defines a new coordinate system and viewport. It is used as the outermost element of SVG documents, but it can also be used to embed an SVG fragment inside an SVG or HTML document.
///
/// - [viewBox]: The SVG viewport coordinates for the current SVG fragment.
/// - [width]: The displayed width of the rectangular viewport. (Not the width of its coordinate system.)
/// - [height]: The displayed height of the rectangular viewport. (Not the height of its coordinate system.)
Component svg(List<Component> children,
    {String? viewBox,
    Unit? width,
    Unit? height,
    Key? key,
    String? id,
    String? classes,
    Styles? styles,
    Map<String, String>? attributes,
    Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'svg',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: {
      ...attributes ?? {},
      if (viewBox != null) 'viewBox': viewBox,
      if (width != null) 'width': width.value,
      if (height != null) 'height': height.value,
    },
    events: events,
    children: children,
  );
}

/// The &lt;rect&gt; element is a basic SVG shape that draws rectangles, defined by their position, width, and height. The rectangles may have their corners rounded.
///
/// - [x]: The x coordinate of the rect.
/// - [y]: The y coordinate of the rect.
/// - [rx]: The rx coordinate of the rect.
/// - [ry]: The ry coordinate of the rect.
/// - [width]: The width of the rect.
/// - [height]: The height of the rect.
/// - [fill]: The color (or gradient or pattern) used to paint the shape.
/// - [stroke]: The color (or gradient or pattern) used to paint the outline of the shape.
/// - [strokeWidth]: The width of the stroke to be applied to the shape.
Component rect(List<Component> children,
    {String? x,
    String? y,
    String? rx,
    String? ry,
    String? width,
    String? height,
    Color? fill,
    Color? stroke,
    String? strokeWidth,
    Key? key,
    String? id,
    String? classes,
    Styles? styles,
    Map<String, String>? attributes,
    Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'rect',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: {
      ...attributes ?? {},
      if (x != null) 'x': x,
      if (y != null) 'y': y,
      if (rx != null) 'rx': rx,
      if (ry != null) 'ry': ry,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (fill != null) 'fill': fill.value,
      if (stroke != null) 'stroke': stroke.value,
      if (strokeWidth != null) 'stroke-width': strokeWidth,
    },
    events: events,
    children: children,
  );
}

/// The &lt;circle&gt; SVG element is an SVG basic shape, used to draw circles based on a center point and a radius.
///
/// - [cx]: The x-axis coordinate of the center of the circle.
/// - [cy]: The y-axis coordinate of the center of the circle.
/// - [r]: The radius of the circle.
/// - [fill]: The color (or gradient or pattern) used to paint the shape.
/// - [stroke]: The color (or gradient or pattern) used to paint the outline of the shape.
/// - [strokeWidth]: The width of the stroke to be applied to the shape.
Component circle(List<Component> children,
    {String? cx,
    String? cy,
    String? r,
    Color? fill,
    Color? stroke,
    String? strokeWidth,
    Key? key,
    String? id,
    String? classes,
    Styles? styles,
    Map<String, String>? attributes,
    Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'circle',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: {
      ...attributes ?? {},
      if (cx != null) 'cx': cx,
      if (cy != null) 'cy': cy,
      if (r != null) 'r': r,
      if (fill != null) 'fill': fill.value,
      if (stroke != null) 'stroke': stroke.value,
      if (strokeWidth != null) 'stroke-width': strokeWidth,
    },
    events: events,
    children: children,
  );
}

/// The &lt;ellipse&gt; element is an SVG basic shape, used to create ellipses based on a center coordinate, and both their x and y radius.
///
/// - [cx]: The x-axis coordinate of the center of the ellipse.
/// - [cy]: The y-axis coordinate of the center of the ellipse.
/// - [rx]: The radius of the ellipse on the x axis.
/// - [ry]: The radius of the ellipse on the y axis.
/// - [fill]: The color (or gradient or pattern) used to paint the shape.
/// - [stroke]: The color (or gradient or pattern) used to paint the outline of the shape.
/// - [strokeWidth]: The width of the stroke to be applied to the shape.
Component ellipse(List<Component> children,
    {String? cx,
    String? cy,
    String? rx,
    String? ry,
    Color? fill,
    Color? stroke,
    String? strokeWidth,
    Key? key,
    String? id,
    String? classes,
    Styles? styles,
    Map<String, String>? attributes,
    Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'ellipse',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: {
      ...attributes ?? {},
      if (cx != null) 'cx': cx,
      if (cy != null) 'cy': cy,
      if (rx != null) 'rx': rx,
      if (ry != null) 'ry': ry,
      if (fill != null) 'fill': fill.value,
      if (stroke != null) 'stroke': stroke.value,
      if (strokeWidth != null) 'stroke-width': strokeWidth,
    },
    events: events,
    children: children,
  );
}

/// The &lt;line&gt; element is an SVG basic shape used to create a line connecting two points.
///
/// - [x1]: Defines the x-axis coordinate of the line starting point.
/// - [y1]: Defines the y-axis coordinate of the line starting point.
/// - [x2]: Defines the x-axis coordinate of the line ending point.
/// - [y2]: Defines the y-axis coordinate of the line ending point.
/// - [fill]: The color (or gradient or pattern) used to paint the shape.
/// - [stroke]: The color (or gradient or pattern) used to paint the outline of the shape.
/// - [strokeWidth]: The width of the stroke to be applied to the shape.
Component line(List<Component> children,
    {String? x1,
    String? y1,
    String? x2,
    String? y2,
    Color? fill,
    Color? stroke,
    String? strokeWidth,
    Key? key,
    String? id,
    String? classes,
    Styles? styles,
    Map<String, String>? attributes,
    Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'line',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: {
      ...attributes ?? {},
      if (x1 != null) 'x1': x1,
      if (y1 != null) 'y1': y1,
      if (x2 != null) 'x2': x2,
      if (y2 != null) 'y2': y2,
      if (fill != null) 'fill': fill.value,
      if (stroke != null) 'stroke': stroke.value,
      if (strokeWidth != null) 'stroke-width': strokeWidth,
    },
    events: events,
    children: children,
  );
}

/// The &lt;path&gt; SVG element is the generic element to define a shape. All the basic shapes can be created with a path element.
///
/// - [d]: This attribute defines the shape of the path.
/// - [fill]: The color (or gradient or pattern) used to paint the shape.
/// - [stroke]: The color (or gradient or pattern) used to paint the outline of the shape.
/// - [strokeWidth]: The width of the stroke to be applied to the shape.
Component path(List<Component> children,
    {String? d,
    Color? fill,
    Color? stroke,
    String? strokeWidth,
    Key? key,
    String? id,
    String? classes,
    Styles? styles,
    Map<String, String>? attributes,
    Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'path',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: {
      ...attributes ?? {},
      if (d != null) 'd': d,
      if (fill != null) 'fill': fill.value,
      if (stroke != null) 'stroke': stroke.value,
      if (strokeWidth != null) 'stroke-width': strokeWidth,
    },
    events: events,
    children: children,
  );
}

/// The &lt;polygon&gt; element defines a closed shape consisting of a set of connected straight line segments. The last point is connected to the first point.
///
/// - [points]: This attribute defines the list of points (pairs of x,y absolute coordinates) required to draw the polygon.
/// - [fill]: The color (or gradient or pattern) used to paint the shape.
/// - [stroke]: The color (or gradient or pattern) used to paint the outline of the shape.
/// - [strokeWidth]: The width of the stroke to be applied to the shape.
Component polygon(List<Component> children,
    {String? points,
    Color? fill,
    Color? stroke,
    String? strokeWidth,
    Key? key,
    String? id,
    String? classes,
    Styles? styles,
    Map<String, String>? attributes,
    Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'polygon',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: {
      ...attributes ?? {},
      if (points != null) 'points': points,
      if (fill != null) 'fill': fill.value,
      if (stroke != null) 'stroke': stroke.value,
      if (strokeWidth != null) 'stroke-width': strokeWidth,
    },
    events: events,
    children: children,
  );
}

/// The &lt;polyline&gt; SVG element is an SVG basic shape that creates straight lines connecting several points. Typically a polyline is used to create open shapes as the last point doesn't have to be connected to the first point.
///
/// - [points]: This attribute defines the list of points (pairs of x,y absolute coordinates) required to draw the polyline.
/// - [fill]: The color (or gradient or pattern) used to paint the shape.
/// - [stroke]: The color (or gradient or pattern) used to paint the outline of the shape.
/// - [strokeWidth]: The width of the stroke to be applied to the shape.
Component polyline(List<Component> children,
    {String? points,
    Color? fill,
    Color? stroke,
    String? strokeWidth,
    Key? key,
    String? id,
    String? classes,
    Styles? styles,
    Map<String, String>? attributes,
    Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'polyline',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: {
      ...attributes ?? {},
      if (points != null) 'points': points,
      if (fill != null) 'fill': fill.value,
      if (stroke != null) 'stroke': stroke.value,
      if (strokeWidth != null) 'stroke-width': strokeWidth,
    },
    events: events,
    children: children,
  );
}
