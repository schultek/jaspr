# dialog

Signature of the dialog component:

```dart
const dialog(List<Component> children, {
  /// Indicates that the dialog is active and can be interacted with. When the open attribute is not set, the dialog shouldn't be shown to the user.
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