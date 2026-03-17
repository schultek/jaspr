# svg

Signature of the svg component:

```dart
const svg(List<Component> children, {
  String? viewBox,
  Unit? width,
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