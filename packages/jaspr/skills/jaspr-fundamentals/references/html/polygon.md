# polygon

Signature of the polygon component:

```dart
const polygon(List<Component> children, {
  /// This attribute defines the list of points (pairs of x,y absolute coordinates) required to draw the polygon.
  String? points,
  /// The color (or gradient or pattern) used to paint the shape.
  Color? fill,
  /// The color (or gradient or pattern) used to paint the outline of the shape.
  Color? stroke,
  /// The width of the stroke to be applied to the shape.
  String? strokeWidth,
  String? id,
  String? classes,
  Styles? styles,
  Map<String, String>? attributes,
  Map<String, EventCallback>? events,
  Key? key,
})
```

Example usage:

```dart
polygon(points: '...', [
  // ...
])
```