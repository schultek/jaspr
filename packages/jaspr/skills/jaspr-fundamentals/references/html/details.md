# details

Signature of the details component:

```dart
const details(List<Component> children, {
  /// Indicates whether or not the details — that is, the contents of the <details> element — are currently visible.
  bool open = false,
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
details(open: true, [
  // ...
])
```