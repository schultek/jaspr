# optgroup

Signature of the optgroup component:

```dart
const optgroup(List<Component> children, {
  /// The name of the group of options, which the browser can use when labeling the options in the user interface.
  required String label,
  /// If this attribute is set, none of the items in this option group is selectable. Often browsers grey out such control and it won't receive any browsing events, like mouse clicks or focus-related ones.
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