# ellipse

Signature of the ellipse component:

```dart
const ellipse(List<Component> children, {
  /// The x-axis coordinate of the center of the ellipse.
  String? cx,
  /// The y-axis coordinate of the center of the ellipse.
  String? cy,
  /// The radius of the ellipse on the x axis.
  String? rx,
  /// The radius of the ellipse on the y axis.
  String? ry,
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
ellipse(cx: '...', [
  // ...
])
```