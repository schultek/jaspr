# line

Signature of the line component:

```dart
const line(List<Component> children, {
  /// Defines the x-axis coordinate of the line starting point.
  String? x1,
  /// Defines the y-axis coordinate of the line starting point.
  String? y1,
  /// Defines the x-axis coordinate of the line ending point.
  String? x2,
  /// Defines the y-axis coordinate of the line ending point.
  String? y2,
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
line(x1: '...', [
  // ...
])
```