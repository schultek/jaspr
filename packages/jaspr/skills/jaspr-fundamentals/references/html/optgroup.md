# optgroup

Signature of the optgroup component:

```dart
const optgroup(List<Component> children, {
  required String label,
  bool disabled = false,
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
optgroup(label: '...', [
  // ...
])
```