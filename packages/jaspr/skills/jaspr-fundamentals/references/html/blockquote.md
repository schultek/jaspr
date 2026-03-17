# blockquote

Signature of the blockquote component:

```dart
const blockquote(List<Component> children, {
  String? cite,
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
blockquote(cite: '...', [
  // ...
])
```