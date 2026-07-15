# button

Signature of the button component:

```dart
const button(List<Component> children, {
  bool autofocus = false,
  bool disabled = false,
  ButtonType? type, // One of `.submit`, `.reset`, `.button`
  VoidCallback? onClick,
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
button(autofocus: true, [
  // ...
])
```