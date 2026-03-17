# circle

Signature of the circle component:

```dart
const circle(List<Component> children, {
  /// The x-axis coordinate of the center of the circle.
  String? cx,
  /// The y-axis coordinate of the center of the circle.
  String? cy,
  /// The radius of the circle.
  String? r,
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
circle(cx: '...', [
  // ...
])
```