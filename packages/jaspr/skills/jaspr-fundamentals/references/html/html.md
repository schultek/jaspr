# html

Signature of the html component:

```dart
const html(List<Component> children, {
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
html(classes: '...', [
  // ...
])
```