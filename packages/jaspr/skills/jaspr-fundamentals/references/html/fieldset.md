# fieldset

Signature of the fieldset component:

```dart
const fieldset(List<Component> children, {
  String? name,
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
fieldset(name: '...', [
  // ...
])
```