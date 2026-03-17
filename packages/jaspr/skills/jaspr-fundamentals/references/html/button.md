# button

Signature of the button component:

```dart
const button(List<Component> children, {
  /// Specifies that the button should have input focus when the page loads. Only one element in a document can have this attribute.
  bool autofocus = false,
  /// Prevents the user from interacting with the button: it cannot be pressed or focused.
  bool disabled = false,
  /// The default behavior of the button.
  ButtonType? type, // One of `.submit`, `.reset`, `.button`
  /// Callback for the 'click' event.
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