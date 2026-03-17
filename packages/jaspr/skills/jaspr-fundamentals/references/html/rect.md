# rect

Signature of the rect component:

```dart
const rect(List<Component> children, {
  /// The x coordinate of the rect.
  String? x,
  /// The y coordinate of the rect.
  String? y,
  /// The horizontal corner radius of the rect.
  String? rx,
  /// The vertical corner radius of the rect.
  String? ry,
  /// The width of the rect.
  String? width,
  /// The height of the rect.
  String? height,
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
rect(x: '...', [
  // ...
])
```