# path

Signature of the path component:

```dart
const path(List<Component> children, {
  String? d,
  Color? fill,
  Color? stroke,
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
path(d: '...', [
  // ...
])
```