# svg

Signature of the svg component:

```dart
const svg(List<Component> children, {
  /// The SVG viewport coordinates for the current SVG fragment.
  String? viewBox,
  /// The displayed width of the rectangular viewport. (Not the width of its coordinate system.)
  Unit? width,
  /// The displayed height of the rectangular viewport. (Not the height of its coordinate system.)
  Unit? height,
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
svg(viewBox: '...', [
  // ...
])
```