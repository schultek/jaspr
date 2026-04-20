# option

Signature of the option component:

```dart
const option(List<Component> children, {
  String? label,
  String? value,
  bool selected = false,
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
option(label: '...', [
  // ...
])
```