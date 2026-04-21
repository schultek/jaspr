# progress

Signature of the progress component:

```dart
const progress(List<Component> children, {
  double? value,
  double? max,
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
progress(value: 1.0, [
  // ...
])
```