# dialog

Signature of the dialog component:

```dart
const dialog(List<Component> children, {
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
dialog(open: true, [
  // ...
])
```